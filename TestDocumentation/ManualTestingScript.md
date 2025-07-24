# Manual Testing Script for ImageComparisonView Zoom Feature

## Test Setup
1. Open Xcode and run the GreenScout app on iPhone 16 Pro simulator
2. Navigate to the image comparison view with test images

## Test Execution

### ✅ Test 1: Basic Slider at 1× Zoom

**iPhone Portrait Mode:**
1. Ensure the slider is centered initially
2. Drag the slider to the left → Should reveal more of the analyzed (green) image
3. Drag the slider to the right → Should reveal more of the original (gray) image
4. Verify the white divider line follows your finger smoothly

**iPhone Landscape Mode:**
1. Rotate device to landscape (⌘ + → arrow)
2. Repeat slider tests from portrait mode
3. Verify UI adjusts properly to new dimensions

### ✅ Test 2: Pinch Zoom (up to 5×)

1. Place two fingers on the screen (hold Option key in simulator)
2. Drag outward to zoom in
3. Verify:
   - Smooth zoom animation
   - "1×" button becomes active (not grayed out)
   - Zoom stops at 5× maximum
4. Try pinching in to zoom out - should stop at 1×

### ✅ Test 3: Pan When Zoomed

1. Zoom to 2× or higher
2. Drag with one finger to pan the image
3. Verify:
   - Image pans smoothly
   - Cannot pan beyond image edges
   - Pan works in all directions

### ✅ Test 4: Slider vs Pan Threshold

1. While zoomed in (2× or more):
2. Make a small drag gesture (< 20 points)
   - Slider should still respond
3. Make a larger drag gesture (> 20 points)
   - Should pan the image, not move slider

### ✅ Test 5: Mask Alignment

1. Position slider at 25% from left
2. Zoom to 2×
3. Verify mask cutoff stays aligned with slider
4. Pan the image - mask should continue working correctly

### ✅ Test 6: UI Controls Stay Fixed

1. Zoom and pan the image
2. Verify these elements don't move:
   - "Original" and "Analyzed" labels at top
   - Close button (×) at top right
   - "1×" reset button
   - Bottom instruction text

### ✅ Test 7: Reset Functions

**1× Button:**
1. Zoom and pan to any position
2. Tap "1×" button
3. Verify zoom resets to 1× with smooth animation
4. Verify image centers itself

**Double Tap:**
1. Zoom and pan again
2. Double-tap anywhere on the image
3. Verify same reset behavior as 1× button

### ✅ Test 8: iPad Testing

1. Stop iPhone simulator (⌘ + Q in simulator)
2. Run app on iPad Pro 11-inch simulator
3. Repeat Tests 1-7 on iPad
4. Pay attention to:
   - Larger screen layout
   - Both orientations
   - Touch responsiveness

## Expected Results Summary

- ✅ Slider works smoothly at 1× zoom
- ✅ Pinch zooms smoothly up to 5× max
- ✅ Pan works when zoomed with proper boundaries
- ✅ Small drags move slider, large drags pan image
- ✅ Mask stays aligned during all operations
- ✅ UI controls remain stationary
- ✅ Reset functions work properly
- ✅ All features work on both iPhone and iPad

## Notes for Testing
- Use Option key in simulator for pinch gestures
- Use ⌘ + arrows for rotation
- Watch for any visual glitches or lag
- Test with different image sizes if available
