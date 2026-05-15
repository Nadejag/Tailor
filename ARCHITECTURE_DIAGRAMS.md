# 🎨 TAILOR APP - VISUAL ARCHITECTURE & FLOW DIAGRAMS

## 📱 APP NAVIGATION FLOW

```
┌─────────────────────────────────────────────────────────┐
│                   START APP (main.dart)                  │
└────────────────────┬────────────────────────────────────┘
                     │
                     ▼
        ┌─────────────────────────┐
        │  Consumer<AuthViewModel>│
        └────────┬────────────────┘
                 │
        ┌────────┴────────┐
        │                 │
        ▼                 ▼
   ┌─────────┐       ┌──────────┐
   │NOT LOGGED│      │LOGGED IN │
   └────┬────┘       └────┬─────┘
        │                 │
        ▼                 ▼
    ┌────────┐        ┌─────────────┐
    │LoginView│       │MainHomeView │
    └────┬───┘        └──────┬──────┘
         │                   │
         │            ┌──────┴──────┬──────────┬──────────┐
         │            │             │          │          │
         │            ▼             ▼          ▼          ▼
         │         [HOME]     [WARDROBE]  [MEASURE]  [PAYMENT]
         │
         ▼
    ┌──────────┐
    │SignupView│
    └──────────┘
```

---

## 🏗️ MVVM ARCHITECTURE FLOW

```
┌──────────────────────────────────────────────────────────────┐
│                    USER INTERACTION (TAP)                    │
└───────────────────────────┬────────────────────────────────┘
                            │
                            ▼
                ┌────────────────────────┐
                │  View Widget (Widget)  │ ← Displays UI
                │  (e.g., DesignCard)    │
                └───────────┬────────────┘
                            │
                            ▼
            ┌───────────────────────────────┐
            │  Consumer<ViewModel>          │ ← Listens to changes
            │  (e.g., DesignViewModel)      │
            └───────────┬───────────────────┘
                        │
                        ▼
        ┌───────────────────────────────────┐
        │  ViewModel Method Called           │ ← Handles logic
        │  .updateStatus(id, newStatus)     │
        └───────────┬───────────────────────┘
                    │
                    ▼
        ┌───────────────────────────────────┐
        │  Update Model/State                │ ← Changes data
        │  _wardrobeItems[index].status =... │
        └───────────┬───────────────────────┘
                    │
                    ▼
        ┌───────────────────────────────────┐
        │  Call notifyListeners()            │ ← Notify changes
        │  (State Management)                │
        └───────────┬───────────────────────┘
                    │
                    ▼
        ┌───────────────────────────────────┐
        │  Widget Rebuilds                   │ ← UI Updates
        │  (Reactive Update)                 │
        └───────────┬───────────────────────┘
                    │
                    ▼
        ┌───────────────────────────────────┐
        │  New UI Displayed                  │
        │  Status badge updated              │
        └───────────────────────────────────┘
```

---

## 📊 DATA MODEL RELATIONSHIPS

```
                    ┌──────────────────┐
                    │   USER MODEL     │
                    │  (id, name,      │
                    │   email, role)   │
                    └────────┬─────────┘
                             │
           ┌─────────────────┼──────────────────┐
           │                 │                  │
           ▼                 ▼                  ▼
      ┌─────────┐      ┌──────────┐      ┌──────────┐
      │WARDROBE │      │MEASUREMENT│    │ PAYMENT  │
      │ MODEL   │      │ MODEL     │    │  MODEL   │
      │ -id     │      │ -id       │    │ -id      │
      │ -status │      │ -chest    │    │ -paid    │
      │ -design │      │ -waist    │    │ -total   │
      │ _id     │      │ -shoulder │    │ -remain  │
      └────┬────┘      │ -arms     │    └────┬─────┘
           │            │ -length   │         │
           │            └──────────┘         │
           │                                 │
           ▼                                 ▼
      ┌──────────┐                    ┌──────────────┐
      │ DESIGN   │                    │PAYMENT HIST  │
      │ MODEL    │                    │(method, amt) │
      │ -name    │                    └──────────────┘
      │ -price   │
      │ -category│
      │ -image   │
      └──────────┘
```

