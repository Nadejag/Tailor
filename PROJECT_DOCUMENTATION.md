# Tailor App - Complete Flutter MVVM Project

## 📱 Project Overview

A fully functional Flutter application built with **MVVM Architecture** for a tailor management system. The app allows customers and tailors to manage designs, wardrobe, measurements, and payments.

## ✨ Features Implemented

### 1. **Authentication System**
- **Login Screen**: User login with email and password validation
- **Signup Screen**: User registration with role selection (Customer/Tailor)
- Session management with Provider state management

### 2. **Home/Designs Screen**
- Browse available designs by tailors
- Search functionality to find specific designs
- Filter designs by category (Kurta, Suit, Waistcoat, Coat)
- Design detail view with full information
- Add designs to wardrobe directly from cards

### 3. **Wardrobe Management**
- View all saved designs with thumbnail images
- Filter items by status: All, Selected, Stitching, Completed
- Update design status (mark as stitching/completed)
- Remove items from wardrobe
- Visual status indicators with color coding

### 4. **Measurements Screen**
- View and update body measurements
- Measurements tracked: Chest, Waist, Shoulder, Arms, Length
- Additional notes field for special instructions
- Last update information (updated by which tailor)
- Interactive measurement cards for easy editing
- Persistent storage of measurement history

### 5. **Payments Screen**
- View payment summary (Total, Paid, Remaining)
- Visual payment progress bar
- Record new payments with method selection (Cash/Online/Card/Check)
- Complete payment history with dates
- Payment method icons for easy identification

### 6. **Bottom Navigation**
- 4-tab navigation: Home | Wardrobe | Measurements | Payments
- Smooth tab transitions
- Persistent state management

## 🏗️ Project Architecture (MVVM)

### Directory Structure
```
lib/
├── models/                    # Data models
│   ├── user_model.dart
│   ├── design_model.dart
│   ├── wardrobe_model.dart
│   ├── measurement_model.dart
│   └── payment_model.dart
│
├── viewmodels/               # Business logic & state management
│   ├── base_viewmodel.dart
│   ├── auth_viewmodel.dart
│   ├── design_viewmodel.dart
│   ├── wardrobe_viewmodel.dart
│   ├── measurement_viewmodel.dart
│   └── payment_viewmodel.dart
│
├── views/                    # UI screens
│   ├── auth/
│   │   ├── login_view.dart
│   │   └── signup_view.dart
│   ├── designs/
│   │   ├── design_list_view.dart
│   │   └── design_detail_view.dart
│   ├── wardrobe/
│   │   └── wardrobe_view.dart
│   ├── measurements/
│   │   └── measurement_view.dart
│   ├── payments/
│   │   └── payment_view.dart
│   ├── home_view.dart
│   └── main_home_view.dart
│
├── widgets/                  # Reusable UI components
│   ├── custom_button.dart
│   ├── custom_text_field.dart
│   ├── design_card.dart
│   ├── wardrobe_card.dart
│   └── payment_history_item.dart
│
├── services/                 # API & backend services
│   └── api_service.dart
│
├── utils/                    # Utility functions
│   └── constants.dart
│
└── main.dart                 # App entry point
```

## 🎨 UI/UX Features

### Design Cards
- Image display with error handling
- Price information
- Category badges
- Quick add-to-wardrobe button
- Rounded corners and shadow effects

### Wardrobe Cards
- Thumbnail images with status
- Status indicators (Selected/Stitching/Completed)
- Quick delete option
- Click to view details and update status

### Measurement Cards
- Visual representation with icons
- Edit measurements inline
- Current values displayed prominently
- Unit labels (cm)

### Payment Cards
- Summary cards with color-coded categories
- Progress bar showing payment completion
- Detailed transaction history
- Record payment dialog for adding new payments

## 🔧 Technologies & Dependencies

### Core
- **Flutter 3.41.9** - UI Framework
- **Dart 3.11.5** - Programming Language

### State Management
- **Provider 6.1.2** - Reactive state management

### HTTP
- **http 1.2.1** - API requests

### Architecture
- **MVVM Pattern** - Separation of concerns
- **ChangeNotifier** - State management mechanism
- **Repository Pattern** - Data access layer ready for extension

## 🚀 Running the App

### Prerequisites
- Flutter SDK installed
- Android emulator/device OR Chrome/Web support OR Windows desktop

### Commands

```bash
# Get dependencies
flutter pub get

# Run on Windows desktop
flutter run -d windows

# Run on Chrome web
flutter run -d chrome

# Build release
flutter build windows   # or apk, ios, web, etc.
```

## 📝 Sample Data

All screens are pre-populated with sample data:
- 5 design items across categories
- 3 wardrobe items with different statuses
- Default measurements
- Payment history with multiple transactions

## 🔐 Authentication Flow

1. User lands on Login screen
2. Can either login or navigate to Signup
3. Signup requires: Name, Email, Password, Role (Customer/Tailor)
4. After authentication, user redirected to Main Home with bottom navigation
5. All screens protected behind authentication check

## 🎯 User Flows

### Customer Flow
1. Browse designs (Home tab)
2. Add designs to wardrobe
3. Update body measurements
4. Track payments and payment history

### Tailor Flow  
1. Upload/View designs
2. Manage customer wardrobe (from admin panel)
3. Update customer measurements
4. Track payments received

## ✅ Best Practices Implemented

- **Clean Code**: Proper naming conventions and organization
- **State Management**: Provider for reactive UI updates
- **Error Handling**: Try-catch blocks and user feedback via SnackBars
- **Form Validation**: Email and password validation
- **Responsive Design**: Works on different screen sizes
- **Code Reusability**: Custom widgets for common UI patterns
- **Performance**: Lazy loading with Future.microtask
- **User Feedback**: Loading states and dialogs

## 📱 Screen Specifications

| Screen | Purpose | Features |
|--------|---------|----------|
| Login | User authentication | Email validation, remember me option |
| Signup | User registration | Role selection, password confirmation |
| Designs | Browse designs | Search, filter, category selection |
| Design Detail | View full design | Features, price, add to wardrobe |
| Wardrobe | Manage saved items | Filter, update status, delete |
| Measurements | Manage body measurements | 5 measurement points, notes field |
| Payments | Payment tracking | Summary, progress, history, record payment |

## 🔄 Data Flow

```
UI (View) → ViewModel → Model → Service/API
                ↑                  ↓
        State Update      (JSON parsing)
```

## 🛣️ Future Enhancement Roadmap

- Backend API integration (replace mock data)
- Image upload for designs
- Push notifications for order status
- Payment gateway integration
- Admin dashboard
- Chat between customer & tailor
- Order tracking with real-time updates
- Expense tracking for tailors
- Rating & reviews system

## 📄 License

This project is open source and available under MIT License.

## 👨‍💻 Development Notes

- All data is currently mocked with 2-second delays to simulate API calls
- User authentication state is managed globally via Provider
- Each screen has its own ViewModel for separation of concerns
- Reusable widgets minimize code duplication
- Easy to extend with new screens or features

---

**Project Status**: ✅ Complete UI/Frontend - Ready for Backend Integration

Created with ❤️ using Flutter & MVVM Architecture
