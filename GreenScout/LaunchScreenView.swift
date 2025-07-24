//
//  LaunchScreenView.swift
//  GreenScout
//
//  Custom launch screen view
//

import SwiftUI

struct LaunchScreenView: View {
    @State private var isActive = false
    @State private var opacity = 1.0
    
    var body: some View {
        ZStack {
            ContentView()
                .opacity(isActive ? 1 : 0)
            
            ZStack {
                // Background color to match splash screen edges
                Color.green // You can adjust this to match your splash screen's edge color
                    .ignoresSafeArea()
                
                GeometryReader { geometry in
                    Image("LaunchScreen")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(minWidth: geometry.size.width, minHeight: geometry.size.height)
                        .scaleEffect(1.02) // 2% larger
                        .clipped()
                }
                .ignoresSafeArea()
            }
            .opacity(opacity)
            .onAppear {
                // Wait for 1.5 seconds, then fade out splash screen
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    withAnimation(.easeInOut(duration: 0.5)) {
                        self.opacity = 0
                        self.isActive = true
                    }
                }
            }
        }
    }
}

struct LaunchScreenView_Previews: PreviewProvider {
    static var previews: some View {
        LaunchScreenView()
    }
}
