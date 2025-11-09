# TechAssist2 🔧

> A data center technician's best friend - work order management meets instant troubleshooting guides, all at the scan of a QR code.

## 🎯 The Problem We Solved

Data center technicians waste precious minutes searching for work orders and troubleshooting guides when critical systems are down. Every second of downtime costs thousands of dollars. We built TechAssist2 to give technicians instant access to everything they need - work orders, equipment details, and step-by-step troubleshooting guides - all through a simple QR code scan.

## 💡 What We Built

TechAssist2 is an iOS app built with SwiftUI that streamlines data center operations:

- **Real-time Work Order Management** - View, track, and update work orders with priority-based organization
- **QR Code Scanning** - Scan equipment QR codes to instantly pull up work orders or troubleshooting articles
- **Troubleshooting Library** - 5 comprehensive guides covering PSU failures, CRAC systems, network infrastructure, server hardware, and UPS power systems
- **Real-time Sync** - Firebase integration ensures all technicians see updates instantly
- **Secure Authentication** - Auth0 integration for secure, enterprise-ready authentication

## Key Features

### Dashboard
- Real-time work order tracking with priority indicators
- Quick metrics: open orders, critical issues, completed today
- One-tap QR code scanning for instant access

### QR Code Integration
- Scan equipment QR codes to pull up work orders instantly
- Scan troubleshooting article QR codes (PSU, CRAC, NETWORK, SERVER, UPS) for instant guides
- No more manual searching - everything is one scan away

### Example Troubleshooting Articles
- **PSU Failures** - Power supply unit troubleshooting
- **CRAC Systems** - Cooling system failure guides
- **Network Infrastructure** - Switch, router, and connectivity issues
- **Server Hardware** - CPU, RAM, disk, and component failures
- **UPS Power** - Battery, power distribution, and backup systems

### Work Order Management
- Priority-based organization (Critical, High, Medium, Low)
- Detailed work order views with location, impact metrics, and required tools
- Real-time status updates
- SLA breach tracking

##  Tech Stack

- **SwiftUI** - Modern iOS UI framework
- **Firebase/Firestore** - Real-time database and cloud services
- **Auth0** - Enterprise authentication
- **AVFoundation** - QR code scanning
- **MVVM Architecture** - Clean, maintainable code structure

##  Our Journey & Challenges

#### Git Merging

One of our biggest challenges was managing Git merges when working as a team. We ran into a classic problem: **merge conflicts that created file duplication nightmares**. 

We were all working on different features - one person on authentication, another on the QR scanner, and someone else on the work order views. When it came time to merge our branches, Git got confused. Files ended up nested inside each other, creating this bizarre loop.

This experience taught us that Git is powerful, but with great power comes great responsibility (and the occasional merge conflict).

#### Other Challenges We Faced

- **QR Code Format Standardization** - Figuring out the right format for QR codes that would work for both work orders and troubleshooting articles
- **Real-time Sync Timing** - Getting Firebase real-time updates to work smoothly without overwhelming the UI
- **Auth0 Callback URLs** - Getting the callback URLs just right (this took way longer than it should have)
- **SwiftUI State Management** - Learning when to use `@State`, `@ObservedObject`, and `@EnvironmentObject`

### What We Learned

1. **Git is your friend, but only if you understand it** - Take time to learn Git properly before working in a team
2. **Communication is key** - Regular sync-ups prevent merge conflicts
3. **Test incrementally** - Don't wait until the end to test your integrations
4. **Documentation saves time** - Writing things down helps when you're stuck
5. **Ask for help** - Stack Overflow and documentation are your friends

## Getting Started

### Prerequisites

- Xcode 14.0 or later
- iOS 15.0+ deployment target
- Auth0 account (free tier available)
- Firebase account (free tier available)

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd TechAssist2
   ```

2. **Install Dependencies**

   Add these Swift packages in Xcode:
   - **Auth0**: `https://github.com/auth0/Auth0.swift.git`
   - **Firebase iOS SDK**: `https://github.com/firebase/firebase-ios-sdk.git`
     - Select: FirebaseAuth, FirebaseFirestore, FirebaseCore

3. **Configure Auth0**

   - Create a Native application in [Auth0 Dashboard](https://manage.auth0.com/)
   - Get your Domain and Client ID
   - Update `TechAssist2/Services/AuthService.swift`:
     ```swift
     private let domain = "your-tenant.auth0.com"
     private let clientId = "your_client_id_here"
     ```
   - Configure Callback URLs in Auth0 Dashboard:
     ```
     techassist2://your-tenant.auth0.com/ios/techassist2/callback
     ```
   - Add URL scheme in Xcode: Target → Info → URL Types → Add `techassist2`

4. **Configure Firebase**

   - Create a Firebase project in [Firebase Console](https://console.firebase.google.com/)
   - Add iOS app with bundle ID: `com.leosantos.TechAssist2`
   - Download `GoogleService-Info.plist`
   - Drag it into `TechAssist2/TechAssist2/` in Xcode
   - Set up Firestore Database in test mode
   - Create `workOrders` collection

5. **Build and Run**

   ```bash
   open TechAssist2.xcodeproj
   # Build and run in Xcode
   ```

##  Usage

### For Technicians

1. **Login** - Use Auth0 authentication to log in
2. **View Dashboard** - See all open work orders with priorities
3. **Scan QR Codes** - Use the QR scanner to instantly access:
   - Work orders by scanning equipment QR codes
   - Troubleshooting articles by scanning article QR codes (PSU, CRAC, NETWORK, SERVER, UPS)
4. **Search Articles** - Use the Search tab to find troubleshooting guides
5. **Update Work Orders** - Mark work orders as in progress or completed

### QR Code Formats

- **Work Orders**: Any QR code containing the work order task ID (e.g., "WO-8472")
- **Troubleshooting Articles**: QR codes containing article IDs:
  - `PSU` - Power Supply Unit troubleshooting
  - `CRAC` - Cooling System troubleshooting
  - `NETWORK` - Network Infrastructure troubleshooting
  - `SERVER` - Server Hardware troubleshooting
  - `UPS` - UPS and Power Distribution troubleshooting

##  Architecture

We followed the **MVVM (Model-View-ViewModel)** pattern:

- **Models** - Data structures (WorkOrder, TroubleshootingArticle)
- **Views** - SwiftUI views for UI
- **ViewModels** - Business logic and state management
- **Services** - External integrations (Auth0, Firebase)

This keeps our code organized, testable, and maintainable.

## Security

- **Auth0 Authentication** - Enterprise-grade authentication
- **Firebase Security Rules** - Protect data access
- **Secure Token Storage** - Auth0 CredentialsManager handles token storage
- **User-specific Data** - Work orders filtered by authenticated user



## Future Enhancements

- [ ] Push notifications for critical work orders
- [ ] Offline mode with local data caching
- [ ] Voice commands for hands-free operation
- [ ] AR overlay for equipment identification
- [ ] Team chat integration
- [ ] Analytics and reporting dashboard
- [ ] Multi-language support


**Pro tip**: Coordinate with the team before making major changes to avoid merge conflicts! 

##  License

This project is licensed under the MIT License - see the LICENSE file for details.

## Acknowledgments

- Auth0 for authentication services
- Firebase for real-time database
- Apple for SwiftUI framework
- All the Stack Overflow answers that saved us hours of debugging

## Contact

For questions or support, please open an issue in this repository.

---




