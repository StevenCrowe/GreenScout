//
//  ContentView.swift
//  GreenScout
//
//  Created by Marketing 2 on 17/7/2025.
//

import SwiftUI
import PhotosUI

struct ContentView: View {
    @StateObject private var viewModel = ImageAnalysisViewModel()
    @State private var showingImagePicker = false
    @State private var showingCamera = false
    @State private var imagePickerSourceType: UIImagePickerController.SourceType = .photoLibrary
    @State private var progressOffset: CGFloat = 0
    @State private var showingRawImageAlert = false
    
    var body: some View {
        if #available(iOS 16.0, *) {
            NavigationStack {
                ContentScrollView(viewModel: viewModel, showingImagePicker: $showingImagePicker, showingCamera: $showingCamera, showingRawImageAlert: $showingRawImageAlert, progressOffset: $progressOffset)
            }
        } else {
            NavigationView {
                ContentScrollView(viewModel: viewModel, showingImagePicker: $showingImagePicker, showingCamera: $showingCamera, showingRawImageAlert: $showingRawImageAlert, progressOffset: $progressOffset)
            }
            .navigationViewStyle(StackNavigationViewStyle())
        }
    }
}

// Extract the content into a separate view for reusability
struct ContentScrollView: View {
    @ObservedObject var viewModel: ImageAnalysisViewModel
    @Binding var showingImagePicker: Bool
    @Binding var showingCamera: Bool
    @Binding var showingRawImageAlert: Bool
    @Binding var progressOffset: CGFloat
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Header - Only show when no results
                    if viewModel.analysisResults == nil {
                        VStack(spacing: 8) {
                            Image(systemName: "leaf.circle.fill")
                                .font(.system(size: 60))
                                .foregroundColor(GA.brand)

                            Text("GreenScout")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .foregroundColor(GA.ink)

                            Text("Analyze green coverage in your fields")
                                .font(.subheadline)
                                .foregroundColor(GA.inkMuted)
                        }
                        .padding(.top)
                    }
                    
