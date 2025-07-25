import SwiftUI

enum SafetyWarning: Equatable {
    case excessiveRate(applied: Double, maximum: Double)
    case highWind(speed: Double)
    case highTemperature(temp: Double)
    case restrictedUseProduct
    case nearWaterSource
    case preHarvestInterval(days: Int)
    
    var message: String {
        switch self {
        case .excessiveRate(let applied, let maximum):
            return String(format: "Application rate (%.2f L/ha) exceeds maximum recommended rate (%.2f L/ha)", applied, maximum)
        case .highWind(let speed):
            return String(format: "Wind speed (%.1f km/h) may cause drift. Consider postponing application.", speed)
        case .highTemperature(let temp):
            return String(format: "High temperature (%.1f°C) may reduce effectiveness and increase volatilization.", temp)
        case .restrictedUseProduct:
            return "This is a restricted use product. Ensure proper licensing and application procedures."
        case .nearWaterSource:
            return "Buffer zones required near water sources. Check local regulations."
        case .preHarvestInterval(let days):
            return "Pre-harvest interval: \(days) days. Do not harvest before this period."
        }
    }
    
    var severity: WarningSeverity {
        switch self {
        case .excessiveRate, .restrictedUseProduct:
            return .critical
        case .highWind, .nearWaterSource, .preHarvestInterval:
            return .warning
        case .highTemperature:
            return .caution
        }
    }
    
    var icon: String {
        switch severity {
        case .critical:
            return "exclamationmark.octagon.fill"
        case .warning:
            return "exclamationmark.triangle.fill"
        case .caution:
            return "exclamationmark.circle.fill"
        }
    }
}

enum WarningSeverity {
    case critical, warning, caution
    
    var color: Color {
        switch self {
        case .critical: 
            return .red
        case .warning: 
            return .orange
        case .caution: 
            return .yellow
        }
    }
}
