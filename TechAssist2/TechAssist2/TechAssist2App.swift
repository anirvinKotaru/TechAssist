//
//  TechAssist2App.swift
//  TechAssist2
//
//  Created by Leo Santos on 11/8/25.
//

import SwiftUI
import FirebaseCore

@main
struct TechAssist2App: App {
    @StateObject private var authViewModel = AuthenticationViewModel()
    
    init() {
        // Initialize Firebase
        FirebaseApp.configure()
        
        // Initialize FirebaseService
        FirebaseService.shared.initialize()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(authViewModel)
        }
    }
}
