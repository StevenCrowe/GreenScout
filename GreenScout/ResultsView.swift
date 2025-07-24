//
//  ResultsView.swift
//  GreenScout
//
//  Results display with agricultural insights
//

import SwiftUI
import Photos

struct ResultsView: View {
    let results: AnalysisResults
    let originalImage: UIImage?
    let processedImage: UIImage?
    let processedImageTransparent: UIImage?
    let imageMetadata: ImageMetadata?
    
    @State private var showingSaveAlert = false
    @State private var saveAlertMessage = ""
    @State private var showingShareSheet = false
    @State private var showingImageComparison = false
    @State private var showingMetadata = false
    
    var body: some View {
        VStack(spacing: 20) {
            // Green Coverage Card
            VStack(spacing: 12) {
                HStack {
                    Image(systemName: "leaf.fill")
                        .font(.largeTitle)
                        .foregroundColor(.green)
                    
                    VStack(alignment: .leading) {
                        Text("Green Coverage")
                            .font(.headline)
                        Text(String(format: "%.1f%%", results.greenPercentage))
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.green)
                    }
                    
                    Spacer()
                }
                
                // Progress Bar
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.gray.opacity(0.2))
                            .frame(height: 20)
                        
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.green)
                            .frame(width: geometry.size.width * CGFloat(results.greenPercentage / 100), height: 20)
                            .animation(.easeInOut(duration: 0.5), value: results.greenPercentage)
                    }
                }
                .frame(height: 20)
            }
            .padding()
            .background(Color.green.opacity(0.1))
            .cornerRadius(12)
            
            // Images Section - Original and Segmented
            if let original = originalImage, let processed = processedImage {
                VStack(spacing: 12) {
                    // Original Image
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Original")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Image(uiImage: original)
                            .resizable()
                            .scaledToFit()
                            .frame(maxHeight: 200)
                            .cornerRadius(8)
                            .shadow(radius: 2)
                    }
                    
                    // Segmented Image
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Segmented View")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Image(uiImage: processed)
                            .resizable()
                            .scaledToFit()
                            .frame(maxHeight: 200)
                            .background(Color.black)
                            .cornerRadius(8)
                            .shadow(radius: 2)
                    }
                    
                    // Compare button
                    Button(action: {
                        showingImageComparison = true
                    }) {
                        HStack {
                            Image(systemName: "slider.horizontal.below.rectangle")
                            Text("Compare Images")
                                .fontWeight(.medium)
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.regular)
                    .tint(.green)
                }
            }
            
            // Statistics Grid
            HStack(spacing: 16) {
                StatCard(
                    icon: "square.grid.3x3",
                    title: "Total Pixels",
                    value: formatNumber(results.totalPixels)
                )
                
                StatCard(
                    icon: "checkmark.square.fill",
                    title: "Green Pixels",
                    value: formatNumber(results.greenPixels),
                    color: .green
                )
            }
            
            // Processing Info
            HStack(spacing: 16) {
                StatCard(
                    icon: "timer",
                    title: "Processing Time",
                    value: String(format: "%.2fs", results.processingTime),
                    color: .blue
                )
                
                StatCard(
                    icon: "waveform.path.ecg",
                    title: "Accuracy",
                    value: "High",
                    color: .orange
                )
            }
            
            // Show Metadata Button (for testing)
            Button(action: {
                showingMetadata = true
            }) {
                HStack {
                    Image(systemName: "info.circle")
                    Text("Show Photo Data")
                        .fontWeight(.medium)
                }
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
            .controlSize(.regular)
            .padding(.horizontal)
            
            // Download/Share Buttons
            HStack(spacing: 16) {
                // Save to Photos Button
                Button(action: {
                    saveImageToPhotoLibrary()
                }) {
                    HStack {
                        Image(systemName: "square.and.arrow.down")
                        Text("Save Image")
                            .fontWeight(.semibold)
                    }
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                
                // Share Button
                Button(action: {
                    showingShareSheet = true
                }) {
                    HStack {
                        Image(systemName: "square.and.arrow.up")
                        Text("Share")
                            .fontWeight(.semibold)
                    }
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .controlSize(.large)
            }
            .padding(.horizontal)
        }
        .alert("Save Image", isPresented: $showingSaveAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(saveAlertMessage)
        }
        .sheet(isPresented: $showingShareSheet) {
            ShareSheet(items: getShareItems())
        }
        .fullScreenCover(isPresented: $showingImageComparison) {
            if let original = originalImage, let transparentImage = processedImageTransparent {
                ImageComparisonView(
                    originalImage: original,
                    analyzedImage: transparentImage,
                    isPresented: $showingImageComparison
                )
            } else if let original = originalImage, let processed = processedImage {
                // Fallback to regular processed image if transparent version is not available
                ImageComparisonView(
                    originalImage: original,
                    analyzedImage: processed,
                    isPresented: $showingImageComparison
                )
            }
        }
        .sheet(isPresented: $showingMetadata) {
            MetadataDetailView(metadata: imageMetadata)
        }
    }
    
    private func saveImageToPhotoLibrary() {
        guard let processedImage = processedImage else { return }
        
        // Create image with percentage overlay
        let imageWithOverlay = createImageWithPercentageOverlay(image: processedImage, percentage: results.greenPercentage)
        
        // Request permission first
        PHPhotoLibrary.requestAuthorization { status in
            DispatchQueue.main.async {
                switch status {
                case .authorized, .limited:
                    // Save the image with custom filename
                    self.saveImageWithMetadata(imageWithOverlay, percentage: self.results.greenPercentage)
                case .denied, .restricted:
                    self.saveAlertMessage = "Please enable photo library access in Settings to save images."
                    self.showingSaveAlert = true
                case .notDetermined:
                    break
                @unknown default:
                    break
                }
            }
        }
    }
    
    private func createImageWithPercentageOverlay(image: UIImage, percentage: Double) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: image.size)
        
        return renderer.image { context in
            // Draw the original image
            image.draw(at: .zero)
            
            // Configure the overlay
            let fontSize: CGFloat = min(image.size.width, image.size.height) * 0.08
            let padding: CGFloat = fontSize * 0.5
            let cornerRadius: CGFloat = fontSize * 0.3
            
            // Create the percentage text
            let percentageText = String(format: "%.1f%%", percentage)
            let font = UIFont.systemFont(ofSize: fontSize, weight: .bold)
            let attributes: [NSAttributedString.Key: Any] = [
                .font: font,
                .foregroundColor: UIColor.white
            ]
            
            let textSize = percentageText.size(withAttributes: attributes)
            let badgeWidth = textSize.width + padding * 2
            let badgeHeight = textSize.height + padding
            
            // Position in top-right corner
            let badgeX = image.size.width - badgeWidth - padding
            let badgeY = padding
            let badgeRect = CGRect(x: badgeX, y: badgeY, width: badgeWidth, height: badgeHeight)
            
            // Draw badge background
            let badgePath = UIBezierPath(roundedRect: badgeRect, cornerRadius: cornerRadius)
            context.cgContext.setFillColor(UIColor.systemGreen.cgColor)
            context.cgContext.addPath(badgePath.cgPath)
            context.cgContext.fillPath()
            
            // Draw the text
            let textRect = CGRect(
                x: badgeX + padding,
                y: badgeY + padding / 2,
                width: textSize.width,
                height: textSize.height
            )
            percentageText.draw(in: textRect, withAttributes: attributes)
        }
    }
    
    private func saveImageWithMetadata(_ image: UIImage, percentage: Double) {
        let percentageString = String(format: "%.1f", percentage)
        
        // Save to photo library
        PHPhotoLibrary.shared().performChanges({
            let creationRequest = PHAssetCreationRequest.forAsset()
            creationRequest.addResource(with: .photo, data: image.jpegData(compressionQuality: 0.9)!, options: nil)
            
            // Add creation date
            creationRequest.creationDate = Date()
            
            // Note: iOS doesn't allow custom filenames in Photos app, but the percentage is visible on the image
        }) { success, error in
            DispatchQueue.main.async {
                if success {
                    self.saveAlertMessage = "Image saved with \(percentageString)% green coverage!"
                } else {
                    self.saveAlertMessage = "Error saving image: \(error?.localizedDescription ?? "Unknown error")"
                }
                self.showingSaveAlert = true
            }
        }
    }
    
    private func getShareItems() -> [Any] {
        var items: [Any] = []
        
        // Add the segmented image with overlay
        if let processedImage = processedImage {
            let imageWithOverlay = createImageWithPercentageOverlay(image: processedImage, percentage: results.greenPercentage)
            items.append(imageWithOverlay)
        }
        
        // Create analysis report text
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .short
        
        let reportText = """
        🌱 GREENSCOUT ANALYSIS REPORT
        Date: \(dateFormatter.string(from: Date()))
        
        📊 ANALYSIS RESULTS
        • Green Coverage: \(String(format: "%.1f%%", results.greenPercentage))
        • Total Pixels Analyzed: \(formatNumber(results.totalPixels))
        • Green Pixels Detected: \(formatNumber(results.greenPixels))
        • Processing Time: \(String(format: "%.2f", results.processingTime)) seconds
        • Detection Accuracy: High
        
        GreenScout by Goldacres
        """
        
        items.append(reportText)
        
        return items
    }
    
    private func formatNumber(_ number: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = ","
        return formatter.string(from: NSNumber(value: number)) ?? "\(number)"
    }
}

