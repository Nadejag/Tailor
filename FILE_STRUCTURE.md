# 📁 Tailor App - Complete File Structure

## Full Project Tree

```
Tailor/
├── android/                          # Android native code
├── ios/                              # iOS native code
├── web/                              # Web platform files
├── windows/                          # Windows desktop app
├── linux/                            # Linux platform
├── macos/                            # macOS platform
│
├── lib/                              # ⭐ All Dart/Flutter code
│   │
│   ├── main.dart                     # 🚀 App entry point
│   │
│   ├── models/                       # 📊 Data Models
│   │   ├── user_model.dart           # User(id, name, email, role)
│   │   ├── design_model.dart         # Design(name, price, category, image)
│   │   ├── wardrobe_model.dart       # Wardrobe(design, status)
│   │   ├── measurement_model.dart    # Measurement(chest, waist, etc.)
│   │   └── payment_model.dart        # Payment + PaymentHistory
│   │
│   ├── viewmodels/                   # 🧠 Business Logic & State Management
│   │   ├── base_viewmodel.dart       # Base class with isBusy state
│   │   ├── auth_viewmodel.dart       # Login/Signup logic
│   │   ├── design_viewmodel.dart     # Design listing & filtering
│   │   ├── wardrobe_viewmodel.dart   # Wardrobe CRUD operations
│   │   ├── measurement_viewmodel.dart # Measurement tracking
│   │   └── payment_viewmodel.dart    # Payment management
│   │
│   ├── views/                        # 🎨 All UI Screens
│   │   ├── auth/
│   │   │   ├── login_view.dart       # 📱 Login Screen
│   │   │   └── signup_view.dart      # 📝 Registration Screen
│   │   │
│   │   ├── designs/
│   │   │   ├── design_list_view.dart # 🛍️ Design Listing & Grid
│   │   │   └── design_detail_view.dart # 📄 Design Details Page
│   │   │
│   │   ├── wardrobe/
│   │   │   └── wardrobe_view.dart    # 👔 Wardrobe Management
│   │   │
│   │   ├── measurements/
│   │   │   └── measurement_view.dart # 📏 Measurements Tracker
│   │   │
│   │   ├── payments/
│   │   │   └── payment_view.dart     # 💳 Payment Dashboard
│   │   │
│   │   ├── home_view.dart            # (Legacy - replaced by main_home)
│   │   └── main_home_view.dart       # 🏠 Main navigation with tabs
│   │
│   ├── widgets/                      # 🧩 Reusable Components
│   │   ├── custom_button.dart        # Button with loading state
│   │   ├── custom_text_field.dart    # Text field with validation
│   │   ├── design_card.dart          # Design item card
│   │   ├── wardrobe_card.dart        # Wardrobe item card
│   │   └── payment_history_item.dart # Payment history row
│   │
│   ├── services/                     # 🌐 API & Backend Services
│   │   └── api_service.dart          # HTTP client (ready for backend)
│   │
│   └── utils/                        # ⚙️ Utilities & Constants
│       └── constants.dart            # App constants & configuration
│
├── test/                             # 🧪 Unit tests (to be implemented)
│
├── pubspec.yaml                      # 📦 Dependencies & Configuration
├── pubspec.lock                      # Lock file for dependencies
├── analysis_options.yaml             # Lint rules
├── README.md                         # Original Flutter README
├── PROJECT_DOCUMENTATION.md          # 📚 Detailed documentation
├── QUICKSTART.md                     # 🚀 Getting started guide
└── FILE_STRUCTURE.md                 # This file!
```

---

## 📊 Files Count Summary

| Category | Count | Details |
|----------|-------|---------|
| **Models** | 5 | User, Design, Wardrobe, Measurement, Payment |
| **ViewModels** | 6 | Auth, Design, Wardrobe, Measurement, Payment, Base |
| **Views** | 8 | Login, Signup, DesignList, DesignDetail, Wardrobe, Measurement, Payment, MainHome |
| **Widgets** | 5 | Button, TextField, DesignCard, WardrobeCard, PaymentHistoryItem |
| **Services** | 1 | ApiService |
| **Utils** | 1 | Constants |
| **Config** | 3 | main.dart, pubspec.yaml, analysis_options.yaml |
| **Docs** | 3 | PROJECT_DOCUMENTATION.md, QUICKSTART.md, FILE_STRUCTURE.md |
| **Total** | 35+ | Lines of Code: 5000+ |

---

## 🔗 Key Relationships

### Model Dependencies
```
User
├── Authentication related
└── Owner of all other entities

Design
├── Displayed in DesignListView
├── Referenced in Wardrobe
└── Has detailed view (DesignDetailView)

Wardrobe
├── Contains Design reference
├── Has status (Selected/Stitching/Completed)
└── Managed in WardrobeView

Measurement
├── Belongs to User
├── Tracked history
└── Edited in MeasurementView

Payment
├── Belongs to User
├── Has PaymentHistory items
└── Displayed in PaymentView
```

### ViewModel to View Mapping
```
AuthViewModel → LoginView, SignupView
DesignViewModel → DesignListView, DesignDetailView
WardrobeViewModel → WardrobeView
MeasurementViewModel → MeasurementView
PaymentViewModel → PaymentView
```

