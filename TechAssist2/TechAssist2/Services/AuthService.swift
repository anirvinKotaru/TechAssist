//
//  AuthService.swift
//  TechAssist2
//
//  Simple Auth0 Authentication Service
//

import Foundation
import Combine
import Auth0

class AuthService: ObservableObject {
    @Published var isAuthenticated = false
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var userEmail: String?
    @Published var userName: String?
    
    // MARK: - Auth0 Configuration
    
    /// Auth0 Domain - Your Auth0 tenant domain
    /// Format: {tenant}.auth0.com or {tenant}.us.auth0.com
    private let domain = "dev-frosjzi3e85zszxa.us.auth0.com"
    
    /// Auth0 Client ID - Your application's client identifier
    /// Found in Auth0 Dashboard → Applications → Your App
    private let clientId = "JNpxt8bUAJCYFnsaOhr8hv3yGee42fi1"
    
    /// Bundle Identifier - Your app's bundle ID
    /// Used to construct the callback/redirect URL
    /// Must match your Xcode project's bundle identifier
    private let bundleId = "com.leosantos.TechAssist2"
    
    /// URL Scheme - Must match Info.plist CFBundleURLSchemes
    /// This is the custom URL scheme that allows Auth0 to redirect back to the app
    /// Configured in Info.plist under CFBundleURLTypes → CFBundleURLSchemes
    private let urlScheme = "techassist2"
    
    /// Callback/Redirect URL - Where Auth0 redirects after authentication
    /// Format: {scheme}://{domain}/ios/{bundleId}/callback
    /// 
    /// This URL is:
    /// 1. Automatically constructed by Auth0 SDK from URL scheme, domain, and bundle ID
    /// 2. Explicitly set here for clarity and to ensure consistency
    /// 3. Must be added to Auth0 Dashboard → Applications → Allowed Callback URLs
    /// 4. Must match exactly in Auth0 Dashboard (including scheme, domain, and bundle ID)
    /// 
    /// Example: techassist2://dev-frosjzi3e85zszxa.us.auth0.com/ios/com.leosantos.TechAssist2/callback
    private var redirectURL: URL {
        let urlString = "\(urlScheme)://\(domain)/ios/\(bundleId)/callback"
        guard let url = URL(string: urlString) else {
            fatalError("Invalid redirect URL: \(urlString)")
        }
        return url
    }
    
    /// Credentials Manager - Handles secure storage of Auth0 tokens
    /// Uses iOS Keychain to store credentials securely
    private var credentialsManager: CredentialsManager?
    
    // MARK: - Initialization
    
    init() {
        // Initialize Auth0 authentication client
        let auth = Auth0.authentication(clientId: clientId, domain: domain)
        
        // Initialize credentials manager for secure token storage
        credentialsManager = CredentialsManager(authentication: auth)
        
        // Check if user is already authenticated (e.g., from previous session)
        checkAuthenticationStatus()
    }
    
    // MARK: - Login
    
    /// Initiates Auth0 WebAuth login flow
    /// Opens Auth0 login page in Safari/WebView
    /// On success, stores credentials and retrieves user info
    /// 
    /// Flow:
    /// 1. Clears any existing credentials (allows account switching)
    /// 2. Opens Auth0 login page in browser/webview
    /// 3. User authenticates with Auth0
    /// 4. Auth0 redirects back to app using the redirectURL
    /// 5. App receives callback URL and processes credentials
    /// 6. Credentials are stored securely in Keychain
    /// 
    /// Requirements:
    /// - URL scheme must be configured in Info.plist (CFBundleURLSchemes)
    /// - Redirect URL must be added to Auth0 Dashboard → Allowed Callback URLs
    /// - App must handle incoming URL in TechAssist2App.swift using .onOpenURL
    func login() {
        isLoading = true
        errorMessage = nil
        
        // IMPORTANT: Clear existing credentials before starting new login
        // This allows users to switch accounts. Without this, Auth0 might automatically
        // log in with the previously stored account, preventing account switching.
        // By clearing credentials first, we force a fresh login flow each time.
        if isAuthenticated {
            _ = credentialsManager?.clear()
            isAuthenticated = false
            userEmail = nil
            userName = nil
        }
        
        // Start Auth0 WebAuth flow
        // This opens a browser/webview for user authentication
        Auth0
            .webAuth(clientId: clientId, domain: domain)
            // Explicitly set the redirect/callback URL
            // This URL tells Auth0 where to redirect the user after successful authentication
            // Format: {scheme}://{domain}/ios/{bundleId}/callback
            // This MUST match exactly what's configured in Auth0 Dashboard → Allowed Callback URLs
            // Example: techassist2://dev-frosjzi3e85zszxa.us.auth0.com/ios/com.leosantos.TechAssist2/callback
            .redirectURL(redirectURL)
            // Use ephemeral session to prevent reusing cached browser sessions
            // This is critical for account switching: without this, the browser might
            // automatically log in with a previously used account, preventing users from
            // switching to a different account. Ephemeral sessions don't persist cookies,
            // forcing a fresh login each time.
            .useEphemeralSession()
            // Request user profile and email information
            // "openid" - Required for OpenID Connect
            // "profile" - User's profile information (name, picture, etc.)
            // "email" - User's email address
            .scope("openid profile email")
            // Start the authentication flow
            // When user completes login, Auth0 will redirect to redirectURL
            // The app must handle this URL in TechAssist2App.swift using .onOpenURL
            .start { [weak self] result in
                DispatchQueue.main.async {
                    self?.isLoading = false
                    switch result {
                    case .success(let credentials):
                        // Authentication successful!
                        // Store credentials securely in iOS Keychain via CredentialsManager
                        // This allows the app to remain authenticated across app launches
                        _ = self?.credentialsManager?.store(credentials: credentials)
                        self?.isAuthenticated = true
                        // Retrieve user profile information (email, name, etc.)
                        self?.retrieveUserInfo()
                    case .failure(let error):
                        // Handle login errors
                        // Common errors:
                        // - "Callback URL mismatch" - redirectURL doesn't match Auth0 Dashboard configuration
                        // - "User cancelled" - user cancelled the login flow
                        // - Network errors - unable to connect to Auth0
                        self?.errorMessage = error.localizedDescription
                        self?.isAuthenticated = false
                    }
                }
            }
    }
    