---

## 🌐 APP SCREEN LAYOUT

```
┌──────────────────────────────────┐
│         APP STRUCTURE            │
├──────────────────────────────────┤
│                                  │
│   ┌─────────────────────────┐   │
│   │   AppBar / Header       │   │
│   │   (Title + Actions)     │   │
│   └─────────────────────────┘   │
│                                  │
│   ┌─────────────────────────┐   │
│   │                         │   │
│   │   MAIN CONTENT AREA     │   │
│   │                         │   │
│   │   (Scrollable)          │   │
│   │                         │   │
│   └─────────────────────────┘   │
│                                  │
│   ┌─────────────────────────┐   │
│   │ BOTTOM NAVIGATION BAR   │   │
│   │ [H] [W] [M] [P]        │   │
│   │ Home|Wardrobe|Measure   │   │
│   │     |Payments           │   │
│   └─────────────────────────┘   │
│                                  │
└──────────────────────────────────┘
```

---

## 🔄 STATE MANAGEMENT FLOW

```
PROVIDER ARCHITECTURE
════════════════════════════════════

    MultiProvider
    ├── AuthViewModel
    ├── DesignViewModel
    ├── WardrobeViewModel
    ├── MeasurementViewModel
    └── PaymentViewModel
         │
         └─► Each manages its own:
             - State/Data
             - Business Logic
             - Notifications

    ┌──────────────────────────────┐
    │  Consumer<ViewModel>         │
    │  Listens to changes and      │
    │  rebuilds affected widgets   │
    └──────────────────────────────┘
```

---

## 📱 SCREEN HIERARCHY

```
ROOT
│
├── LoginView
│   └── EmailField → PasswordField → LoginButton → SignupLink
│
├── SignupView
│   └── NameField → RoleToggle → EmailField → PasswordField → SignupButton
│
└── MainHomeView (Bottom Navigation)
    │
    ├── Tab 0: DesignListView
    │   ├── SearchBar
    │   ├── CategoryFilter (Pills)
    │   └── GridView of DesignCards
    │       └── DesignCard
    │           └── OnTap: DesignDetailView
    │
    ├── Tab 1: WardrobeView
    │   ├── StatusFilter (Pills)
    │   └── ListView of WardrobeCards
    │       └── WardrobeCard
    │           └── OnTap: StatusActionSheet
    │
    ├── Tab 2: MeasurementView
    │   ├── SummaryInfo
    │   ├── GridView of MeasurementCards
    │   │   └── MeasurementCard
    │   │       └── OnTap: EditDialog
    │   ├── NotesField
    │   └── UpdateButton
    │
    └── Tab 3: PaymentView
        ├── SummaryCards (3)
        ├── ProgressBar
        ├── PaymentHistoryTitle
        └── ListView of PaymentHistoryItems
            └── PaymentHistoryItem
                └── OnTap: RecordPaymentDialog
```

---

## 💻 CLASS HIERARCHY

```
BaseViewModel
├── AuthViewModel
│   ├── login()
│   ├── signup()
│   └── logout()
│
├── DesignViewModel
│   ├── fetchDesigns()
│   ├── filterByCategory()
│   └── searchDesigns()
│
├── WardrobeViewModel
│   ├── fetchWardrobeItems()
│   ├── filterByStatus()
│   ├── addToWardrobe()
│   ├── removeFromWardrobe()
│   └── updateStatus()
│
├── MeasurementViewModel
│   ├── fetchMeasurements()
│   ├── setChest/Waist/Shoulder/Arms/Length()
│   └── updateMeasurements()
│
└── PaymentViewModel
    ├── fetchPaymentInfo()
    ├── recordPayment()
    └── getPaymentHistory()

StatelessWidget
├── LoginView
├── SignupView
├── MainHomeView
├── DesignListView
├── DesignDetailView
├── WardrobeView
├── MeasurementView
├── PaymentView
├── CustomButton
├── CustomTextField
├── DesignCard
├── WardrobeCard
└── PaymentHistoryItem
```