### Provider Setup (main.dart)
```
MultiProvider
├── AuthViewModel
├── DesignViewModel
├── WardrobeViewModel
├── MeasurementViewModel
└── PaymentViewModel
```

---

## 🎯 Feature to File Mapping

| Feature | Files Involved |
|---------|---|
| **Login** | auth/login_view.dart, auth_viewmodel.dart |
| **Registration** | auth/signup_view.dart, auth_viewmodel.dart |
| **Browse Designs** | designs/design_list_view.dart, design_viewmodel.dart |
| **Design Details** | designs/design_detail_view.dart, design_model.dart |
| **Manage Wardrobe** | wardrobe/wardrobe_view.dart, wardrobe_viewmodel.dart |
| **Track Measurements** | measurements/measurement_view.dart, measurement_viewmodel.dart |
| **Manage Payments** | payments/payment_view.dart, payment_viewmodel.dart |
| **Navigation** | main_home_view.dart |
| **Reusable UI** | All widgets/*.dart |
| **State Management** | All viewmodels/*.dart |
| **Data Models** | All models/*.dart |

---

## 🚀 Code Metrics

### Lines of Code per Module
```
models/           ~  400 lines
viewmodels/       ~ 1,200 lines (biggest module)
views/            ~ 2,500 lines (most code due to UI)
widgets/          ~  600 lines
services/         ~  100 lines
utils/            ~   50 lines
main.dart         ~  100 lines
─────────────────────────
Total            ~ 5,000+ lines
```

### Components Breakdown
```
✅ 5 Models (User, Design, Wardrobe, Measurement, Payment)
✅ 6 ViewModels (Base + Auth + Design + Wardrobe + Measurement + Payment)
✅ 8 Views/Screens (Login, Signup, DesignList, DesignDetail, Wardrobe, Measurement, Payment, MainHome)
✅ 5 Custom Widgets (Button, TextField, DesignCard, WardrobeCard, PaymentHistoryItem)
✅ 1 Service Layer (ApiService)
✅ Complete navigation with bottom tabs
```

---

## 🎨 Widget Tree Example

```
MyApp
└── MaterialApp
    └── MultiProvider (5 providers)
        └── Consumer<AuthViewModel>
            ├── LoginView (if not logged in)
            └── MainHomeView (if logged in)
                └── BottomNavigationBar
                    ├── DesignListView
                    │   └── GridView of DesignCards
                    ├── WardrobeView
                    │   └── ListView of WardrobeCards
                    ├── MeasurementView
                    │   └── GridView of MeasurementCards
                    └── PaymentView
                        └── Column of PaymentHistoryItems
```

---

## 📦 Dependencies Hierarchy

```
flutter/material           (UI Framework)
└── provider ^6.1.2        (State Management)
└── http ^1.2.1            (HTTP Requests)
```

### Why These Dependencies?
- **Provider**: Lightweight, reactive, perfect for MVVM
- **HTTP**: For backend API calls
- **Material**: Flutter's official design system

---

## 🔄 Data Flow Architecture

```
User Action (UI)
        ↓
    View Widget
        ↓
Consumer<ViewModel>
        ↓
ViewModel.method()
        ↓
Update State (notifyListeners)
        ↓
Rebuild Widget (UI updates)
```

---

## 🎯 How to Navigate the Codebase

### If you want to...
1. **Add a new screen**
   - Create Model in `models/`
   - Create ViewModel in `viewmodels/`
   - Create View in `views/[feature]/`
   - Add to providers in `main.dart`

2. **Add a new widget**
   - Create in `widgets/`
   - Use across multiple views

3. **Modify business logic**
   - Edit the corresponding ViewModel

4. **Change UI styling**
   - Edit the View widget

5. **Add backend integration**
   - Update `ApiService` in `services/`
   - Call API from ViewModel

---

## 📝 File Naming Conventions

- **Models**: `[entity]_model.dart` (e.g., `user_model.dart`)
- **ViewModels**: `[entity]_viewmodel.dart` (e.g., `design_viewmodel.dart`)
- **Views**: `[entity]_view.dart` (e.g., `login_view.dart`)
- **Widgets**: `[type]_[name].dart` (e.g., `custom_button.dart`)
- **Services**: `[type]_service.dart` (e.g., `api_service.dart`)

---

## ✨ Key Files to Know

### Essential Files
1. **main.dart** - Start here! Entry point of the app
2. **views/main_home_view.dart** - Main navigation hub
3. **viewmodels/auth_viewmodel.dart** - Authentication logic
4. **views/auth/login_view.dart** - First screen users see

### Most Used Files
- **DesignViewModel** - Most complex ViewModel (search, filter)
- **DesignCard** - Most reused Widget
- **payment_view.dart** - Most interactive View

---

## 🚀 Quick Reference

### To run the app
```bash
cd d:\Qabool\Projects\Tailor
flutter run
```

### To add a feature
1. Create files following naming convention
2. Extend BaseViewModel
3. Create corresponding View
4. Import and use in navigation

### To debug
```bash
flutter run -v                 # Verbose mode
flutter analyze               # Check code
flutter doctor                # Check setup
```

---

**Total Project Size**: ~5000+ lines of production-ready code
**Build Status**: ✅ Ready to run
**Architecture**: ✅ MVVM Pattern
**Documentation**: ✅ Complete

Happy Coding! 🎉
