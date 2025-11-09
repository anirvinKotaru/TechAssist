//
//  AuthenticationViewModel.swift
//  TechAssist2
//
//  Simple Authentication View Model (No Auth0)
//

import Foundation
import Combine
import SwiftUI

class AuthenticationViewModel: ObservableObject {
    @Published var isAuthenticated = true  // Always authenticated for now
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var userEmail: String?
    @Published var userName: String?
    
    init() {
        // Set default user info
        userName = "MICHAEL BERNANDO"
        userEmail = "michael.bernando@nmc2.com"
        isAuthenticated = true
    }
    
    func login() {
        // No-op - authentication removed
        isAuthenticated = true
    }
    
    func logout() {
        // No-op - authentication removed
        isAuthenticated = true
    }
}
