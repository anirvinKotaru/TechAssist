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
                        VStack(spacing: 16) {
                            Circle()
                                .fill(AppTheme.accentPrimary.opacity(0.1))
                                .frame(width: 90, height: 90)
                                .overlay(
                                    Text(initials)
                                        .font(.system(size: 32, weight: .semibold))
                                        .foregroundColor(AppTheme.accentPrimary)
                                )
                            
                            Text(authViewModel.userName ?? "Technician")
                                .font(.system(size: 22, weight: .semibold))
                                .foregroundColor(AppTheme.textPrimary)
                            
                            if let email = authViewModel.userEmail {
                                Text(email)
                                    .font(.system(size: 15, weight: .regular))
                                    .foregroundColor(AppTheme.textSecondary)
                            }
                            
                            Text("Technician")
                                .font(.system(size: 13, weight: .regular))
                                .foregroundColor(AppTheme.textSecondary)
                        }
                        .padding(.top, 60)
                        
                        // Logout Button
                        Button(action: {
                            authViewModel.logout()
                        }) {
                            HStack {
                                Image(systemName: "arrow.right.square")
                                    .font(.system(size: 16))
                                Text("Sign Out")
                                    .font(.system(size: 15, weight: .medium))
                                Spacer()
                            }
                            .foregroundColor(AppTheme.error)
                            .padding(AppTheme.cardPadding)
                            .background(Color.white)
                            .overlay(
                                RoundedRectangle(cornerRadius: AppTheme.cardCornerRadius)
                                    .stroke(AppTheme.cardBorderColor, lineWidth: 1)
                            )
                            .cornerRadius(AppTheme.cardCornerRadius)
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 40)
                        
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
