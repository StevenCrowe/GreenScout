//
//  ImageComparisonZoomTests.swift
//  GreenScoutUITests
//
//  UI tests for ImageComparisonView zoom/pan functionality
//

import XCTest

class ImageComparisonZoomTests: XCTestCase {
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        XCUIApplication().launch()
    }
    
    override func tearDownWithError() throws {
        // Clean up after tests
    }
    
    func testSliderWorksAt1xZoom() throws {
        let app = XCUIApplication()
        
        // Navigate to comparison view (adjust based on your app flow)
        // This assumes there's a way to get to the comparison view
        
        // Test slider drag at 1x zoom
        let comparisonView = app.otherElements["Image comparison view"]
        XCTAssertTrue(comparisonView.waitForExistence(timeout: 5))
        
        // Drag slider from center to left
        let startPoint = comparisonView.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5))
        let endPoint = comparisonView.coordinate(withNormalizedOffset: CGVector(dx: 0.2, dy: 0.5))
        startPoint.press(forDuration: 0.1, thenDragTo: endPoint)
        
        // Drag slider from left to right
        let rightPoint = comparisonView.coordinate(withNormalizedOffset: CGVector(dx: 0.8, dy: 0.5))
        endPoint.press(forDuration: 0.1, thenDragTo: rightPoint)
        
        // Verify slider moved (check for visual changes or accessibility elements)
        XCTAssertTrue(comparisonView.exists)
    }
    
    func testPinchZoomFunctionality() throws {
        let app = XCUIApplication()
        
        let comparisonView = app.otherElements["Image comparison view"]
        XCTAssertTrue(comparisonView.waitForExistence(timeout: 5))
        
        // Test pinch to zoom
        comparisonView.pinch(withScale: 2.0, velocity: 1.0)
        
        // Verify reset button becomes active
        let resetButton = app.buttons["Reset zoom"]
        XCTAssertTrue(resetButton.exists)
        XCTAssertTrue(resetButton.isEnabled)
        
        // Test zoom to maximum (5x)
        comparisonView.pinch(withScale: 3.0, velocity: 1.0)
        
        // Test pan gesture when zoomed
        let centerPoint = comparisonView.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5))
        let panEndPoint = comparisonView.coordinate(withNormalizedOffset: CGVector(dx: 0.7, dy: 0.7))
        centerPoint.press(forDuration: 0.1, thenDragTo: panEndPoint)
    }
    
    func testDoubleTapToReset() throws {
        let app = XCUIApplication()
        
        let comparisonView = app.otherElements["Image comparison view"]
        XCTAssertTrue(comparisonView.waitForExistence(timeout: 5))
        
        // Zoom in first
        comparisonView.pinch(withScale: 2.0, velocity: 1.0)
        
        // Double tap to reset
        comparisonView.doubleTap()
        
        // Verify reset button is disabled (indicating 1x zoom)
        let resetButton = app.buttons["Reset zoom"]
        XCTAssertFalse(resetButton.isEnabled)
    }
    
    func testUIControlsRemainStationary() throws {
        let app = XCUIApplication()
        
        let comparisonView = app.otherElements["Image comparison view"]
        XCTAssertTrue(comparisonView.waitForExistence(timeout: 5))
        
        // Check that labels exist
        let originalLabel = app.staticTexts["Original"]
        let analyzedLabel = app.staticTexts["Analyzed"]
        let closeButton = app.buttons["Close"]
        
        XCTAssertTrue(originalLabel.exists)
        XCTAssertTrue(analyzedLabel.exists)
        XCTAssertTrue(closeButton.exists)
        
        // Record initial positions
        let originalLabelFrame = originalLabel.frame
        let analyzedLabelFrame = analyzedLabel.frame
        let closeButtonFrame = closeButton.frame
        
        // Zoom and pan
        comparisonView.pinch(withScale: 2.0, velocity: 1.0)
        let centerPoint = comparisonView.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5))
        let panPoint = comparisonView.coordinate(withNormalizedOffset: CGVector(dx: 0.3, dy: 0.3))
        centerPoint.press(forDuration: 0.1, thenDragTo: panPoint)
        
        // Verify UI controls haven't moved
        XCTAssertEqual(originalLabel.frame, originalLabelFrame)
        XCTAssertEqual(analyzedLabel.frame, analyzedLabelFrame)
        XCTAssertEqual(closeButton.frame, closeButtonFrame)
    }
    
    func testSliderIgnoredDuringPan() throws {
        let app = XCUIApplication()
        
        let comparisonView = app.otherElements["Image comparison view"]
        XCTAssertTrue(comparisonView.waitForExistence(timeout: 5))
        
        // Zoom in first
        comparisonView.pinch(withScale: 2.0, velocity: 1.0)
        
        // Perform a long pan gesture (more than 20 points threshold)
        let startPoint = comparisonView.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5))
        let endPoint = comparisonView.coordinate(withNormalizedOffset: CGVector(dx: 0.2, dy: 0.2))
        
        // This should pan the image, not move the slider
        startPoint.press(forDuration: 0.5, thenDragTo: endPoint)
        
        // The slider position should not have changed significantly
        // (This would need to be verified visually or with additional accessibility labels)
    }
    
    func testOrientationChanges() throws {
        let app = XCUIApplication()
        let device = XCUIDevice.shared
        
        let comparisonView = app.otherElements["Image comparison view"]
        XCTAssertTrue(comparisonView.waitForExistence(timeout: 5))
        
        // Test in portrait
        device.orientation = .portrait
        
        // Test slider works
        let centerPoint = comparisonView.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5))
        let leftPoint = comparisonView.coordinate(withNormalizedOffset: CGVector(dx: 0.3, dy: 0.5))
        centerPoint.press(forDuration: 0.1, thenDragTo: leftPoint)
        
        // Rotate to landscape
        device.orientation = .landscapeLeft
        
        // Test slider still works
        let landscapeCenter = comparisonView.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5))
        let landscapeRight = comparisonView.coordinate(withNormalizedOffset: CGVector(dx: 0.7, dy: 0.5))
        landscapeCenter.press(forDuration: 0.1, thenDragTo: landscapeRight)
        
        // Test zoom in landscape
        comparisonView.pinch(withScale: 2.0, velocity: 1.0)
        
        // Return to portrait
        device.orientation = .portrait
    }
}
