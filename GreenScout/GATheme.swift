//
//  GATheme.swift
//  GreenScout
//
//  Goldacres EcoSYSTEM design tokens (from ga-brand: tailwind.config.js + app.css).
//  Colours adapt to light/dark so the app matches the EcoSYSTEM palette in both modes.
//

import SwiftUI
import UIKit

enum GA {
    static let brand        = dyn(0x008c33, 0x1aa843)   // primary green
    static let brandHover   = dyn(0x006d27, 0x3cc364)
    static let brandBright  = dyn(0x006d27, 0x7dffa0)   // green text/icon on dark
    static let brandTint    = dyn(0xe8f5ee, 0x153824)   // active/selected tint
    static let ink          = dyn(0x000000, 0xf0f0f5)   // titles
    static let ink70        = dyn(0x434549, 0xc3c8d1)
    static let inkBody      = dyn(0x2d2d2d, 0xd2d5da)
    static let inkMuted     = dyn(0x5f6673, 0x8a8f99)   // labels / captions
    static let surfacePage  = dyn(0xf2f3f5, 0x0d1117)   // app background
    static let surfacePanel = dyn(0xffffff, 0x161a22)   // cards / panels
    static let line         = dyn(0xdde0e4, 0x2a2e36)   // borders / dividers
    static let danger       = dyn(0xb00020, 0xf87171)

    static let radiusControl: CGFloat = 8
    static let radiusPanel: CGFloat = 10

    private static func dyn(_ light: Int, _ dark: Int) -> Color {
        Color(UIColor { $0.userInterfaceStyle == .dark ? UIColor(gaHex: dark) : UIColor(gaHex: light) })
    }
}

extension UIColor {
    convenience init(gaHex hex: Int) {
        self.init(red: CGFloat((hex >> 16) & 0xff) / 255,
                  green: CGFloat((hex >> 8) & 0xff) / 255,
                  blue: CGFloat(hex & 0xff) / 255,
                  alpha: 1)
    }
}

// Card / panel container: surface-panel fill, 1px line border, panel radius.
extension View {
    func gaPanel(padding: CGFloat = 16) -> some View {
        self
            .padding(padding)
            .background(GA.surfacePanel)
            .clipShape(RoundedRectangle(cornerRadius: GA.radiusPanel, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: GA.radiusPanel, style: .continuous)
                    .stroke(GA.line, lineWidth: 1)
            )
    }
}

// Primary action — one per screen. Filled brand green, white bold label.
struct GAPrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 16, weight: .bold))
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 13)
            .background(GA.brand.opacity(configuration.isPressed ? 0.85 : 1))
            .clipShape(RoundedRectangle(cornerRadius: GA.radiusControl, style: .continuous))
    }
}

// Secondary action — bordered, neutral (or tinted).
struct GASecondaryButtonStyle: ButtonStyle {
    var tint: Color? = nil
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 16, weight: .semibold))
            .foregroundColor(tint ?? GA.ink70)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 13)
            .background(GA.surfacePanel.opacity(configuration.isPressed ? 0.5 : 1))
            .overlay(
                RoundedRectangle(cornerRadius: GA.radiusControl, style: .continuous)
                    .stroke(tint?.opacity(0.55) ?? GA.line, lineWidth: 1.5)
            )
            .clipShape(RoundedRectangle(cornerRadius: GA.radiusControl, style: .continuous))
    }
}
