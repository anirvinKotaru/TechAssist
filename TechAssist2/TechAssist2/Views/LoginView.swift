//
//  LoginView.swift
//  TechAssist2
//
//  Simple Login View with Auth0
//

import SwiftUI

struct LoginView: View {
    @ObservedObject var viewModel: AuthenticationViewModel
    @State private var showError = false
    
    var body: some View {
        ZStack {
            // Dark blue gradient background
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.1, green: 0.15, blue: 0.25),
                    Color(red: 0.05, green: 0.1, blue: 0.2),
                    Color(red: 0.0, green: 0.05, blue: 0.15)
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                Spacer()
                
                // Logo and App Name
                VStack(spacing: 16) {
                    // Logo with fallback
                    Group {
                        if UIImage(named: AppTheme.appLogo) != nil {
                            Image(AppTheme.appLogo)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 70, height: 70)
                                .foregroundColor(.white)
                        } else {
                            // Fallback icon if logo not found
                            Image(systemName: "wrench.and.screwdriver")
                                .font(.system(size: 50))
                                .foregroundColor(.white)
                        }
                    }
                    
                    Text("TechAssist")
                        .font(.system(size: 28, weight: .semibold))
                        .foregroundColor(.white)
                }
                .padding(.bottom, 40)
                
                // Login Button
                Button(action: {
                    viewModel.login()
                }) {
                    if viewModel.isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    } else {
                        Text("Sign In")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                    }
                }
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color(red: 0.2, green: 0.4, blue: 0.8),
                            Color(red: 0.1, green: 0.3, blue: 0.7)
                        ]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .foregroundColor(.white)
                .cornerRadius(10)
                .shadow(color: Color.black.opacity(0.3), radius: 8, x: 0, y: 4)
                .disabled(viewModel.isLoading)
                .padding(.horizontal, 32)
                
                // Error Message
                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .font(.system(size: 13))
                        .foregroundColor(.red.opacity(0.9))
                        .padding(.horizontal, 32)
                        .padding(.top, 16)
                        .multilineTextAlignment(.center)
                }
                
                Spacer()
            }
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView(viewModel: AuthenticationViewModel())
    }
}

