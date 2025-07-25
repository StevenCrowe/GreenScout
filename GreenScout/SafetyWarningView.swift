import SwiftUI

struct SafetyWarningView: View {
    let warning: SafetyWarning
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: warning.icon)
                .foregroundColor(warning.severity.color)
                .font(.title2)
            
            Text(warning.message)
                .font(.subheadline)
                .foregroundColor(.primary)
                .multilineTextAlignment(.leading)
            
            Spacer()
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(warning.severity.color.opacity(0.15))
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(warning.severity.color.opacity(0.3), lineWidth: 1)
                )
        )
    }
}

struct SafetyWarningListView: View {
    @ObservedObject var complianceChecker: ComplianceChecker
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            if !complianceChecker.warnings.isEmpty {
                Text("Safety & Compliance Warnings")
                    .font(.headline)
                    .padding(.horizontal)
                
                ScrollView {
                    VStack(spacing: 12) {
                        ForEach(complianceChecker.sortedWarnings, id: \.message) { warning in
                            SafetyWarningView(warning: warning)
                                .padding(.horizontal)
                        }
                    }
                    .padding(.vertical, 8)
                }
                
                if complianceChecker.hasBlockingWarnings {
                    HStack {
                        Image(systemName: "hand.raised.fill")
                            .foregroundColor(.red)
                        Text("Critical warnings must be addressed before proceeding")
                            .font(.caption)
                            .foregroundColor(.red)
                    }
                    .padding(.horizontal)
                }
            }
        }
    }
}

// Preview
struct SafetyWarningView_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            SafetyWarningView(
                warning: .excessiveRate(applied: 5.5, maximum: 4.0)
            )
            
            SafetyWarningView(
                warning: .highWind(speed: 25.0)
            )
            
            SafetyWarningView(
                warning: .restrictedUseProduct
            )
        }
        .padding()
    }
}
