# Quick Start Guide - Auth0 & Firebase Integration

## Prerequisites Checklist

- [ ] Auth0 account created
- [ ] Firebase project created
- [ ] Xcode 14.0 or later
- [ ] iOS 15.0+ deployment target

## Step 1: Install Dependencies (5 minutes)

### Add Auth0 SDK
1. In Xcode: **File** → **Add Packages**
2. URL: `https://github.com/auth0/Auth0.swift.git`
3. Version: **Up to Next Major** (2.0.0+)
4. Select: **Auth0** library

### Add Firebase SDK
1. In Xcode: **File** → **Add Packages**
2. URL: `https://github.com/firebase/firebase-ios-sdk.git`
3. Version: **Up to Next Major** (10.0.0+)
4. Select:
   - **FirebaseAuth**
   - **FirebaseFirestore**
   - **FirebaseCore**

## Step 2: Configure Auth0 (10 minutes)

1. **Get Auth0 Credentials:**
   - Go to [Auth0 Dashboard](https://manage.auth0.com/)
   - Create Native application
   - Copy **Domain** and **Client ID**

2. **Update AuthService.swift:**
   ```swift
   private let domain = "your-tenant.auth0.com"
   private let clientId = "your_client_id_here"
   ```

3. **Configure Callback URLs:**
   - In Auth0 Dashboard → Application Settings
   - Allowed Callback URLs: `techassist2://your-tenant.auth0.com/ios/techassist2/callback`
   - Allowed Logout URLs: `techassist2://your-tenant.auth0.com/ios/techassist2/callback`

4. **Add URL Scheme in Xcode:**
   - Target → Info → URL Types
   - Add: `techassist2`

## Step 3: Configure Firebase (10 minutes)

1. **Download GoogleService-Info.plist:**
   - Go to [Firebase Console](https://console.firebase.google.com/)
   - Add iOS app with bundle ID: `com.leosantos.TechAssist2`
   - Download `GoogleService-Info.plist`

2. **Add to Xcode:**
   - Drag `GoogleService-Info.plist` into `TechAssist2/TechAssist2/`
   - Check "Copy items if needed"
   - Add to target

3. **Set Up Firestore:**
   - Firebase Console → Firestore Database
   - Create database in test mode
   - Set security rules (see SETUP_AUTH0_FIREBASE.md)

## Step 4: Test (5 minutes)

1. Build and run the app
2. You should see the login screen
3. Click "Sign In with Auth0"
4. Complete authentication
5. Dashboard should appear with work orders

## Common Issues

### "Firebase not initialized"
- Ensure `GoogleService-Info.plist` is in the project and added to target
- Check that `FirebaseApp.configure()` is called in `TechAssist2App.swift`

### "Auth0 login not working"
- Verify domain and client ID in `AuthService.swift`
- Check URL scheme is set in Info.plist
- Verify callback URLs in Auth0 Dashboard

### "No data loading"
- Check Firestore security rules allow reads
- Verify collection name is `workOrders`
- Check Firestore console for data

## Next Steps

1. Read `SETUP_AUTH0_FIREBASE.md` for detailed configuration
2. Set up production Firestore security rules
3. Implement token refresh
4. Add error handling and retry logic

## File Structure

```
TechAssist2/
├── Services/
│   ├── AuthService.swift          # Auth0 authentication
│   └── FirebaseService.swift      # Firebase data management
├── ViewModels/
│   └── AuthenticationViewModel.swift
├── Views/
│   └── LoginView.swift
└── TechAssist2App.swift           # App entry point
```

## Support

- [Auth0 Swift SDK Docs](https://github.com/auth0/Auth0.swift)
- [Firebase iOS Docs](https://firebase.google.com/docs/ios/setup)
- See `SETUP_AUTH0_FIREBASE.md` for detailed setup

