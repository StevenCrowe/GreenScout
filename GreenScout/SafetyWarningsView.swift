import SwiftUI

struct SafetyWarningsView: View {
    let warnings: [SafetyWarning]

    var body: some View {
        if !warnings.isEmpty {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(.orange)
                    Text("Safety Checks")
                        .font(.headline)
                }

                ForEach(warnings.indices, id: \.self) { index in
                    let warning = warnings[index]
                    HStack(alignment: .top, spacing: 10) {
                        Circle()
                            .fill(warning.severity.color)
                            .frame(width: 8, height: 8)
                            .padding(.top, 6)

                        Text(warning.message)
                            .font(.caption)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }

                if warnings.contains(where: { $0.severity == .critical }) {
                    Text("⚠️ Critical warnings must be addressed before proceeding")
                        .font(.caption)
                        .foregroundColor(.red)
                        .fontWeight(.semibold)
                }
            }
            .padding()
            .background(Color.orange.opacity(0.1))
            .cornerRadius(10)
        }
    }
}

// Compact version for embedding in other views
struct CompactSafetyWarningsView: View {
    let warnings: [SafetyWarning]
    @State private var isExpanded = false
    
    var body: some View {
        if !warnings.isEmpty {
            VStack(alignment: .leading, spacing: 8) {
                Button(action: { isExpanded.toggle() }) {
                    HStack {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundColor(warningColor)
                        Text("\(warnings.count) Safety Warning\(warnings.count > 1 ? "s" : "")")
                            .font(.subheadline)
                            .foregroundColor(.primary)
                        Spacer()
                        Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                            .foregroundColor(.secondary)
                            .font(.caption)
                    }
                }
                
                if isExpanded {
                    VStack(alignment: .leading, spacing: 6) {
                        ForEach(warnings.indices, id: \.self) { index in
                            let warning = warnings[index]
                            HStack(alignment: .top, spacing: 8) {
                                Circle()
                                    .fill(warning.severity.color)
                                    .frame(width: 6, height: 6)
                                    .padding(.top, 5)
                                
                                Text(warning.message)
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                        }
                    }
                    .padding(.leading, 20)
                }
            }
            .padding()
            .background(warningColor.opacity(0.1))
            .cornerRadius(8)
        }
    }
    
    var warningColor: Color {
        if warnings.contains(where: { $0.severity == .critical }) {
            return .red
        } else if warnings.contains(where: { $0.severity == .warning }) {
            return .orange
        } else {
            return .yellow
        }
    }
}

// Preview
struct SafetyWarningsView_Previews: PreviewProvider {
    static var previews: some View {
        let sampleWarnings = [
            SafetyWarning.highWind(speed: 25.0),
            SafetyWarning.excessiveRate(applied: 5.0, maximum: 4.0),
            SafetyWarning.nearWaterSource
        ]
        
        VStack(spacing: 20) {
            SafetyWarningsView(warnings: sampleWarnings)
            
            CompactSafetyWarningsView(warnings: sampleWarnings)
        }
        .padding()
        .previewLayout(.sizeThatFits)
    }
}