---

## 🎯 FEATURE INTERACTION MAP

```
LOGIN/SIGNUP
    │
    └─► AUTHENTICATED
        │
        ├─► HOME (Designs)
        │   └─► SearchDesigns
        │   └─► FilterByCategory
        │   └─► ViewDesignDetail
        │   └─► AddToWardrobe
        │
        ├─► WARDROBE
        │   └─► FilterByStatus
        │   └─► UpdateStatus
        │   └─► DeleteItem
        │
        ├─► MEASUREMENTS
        │   └─► ViewMeasurements
        │   └─► EditMeasurements
        │   └─► AddNotes
        │   └─► SaveMeasurements
        │
        └─► PAYMENTS
            └─► ViewSummary
            └─► ViewHistory
            └─► RecordPayment
```

---

## 🔐 AUTHENTICATION FLOW

```
START
│
├─► NOT AUTHENTICATED
│   │
│   ├─► LOGIN SCREEN
│   │   ├─► Enter Email
│   │   ├─► Enter Password
│   │   ├─► Click Login
│   │   │   └─► AuthViewModel.login()
│   │   │       └─► Set currentUser
│   │   │       └─► Set isLoggedIn = true
│   │   │       └─► notifyListeners()
│   │   │           └─► Consumer rebuilds
│   │   │               └─► Redirect to MainHome
│   │   │
│   │   └─► OR Click Signup
│   │       └─► SIGNUP SCREEN
│   │           ├─► Enter Name
│   │           ├─► Select Role (Customer/Tailor)
│   │           ├─► Enter Email
│   │           ├─► Enter Password
│   │           ├─► Confirm Password
│   │           ├─► Click Signup
│   │           │   └─► AuthViewModel.signup()
│   │           │       └─► Create user
│   │           │       └─► Set isLoggedIn = true
│   │           │           └─► Redirect to MainHome
│   │
└─► AUTHENTICATED
    │
    └─► MainHomeView (with 4 tabs)
        └─► Available Features
```

---

## 📈 DESIGN BROWSING FLOW

```
HOME SCREEN
    │
    ├─► SEARCH BAR
    │   │
    │   └─► Type search query
    │       └─► DesignViewModel.searchDesigns(query)
    │           └─► Filter _designs list
    │           └─► notifyListeners()
    │               └─► UI Updates with filtered results
    │
    ├─► CATEGORY FILTER
    │   │
    │   └─► Tap Category Pill (Kurta/Suit/etc)
    │       └─► DesignViewModel.filterByCategory(category)
    │           └─► Filter _designs list
    │           └─► notifyListeners()
    │               └─► UI Updates with filtered results
    │
    └─► DESIGN CARD
        │
        ├─► Tap Card Body
        │   └─► Navigate to DesignDetailView
        │       └─► Display full design details
        │
        └─► Tap Add Button
            └─► Add to Wardrobe
                └─► WardrobeViewModel.addToWardrobe()
                    └─► Show SnackBar confirmation
```

---

## 🛍️ WARDROBE MANAGEMENT FLOW

```
WARDROBE SCREEN
    │
    ├─► STATUS FILTER
    │   │
    │   └─► Tap Filter (Selected/Stitching/Completed/All)
    │       └─► WardrobeViewModel.filterByStatus(status)
    │           └─► Filter _wardrobeItems
    │           └─► notifyListeners()
    │               └─► UI Updates with filtered items
    │
    └─► WARDROBE CARD
        │
        ├─► Tap Card
        │   └─► ShowModalBottomSheet
        │       └─► Show Actions:
        │           ├─ Update to Stitching
        │           ├─ Update to Completed
        │           └─ Remove from Wardrobe
        │
        └─► Swipe Delete Button
            └─► WardrobeViewModel.removeFromWardrobe(id)
                └─► Remove from list
                └─► notifyListeners()
                    └─► Item disappears from UI
```

---

## 📏 MEASUREMENT TRACKING FLOW

