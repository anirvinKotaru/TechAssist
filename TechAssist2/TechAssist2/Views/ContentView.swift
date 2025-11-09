//
//  ContentView.swift
//  TechAssist2
//
//  Main Navigation View
//

import SwiftUI
import UIKit

struct ContentView: View {
    @StateObject private var firebaseService = FirebaseService.shared
    @EnvironmentObject var authViewModel: AuthenticationViewModel
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            DashboardView()
                .tabItem {
                    Image(systemName: "house")
                    Text("Home")
                }
                .tag(0)
            
            WorkOrderListView()
                .tabItem {
                    Image(systemName: "list.bullet")
                    Text("Orders")
                }
                .tag(1)
            
            SearchView()
                .tabItem {
                    Image(systemName: "magnifyingglass")
                    Text("Search")
                }
                .tag(2)
            
            ProfileView()
                .tabItem {
                    Image(systemName: "person")
                    Text("Profile")
                }
                .tag(3)
        }
        .accentColor(AppTheme.accentPrimary)
        .onAppear {
            // Configure tab bar appearance for dark theme
            let appearance = UITabBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = UIColor(red: 0.08, green: 0.12, blue: 0.18, alpha: 1.0)
            appearance.shadowColor = .clear
            
            // Tab bar item colors
            appearance.stackedLayoutAppearance.normal.iconColor = UIColor(white: 0.6, alpha: 1.0)
            appearance.stackedLayoutAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor(white: 0.6, alpha: 1.0)]
            appearance.stackedLayoutAppearance.selected.iconColor = UIColor(AppTheme.accentPrimary)
            appearance.stackedLayoutAppearance.selected.titleTextAttributes = [.foregroundColor: UIColor(AppTheme.accentPrimary)]
            
            UITabBar.appearance().standardAppearance = appearance
            UITabBar.appearance().scrollEdgeAppearance = appearance
            
            // Fetch work orders from Firebase when view appears
            firebaseService.fetchWorkOrders()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(AuthenticationViewModel())
    }
}
