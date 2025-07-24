//
//  ImageComparisonView.swift
//  GreenScout
//
//  Full-screen image comparison view with slider
//

import SwiftUI

// Extension to clamp values within a range
extension Comparable {
    func clamped(_ range: ClosedRange<Self>) -> Self {
        return min(max(self, range.lowerBound), range.upperBound)
    }
}

struct ImageComparisonView: View {
    let originalImage: UIImage
    let analyzedImage: UIImage
    @Binding var isPresented: Bool
    
    @State private var sliderPosition: CGFloat = 0.5
    @State private var isDragging = false
    @State private var actualImageFrame: CGRect = .zero
    
    // Zoom state properties
    @State private var currentScale: CGFloat = 1.0      // accumulated scale
    @State private var gestureScale: CGFloat = 1.0       // in-progress pinch
    @State private var currentOffset: CGSize = .zero     // accumulated pan
    @State private var gestureOffset: CGSize = .zero     // in-progress drag
    
    // Gesture state tracking
    @State private var isPanning = false
    @State private var initialSliderPosition: CGFloat = 0.5  // Track initial position for drag
    
    // Scale limits
    private let minScale: CGFloat = 1.0
    private let maxScale: CGFloat = 5.0
    
    // Threshold for pan distance to ignore slider when zoomed
    private let panThreshold: CGFloat = 20
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Black background
                Color.black
                    .ignoresSafeArea()
                
