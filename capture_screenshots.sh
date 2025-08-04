#!/bin/bash

# Function to wait for app to settle
wait_for_app() {
    sleep 2
}

# Function to tap on coordinates
tap_element() {
    xcrun simctl io $1 tap $2 $3
    wait_for_app
}

# Function to capture screenshot
capture_screenshot() {
    local device_id=$1
    local mode=$2
    local device_type=$3
    local filename=$4
    local description=$5
    
    echo "Capturing: $description"
    xcrun simctl io $device_id screenshot "Screenshots/$mode/$device_type/$filename"
}

# Simulator device ID
SIMULATOR_ID="E5523B02-EA91-4DF2-B4F5-190A107302B5"

# Kill the app if running
xcrun simctl terminate $SIMULATOR_ID com.goldacres.GreenScout 2>/dev/null

# Test Light Mode
echo "=== Testing Light Mode on Simulator ==="
xcrun simctl ui $SIMULATOR_ID appearance light
wait_for_app

# Launch app
xcrun simctl launch $SIMULATOR_ID com.goldacres.GreenScout
wait_for_app

# Main screen
capture_screenshot $SIMULATOR_ID "Light" "Simulator" "01_main_screen.png" "Main screen with tab bar"

# Tap on Camera/Photo selection (approximate center of screen)
tap_element $SIMULATOR_ID 197 400
capture_screenshot $SIMULATOR_ID "Light" "Simulator" "02_photo_selection.png" "Photo/Camera selection sheet"

# Dismiss sheet
tap_element $SIMULATOR_ID 197 200
wait_for_app

# Navigate to Calculator tab
tap_element $SIMULATOR_ID 98 812  # Calculator tab
capture_screenshot $SIMULATOR_ID "Light" "Simulator" "03_calculator_tab.png" "Calculator tab"

# Navigate to Chemicals tab
tap_element $SIMULATOR_ID 197 812  # Chemicals tab
capture_screenshot $SIMULATOR_ID "Light" "Simulator" "04_chemicals_tab.png" "Chemicals list"

# Navigate to History tab
tap_element $SIMULATOR_ID 295 812  # History tab
capture_screenshot $SIMULATOR_ID "Light" "Simulator" "05_history_tab.png" "History view"

# Navigate to Settings tab
tap_element $SIMULATOR_ID 344 812  # Settings tab
capture_screenshot $SIMULATOR_ID "Light" "Simulator" "06_settings_tab.png" "Settings view"

# Kill app
xcrun simctl terminate $SIMULATOR_ID com.goldacres.GreenScout

# Test Dark Mode
echo -e "\n=== Testing Dark Mode on Simulator ==="
xcrun simctl ui $SIMULATOR_ID appearance dark
wait_for_app

# Launch app
xcrun simctl launch $SIMULATOR_ID com.goldacres.GreenScout
wait_for_app

# Main screen
capture_screenshot $SIMULATOR_ID "Dark" "Simulator" "01_main_screen.png" "Main screen with tab bar"

# Tap on Camera/Photo selection
tap_element $SIMULATOR_ID 197 400
capture_screenshot $SIMULATOR_ID "Dark" "Simulator" "02_photo_selection.png" "Photo/Camera selection sheet"

# Dismiss sheet
tap_element $SIMULATOR_ID 197 200
wait_for_app

# Navigate to Calculator tab
tap_element $SIMULATOR_ID 98 812  # Calculator tab
capture_screenshot $SIMULATOR_ID "Dark" "Simulator" "03_calculator_tab.png" "Calculator tab"

# Navigate to Chemicals tab
tap_element $SIMULATOR_ID 197 812  # Chemicals tab
capture_screenshot $SIMULATOR_ID "Dark" "Simulator" "04_chemicals_tab.png" "Chemicals list"

# Navigate to History tab
tap_element $SIMULATOR_ID 295 812  # History tab
capture_screenshot $SIMULATOR_ID "Dark" "Simulator" "05_history_tab.png" "History view"

# Navigate to Settings tab
tap_element $SIMULATOR_ID 344 812  # Settings tab
capture_screenshot $SIMULATOR_ID "Dark" "Simulator" "06_settings_tab.png" "Settings view"

echo -e "\n=== Screenshot capture complete ==="
echo "Screenshots saved in Screenshots/Light/Simulator and Screenshots/Dark/Simulator"
echo ""
echo "For real device testing:"
echo "1. Build the app for device: xcodebuild -project GreenScout.xcodeproj -scheme GreenScout -destination 'id=329DB90F-4067-516A-986D-36BD72EB9AFF' build"
echo "2. Install on device and manually capture screenshots"
echo "3. Save them to Screenshots/Light/Device and Screenshots/Dark/Device"