                    // Image Selection Section - Only show if no results
                    if viewModel.analysisResults == nil {
                        VStack(spacing: 16) {
                            if let image = viewModel.selectedImage {
                                // Image Preview
                                Image(uiImage: image)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(maxHeight: 300)
                                    .cornerRadius(12)
                                    .shadow(radius: 4)
                                    .onTapGesture {
                                        // Allow changing image by tapping on it
                                        showingImagePicker = true
                                    }
                            } else {
                                // Upload Area - Now clickable
                                VStack(spacing: 12) {
                                    Image(systemName: "photo.on.rectangle.angled")
                                        .font(.system(size: 50))
                                        .foregroundColor(GA.brand)

                                    Text("Tap to select an image")
                                        .font(.headline)
                                        .foregroundColor(GA.ink)

                                    Text("Choose from library or camera")
                                        .font(.caption)
                                        .foregroundColor(GA.inkMuted)

                                    Text("For best results, use high-quality images")
                                        .font(.caption)
                                        .foregroundColor(GA.inkMuted)
                                }
                                .frame(maxWidth: .infinity)
                                .frame(height: 200)
                                .background(GA.surfacePanel)
                                .clipShape(RoundedRectangle(cornerRadius: GA.radiusPanel, style: .continuous))
                                .overlay(
                                    RoundedRectangle(cornerRadius: GA.radiusPanel, style: .continuous)
                                        .stroke(style: StrokeStyle(lineWidth: 2, dash: [8]))
                                        .foregroundColor(GA.line)
                                )
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    // Show action sheet to choose between camera and photo library
                                    if UIImagePickerController.isSourceTypeAvailable(.camera) {
                                        // If camera is available, show options
                                        showingImagePicker = true
                                    } else {
                                        // If no camera (simulator), go straight to photo library
                                        showingImagePicker = true
                                    }
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                    // Image Quality Warning and Analyze Button - Only show if no results
                    if viewModel.analysisResults == nil {
                        if let warning = viewModel.imageQualityWarning {
                            HStack(spacing: 12) {
                                Image(systemName: getWarningIcon(for: warning))
                                    .font(.title3)
                                    .foregroundColor(getWarningColor(for: warning))
                                
                                Text(warning)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.leading)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                            .padding()
                            .background(getWarningColor(for: warning).opacity(0.1))
                            .cornerRadius(8)
                            .padding(.horizontal)
                            
                            // Option to choose another image if resolution is too low
                            if warning.contains("too low") {
                                Button(action: {
                                    viewModel.selectedImage = nil
                                    viewModel.imageQualityWarning = nil
                                    showingImagePicker = true
                                }) {
                                    HStack {
                                        Image(systemName: "photo")
                                        Text("Choose Another Image")
                                    }
                                }
                                .buttonStyle(GAPrimaryButtonStyle())
                                .padding(.horizontal)
                            }
                        }
                        
                        // Green sensitivity control (once an image is chosen, before analysing)
                        if viewModel.selectedImage != nil && !viewModel.isAnalyzing {
                            GreenSensitivityPicker(sensitivity: $viewModel.sensitivity,
                                                   isAnalyzing: viewModel.isAnalyzing)
                                .padding(.horizontal)
                        }

                        // Analyze Button
                        if viewModel.selectedImage != nil {
                            if viewModel.isAnalyzing {
                                // Progress Bar during analysis
                                VStack(spacing: 16) {
                                    HStack(spacing: 12) {
                                        ProgressView()
                                            .progressViewStyle(CircularProgressViewStyle(tint: .green))
                                            .scaleEffect(1.2)
                                        
                                        Text("Analyzing image...")
                                            .font(.headline)
                                            .foregroundColor(.primary)
                                    }
                                    
                                    // Custom Progress Bar
                                    GeometryReader { geometry in
                                        ZStack(alignment: .leading) {
                                            // Background track
                                            RoundedRectangle(cornerRadius: 6)
                                                .fill(Color.gray.opacity(0.2))
                                                .frame(height: 12)
                                            
                                            // Animated progress indicator
                                            RoundedRectangle(cornerRadius: 6)
                                                .fill(LinearGradient(
                                                    gradient: Gradient(colors: [Color.green, Color.green.opacity(0.7), Color.green]),
                                                    startPoint: .leading,
                                                    endPoint: .trailing
                                                ))
                                                .frame(width: geometry.size.width * 0.4, height: 12)
                                                .offset(x: progressOffset)
                                                .animation(
                                                    Animation.linear(duration: 1.2)
                                                        .repeatForever(autoreverses: false),
                                                    value: progressOffset
                                                )
                                        }
                                        .clipShape(RoundedRectangle(cornerRadius: 6))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 6)
                                                .stroke(Color.green.opacity(0.3), lineWidth: 1)
                                        )
                                    }
                                    .frame(height: 12)
                                    .onAppear {
                                        // Start animation immediately
                                        progressOffset = -UIScreen.main.bounds.width * 0.4
                                        withAnimation(.linear(duration: 1.2).repeatForever(autoreverses: false)) {
                                            progressOffset = UIScreen.main.bounds.width
                                        }
                                    }
                                    
                                    Text("Detecting green vegetation...")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                        .padding(.top, 4)
                                }
                                .padding(24)
                                .background(
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(Color.green.opacity(0.05))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 16)
                                                .stroke(Color.green.opacity(0.2), lineWidth: 1)
                                        )
                                )
                                .padding(.horizontal)
                            } else {
                                Button(action: {
                                    viewModel.analyzeImage()
                                }) {
                                    Text("Analyze Green Coverage")
                                }
                                .buttonStyle(GAPrimaryButtonStyle())
                                .disabled(viewModel.imageQualityWarning?.contains("too low") == true)
                                .padding(.horizontal)
                            }
                        }
                    }
                    
                    // Results Section
                    if let results = viewModel.analysisResults {
                        ResultsView(results: results, originalImage: viewModel.displayImage ?? viewModel.selectedImage, processedImage: viewModel.processedImage, processedImageTransparent: viewModel.processedImageTransparent, imageMetadata: viewModel.imageMetadata, sensitivity: $viewModel.sensitivity, isAnalyzing: viewModel.isAnalyzing)
                            .padding(.horizontal)
                        
                        // Image Quality Info near Analyze Another button
                        if let warning = viewModel.imageQualityWarning {
                            HStack(spacing: 12) {
                                Image(systemName: getWarningIcon(for: warning))
                                    .font(.body)
                                    .foregroundColor(getWarningColor(for: warning))
                                
                                Text(warning)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.leading)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                            .padding()
                            .background(getWarningColor(for: warning).opacity(0.1))
                            .cornerRadius(8)
                            .padding(.horizontal)
                        }
                        
                        // Analyze Another Button
                        Button(action: {
                            // Reset everything for a new analysis
                            viewModel.selectedImage = nil
                            viewModel.analysisResults = nil
                            viewModel.processedImage = nil
                            viewModel.processedImageTransparent = nil
                            viewModel.imageQualityWarning = nil
                        }) {
                            HStack {
                                Image(systemName: "camera.fill")
                                Text("Analyze Another Image")
                            }
                        }
                        .buttonStyle(GASecondaryButtonStyle())
                        .padding(.horizontal)
                    }
                    
                    Spacer(minLength: 50)
            }
        }
        .background(GA.surfacePage.ignoresSafeArea())
        .navigationBarHidden(true)
        .overlay {
            // Prominent centre-screen cue during a quick re-run (sensitivity change).
            if viewModel.isAnalyzing && viewModel.analysisResults != nil {
                RecalculatingOverlay()
            }
        }
        .animation(.easeInOut(duration: 0.2), value: viewModel.isAnalyzing)
        .onChange(of: viewModel.sensitivity) { _ in
            // If results are already on screen, re-run so the operator sees the
            // effect of the new strictness immediately (Strict/Balanced/Loose A/B).
            if viewModel.analysisResults != nil && viewModel.selectedImage != nil {
                viewModel.analyzeImage()
            }
        }
        .sheet(isPresented: $showingImagePicker) {
            PhotoPicker(image: $viewModel.selectedImage, 
                       onImageDataReceived: { imageData in
                           // Extract metadata from image data
                           viewModel.extractMetadataFromImageData(imageData)
                       },
                       onRawImageDetected: {
                           // Show alert for RAW images
                           showingRawImageAlert = true
                       }
            )
        }
        .sheet(isPresented: $showingCamera) {
            ImagePicker(image: $viewModel.selectedImage, sourceType: .camera)
        }
        .alert("Unsupported Image Format", isPresented: $showingRawImageAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("RAW image formats (including DNG, ARW, NEF, CR2) are not currently supported. Please upload a JPEG, PNG, or HEIF image instead.")
        }
    }
    
    private func getWarningIcon(for warning: String) -> String {
        if warning.contains("too low") {
            return "exclamationmark.triangle.fill"
        } else if warning.contains("Warning:") {
            return "exclamationmark.circle.fill"
        } else {
            return "info.circle.fill"
        }
    }
    
    private func getWarningColor(for warning: String) -> Color {
        if warning.contains("too low") {
            return .red
        } else if warning.contains("Warning:") {
            return .orange
        } else {
            return .blue
        }
    }
}

