# Auth0 and Firebase Setup Guide

This guide will help you set up Auth0 and Firebase for the TechAssist2 app.

## Prerequisites

1. Auth0 account (free tier available)
2. Firebase account (free tier available)
3. Xcode 14.0 or later

## Step 1: Auth0 Setup

### 1.1 Create Auth0 Application

1. Go to [Auth0 Dashboard](https://manage.auth0.com/)
2. Navigate to **Applications** → **Applications**
3. Click **Create Application**
4. Enter application name: "TechAssist2"
5. Select **Native** as the application type
6. Click **Create**

### 1.2 Configure Auth0 Application

1. In your application settings, note down:
   - **Domain** (e.g., `your-tenant.auth0.com`)
   - **Client ID**

2. Configure **Allowed Callback URLs**:
   - Add: `techassist2://your-tenant.auth0.com/ios/techassist2/callback`

3. Configure **Allowed Logout URLs**:
   - Add: `techassist2://your-tenant.auth0.com/ios/techassist2/callback`

4. Enable **OIDC Conformant** in **Advanced Settings**

### 1.3 Update AuthService.swift

1. Open `TechAssist2/Services/AuthService.swift`
2. Replace the following values:
   ```swift
   private let domain = "YOUR_AUTH0_DOMAIN" // e.g., "your-tenant.auth0.com"
   private let clientId = "YOUR_AUTH0_CLIENT_ID"
   ```
3. In the `login()` method, replace:
   ```swift
   .audience("YOUR_AUTH0_API_AUDIENCE") // Optional: Add if using API
   ```

### 1.4 Configure URL Scheme

1. Open your Xcode project
2. Select your app target
3. Go to **Info** tab
4. Under **URL Types**, click **+**
5. Add URL Scheme: `techassist2`
6. Set Identifier: `techassist2`

## Step 2: Firebase Setup

### 2.1 Create Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click **Add project**
3. Enter project name: "TechAssist2"
4. Follow the setup wizard
5. Enable **Google Analytics** (optional)

### 2.2 Add iOS App to Firebase

1. In Firebase Console, click **Add app** → **iOS**
2. Enter iOS bundle ID (check in Xcode: `com.leosantos.TechAssist2`)
3. Download `GoogleService-Info.plist`
4. Drag `GoogleService-Info.plist` into your Xcode project (under `TechAssist2/TechAssist2/`)
5. Make sure "Copy items if needed" is checked
6. Add it to the target

### 2.3 Configure Firestore Database

1. In Firebase Console, go to **Firestore Database**
2. Click **Create database**
3. Start in **test mode** (for development)
4. Select a location for your database
5. Click **Enable**

### 2.4 Set Up Firestore Security Rules

1. Go to **Firestore Database** → **Rules**
2. Update rules for development (replace with production rules later):
   ```javascript
   rules_version = '2';
   service cloud.firestore {
     match /databases/{database}/documents {
       // Allow read/write access to workOrders collection
       match /workOrders/{workOrderId} {
         allow read, write: if request.auth != null;
       }
       
       // Allow read/write access to users collection
       match /users/{userId} {
         allow read: if request.auth != null;
         allow write: if request.auth != null && request.auth.uid == userId;
       }
     }
   }
   ```

### 2.5 Create Firestore Collections Structure

Create the following collections in Firestore:

1. **workOrders** collection with documents containing:
   - `id` (string)
   - `title` (string)
   - `description` (string)
   - `priority` (string: "CRITICAL", "HIGH", "MEDIUM", "LOW")
   - `status` (string: "Pending", "In Progress", "Completed", "On Hold")
   - `assignedTechnician` (string)
   - `assignedTechnicianId` (string) - Auth0 user ID
   - `createdAt` (timestamp)
   - `dueDate` (timestamp, optional)
   - `timeSpent` (number)
   - `location` (string)
   - `equipment` (string, optional)

2. **users** collection with documents containing:
   - `email` (string)
   - `name` (string)
   - `updatedAt` (timestamp)

## Step 3: Install Dependencies

### 3.1 Add Auth0 SDK

1. In Xcode, go to **File** → **Add Packages**
2. Enter package URL: `https://github.com/auth0/Auth0.swift.git`
3. Select version: **Up to Next Major** with version `2.0.0` or later
4. Click **Add Package**
5. Select **Auth0** library
6. Click **Add Package**

### 3.2 Add Firebase SDK

1. In Xcode, go to **File** → **Add Packages**
2. Enter package URL: `https://github.com/firebase/firebase-ios-sdk.git`
3. Select version: **Up to Next Major** with version `10.0.0` or later
4. Click **Add Package**
5. Select the following libraries:
   - **FirebaseAuth**
   - **FirebaseFirestore**
   - **FirebaseCore**
6. Click **Add Package**

## Step 4: Configure Info.plist

1. Open `Info.plist` (or create if it doesn't exist)
2. Add the following keys:

```xml
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleTypeRole</key>
        <string>Editor</string>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>techassist2</string>
        </array>
    </dict>
</array>
```

## Step 5: Backend Integration (Optional but Recommended)

For production, you'll want to create a backend service that:

1. Exchanges Auth0 tokens for Firebase custom tokens
2. Handles user synchronization between Auth0 and Firebase
3. Manages API authentication

### Backend Endpoint Example

Create an endpoint that accepts Auth0 access tokens and returns Firebase custom tokens:

```
POST /auth/firebase-token
Headers: Authorization: Bearer <auth0_token>
Response: { "firebaseToken": "..." }
```

Then update `FirebaseService.authenticateWithFirebase()` to use this endpoint.

## Step 6: Testing

1. Build and run the app
2. You should see the login screen
3. Click "Sign In with Auth0"
4. Complete the authentication flow
5. After login, you should see the dashboard
6. Work orders should load from Firestore (if data exists)

## Troubleshooting

### Auth0 Issues

- **Callback URL not working**: Check URL scheme in Info.plist and Auth0 dashboard
- **Login not completing**: Verify domain and client ID are correct
- **Token expiration**: Implement token refresh logic

### Firebase Issues

- **GoogleService-Info.plist not found**: Ensure it's added to the target
- **Permission denied**: Check Firestore security rules
- **Data not loading**: Verify Firestore collection structure matches the code

### General Issues

- **Build errors**: Ensure all packages are properly installed
- **Import errors**: Clean build folder (Cmd+Shift+K) and rebuild

## Next Steps

1. Implement token refresh for Auth0
2. Add error handling and retry logic
3. Set up proper Firestore security rules for production
4. Add offline support with Firestore cache
5. Implement push notifications (optional)
6. Add analytics tracking

## Security Notes

- Never commit `GoogleService-Info.plist` or Auth0 credentials to version control
- Use environment variables or secure configuration management
- Implement proper Firestore security rules for production
- Use Firebase App Check for additional security
- Consider using Auth0 Rules/Hooks for user management

## Resources

- [Auth0 Swift SDK Documentation](https://github.com/auth0/Auth0.swift)
- [Firebase iOS Documentation](https://firebase.google.com/docs/ios/setup)
- [Firestore Documentation](https://firebase.google.com/docs/firestore)
- [Auth0 Native Apps Guide](https://auth0.com/docs/quickstart/native/ios-swift)