```
MEASUREMENT SCREEN
    │
    ├─► VIEW MEASUREMENTS
    │   └─► MeasurementViewModel.fetchMeasurements()
    │       └─► Load saved measurements
    │       └─► Display in cards
    │
    ├─► EDIT MEASUREMENT
    │   │
    │   └─► Tap Measurement Card
    │       └─► Show Edit Dialog
    │           └─► Enter new value
    │           └─► Click Save
    │               └─► ViewModel.setMeasurement(value)
    │               └─► Update state variable
    │               └─► notifyListeners()
    │
    ├─► ADD NOTES
    │   │
    │   └─► Type in Notes Field
    │       └─► ViewModel.setNotes(text)
    │
    └─► UPDATE/SAVE
        │
        └─► Click Update Button
            └─► ViewModel.updateMeasurements()
                └─► Save all changes
                └─► Show success message
```

---

## 💳 PAYMENT TRACKING FLOW

```
PAYMENT SCREEN
    │
    ├─► VIEW SUMMARY
    │   │
    │   ├─► Total Amount Card
    │   │   └─► Shows total order value
    │   │
    │   ├─► Paid Amount Card
    │   │   └─► Shows paid so far
    │   │
    │   └─► Remaining Amount Card
    │       └─► Shows balance due
    │
    ├─► PROGRESS BAR
    │   │
    │   └─► Visual representation of payment progress
    │       └─► Updated as payments recorded
    │
    ├─► PAYMENT HISTORY
    │   │
    │   └─► ListView of PaymentHistoryItems
    │       └─► Shows past transactions
    │
    └─► RECORD PAYMENT
        │
        └─► Tap Record Button
            └─► Show Dialog
                ├─► Enter Amount
                ├─► Select Payment Method (Cash/Online/Card)
                └─► Click Record
                    └─► PaymentViewModel.recordPayment()
                        └─► Add to payment history
                        └─► Update totals
                        └─► notifyListeners()
                            └─► UI Updates with new payment
```

---

## 🔗 COMPONENT REUSABILITY

```
CustomButton
├── Used in: LoginView, SignupView, MeasurementView, DesignDetailView
│   └── Purpose: Primary actions, form submission

CustomTextField
├── Used in: LoginView, SignupView, DesignListView
│   └── Purpose: Text input with validation

DesignCard
├── Used in: DesignListView
│   └── Purpose: Design item display in grid

WardrobeCard
├── Used in: WardrobeView
│   └── Purpose: Wardrobe item display in list

PaymentHistoryItem
├── Used in: PaymentView
│   └── Purpose: Payment transaction display in list
```

---

## 📊 PROVIDER STATE TREE

```
MultiProvider
│
├─ ChangeNotifierProvider<AuthViewModel>
│  └─ currentUser: User?
│  └─ isLoggedIn: bool
│  └─ errorMessage: String
│
├─ ChangeNotifierProvider<DesignViewModel>
│  └─ designs: List<Design>
│  └─ filteredDesigns: List<Design>
│  └─ selectedCategory: String
│
├─ ChangeNotifierProvider<WardrobeViewModel>
│  └─ wardrobeItems: List<Wardrobe>
│  └─ filteredItems: List<Wardrobe>
│  └─ selectedFilter: String
│
├─ ChangeNotifierProvider<MeasurementViewModel>
│  └─ measurement: Measurement?
│  └─ chest, waist, shoulder, arms, length: double
│  └─ notes: String
│
└─ ChangeNotifierProvider<PaymentViewModel>
   └─ payment: Payment?
   └─ paymentHistory: List<PaymentHistory>
   └─ errorMessage: String
```

---

## ✅ FLOW COMPLETION SUMMARY

Each user interaction follows this pattern:
1. User taps UI element
2. View calls ViewModel method
3. ViewModel updates state
4. ViewModel calls notifyListeners()
5. Consumer widgets rebuild
6. UI displays updated data

This ensures:
- ✅ Reactive updates
- ✅ Separation of concerns
- ✅ Testability
- ✅ Maintainability
- ✅ Performance

---

**DIAGRAM COMPLETE** - Visual architecture and flows documented! 🎨
