//
//  SettingsView.swift
//  GreenScout
//
//  Placeholder view for app settings
//

import SwiftUI

struct SettingsView: View {
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Image(systemName: "gearshape.2")
                    .font(.system(size: 60))
                    .foregroundColor(AppColors.textSecondary)
                
                Text("Settings")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Text("App settings and preferences will be available here")
                    .font(.body)
                    .foregroundColor(AppColors.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                Spacer()
            }
            .padding(.top, 40)
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
