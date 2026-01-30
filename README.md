# ConectaTec

---

## 📱 Project Description

**ConectaTec** is a mobile application designed exclusively for university students looking to create authentic connections within their academic community. Whether for friendship, dating, or professional networking, ConectaTec offers a safe, verified, and private space where students can meet without worrying about fake profiles or external users.

Unlike generic dating apps, ConectaTec is focused on the university context, prioritizing academic proximity, shared interests, and the safety of its users.

### 🎯 Problem Solved

Many university students face challenges meeting people on their own campus due to:

- **Lack of time** between classes and academic responsibilities
- **Shyness** or difficulty initiating conversations in person
- **Limited social environments** outside their usual circle
- **Generic apps** that don't consider the university context

ConectaTec solves these problems through:

✅ Limited access exclusively for verified students
✅ Connections based on academic proximity and genuine affinities
✅ An environment focused on respect, privacy, and security

---

## ✨ Main Features

### Current Functionalities

- **Secure Registration and Authentication**
- Login with student identity verification
- Password recovery
- Secure session management

- **User Profile**
- Creation and editing of a personalized profile
- Academic and personal information
- Photo gallery

- **Profile Discovery**
- Explore students at your university
- Filter and preference system
- Detailed profile view

- **Matching System**
- Matching algorithm
- Real-time notifications
- Integrated chat (coming soon)

- **Premium Subscriptions**
- Weekly, monthly, and semester plans
- Exclusive features for subscribers
- Manage subscriptions from the app
- Integration with the App Store and Google Play

### Premium Features

Users with an active subscription have access to:

- Unlimited likes
- See who liked you
- Rematch
- Advanced search filters
- Featured profile
- No ads

---

## 🛠️ Technologies Used

### Frontend
- **Flutter** 3.x - Cross-platform framework for iOS and Android
- **Dart** - Main programming language

### Backend
- **Supabase** - Platform Backend-as-a-Service
- PostgreSQL Database
- User Authentication
- File Storage
- Real-time APIs

### Payments and Subscriptions
- **In-App Purchase (IAP)**
- StoreKit for iOS
- Google Play Billing for Android
- **Stripe SDK** - Payment Processing (Android)

### Utilities

- **flutter_dotenv** - Environment Variable Management
- **http** - HTTP Requests
- **provider** - State Management
- **flutter_card_swiper** - Creation of the popular Tinder-style swipe
- **flutter_stripe** - Use of external payments on Android only
- **flutter_launcher_icons** - Generation of app icons for different operating systems
- **url_launcher** - Management of external URLs

---

## 📦 Installation and Execution

### Prerequisites

Make sure you have the following installed:

