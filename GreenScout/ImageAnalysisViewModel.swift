//
//  ImageAnalysisViewModel.swift
//  GreenScout
//
//  Image analysis logic for green pixel detection
//

import SwiftUI
import UIKit
import CoreImage
import Accelerate
import Photos
import ImageIO

/// Controls how strict green-pixel detection is.
///
/// "Green" is a judgement call in the field — a dry-stubble paddock and a lush
/// irrigated crop want different answers — so the operator picks the strictness.
/// Each case tunes the HSV band and the margin green must beat red/blue by.
/// See the colour table in the project notes for why the old 60°–180° band
/// counted pure yellow, chlorotic leaves and even cyan sky as "green".
enum GreenSensitivity: String, CaseIterable, Identifiable {
    case strict   = "Strict"
    case balanced = "Balanced"
    case loose    = "Loose"

    var id: String { rawValue }
    var label: String { rawValue }

    /// One-line explanation shown under the picker.
    var blurb: String {
        switch self {
        case .strict:   return "Only vivid, healthy green — excludes anything yellowing."
        case .balanced: return "Recommended. Real green; rejects yellow, straw and sky."
        case .loose:    return "Includes yellow-green and early senescence."
        }
    }

    // Hue is in degrees (0–360); saturation and value are 0–1.
    var hueLow: CGFloat        { self == .strict ? 90  : self == .balanced ? 78  : 62 }
    var hueHigh: CGFloat       { self == .strict ? 158 : self == .balanced ? 160 : 172 }
    var saturationMin: CGFloat { self == .strict ? 0.25 : self == .balanced ? 0.18 : 0.10 }
    var valueMin: CGFloat      { self == .strict ? 0.15 : self == .balanced ? 0.15 : 0.12 }
    /// Minimum amount green must exceed the larger of red/blue (0–1).
    var greenExcessMin: CGFloat { self == .strict ? 0.06 : self == .balanced ? 0.02 : 0.0 }
}

class ImageAnalysisViewModel: ObservableObject {
    @Published var selectedImage: UIImage? {
        didSet {
            // Reset results when new image is selected
            analysisResults = nil
            processedImage = nil
            processedImageTransparent = nil
            displayImage = nil
            imageQualityWarning = nil
            imageMetadata = nil
            currentPhotoAsset = nil
            
            // Check image quality when new image is selected
            if let image = selectedImage {
                checkImageQuality(image)
            }
        }
    }
    @Published var analysisResults: AnalysisResults?
    @Published var isAnalyzing = false
    @Published var processedImage: UIImage?
    @Published var processedImageTransparent: UIImage?
    /// Display-sized copy of the original (keeps the preview and comparison view smooth).
    @Published var displayImage: UIImage?
    @Published var imageQualityWarning: String?
    @Published var imageMetadata: ImageMetadata?

    /// How strict green detection is. Changing it re-runs analysis (see ContentView).
    @Published var sensitivity: GreenSensitivity = .balanced

    // Store the photo asset for metadata extraction
    var currentPhotoAsset: PHAsset?
    // Store image data for metadata extraction
    private var currentImageData: Data?
    
    private let context = CIContext()
    
    // Image quality thresholds
    private let minimumPixels = 1024 * 1024      // 1 megapixel minimum
    private let warningPixels = 2048 * 2048      // 4 megapixels warning threshold
    private let recommendedPixels = 4096 * 4096  // 16 megapixels recommended
    
