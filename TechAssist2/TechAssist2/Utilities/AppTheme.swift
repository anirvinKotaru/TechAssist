//
//  AppTheme.swift
//  TechAssist2
//
//  Minimalist White Theme Configuration
//

import SwiftUI

struct AppTheme {
    // Minimalist White Background Colors
    static let backgroundPrimary = Color.white
    static let backgroundSecondary = Color(red: 0.98, green: 0.98, blue: 0.98) // Very light gray for subtle cards
    static let backgroundTertiary = Color(red: 0.95, green: 0.95, blue: 0.95)
    
    // Subtle Accent Colors
    static let accentPrimary = Color(red: 0.0, green: 0.45, blue: 0.80) // Soft blue
    static let accentSecondary = Color(red: 0.0, green: 0.5, blue: 0.9)
    static let accentTertiary = Color(red: 0.1, green: 0.6, blue: 0.95)
    
    // Dark Text Colors for White Background
    static let textPrimary = Color(red: 0.1, green: 0.1, blue: 0.1) // Near black
    static let textSecondary = Color(red: 0.4, green: 0.4, blue: 0.4) // Medium gray
    static let textTertiary = Color(red: 0.6, green: 0.6, blue: 0.6) // Light gray
    
    // Status Colors (softer for minimalist design)
    static let success = Color(red: 0.2, green: 0.7, blue: 0.3)
    static let warning = Color(red: 0.95, green: 0.7, blue: 0.0)
    static let error = Color(red: 0.9, green: 0.25, blue: 0.25)
    
    // Minimalist Card Style
    static let cardCornerRadius: CGFloat = 12
    static let cardPadding: CGFloat = 16
    static let cardBorderColor = Color(red: 0.9, green: 0.9, blue: 0.9) // Subtle border
}