    // MARK: - Logout
    
    /// Logs out the current user
    /// Clears stored credentials from Keychain and resets authentication state
    /// 
    /// This function:
    /// 1. Clears credentials from iOS Keychain (local storage)
    /// 2. Resets all authentication state (isAuthenticated, userEmail, userName)
    /// 3. After logout, user will see the login screen
    /// 4. User can then log in with a different account if desired
    /// 
    /// Note: This clears local credentials. The Auth0 server-side session
    /// will be cleared on the next login attempt due to .useEphemeralSession()
    func logout() {
        // Clear credentials from secure storage (iOS Keychain)
        // This removes the stored access token, refresh token, and ID token
        // After this, the user will need to log in again
        _ = credentialsManager?.clear()
        
        // Reset authentication state
        // This ensures the UI updates to show the login screen
        // and clears any displayed user information
        isAuthenticated = false
        userEmail = nil
        userName = nil
    }
    
    // MARK: - Check Authentication Status
    
    /// Checks if user is already authenticated (e.g., from previous session)
    /// Validates stored credentials and retrieves user info if valid
    /// Called on app launch to restore user session
    private func checkAuthenticationStatus() {
        guard let credentialsManager = credentialsManager else { return }
        
        // Check if valid credentials exist in Keychain
        guard credentialsManager.hasValid() else {
            isAuthenticated = false
            return
        }
        
        // Retrieve stored credentials
        credentialsManager.credentials { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    // Credentials are valid, user is authenticated
                    self?.isAuthenticated = true
                    // Retrieve user profile information
                    self?.retrieveUserInfo()
                case .failure:
                    // Credentials are invalid or expired
                    self?.isAuthenticated = false
                }
            }
        }
    }
    
    // MARK: - Retrieve User Info
    
    /// Retrieves user profile information from Auth0
    /// Fetches email, name, and other profile data
    /// Called after successful authentication
    private func retrieveUserInfo() {
        guard let credentialsManager = credentialsManager else { return }
        
        // Get stored credentials (includes access token)
        credentialsManager.credentials { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let credentials):
                // Use access token to fetch user profile from Auth0
                Auth0
                    .authentication(clientId: self.clientId, domain: self.domain)
                    .userInfo(withAccessToken: credentials.accessToken ?? "")
                    .start { userInfoResult in
                        DispatchQueue.main.async {
                            switch userInfoResult {
                            case .success(let profile):
                                // Update user information
                                self.userEmail = profile.email
                                
                                // Extract name from profile with multiple fallback strategies
                                // 1. Try full name (name field)
                                // 2. Try constructing from given_name + family_name
                                // 3. Try nickname
                                // 4. Try email local part (before @) as display name
                                // 5. Fallback to full email
                                if let name = profile.name, !name.isEmpty {
                                    self.userName = name
                                } else if let givenName = profile.givenName, let familyName = profile.familyName {
                                    self.userName = "\(givenName) \(familyName)"
                                } else if let givenName = profile.givenName {
                                    self.userName = givenName
                                } else if let nickname = profile.nickname, !nickname.isEmpty {
                                    self.userName = nickname
                                } else if let email = profile.email {
                                    // Extract display name from email (part before @)
                                    let emailParts = email.components(separatedBy: "@")
                                    if let localPart = emailParts.first, !localPart.isEmpty {
                                        // Capitalize first letter and replace dots/underscores with spaces
                                        let displayName = localPart
                                            .replacingOccurrences(of: ".", with: " ")
                                            .replacingOccurrences(of: "_", with: " ")
                                            .replacingOccurrences(of: "-", with: " ")
                                            .split(separator: " ")
                                            .map { $0.capitalized }
                                            .joined(separator: " ")
                                        self.userName = displayName.isEmpty ? email : displayName
                                    } else {
                                        self.userName = email
                                    }
                                } else {
                                    self.userName = nil
                                }
                            case .failure(let error):
                                // Log error but don't break authentication flow
                                print("Error retrieving user info: \(error.localizedDescription)")
                            }
                        }
                    }
            case .failure:
                // Credentials retrieval failed
                break
            }
        }
    }
}

