//
//  AppColours.swift
//  GreenScout
//
//  Created by Steven Crowe on 30/7/2025.
//

import SwiftUI
import UIKit

struct AppColors {
    
    // Primary colors
    static let primary = Color(red: 255/255, green: 0.7, blue: 0.3)
    static let secondary = Color(red: 0.1, green: 0.5, blue: 0.8)
    static let accent = Color(red: 0.9, green: 0.4, blue: 0.1)
    
    // Background colors
    static let backgroundLight = Color(red: 0.98, green: 0.98, blue: 0.98)
    static let backgroundDark = Color(red: 0.1, green: 0.1, blue: 0.1)
    
    // Text colors
    static let textPrimary = Color(red: 0.2, green: 0.2, blue: 0.2)
    static let textSecondary = Color(red: 0.5, green: 0.5, blue: 0.5)
    
    // Status colors
    static let success = Color(red: 0.2, green: 0.8, blue: 0.2)
    static let warning = Color(red: 1.0, green: 0.8, blue: 0.0)
    static let error = Color(red: 0.9, green: 0.2, blue: 0.2)
    
    // Custom green shades for your GreenScout app
    static let greenLight = Color(red: 0.7, green: 0.9, blue: 0.7)
    static let greenGoldacres = Color(red: 0/255, green: 140/255, blue: 51/255) // Goldacres Green
    static let greenDark = Color(red: 0.1, green: 0.6, blue: 0.1)
    
    // Lines
    static let greyLine = Color(red: 230/255, green: 231/255, blue: 232/255)
    
    
    // Green gradients for buttons
    static let greenButtonGradient = LinearGradient(
        gradient: Gradient(colors: [
            Color(red: 0.2, green: 0.8, blue: 0.4),  // Light green
            Color(red: 0.1, green: 0.6, blue: 0.2)   // Darker green
        ]),
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let greenButtonGradientPressed = LinearGradient(
        gradient: Gradient(colors: [
            Color(red: 0.1, green: 0.6, blue: 0.2),  // Darker green
            Color(red: 0.05, green: 0.4, blue: 0.1)  // Even darker
        ]),
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    // Alternative vibrant green gradient
    static let vibrantGreenGradient = LinearGradient(
        gradient: Gradient(colors: [
            Color(red: 0.4, green: 0.9, blue: 0.5),  // Bright green
            Color(red: 0.2, green: 0.7, blue: 0.3),  // Medium green
            Color(red: 0.1, green: 0.5, blue: 0.2)   // Deep green
        ]),
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    // Subtle green gradient for secondary buttons
    static let subtleGreenGradient = LinearGradient(
        gradient: Gradient(colors: [
            Color(red: 0.7, green: 0.9, blue: 0.7),  // Very light green
            Color(red: 0.5, green: 0.8, blue: 0.6)   // Light green
        ]),
        startPoint: .top,
        endPoint: .bottom
    )
    
    
}
struct AppFonts {
    // Rajdhani font family
    static let tabBarFont = "Rajdhani-SemiBold"
    static let headingFont = "Rajdhani-Bold"
    static let subheadingFont = "Rajdhani-Medium"
    static let bodyFont = "Rajdhani-Regular"
    
    // Helper function
    static func font(name: String, size: CGFloat, fallback: UIFont.Weight = .regular) -> UIFont {
        return UIFont(name: name, size: size) ?? UIFont.systemFont(ofSize: size, weight: fallback)
    }
    
    // SwiftUI Font versions (the missing method)
    static func swiftUIFont(name: String, size: CGFloat) -> Font {
        return Font.custom(name, size: size)
    }
    
    // Alternative Rajdhani-specific method
    static func rajdhani(_ weight: RajdhaniWeight, size: CGFloat) -> Font {
        return Font.custom(weight.rawValue, size: size)
    }
}

enum RajdhaniWeight: String {
    case light = "Rajdhani-Light"
    case regular = "Rajdhani-Regular"
    case medium = "Rajdhani-Medium"
    case semiBold = "Rajdhani-SemiBold"
    case bold = "Rajdhani-Bold"
}

// MARK: - UIColor Extension for SwiftUI Color Conversion
// Note: This extension is not needed since iOS 14+ already provides UIColor(_ color: Color)
// We'll use the built-in UIColor initializer directly

// Font testing function
extension AppFonts {
    static func printAvailableFonts() {
        print("\n=== AVAILABLE FONTS ===")
        for family in UIFont.familyNames.sorted() {
            print("\nFamily: \(family)")
            for font in UIFont.fontNames(forFamilyName: family) {
                print("  - \(font)")
            }
        }
        print("\n=== RAJDHANI FONTS ===")
        for family in UIFont.familyNames where family.contains("Rajdhani") {
            print("Found Rajdhani family: \(family)")
        }
    }
}