    func analyzeImage() {
        guard let image = selectedImage, !isAnalyzing else { return }

        isAnalyzing = true
        // Capture on the main thread before crossing to the background queue.
        let sensitivity = self.sensitivity
        let isReanalysis = analysisResults != nil

        // Perform analysis on background queue
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            
            let startTime = Date()

            // Fix orientation first
            let orientedImage = image.fixedOrientation()
            // A display-sized copy for the preview and comparison view — compositing the
            // full-resolution original under gestures is what made the slider lag.
            let displayOriginal = orientedImage.downscaled(maxDimension: 1400)

            // Convert UIImage to CIImage for processing
            guard let ciImage = CIImage(image: orientedImage) else {
                DispatchQueue.main.async {
                    self.isAnalyzing = false
                }
                return
            }
            
            // Get image dimensions
            let extent = ciImage.extent
            let originalPixelCount = Int(extent.width * extent.height)

            // Create bitmap context
            guard let cgImage = self.context.createCGImage(ciImage, from: extent) else {
                DispatchQueue.main.async {
                    self.isAnalyzing = false
                }
                return
            }
            
            // Analyze pixels (downsampled internally for speed — the coverage ratio is unaffected)
            let (greenPixelCount, analyzedPixelCount, processedCGImage, transparentCGImage) = self.analyzePixels(in: cgImage, sensitivity: sensitivity)

            // Coverage percentage from the analysed sample
            let greenPercentage = analyzedPixelCount > 0 ? (Double(greenPixelCount) / Double(analyzedPixelCount)) * 100 : 0

            // Report pixel counts on the real image's scale so the numbers stay meaningful
            let displayGreenPixels = Int((greenPercentage / 100.0) * Double(originalPixelCount))
            
            let processingTime = Date().timeIntervalSince(startTime)
            
            // Create processed UIImage
            let processedUIImage = processedCGImage != nil ? UIImage(cgImage: processedCGImage!) : nil
            let transparentUIImage = transparentCGImage != nil ? UIImage(cgImage: transparentCGImage!) : nil
            
            // Update UI on main thread
            DispatchQueue.main.async {
                self.analysisResults = AnalysisResults(
                    greenPercentage: min(100, greenPercentage),
                    totalPixels: originalPixelCount,
                    greenPixels: displayGreenPixels,
                    processingTime: processingTime,
                    rawPercentage: greenPercentage,
                    sensitivityUsed: 1.0
                )
                self.displayImage = displayOriginal
                self.processedImage = processedUIImage
                self.processedImageTransparent = transparentUIImage

                // Extract and save metadata
                self.extractAndSaveMetadata(greenPercentage: greenPercentage)

                // On quick re-runs (a sensitivity change) hold the "Recalculating…"
                // overlay on screen long enough to be noticed, without slowing analysis.
                let elapsed = Date().timeIntervalSince(startTime)
                let minVisible = 0.5
                if isReanalysis && elapsed < minVisible {
                    DispatchQueue.main.asyncAfter(deadline: .now() + (minVisible - elapsed)) {
                        self.isAnalyzing = false
                    }
                } else {
                    self.isAnalyzing = false
                }
            }
        }
    }
    
    private func analyzePixels(in cgImage: CGImage, sensitivity: GreenSensitivity) -> (greenPixels: Int, totalPixels: Int, processedImage: CGImage?, transparentImage: CGImage?) {
        // Downsample large images before the per-pixel scan. A 24 MP photo and its
        // ~1.3 MP downsample give the same coverage %, but the scan is ~20x faster.
        let maxDimension = 1400
        let sourceMax = Swift.max(cgImage.width, cgImage.height)
        let scale = sourceMax > maxDimension ? CGFloat(maxDimension) / CGFloat(sourceMax) : 1.0
        let width = Swift.max(1, Int((CGFloat(cgImage.width) * scale).rounded()))
        let height = Swift.max(1, Int((CGFloat(cgImage.height) * scale).rounded()))
        let bytesPerPixel = 4
        let bytesPerRow = bytesPerPixel * width
        let bitsPerComponent = 8
        
        // Create a mutable copy of the image for processing
        guard let colorSpace = cgImage.colorSpace ?? CGColorSpace(name: CGColorSpace.sRGB),
              let context = CGContext(data: nil,
                                     width: width,
                                     height: height,
                                     bitsPerComponent: bitsPerComponent,
                                     bytesPerRow: bytesPerRow,
                                     space: colorSpace,
                                     bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue) else {
            return (0, 0, nil, nil)
        }
        
        context.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))
        
        guard let pixelData = context.data else {
            return (0, 0, nil, nil)
        }
        
        let data = pixelData.bindMemory(to: UInt8.self, capacity: width * height * bytesPerPixel)
        
        var greenPixelCount = 0
        let totalPixelCount = width * height
        
        // Process each pixel
        for y in 0..<height {
            for x in 0..<width {
                let pixelIndex = (y * width + x) * bytesPerPixel
                
                let r = CGFloat(data[pixelIndex]) / 255.0
                let g = CGFloat(data[pixelIndex + 1]) / 255.0
                let b = CGFloat(data[pixelIndex + 2]) / 255.0
                
                if isGreenPixel(r: r, g: g, b: b, sensitivity: sensitivity) {
                    greenPixelCount += 1
                    
                    // Keep green pixels as they are (or make them bright green)
                    data[pixelIndex] = 0       // R
                    data[pixelIndex + 1] = 255 // G
                    data[pixelIndex + 2] = 0   // B
                } else {
                    // Make non-green pixels black (segmented view)
                    data[pixelIndex] = 0       // R
                    data[pixelIndex + 1] = 0   // G
                    data[pixelIndex + 2] = 0   // B
                }
            }
        }
        
        // Create processed image with black background
        let processedImage = context.makeImage()
        
        // Create transparent version for comparison view
        guard let transparentContext = CGContext(data: nil,
                                               width: width,
                                               height: height,
                                               bitsPerComponent: bitsPerComponent,
                                               bytesPerRow: bytesPerRow,
                                               space: colorSpace,
                                               bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue) else {
            return (greenPixelCount, totalPixelCount, processedImage, nil)
        }
        
        // Draw original image first
        transparentContext.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))
        
        guard let transparentData = transparentContext.data else {
            return (greenPixelCount, totalPixelCount, processedImage, nil)
        }
        
        let tData = transparentData.bindMemory(to: UInt8.self, capacity: width * height * bytesPerPixel)
        
        // Process pixels for transparent version
        for y in 0..<height {
            for x in 0..<width {
                let pixelIndex = (y * width + x) * bytesPerPixel
                
                let r = CGFloat(tData[pixelIndex]) / 255.0
                let g = CGFloat(tData[pixelIndex + 1]) / 255.0
                let b = CGFloat(tData[pixelIndex + 2]) / 255.0
                
                if isGreenPixel(r: r, g: g, b: b, sensitivity: sensitivity) {
                    // Make green pixels bright green
                    tData[pixelIndex] = 0       // R
                    tData[pixelIndex + 1] = 255 // G
                    tData[pixelIndex + 2] = 0   // B
                    tData[pixelIndex + 3] = 255 // A (fully opaque)
                } else {
                    // Make non-green pixels transparent
                    tData[pixelIndex + 3] = 0   // A (fully transparent)
                }
            }
        }
        
        let transparentImage = transparentContext.makeImage()
        
        return (greenPixelCount, totalPixelCount, processedImage, transparentImage)
    }
    
    private func isGreenPixel(r: CGFloat, g: CGFloat, b: CGFloat, sensitivity: GreenSensitivity) -> Bool {
        // Convert RGB to HSV — hue lets us separate green from yellow, which
        // the old "green just has to beat red and blue" rule could not do.
        let maxC = Swift.max(r, g, b)
        let minC = Swift.min(r, g, b)
        let delta = maxC - minC

        // Hue in degrees (0–360). 60° is pure yellow, ~120° is pure green, 180° is cyan.
        var h: CGFloat = 0
        if delta > 0 {
            if maxC == r {
                h = ((g - b) / delta).truncatingRemainder(dividingBy: 6)
            } else if maxC == g {
                h = (b - r) / delta + 2
            } else {
                h = (r - g) / delta + 4
            }
            h = h * 60
            if h < 0 { h += 360 }
        }

        let s = maxC == 0 ? 0 : delta / maxC   // saturation 0–1
        let v = maxC                            // value 0–1
        let greenExcess = g - Swift.max(r, b)   // how far green leads red/blue

        // A pixel is green only if it sits in the green hue band AND is colourful
        // enough AND green genuinely leads. All four gates must pass — no hue-free
        // escape hatch — so yellow (hue < ~78°) and cyan (hue > ~160°) are excluded.
        return h >= sensitivity.hueLow
            && h <= sensitivity.hueHigh
            && s >= sensitivity.saturationMin
            && v >= sensitivity.valueMin
            && greenExcess >= sensitivity.greenExcessMin
    }
    
    private func checkImageQuality(_ image: UIImage) {
        // For images loaded from RAW/DNG, scale might be 1.0 even for high-res images
        // Calculate actual pixel dimensions
        let actualWidth = Int(image.size.width * image.scale)
        let actualHeight = Int(image.size.height * image.scale)
        let pixelCount = actualWidth * actualHeight
        
        // Debug print to check actual dimensions
        print("Image dimensions: \(actualWidth) x \(actualHeight) = \(pixelCount) pixels")
        print("Image size: \(image.size), scale: \(image.scale)")
        
        if pixelCount < minimumPixels {
            imageQualityWarning = "Image resolution is too low (\(formatResolution(pixelCount))). Please use a higher resolution image (minimum 1024x1024) for accurate analysis."
        } else if pixelCount < warningPixels {
            imageQualityWarning = "Warning: Low image resolution (\(formatResolution(pixelCount))) may reduce accuracy. For best results, use images with at least 2048x2048 resolution."
        } else if pixelCount < recommendedPixels {
            imageQualityWarning = "Good image quality (\(formatResolution(pixelCount))). For optimal results, consider using 4K resolution (4096x4096) or higher."
        } else {
            imageQualityWarning = nil // Excellent quality, no warning needed
        }
    }
    
    private func formatResolution(_ pixelCount: Int) -> String {
        let megapixels = Double(pixelCount) / 1_000_000.0
        if megapixels < 1 {
            let kilopixels = pixelCount / 1000
            return "\(kilopixels)K pixels"
        } else {
            return String(format: "%.1f megapixels", megapixels)
        }
    }
    
    // Extract metadata from image data
    func extractMetadataFromImageData(_ data: Data) {
        currentImageData = data
        
        // Extract metadata immediately if we can
        if let source = CGImageSourceCreateWithData(data as CFData, nil),
           let metadata = CGImageSourceCopyPropertiesAtIndex(source, 0, nil) as? [String: Any] {
            
            // Debug print to see what metadata is available
            print("Available metadata keys:")
            for (key, value) in metadata {
                print("  \(key): \(type(of: value))")
                if let dict = value as? [String: Any] {
                    for (subKey, subValue) in dict {
                        print("    \(subKey): \(subValue)")
                    }
                }
            }
            
            // Store for later use during analysis
            let tempMetadata = ImageMetadata(from: metadata, analysisDate: Date(), greenCoveragePercentage: nil)
            
            // Print extracted values for debugging
            print("\nExtracted metadata:")
            print("  Location: \(tempMetadata.formattedLocation ?? "None")")
            print("  Capture Date: \(tempMetadata.formattedCaptureDate ?? "None")")
            print("  Device: \(tempMetadata.deviceMake ?? "Unknown") \(tempMetadata.deviceModel ?? "")")
            print("  Dimensions: \(tempMetadata.imageWidth ?? 0) x \(tempMetadata.imageHeight ?? 0)")
        }
    }
}