- [Flutter SDK](https://flutter.dev/docs/get-started/install) (version 3.0 or higher)
- [Dart SDK](https://dart.dev/get-dart) (included with Flutter)
- Android Studio or Xcode (depending on your development platform)
- Git

### Installation Steps

1. **Clone the repository**

```bash
git clone https://github.com/neurovix/tindertec.git
cd tindertec
```

2. **Install dependencies**

```bash
flutter pub get
```

3. **Configure environment variables**

Create a `.env` file in the project root:

```bash
cp .env.example .env
```

Edit the File `.env` with your credentials (see Environment Variables section).

4. **Running the Application**

General
```bash
flutter run --debug
```

For Android:
```bash
flutter run
```

For iOS:
```bash
flutter run -d ios
```

For a specific device:
```bash
flutter devices
flutter run -d [device-id]
```

### Production Build

**Android (APK):**
```bash
flutter build apk --release
```

**Android (App Bundle):**
```bash
flutter build appbundle --release
```

**iOS:**
```bash
flutter build ios --release
```

---

## 🔐 Environment Variables

Create a `.env` file in the project root with the following variables:

```env
# Supabase Configuration
SUPABASE_URL=your_supabase_url
SUPABASE_ANON_KEY=your_supabase_anon_key

# Stripe Configuration (Android)
STRIPE_PUBLISHABLE_KEY=your_stripe_publishable_key
STRIPE_SECRET_KEY=your_stripe_secret_key
```

### Obtain Credentials

1. **Supabase:**

- Create a project at [Supabase](https://supabase.com)
- Obtain the URL and Anon Key from Project Settings > API

2. **Stripe:**

- Create an account at [Stripe](https://stripe.com)
- Obtain the keys from Developers > API keys

⚠️ **Important:** Never upload the `.env` file to the repository. Make sure it's included in `.gitignore`.

---

## 📁 Project Structure

```
tindertec/
├── lib/
│ ├── main.dart             # Application entry point
│ ├── screens/              # Application screens
│ │ ├── auth/               # Authentication screens
│ │ │ ├── OnRegisterFlow...
│ │ ├── home/               # Main screens
│ │ │ ├── home.dart
│ │ │ ├── matches.dart
│ │ │ ├── likes.dart
│ │ │ ├── profile.dart
│ │ │ └── premium_details.dart
│ ├── models/               # Data models
│ ├── services/
├── assets/                 # Where images are located
│ ├── icons/                # Icons used in the application
│ ├── images/               # Images used in the application
├── android/                # Android configuration
├── ios/                    # iOS configuration
├── .env.example            # Environment variable template
├── pubspec.yaml            # Project dependencies
└── README.md               # This File
```

---

## 💳 Subscription System

ConectaTec uses a subscription model to unlock premium features.

### Available Plans

| Plan | Duration | Price* |

------|----------|---------|

**Weekly** | 7 days | $19.99 MXN ~ $1 USD |

**Monthly** | 30 days | $59.99 MXN ~ $3 USD |

**Semi-annual** | 180 days | $99.99 MXN ~ $5 USD |

*Prices may vary depending on the region and app store.

### Technical Implementation

- **iOS:** Uses StoreKit and is processed through the App Store
- **Android:** Uses Google Play Billing and Stripe SDK
- **Management:** Users can manage or cancel subscriptions from their account settings in the corresponding store
- **Compliance:** All transactions comply with App Store and Google Play policies

### Subscription Features

- ✅ Manual renewal
- ✅ Free features available (depending on configuration)
- ✅ Cancellation at any time
- ✅ Cross-device synchronization
- ✅ Purchase restoration

---

## ⚠️ Warnings and Considerations

### Security

- **Never share** your API keys or secrets in the source code
- All credentials must be in the `.env` file
- Communications with the backend use **HTTPS exclusively**

### Privacy

- User data is confidential and are protected
- Personal information is not shared without explicit consent

### Subscriptions

- **Sandbox Testing:** Before launching to production, thoroughly test in test environments (TestFlight for iOS, Internal Testing for Android)
- **Receipt Verification:** Implement server-side receipt validation to prevent fraud
- **Error Handling:** Properly manage payment errors and subscription statuses
- **Purchase Restoration:** Ensure users can restore their subscriptions on new devices

### App Store and Google Play

- Review and comply with the [App Store Review Guidelines](https://developer.apple.com/app-store/review/guidelines/)
- Comply with the [Google Play Developer Policy](https://play.google.com/about/developer-content-policy/)
- Prepare appropriate screenshots, descriptions, and metadata
- Have a response plan ready for reviews Rejected

---

## 🚀 Project Status

**Current Status:** ✅ Functional version in active development

- [x] User authentication
- [x] Profile creation and management
- [x] Discovery system
- [x] Basic matching system
- [x] Subscription integration
- [ ] Real-time chat
- [ ] Push notifications
- [ ] Reporting and moderation system
- [x] Expansion to more universities

---

## 🎓 Target Audience

**User Profile:**

- Active university students
- Primarily from the Saltillo Institute of Technology
- Expandable to other educational institutions
- Young adults (18-25 years old) interested in genuine connections within their academic community

---

## 🌟 Roadmap and Long-Term Vision

ConectaTec aspires to become the leading platform for university connections in Mexico.

### Future Objectives

1. **Geographic Expansion**

- Integration with more campuses of the Technological Institute
- Opening up to other public and private universities
- National coverage at leading institutions

2. **New Features**
- University events and activities system
- Study groups and academic networking
- Integration with academic calendars
- Gamification and achievement system

3. **Technical Improvements**
- AI-based matching algorithm
- Improved identity verification
- Performance optimization
- Accessibility and multilingual support

---

## 🤝 Contributions
Contributions are welcome. If you would like to contribute to theProject:

1. Fork the repository
2. Create a branch for your feature (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a pull request

Please be sure to follow the project style guides and add tests where appropriate.

---

## 📄 License
This project is licensed under the MIT License. See the `LICENSE` file for details.

---

## 📧 Contact
**ConectaTec Team**

- Website: [https://neurovix.com.mx/apps/seguratec](#) (coming soon)
- Email: fervazquez@neurovix.com.mx
- GitHub: [github.com/neurovix/cargatec](#)

---
## Made by
**Fernando Vazquez (CEO of Neurovix)**

---