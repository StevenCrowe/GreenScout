# Image Comparison Zoom Feature - Test Checklist

## Pre-requisites
- [ ] App is installed on simulator/device
- [ ] Navigate to the Image Comparison View

## Basic Functionality Tests

### 1. Slider Functionality (Zoom = 1×)
- [ ] Verify slider can be dragged left and right
- [ ] Verify analyzed image reveals/hides properly
- [ ] Verify slider position indicator is visible

### 2. Pinch Zoom
- [ ] Perform pinch-out gesture to zoom in
- [ ] Verify images zoom together
- [ ] Verify slider line zooms with images
- [ ] Verify zoom indicator shows current zoom level (e.g., "2.5×")
- [ ] Verify maximum zoom is 5×
- [ ] Perform pinch-in gesture to zoom out
- [ ] Verify minimum zoom is 1×

### 3. Pan When Zoomed
- [ ] Zoom in to 2× or more
- [ ] Drag to pan the image
- [ ] Verify both images pan together
- [ ] Verify slider line pans with images
- [ ] Verify pan is constrained to image bounds

### 4. Slider Behavior When Zoomed
- [ ] Zoom in to 2× or more
- [ ] Attempt to drag the slider
- [ ] Verify slider does NOT move (it should be disabled when zoomed)
- [ ] Verify dragging performs pan instead

### 5. Reset Zoom
- [ ] Zoom and pan to any position
- [ ] Double-tap on image
- [ ] Verify zoom resets to 1× with animation
- [ ] Verify pan resets to center with animation
- [ ] Verify zoom indicator shows "1×"

### 6. Reset Button
- [ ] Zoom and pan to any position
- [ ] Tap the zoom indicator button (shows current zoom level)
- [ ] Verify zoom resets to 1× with animation
- [ ] Verify pan resets to center with animation
- [ ] Verify button shows "1×" after reset

### 7. UI Element Positions
- [ ] Verify close button remains in top-left corner
- [ ] Verify zoom indicator button remains in top-right corner
- [ ] Verify image labels remain at bottom
- [ ] Verify instructions text appears/disappears correctly

### 8. Instructions Text
- [ ] At 1× zoom: verify shows "Drag the slider to compare images"
- [ ] When zoomed: verify shows "Pan to explore • Pinch to zoom"
- [ ] Verify instructions hide during interactions

### 9. Gesture Interactions
- [ ] Verify pinch zoom works smoothly
- [ ] Verify pan gesture is responsive
- [ ] Verify no gesture conflicts

### 10. Edge Cases
- [ ] Rotate device and verify layout adjusts properly
- [ ] Test with different image sizes
- [ ] Test rapid zoom in/out
- [ ] Test zoom at image edges

## Performance Tests
- [ ] Verify no lag during zoom
- [ ] Verify no lag during pan
- [ ] Verify smooth animations

## Accessibility
- [ ] Verify VoiceOver reads zoom level correctly
- [ ] Verify reset button has proper accessibility label

## Test Results
- Date: _____________
- Tester: _____________
- Device/Simulator: _____________
- iOS Version: _____________
- Pass/Fail: _____________

## Notes:
_____________________________________
_____________________________________
_____________________________________