struct StatCard: View {
    let icon: String
    let title: String
    let value: String
    var color: Color = .primary
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            
            Text(value)
                .font(.headline)
                .fontWeight(.semibold)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(8)
    }
}

struct InsightsCard: View {
    let greenPercentage: Double
    
    var recommendation: String {
        switch greenPercentage {
        case 0..<20:
            return "Very low vegetation coverage. Consider increasing fertilizer application or checking soil health. May require immediate intervention."
        case 20..<40:
            return "Low vegetation coverage. Monitor field conditions closely and consider targeted treatment. Check for pest issues or nutrient deficiencies."
        case 40..<60:
            return "Moderate vegetation coverage. Field is developing well, maintain current practices and monitor for optimal growth timing."
        case 60..<80:
            return "Good vegetation coverage. Field is healthy, continue monitoring for optimal harvest timing and pest management."
        default:
            return "Excellent vegetation coverage. Field is thriving with optimal green coverage. Monitor for over-fertilization or excessive growth."
        }
    }
    
    var chemicalMixingAdvice: String {
        switch greenPercentage {
        case 0..<20:
            return "High concentration mix recommended (1:50 ratio)"
        case 20..<40:
            return "Medium-high concentration mix (1:75 ratio)"
        case 40..<60:
            return "Standard concentration mix (1:100 ratio)"
        case 60..<80:
            return "Light concentration mix (1:125 ratio)"
        default:
            return "Minimal or no treatment needed"
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // General Insight
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: "lightbulb.fill")
                        .foregroundColor(.yellow)
                    Text("Agricultural Insight")
                        .font(.headline)
                }
                
                Text(recommendation)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            .background(Color.yellow.opacity(0.1))
            .cornerRadius(8)
            
            // Chemical Mixing Recommendation
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: "drop.fill")
                        .foregroundColor(.blue)
                    Text("Chemical Mixing Guide")
                        .font(.headline)
                }
                
                Text(chemicalMixingAdvice)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.blue)
                
                Text("Always follow manufacturer guidelines and local regulations")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            .background(Color.blue.opacity(0.1))
            .cornerRadius(8)
        }
    }
}
