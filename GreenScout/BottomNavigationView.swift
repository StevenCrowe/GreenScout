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
            
            // Search Tab
            SearchView()
                .tabItem {
                    Image(systemName: "magnifyingglass")
                    Text("Calculator")
                }
                .tag(1)
            
            // Chemicals Tab
            ExploreView()
                .tabItem {
                    Image(systemName: "globe")
                    Text("Chemicals")
                }
                .tag(2)
            
            // History Tab
            FavoritesView()
                .tabItem {
                    Image(systemName: "heart")
                    Text("History")
                }
                .tag(3)
            
            
            
            // Settings Tab
            SettingsView()
                .tabItem {
                    Image(systemName: "gearshape")
                    Text("Settings")
                }
                .tag(4)
        }
        .accentColor(.green) // Customize selected tab color
    }
}

// Your app's actual views - replace these with your real content
struct SearchView: View {
    var body: some View {
        NavigationView {
            VStack {
                Text("Search for items here")
                    .font(.title2)
                    .padding()
                
                // Add your search functionality here
                SearchBar()
                
                Spacer()
            }
            .navigationTitle("Search")
        }
    }
}

struct ExploreView: View {
    var body: some View {
        NavigationView {
            VStack {
                Text("Discover new content")
                    .font(.title2)
                    .padding()
                
                // Add your explore content here
                
                Spacer()
            }
            .navigationTitle("Explore")
        }
    }
}

struct FavoritesView: View {
    var body: some View {
        NavigationView {
            VStack {
                Text("Your favorite items")
                    .font(.title2)
                    .padding()
                
                // Add your favorites list here
                
                Spacer()
            }
            .navigationTitle("Favorites")
        }
    }
}

struct ProfileView: View {
    var body: some View {
        NavigationView {
            VStack {
                Text("User Profile")
                    .font(.title2)
                    .padding()
                
                // Add profile information here
                
                Spacer()
            }
            .navigationTitle("Profile")
        }
    }
}

struct SettingsView: View {
    var body: some View {
        NavigationView {
            VStack {
                Text("App Settings")
                    .font(.title2)
                    .padding()
                
                // Add settings options here
                
                Spacer()
            }
            .navigationTitle("Settings")
        }
    }
}

// Sample search bar component
struct SearchBar: View {
    @State private var searchText = ""
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
            
            TextField("Search...", text: $searchText)
                .textFieldStyle(RoundedBorderTextFieldStyle())
        }
        .padding(.horizontal)
    }
}

// Preview
struct BottomNavigationView_Previews: PreviewProvider {
    static var previews: some View {
        BottomNavigationView()
    }
}
