//
//  ImagePickers.swift
//  GreenScout
//
//  Image picker components for photo library and camera
//

import SwiftUI
import UIKit
import PhotosUI
import UniformTypeIdentifiers

// MARK: - Photo Library Picker
struct PhotoPicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    var onImageDataReceived: ((Data) -> Void)? = nil
    var onRawImageDetected: (() -> Void)? = nil
    @Environment(\.presentationMode) var presentationMode
    
    func makeUIViewController(context: Context) -> PHPickerViewController {
        var configuration = PHPickerConfiguration()
        // Configure to accept both standard images and RAW/DNG files
        configuration.filter = .any(of: [.images, .livePhotos])
        configuration.selectionLimit = 1
        // Request current format to preserve original quality
        configuration.preferredAssetRepresentationMode = .current
        
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        let parent: PhotoPicker
        
        init(_ parent: PhotoPicker) {
            self.parent = parent
        }
        
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            parent.presentationMode.wrappedValue.dismiss()
            
            guard let provider = results.first?.itemProvider else { return }
            
            // Try to get the PHAsset for metadata extraction
            if let assetIdentifier = results.first?.assetIdentifier {
                let fetchResult = PHAsset.fetchAssets(withLocalIdentifiers: [assetIdentifier], options: nil)
                if let _ = fetchResult.firstObject {
                    // Asset is available for metadata extraction
                    // Note: PHAsset needs to be passed through a different mechanism
                    // since we can't directly access the view model from here
                }
            }
            
            // Check if it's a DNG/RAW file
            let rawTypes = [UTType.rawImage, UTType("com.adobe.raw-image"), UTType("public.camera-raw-image")]
            let hasRawType = rawTypes.contains { type in
                provider.hasItemConformingToTypeIdentifier(type?.identifier ?? "")
            }
            
            if hasRawType {
                // RAW files are not supported
                print("RAW/DNG image detected - not supported")
                DispatchQueue.main.async {
                    self.parent.onRawImageDetected?()
                }
            } else {
                // Try to load as data first to preserve full resolution
                if provider.hasItemConformingToTypeIdentifier(UTType.image.identifier) {
                    provider.loadDataRepresentation(forTypeIdentifier: UTType.image.identifier) { [weak self] data, error in
                        if let data = data, let image = UIImage(data: data) {
                            print("Loaded image from data: \(image.size.width) x \(image.size.height), scale: \(image.scale)")
                            DispatchQueue.main.async {
                                self?.parent.image = image
                                // Pass the data for metadata extraction
                                self?.parent.onImageDataReceived?(data)
                            }
                        } else {
                            // Fallback to loading as UIImage
                            provider.loadObject(ofClass: UIImage.self) { [weak self] image, error in
                                DispatchQueue.main.async {
                                    if let image = image as? UIImage {
                                        print("Loaded image as UIImage: \(image.size.width) x \(image.size.height), scale: \(image.scale)")
                                        self?.parent.image = image
                                    }
                                }
                            }
                        }
                    }
                } else {
                    // Fallback to loading as UIImage
                    provider.loadObject(ofClass: UIImage.self) { [weak self] image, error in
                        DispatchQueue.main.async {
                            if let image = image as? UIImage {
                                print("Loaded image as UIImage (fallback): \(image.size.width) x \(image.size.height), scale: \(image.scale)")
                                self?.parent.image = image
                            }
                        }
                    }
                }
            }
        }
    }
}

// MARK: - Camera Picker
struct ImagePicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    var sourceType: UIImagePickerController.SourceType
    @Environment(\.presentationMode) var presentationMode
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = sourceType
        picker.allowsEditing = false
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, 
                                 didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            parent.presentationMode.wrappedValue.dismiss()
            
            if let image = info[.originalImage] as? UIImage {
                parent.image = image
            }
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}
