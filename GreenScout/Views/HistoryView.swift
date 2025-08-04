//
//  HistoryView.swift
//  GreenScout
//
//  Placeholder view for displaying analysis history
//

import SwiftUI

struct HistoryView: View {
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Image(systemName: "clock.arrow.circlepath")
                    .font(.system(size: 60))
                    .foregroundColor(AppColors.textSecondary)
                
                Text("Analysis History")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Text("Your previous field analyses will appear here")
                    .font(.body)
                    .foregroundColor(AppColors.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                Spacer()
            }
            .padding(.top, 40)
            .navigationTitle("History")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

struct HistoryView_Previews: PreviewProvider {
    static var previews: some View {
        HistoryView()
    }
}