// Reusable green-strictness control, shown before a scan and again on the result,
// directly under the number it controls. Changing it re-runs analysis (see ContentView).
struct GreenSensitivityPicker: View {
    @Binding var sensitivity: GreenSensitivity
    var isAnalyzing: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 6) {
                Image(systemName: "slider.horizontal.3")
                    .foregroundColor(GA.brand)
                Text("Green sensitivity")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(GA.ink)
                Spacer()
                // Live "it's working" cue when a mode change re-runs analysis.
                if isAnalyzing {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: GA.brand))
                        .scaleEffect(0.8)
                    Text("Recalculating…")
                        .font(.caption)
                        .foregroundColor(GA.inkMuted)
                }
            }
            Picker("Green sensitivity", selection: $sensitivity) {
                ForEach(GreenSensitivity.allCases) { level in
                    Text(level.label).tag(level)
                }
            }
            .pickerStyle(.segmented)
            .tint(GA.brand)
            .disabled(isAnalyzing)
            Text(sensitivity.blurb)
                .font(.caption)
                .foregroundColor(GA.inkMuted)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

// Centre-of-screen "working" indicator: dimmed backdrop + pulsing leaf, shown
// briefly on quick re-runs so a sensitivity change is clearly registered.
struct RecalculatingOverlay: View {
    @State private var pulse = false

    var body: some View {
        ZStack {
            Color.black.opacity(0.25)
                .ignoresSafeArea()
            VStack(spacing: 16) {
                Image(systemName: "leaf.fill")
                    .font(.system(size: 46))
                    .foregroundColor(.green)
                    .scaleEffect(pulse ? 1.15 : 0.82)
                    .opacity(pulse ? 1.0 : 0.55)
                    .animation(.easeInOut(duration: 0.6).repeatForever(autoreverses: true), value: pulse)
                Text("Recalculating…")
                    .font(.headline)
                    .foregroundColor(.primary)
            }
            .padding(30)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20))
            .shadow(color: .black.opacity(0.2), radius: 12, y: 4)
        }
        .onAppear { pulse = true }
        .transition(.opacity)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