private extension ImageAnalysisViewModel {
    // Extract metadata and save it
    func extractAndSaveMetadata(greenPercentage: Double) {
        // If we have image data, use it for metadata extraction
        if let imageData = currentImageData,
           let source = CGImageSourceCreateWithData(imageData as CFData, nil),
           let metadata = CGImageSourceCopyPropertiesAtIndex(source, 0, nil) as? [String: Any] {
            let imageMetadata = ImageMetadata(from: metadata, analysisDate: Date(), greenCoveragePercentage: greenPercentage)
            self.imageMetadata = imageMetadata
            
            // Save metadata
            MetadataStorage.shared.save(imageMetadata)
        } else if let asset = self.currentPhotoAsset {
            // Fallback to PHAsset if available
            let options = PHContentEditingInputRequestOptions()
            options.isNetworkAccessAllowed = true
            asset.requestContentEditingInput(with: options) { [weak self] (contentEditingInput, info) in
                guard let self = self,
                      let url = contentEditingInput?.fullSizeImageURL else { return }
                
                // Extract metadata
                if let imageSource = CGImageSourceCreateWithURL(url as CFURL, nil),
                   let metadata = CGImageSourceCopyPropertiesAtIndex(imageSource, 0, nil) as? [String: Any] {
                    let imageMetadata = ImageMetadata(from: metadata, analysisDate: Date(), greenCoveragePercentage: greenPercentage)
                    DispatchQueue.main.async {
                        self.imageMetadata = imageMetadata
                    }
                    
                    // Save metadata
                    MetadataStorage.shared.save(imageMetadata)
                }
            }
        } else if let image = self.selectedImage {
            // Fallback: Extract metadata from UIImage if no PHAsset available
            extractMetadataFromUIImage(image, greenPercentage: greenPercentage)
        }
    }
    
