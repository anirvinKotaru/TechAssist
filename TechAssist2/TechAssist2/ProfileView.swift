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
                                .fill(AppTheme.accentPrimary)
                                .frame(width: 100, height: 100)
                                .overlay(
                                    Text(initials)
                                        .font(.system(size: 36, weight: .bold))
                                        .foregroundColor(.white)
                                )
                            
                            Text(authViewModel.userName ?? "MICHAEL BERNANDO")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(AppTheme.textPrimary)
                            
                            if let email = authViewModel.userEmail {
                                Text(email)
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(AppTheme.textSecondary)
                            }
                            
                            Text("NMC^2 Technician")
                                .font(.system(size: 14, weight: .regular))
                                .foregroundColor(AppTheme.textSecondary)
                        }
                        .padding(.top, 60)
                        
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
            .preferredColorScheme(.dark)
    }
}
