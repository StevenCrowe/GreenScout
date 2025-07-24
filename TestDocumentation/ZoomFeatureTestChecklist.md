# ImageComparisonView Zoom Feature Test Checklist

## Test Environment Setup
- [ ] Build and run the app on iPhone device/simulator
- [ ] Build and run the app on iPad device/simulator
- [ ] Have test images ready (original and analyzed versions)

## Test Cases

### 1. Slider Functionality at 1× Zoom

#### iPhone Portrait
- [ ] Open image comparison view
- [ ] Verify slider is visible and centered
- [ ] Drag slider to the left (shows more analyzed image)
- [ ] Drag slider to the right (shows more original image)
- [ ] Verify smooth animation during drag
- [ ] Verify mask properly reveals/hides the analyzed image
- [ ] Verify white divider line follows finger position

#### iPhone Landscape
- [ ] Rotate device to landscape
- [ ] Repeat all portrait tests
- [ ] Verify slider adjusts to new dimensions
- [ ] Verify no UI glitches during rotation

#### iPad
- [ ] Repeat all tests on iPad
- [ ] Test in both orientations
- [ ] Verify larger screen size doesn't affect functionality

### 2. Pinch Zoom Functionality

#### Zoom In (up to 5×)
- [ ] Perform pinch-out gesture to zoom in
- [ ] Verify smooth zoom animation
- [ ] Verify zoom stops at 5× maximum
- [ ] Verify "1×" reset button becomes active when zoomed
- [ ] Verify image quality remains good at max zoom

#### Zoom Boundaries
- [ ] At max zoom, try to zoom further - should stop at 5×
- [ ] Pinch-in to zoom out - should stop at 1× minimum
- [ ] Verify no visual glitches at zoom limits

### 3. Pan Functionality When Zoomed

#### Basic Pan
- [ ] Zoom to 2× or higher
- [ ] Drag to pan the image
- [ ] Verify smooth panning motion
- [ ] Verify pan boundaries (can't pan beyond image edges)
- [ ] Test panning in all directions

#### Pan Distance Threshold
- [ ] When zoomed, make small drag gesture (<20 points)
- [ ] Verify slider still responds to small drags
- [ ] Make larger pan gesture (>20 points)
- [ ] Verify slider is ignored during larger pans
- [ ] Verify image pans instead of slider moving

### 4. Mask Alignment During Zoom

- [ ] Position slider at 25% from left
- [ ] Zoom to 2×
- [ ] Verify mask cutoff stays aligned with slider position
- [ ] Pan the image
- [ ] Verify mask continues to work correctly
- [ ] Move slider while zoomed
- [ ] Verify mask updates properly

### 5. UI Controls Behavior

#### Stationary Elements
- [ ] Zoom and pan the image
- [ ] Verify "Original" label stays in place
- [ ] Verify "Analyzed" label stays in place
- [ ] Verify close button (×) stays in place
- [ ] Verify "1×" reset button stays in place
- [ ] Verify instruction text at bottom stays in place

#### Control Functionality While Zoomed
- [ ] While zoomed, tap "1×" button
- [ ] Verify zoom resets to 1× with animation
- [ ] Verify pan offset resets to center
- [ ] While zoomed, tap close button
- [ ] Verify view dismisses properly

### 6. Double-Tap Reset
- [ ] Zoom and pan to any position
- [ ] Double-tap anywhere on the image
- [ ] Verify zoom resets to 1×
- [ ] Verify pan resets to center
- [ ] Verify smooth animation during reset

### 7. Gesture Interactions

#### Simultaneous Gestures
- [ ] Try pinch while dragging - verify proper priority
- [ ] Start dragging slider, then try to pinch
- [ ] Verify gestures don't conflict

#### Gesture Transitions
- [ ] Zoom in, then immediately pan
- [ ] Pan, then immediately zoom
- [ ] Verify smooth transitions between gestures

### 8. Performance Testing

- [ ] Load high-resolution images
- [ ] Test all zoom/pan operations
- [ ] Verify no lag or stuttering
- [ ] Monitor for memory warnings
- [ ] Test rapid zoom in/out
- [ ] Test rapid panning

### 9. Edge Cases

- [ ] Test with square images
- [ ] Test with very wide panoramic images
- [ ] Test with very tall portrait images
- [ ] Test with small/low-res images
- [ ] Test rapid orientation changes while zoomed

### 10. Accessibility

- [ ] Enable VoiceOver
- [ ] Verify "Image comparison view" is announced
- [ ] Verify "Reset zoom" button is properly labeled
- [ ] Verify double-tap gesture hint is announced
- [ ] Test with Zoom accessibility feature enabled

## iOS 15 Compatibility Check

Since iOS 15 simulator is not available, test on oldest available iOS version:
- [ ] Verify all gestures work
- [ ] Check for any deprecated API warnings
- [ ] Verify animations are smooth
- [ ] Test all features listed above

## Bug Report Template

If any issues are found, document:
1. Device/Simulator type
2. iOS version
3. Orientation
4. Steps to reproduce
5. Expected behavior
6. Actual behavior
7. Screenshot/video if applicable

## Sign-off

- [ ] All tests passed on iPhone
- [ ] All tests passed on iPad
- [ ] No performance issues detected
- [ ] No visual glitches observed
- [ ] Accessibility features working correctly

Tested by: ________________
Date: ________________
iOS Versions tested: ________________
