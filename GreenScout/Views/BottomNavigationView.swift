//
//  BottomNavigationView.swift
//  GreenScout
//
//  Created by Marketing 2 on 30/7/2025.
//

import SwiftUI

struct BottomNavigationView: View {
    
    @State private var selectedTab = 0
    
    var body: some View {
        
            
            TabView(selection: $selectedTab) {
                // Main/Home Tab - Your existing ContentView
                ContentView()
                    .tabItem {
                        Image("tabbar_camera")
                            .renderingMode(.template)
                        Text("Analyse")
                    }
                    .tag(0)
                
                // Calculator Tab
                ContentView()
                    .tabItem {
                        Image("tabbar_calculator")
                            .renderingMode(.template)
                        Text("Calculator")
                    }
                    .tag(1)
                
                // Chemicals Tab
                ContentView()
                    .tabItem {
                        Image("tabbar_chemicals")
                            .renderingMode(.template)
                        Text("Chemicals")
                    }
                    .tag(2)
                
                // History Tab
                ContentView()
                    .tabItem {
                        Image("tabbar_history")
                            .renderingMode(.template)
                        Text("History")
                    }
                    .tag(3)
                
                // Settings Tab
                ContentView()
                    .tabItem() {
                        Image("tabbar_settings")
                            .renderingMode(.template)
                        Text("Settings")
                    }
                    .tag(4)
            }
        
           
        
            .onAppear {
                        // Test if fonts are loaded
                        AppFonts.printAvailableFonts()
                        
                        // Customize tab bar appearance
                        let appearance = UITabBarAppearance()
                        appearance.configureWithOpaqueBackground()
                        appearance.backgroundColor = UIColor(AppColors.backgroundLight)
                        
                        // Custom Rajdhani font for tab bar labels
                        let customFont = AppFonts.font(name: AppFonts.tabBarFont, size: 12, fallback: .semibold)
                        
                        // Customize unselected (normal) tab items
                        appearance.stackedLayoutAppearance.normal.iconColor = UIColor(AppColors.textPrimary)
                        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [
                            .foregroundColor: UIColor(AppColors.textPrimary),
                            .font: customFont
                        ]
                        
                        // Customize selected tab items
                        appearance.stackedLayoutAppearance.selected.iconColor = UIColor(AppColors.greenGoldacres)
                        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [
                            .foregroundColor: UIColor(AppColors.greenGoldacres),
                            .font: customFont
                            
                        ]
                  
                
                    // Apply the appearance
                    UITabBar.appearance().standardAppearance = appearance
                
              
                }
                
            
        
        //Horizontal line at base of menu
                .overlay(
                    
                VStack {
                    Spacer()
                    Rectangle()
                            .fill(AppColors.greyLine)
                            .frame(height: 2)
                            .offset(y: -60  )
                    
                }
                    .allowsHitTesting(false) // Prevents the overlay from blocking touches
                                
            )
            
        }
    }


// Preview
struct BottomNavigationView_Previews: PreviewProvider {
    static var previews: some View {
        BottomNavigationView()
    }
}