                // Container for images with proper boundary tracking
                ZStack {
                    GeometryReader { imageContainerGeometry in
                        ZStack {
                            // Original image (bottom layer)
                            Image(uiImage: originalImage)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: imageContainerGeometry.size.width, height: imageContainerGeometry.size.height)
                                .background(
                                    GeometryReader { imageGeometry in
                                        Color.clear
                                            .onAppear {
                                                actualImageFrame = imageGeometry.frame(in: .local)
                                            }
                                            .onChange(of: imageGeometry.size) { _ in
                                                actualImageFrame = imageGeometry.frame(in: .local)
                                            }
                                    }
                                )
                            
                            // Analyzed image (top layer with clipping)
                            Image(uiImage: analyzedImage)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: imageContainerGeometry.size.width, height: imageContainerGeometry.size.height)
                                .mask(
                                    GeometryReader { maskGeometry in
                                        // Always use slider mask for comparison
                                        HStack(spacing: 0) {
                                            Rectangle()
                                                .frame(width: maskGeometry.size.width * sliderPosition)
                                            
                                            Color.clear
                                                .frame(width: maskGeometry.size.width * (1 - sliderPosition))
                                        }
                                    }
                                )
                            
                            // Slider overlay - always visible
                            if actualImageFrame.width > 0 {
                                // Vertical divider line
                                Rectangle()
                                    .fill(Color.white)
                                    .frame(width: 2, height: actualImageFrame.height)
                                    .opacity(isDragging ? 1.0 : 0.6)
                                    .shadow(color: .black.opacity(0.5), radius: 2)
                                    .animation(.easeInOut(duration: 0.2), value: isDragging)
                                    .position(x: actualImageFrame.minX + actualImageFrame.width * sliderPosition, y: actualImageFrame.midY)
                            }
                        }
                    }
                }
                .scaleEffect(currentScale * gestureScale)
                .offset(x: currentOffset.width + gestureOffset.width, y: currentOffset.height + gestureOffset.height)
                
                // Top overlay with labels and close button
                VStack {
                    HStack {
                        // Labels
                        HStack(spacing: 20) {
                            // Original label
                            HStack(spacing: 6) {
                                Circle()
                                    .fill(Color.gray)
                                    .frame(width: 10, height: 10)
                                Text("Original")
                                    .font(.caption)
                                    .fontWeight(.medium)
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.black.opacity(0.6))
                            .cornerRadius(20)
                            
                            // Analyzed label
                            HStack(spacing: 6) {
                                Circle()
                                    .fill(Color.green)
                                    .frame(width: 10, height: 10)
                                Text("Analyzed")
                                    .font(.caption)
                                    .fontWeight(.medium)
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.black.opacity(0.6))
                            .cornerRadius(20)
                        }
                        .foregroundColor(.white)
                        .opacity(isDragging ? 0 : 1)
                        .animation(.easeOut(duration: 0.3), value: isDragging)
                        
                        Spacer()
                        
                        // Reset and Close buttons
                        HStack(spacing: 12) {
                            // Reset button (shows current zoom level)
                            Button(action: {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                    currentScale = 1
                                    currentOffset = .zero
                                    gestureScale = 1
                                    gestureOffset = .zero
                                }
                            }) {
                                Text(String(format: "%.1f×", currentScale * gestureScale))
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(.white)
                                    .frame(width: 44, height: 36)
                                    .background(Capsule().fill(Color.black.opacity(0.6)))
                            }
                            .opacity(currentScale > 1 ? 1 : 0.5)
                            .disabled(currentScale == 1)
                            .accessibilityLabel("Reset zoom")
                            .accessibilityHint("Currently at \(String(format: "%.1f", currentScale * gestureScale))× zoom. Tap to reset.")
                            
                            // Close button
                            Button(action: {
                                isPresented = false
                            }) {
                                Image(systemName: "xmark.circle.fill")
                                    .font(.title)
                                    .foregroundColor(.white)
                                    .background(Circle().fill(Color.black.opacity(0.5)))
                            }
                            .accessibilityLabel("Close")
                            .accessibilityHint("Closes the image comparison view")
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, geometry.safeAreaInsets.top + 20) // Add safe area plus extra padding
                    .padding(.bottom, 10)
                    
                    Spacer()
                    
                    // Instructions at bottom
                    Text(currentScale > 1 ? "Drag slider to compare • Pan to explore • Pinch to zoom" : "Drag the slider to compare images")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.8))
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(Color.black.opacity(0.6))
                        .cornerRadius(20)
                        .padding(.bottom, 30)
                        .opacity((isDragging || isPanning || gestureScale != 1.0) ? 0 : 1)
                        .animation(.easeOut(duration: 0.3), value: isDragging)
                        .animation(.easeOut(duration: 0.3), value: isPanning)
                        .animation(.easeOut(duration: 0.3), value: gestureScale)
                }
            }
            .simultaneousGesture(zoomGesture)
            .gesture(dragGesture)
            .onTapGesture(count: 2) {                // double-tap to reset
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    currentScale = 1
                    currentOffset = .zero
                    gestureScale = 1
                    gestureOffset = .zero
                }
            }
            .accessibilityLabel("Image comparison view")
            .accessibilityHint("Double-tap to reset zoom and position")
        }
        .ignoresSafeArea(.container, edges: [.bottom, .horizontal])
        .preferredColorScheme(.dark)
    }
    
    // Define gestures
    private var zoomGesture: some Gesture {
        MagnificationGesture()
            .onChanged { value in
                let newScale = currentScale * value
                // Apply scale limits during gesture for smooth experience
                if newScale >= minScale && newScale <= maxScale {
                    gestureScale = value
                }
            }
            .onEnded { _ in
                currentScale = (currentScale * gestureScale).clamped(minScale...maxScale)
                gestureScale = 1
                // Reset pan offset when zooming back to 1x
                if currentScale == 1 {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        currentOffset = .zero
                        gestureOffset = .zero
                    }
                }
            }
    }
    
    private var dragGesture: some Gesture {
        DragGesture(minimumDistance: 0)
            .onChanged { value in
                if actualImageFrame.width > 0 {
                    // Check if we're near the slider line
                    let sliderX = actualImageFrame.minX + actualImageFrame.width * sliderPosition
                    let touchX = value.location.x
                    let distanceFromSlider = abs(touchX - sliderX)
                    
                    // If zoomed and not near slider, pan the view
                    if currentScale > 1 && distanceFromSlider > 30 && !isDragging {
                        isPanning = true
                        gestureOffset = CGSize(
                            width: value.translation.width,
                            height: value.translation.height
                        )
                    } else {
                        // Slider mode - works at any zoom level
                        isDragging = true
                        isPanning = false
                        
                        // When zoomed, we need to adjust the slider sensitivity
                        if currentScale > 1 {
                            // On first touch, record the initial position
                            if value.translation.width == 0 && value.translation.height == 0 {
                                initialSliderPosition = sliderPosition
                            }
                            
                            // Scale the movement by the zoom level to make it less sensitive
                            let scaledMovement = value.translation.width / (currentScale * 2)
                            let movementRatio = scaledMovement / actualImageFrame.width
                            
                            // Update slider position based on scaled movement from initial position
                            let newPosition = initialSliderPosition + movementRatio
                            sliderPosition = min(max(newPosition, 0), 1)
                            
                            // Auto-center on slider when zoomed (with less frequent updates)
                            if abs(sliderPosition - initialSliderPosition) > 0.02 {
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    // Calculate offset to center the slider position
                                    let imageWidth = actualImageFrame.width * currentScale
                                    let viewWidth = actualImageFrame.width
                                    let maxOffset = (imageWidth - viewWidth) / 2
                                    
                                    // Calculate where the slider position should be centered
                                    let targetCenterX = (sliderPosition - 0.5) * imageWidth
                                    currentOffset.width = -targetCenterX.clamped(-maxOffset...maxOffset)
                                }
                            }
                        } else {
                            // At 1x zoom, use direct positioning
                            let relativeX = touchX - actualImageFrame.minX
                            let newPosition = relativeX / actualImageFrame.width
                            sliderPosition = min(max(newPosition, 0), 1)
                        }
                    }
                }
            }
            .onEnded { _ in
                if isPanning {
                    // Commit pan offset
                    currentOffset = CGSize(
                        width: currentOffset.width + gestureOffset.width,
                        height: currentOffset.height + gestureOffset.height
                    )
                    gestureOffset = .zero
                    isPanning = false
                } else {
                    isDragging = false
                }
            }
    }
}

// Preference key to track image frame
struct ImageFramePreferenceKey: PreferenceKey {
    static var defaultValue: CGRect = .zero
    static func reduce(value: inout CGRect, nextValue: () -> CGRect) {
        value = nextValue()
    }
}

// Preview provider for SwiftUI canvas
struct ImageComparisonView_Previews: PreviewProvider {
    static var previews: some View {
        ImageComparisonView(
            originalImage: UIImage(systemName: "photo")!,
            analyzedImage: UIImage(systemName: "photo.fill")!,
            isPresented: .constant(true)
        )
    }
}
