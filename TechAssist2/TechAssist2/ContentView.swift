//
//  ContentView.swift
//  TechAssist2
//
//  Main Navigation View
//

import SwiftUI

struct ContentView: View {
    @StateObject private var firebaseService = FirebaseService.shared
    @EnvironmentObject var authViewModel: AuthenticationViewModel
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            DashboardView()
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Dashboard")
                }
                .tag(0)
            
            WorkOrderListView()
                .tabItem {
                    Image(systemName: "list.bullet")
                    Text("Work Orders")
                }
                .tag(1)
            
            PriorityView()
                .tabItem {
                    Image(systemName: "exclamationmark.triangle.fill")
                    Text("Priority")
                }
                .tag(2)
            
            ProfileView()
                .tabItem {
                    Image(systemName: "person.fill")
                    Text("Profile")
                }
                .tag(3)
        }
        .accentColor(AppTheme.accentPrimary)
        .onAppear {
            // Fetch work orders from Firebase when view appears
            firebaseService.fetchWorkOrders()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(AuthenticationViewModel())
            .preferredColorScheme(.dark)
    }
}
