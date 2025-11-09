//
//  ProfileView.swift
//  TechAssist2
//
//  Profile View
//

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var authViewModel: AuthenticationViewModel
    
    var initials: String {
        guard let name = authViewModel.userName else {
            return "MB"
        }
        let components = name.components(separatedBy: " ")
        if components.count >= 2 {
            return String(components[0].prefix(1)) + String(components[1].prefix(1))
        } else if !components.isEmpty {
            return String(components[0].prefix(2)).uppercased()
        }
        return "MB"
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                AppTheme.backgroundPrimary.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Profile Header
                        VStack(spacing: 12) {
                            Image(AppTheme.appLogo)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 60, height: 60)
                            
                            // Show name as primary identifier, fallback to email if name not available
                            Text(authViewModel.userName ?? authViewModel.userEmail ?? "Technician")
                                .font(.system(size: 18, weight: .medium))
                                .foregroundColor(AppTheme.textPrimary)
                            
                            // Show email below name if name exists, otherwise hide this
                            if authViewModel.userName != nil, let email = authViewModel.userEmail {
                                Text(email)
                                    .font(.system(size: 14, weight: .regular))
                                    .foregroundColor(AppTheme.textSecondary)
                            }
                        }
                        .padding(.top, 32)
                        
                        // Logout Button
                        Button(action: {
                            authViewModel.logout()
                        }) {
                            Text("Sign Out")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(AppTheme.error)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(AppTheme.backgroundSecondary)
                                .cornerRadius(AppTheme.cardCornerRadius)
                                .overlay(
                                    RoundedRectangle(cornerRadius: AppTheme.cardCornerRadius)
                                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                                )
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 24)
                        
                        Spacer()
                    }
                }
            }
            .navigationBarHidden(true)
        }
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
            .environmentObject(AuthenticationViewModel())
    }
}
