//
//  AppTheme.swift
//  TechAssist2
//
//  Dark Blue Theme Configuration
//

import SwiftUI

struct AppTheme {
    // Dark Blue Background Colors
    static let backgroundPrimary = Color(red: 0.08, green: 0.12, blue: 0.18)
    static let backgroundSecondary = Color(red: 0.12, green: 0.16, blue: 0.22)
    static let backgroundTertiary = Color(red: 0.15, green: 0.19, blue: 0.25)
    
    // Professional Accent Color (Bright Blue)
    static let accentPrimary = Color(red: 0.2, green: 0.4, blue: 0.8)
    
    // Professional Text Colors (Light for dark background)
    static let textPrimary = Color.white
    static let textSecondary = Color(red: 0.7, green: 0.7, blue: 0.75)
    
    // Status Colors
    static let success = Color(red: 0.3, green: 0.75, blue: 0.4)
    static let warning = Color(red: 1.0, green: 0.7, blue: 0.2)
    static let error = Color(red: 0.9, green: 0.3, blue: 0.3)
    
    // Card Style
    static let cardCornerRadius: CGFloat = 12
    static let cardPadding: CGFloat = 16
    
    // App Logo
    static let appLogo = "AppLogo"
    
    // Gradient Helper
    static var darkGradient: LinearGradient {
        LinearGradient(
            gradient: Gradient(colors: [
                Color(red: 0.1, green: 0.15, blue: 0.25),
                Color(red: 0.05, green: 0.1, blue: 0.2),
                Color(red: 0.0, green: 0.05, blue: 0.15)
            ]),
            startPoint: .top,
            endPoint: .bottom
        )
    }
}