    func extractMetadataFromUIImage(_ image: UIImage, greenPercentage: Double) {
        // Try to extract basic metadata from UIImage
        var metadata: [String: Any] = [:]
        
        // Add basic image properties
        metadata["PixelWidth"] = Int(image.size.width * image.scale)
        metadata["PixelHeight"] = Int(image.size.height * image.scale)
        
        // Create metadata with what we have
        let imageMetadata = ImageMetadata(
            from: metadata,
            analysisDate: Date(),
            greenCoveragePercentage: greenPercentage
        )
        
        DispatchQueue.main.async {
            self.imageMetadata = imageMetadata
        }
        
        // Save metadata
        MetadataStorage.shared.save(imageMetadata)
    }
}

// Extension to fix image orientation
extension UIImage {
    /// Returns a copy scaled so its longest side is at most `maxDimension` pixels,
    /// or self if already small enough. Keeps on-screen display and compositing cheap.
    func downscaled(maxDimension: CGFloat) -> UIImage {
        let longest = Swift.max(size.width, size.height)
        guard longest > maxDimension else { return self }
        let scaleFactor = maxDimension / longest
        let newSize = CGSize(width: size.width * scaleFactor, height: size.height * scaleFactor)
        let format = UIGraphicsImageRendererFormat.default()
        format.scale = 1
        let renderer = UIGraphicsImageRenderer(size: newSize, format: format)
        return renderer.image { _ in
            draw(in: CGRect(origin: .zero, size: newSize))
        }
    }

