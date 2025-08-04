//
//  FontDebugView.swift
//  GreenScout
//
//  Debug view to test font loading
//

import SwiftUI

struct FontDebugView: View {
    @State private var fontLoadingStatus: String = "Checking fonts..."
    @State private var rajdhaniFonts: [String] = []
    @State private var rajdhaniFound = false
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Font Debug View")
                .font(.largeTitle)
                .padding()
            
            Text(fontLoadingStatus)
                .font(.caption)
                .foregroundColor(AppColors.textSecondary)
                .padding(.horizontal)
            
            Group {
                Text("Rajdhani Light")
                    .font(.custom("Rajdhani-Light", size: 20))
                
                Text("Rajdhani Regular")
                    .font(.custom("Rajdhani-Regular", size: 20))
                
                Text("Rajdhani Medium")
                    .font(.custom("Rajdhani-Medium", size: 20))
                
                Text("Rajdhani SemiBold")
                    .font(.custom("Rajdhani-SemiBold", size: 20))
                
                Text("Rajdhani Bold")
                    .font(.custom("Rajdhani-Bold", size: 20))
            }
            
            Divider()
            
            Text("Available Fonts:")
                .font(.headline)
            
            if rajdhaniFound {
                Text("Found PostScript Names:")
                    .font(.headline)
                    .padding(.top)
                
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(rajdhaniFonts.sorted(), id: \.self) { fontName in
                        HStack {
                            Text(fontName)
                                .font(.system(.body, design: .monospaced))
                                .foregroundColor(.blue)
                            Spacer()
                            Text("Use in: Font.custom(\"\(fontName)\", size: X)")
                                .font(.caption)
                                .foregroundColor(AppColors.textSecondary)
                        }
                        .padding(.horizontal)
                    }
                }
                .padding(.vertical)
            }
            
            ScrollView {
                ForEach(UIFont.familyNames.sorted(), id: \.self) { family in
                    if family.contains("Rajdhani") {
                        VStack(alignment: .leading) {
                            Text(family)
                                .font(.headline)
                            ForEach(UIFont.fontNames(forFamilyName: family), id: \.self) { font in
                                Text(font)
                                    .font(.caption)
                            }
                        }
                        .padding(.horizontal)
                    }
                }
            }
            .frame(maxHeight: 200)
            
            Spacer()
        }
        .onAppear {
            // Diagnostic snippet for Rajdhani fonts
            print("\n=== Rajdhani Font Diagnostic ===")
            UIFont.familyNames.filter { $0.contains("Rajdhani") }.forEach { family in
                print("Family: \(family) — \(UIFont.fontNames(forFamilyName: family))")
            }
            print("=== End Rajdhani Diagnostic ===\n")
            
            // Print all font families for reference
            print("All font families:")
            for family in UIFont.familyNames.sorted() {
                print("Family: \(family)")
                for font in UIFont.fontNames(forFamilyName: family) {
                    print("  - \(font)")
                }
            }
            
            // Update state based on findings
            let rajdhaniFamilies = UIFont.familyNames.filter { $0.contains("Rajdhani") }
            if !rajdhaniFamilies.isEmpty {
                rajdhaniFound = true
                fontLoadingStatus = "Rajdhani fonts loaded successfully"
                rajdhaniFamilies.forEach { family in
                    rajdhaniFonts.append(contentsOf: UIFont.fontNames(forFamilyName: family))
                }
            } else {
                fontLoadingStatus = "Warning: Rajdhani fonts not found"
            }
        }
    }
}

struct FontDebugView_Previews: PreviewProvider {
    static var previews: some View {
        FontDebugView()
    }
}
