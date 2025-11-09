//
//  AppTheme.swift
//  TechAssist2
//
//  NMC^2 Brand Colors and Theme Configuration
//

import SwiftUI

struct AppTheme {
    // Dark Background Colors
    static let backgroundPrimary = Color(red: 0.11, green: 0.11, blue: 0.12) // #1C1C1E equivalent
    static let backgroundSecondary = Color(red: 0.17, green: 0.17, blue: 0.18) // Slightly lighter for cards
    static let backgroundTertiary = Color(red: 0.22, green: 0.22, blue: 0.24)
    
    // NMC^2 Brand Colors (adjust these based on actual brand colors)
    // Using professional blue/teal as default - replace with actual NMC^2 colors
    static let accentPrimary = Color(red: 0.0, green: 0.6, blue: 0.8) // Professional blue
    static let accentSecondary = Color(red: 0.0, green: 0.7, blue: 0.9) // Lighter blue
    static let accentTertiary = Color(red: 0.2, green: 0.8, blue: 1.0) // Bright cyan
    
    // Text Colors
    static let textPrimary = Color.white
    static let textSecondary = Color(red: 0.7, green: 0.7, blue: 0.7)
    static let textTertiary = Color(red: 0.5, green: 0.5, blue: 0.5)
    
    // Status Colors
    static let success = Color(red: 0.2, green: 0.8, blue: 0.4)
    static let warning = Color(red: 1.0, green: 0.84, blue: 0.0)
    static let error = Color(red: 1.0, green: 0.3, blue: 0.3)
    
    // Card Style
    static let cardCornerRadius: CGFloat = 16
    static let cardPadding: CGFloat = 16
}