    func fixedOrientation() -> UIImage {
        // If image orientation is already correct, return it
        if imageOrientation == .up {
            return self
        }
        
        // Calculate the proper transformation
        var transform = CGAffineTransform.identity
        
        switch imageOrientation {
        case .down, .downMirrored:
            transform = transform.translatedBy(x: size.width, y: size.height)
            transform = transform.rotated(by: .pi)
        case .left, .leftMirrored:
            transform = transform.translatedBy(x: size.width, y: 0)
            transform = transform.rotated(by: .pi / 2)
        case .right, .rightMirrored:
            transform = transform.translatedBy(x: 0, y: size.height)
            transform = transform.rotated(by: -.pi / 2)
        default:
            break
        }
        
        switch imageOrientation {
        case .upMirrored, .downMirrored:
            transform = transform.translatedBy(x: size.width, y: 0)
            transform = transform.scaledBy(x: -1, y: 1)
        case .leftMirrored, .rightMirrored:
            transform = transform.translatedBy(x: size.height, y: 0)
            transform = transform.scaledBy(x: -1, y: 1)
        default:
            break
        }
        
        // Create a graphics context and draw the image with the correct orientation
        guard let cgImage = cgImage,
              let colorSpace = cgImage.colorSpace,
              let context = CGContext(data: nil,
                                     width: Int(size.width),
                                     height: Int(size.height),
                                     bitsPerComponent: cgImage.bitsPerComponent,
                                     bytesPerRow: 0,
                                     space: colorSpace,
                                     bitmapInfo: cgImage.bitmapInfo.rawValue) else {
            return self
        }
        
        context.concatenate(transform)
        
        switch imageOrientation {
        case .left, .leftMirrored, .right, .rightMirrored:
            context.draw(cgImage, in: CGRect(x: 0, y: 0, width: size.height, height: size.width))
        default:
            context.draw(cgImage, in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        }
        
        guard let newCGImage = context.makeImage() else {
            return self
        }
        
        return UIImage(cgImage: newCGImage)
    }
}

struct AnalysisResults {
    let greenPercentage: Double
    let totalPixels: Int
    let greenPixels: Int
    let processingTime: TimeInterval
    let rawPercentage: Double
    let sensitivityUsed: Double
}
