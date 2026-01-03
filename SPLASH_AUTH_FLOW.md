# Splash Screen & Authentication Flow - Documentation

## 🎯 Overview

The app now features a professional splash screen with logo and always starts at the login page (no auto-login).

---

## 🖼️ Splash Screen Design

### Visual Elements:

```
┌────────────────────────────────┐
│                                │
│                                │
│        ┌──────────┐            │
│        │          │            │
│        │   LOGO   │            │  ← Logo (150x150, rounded, shadow)
│        │          │            │
│        └──────────┘            │
│                                │
│     DayFlow HRMS               │  ← App Name (32px, bold, navy)
│                                │
│  Human Resource Management     │  ← Tagline (14px, grey)
│         System                 │
│                                │
│           ⏳                    │  ← Loading indicator
│                                │
└────────────────────────────────┘
```

### Features:
- **Logo**: DayFlow logo with rounded corners and shadow
- **App Name**: "DayFlow HRMS" in bold Deep Navy
- **Tagline**: "Human Resource Management System"
- **Fade Animation**: 1.5 seconds smooth fade-in
- **Duration**: 3 seconds total display time
- **Loading Indicator**: Steel Blue circular progress

---

## 🔄 Authentication Flow

### App Startup Flow:

```
1. App Starts
   ↓
2. Splash Screen (3 seconds)
   - Show logo
   - Show app name
   - Fade animation
   ↓
3. Navigate to Login Page
   - Always starts at login
   - No auto-login
   - Clean state
```

### Previous Behavior (Disabled):
```
❌ Old Flow:
1. App Starts
2. Check stored token
3. If token exists → Auto-login
4. Direct to dashboard
```

### New Behavior (Current):
```
✅ New Flow:
1. App Starts
2. Splash Screen (3 seconds)
3. Always navigate to Login
4. User must login manually
5. Then navigate to dashboard
```

---

## 🔐 Auth Provider Changes

### Auto-Login Disabled:

**Before:**
```dart
AuthNotifier(this._apiService, this._storage) 
  : super(const AsyncValue.loading()) {
    _checkAuthStatus(); // ❌ Auto-checked token
}
```

**After:**
```dart
AuthNotifier(this._apiService, this._storage) 
  : super(const AsyncValue.data(null)) {
    // Disabled auto-login - app always starts at login screen
    // _checkAuthStatus(); // ✅ Commented out
}
```

### Initial State:
- **Before**: `AsyncValue.loading()` - checked for token
- **After**: `AsyncValue.data(null)` - always null (logged out)

---

## 📱 Splash Screen Code

### Key Components:

**1. Animation Controller:**
```dart
_controller = AnimationController(
  duration: const Duration(milliseconds: 1500),
  vsync: this,
);

_fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
  CurvedAnimation(parent: _controller, curve: Curves.easeIn),
);
```

**2. Timer Navigation:**
```dart
Future.delayed(const Duration(seconds: 3), () {
  if (mounted) {
    context.go('/login');
  }
});
```

**3. Logo Display:**
```dart
Container(
  width: 150,
  height: 150,
  decoration: BoxDecoration(
    borderRadius: BorderRadius.circular(20),
    boxShadow: [
      BoxShadow(
        color: AppTheme.steelBlue.withOpacity(0.3),
        blurRadius: 20,
        offset: const Offset(0, 10),
      ),
    ],
  ),
  child: ClipRRect(
    borderRadius: BorderRadius.circular(20),
    child: Image.asset(
      'assets/images/dayflow_logo.jpg',
      fit: BoxFit.cover,
    ),
  ),
)
```

---

## 🎨 Design Specifications

### Colors:
```
Background:      White (#FFFFFF)
App Name:        Deep Navy (#052659)
Tagline:         Grey 600 (#757575)
Loading:         Steel Blue (#5483B3)
Logo Shadow:     Steel Blue 30% opacity
```

### Typography:
```
App Name:        32px, Bold, Letter Spacing: 1.5
Tagline:         14px, Regular, Letter Spacing: 0.5
```

### Spacing:
```
Logo Size:       150x150px
Logo Radius:     20px
Logo to Name:    32px
Name to Tagline: 8px
Tagline to Load: 48px
```

### Timing:
```
Fade Duration:   1.5 seconds
Total Display:   3 seconds
Curve:           Ease In
```

---

## 🚀 User Experience Flow

### First Time User:
```
1. Open app
2. See splash screen (3s)
3. Arrive at Login/Signup page
4. Click "Sign Up"
5. Register company
6. Auto-login after registration
7. Navigate to dashboard
```

### Returning User:
```
1. Open app
2. See splash screen (3s)
3. Arrive at Login page
4. Enter credentials
5. Click "Sign In"
6. Navigate to dashboard
```

### Logout Flow:
```
1. User logged in
2. Click profile dropdown
3. Click "Log Out"
4. Token cleared from storage
5. Navigate to Login page
6. Next app open: starts at splash → login
```

---

## 🔧 Technical Implementation

### Splash Screen (splash_screen.dart):
- **Type**: StatefulWidget
- **Mixin**: SingleTickerProviderStateMixin
- **Navigation**: GoRouter context.go('/login')
- **Animation**: FadeTransition with AnimationController

### Auth Provider (auth_provider.dart):
- **Type**: StateNotifierProvider
- **Initial State**: AsyncValue.data(null)
- **Auto-login**: Disabled (commented out)
- **Token Check**: Only on manual login

### Storage:
- **Package**: flutter_secure_storage
- **Keys**: 'jwt_token', 'user_role'
- **Clear on**: Logout
- **Check on**: Manual login only

---

## ✅ Benefits

### Security:
✅ No automatic authentication
✅ User must explicitly login
✅ Tokens cleared properly on logout

### User Experience:
✅ Professional branded splash
✅ Clear app identity
✅ Smooth fade animation
✅ Consistent login flow

### Development:
✅ Easier testing (always starts fresh)
✅ No state confusion
✅ Clean authentication state
✅ Predictable behavior

---

## 🎯 Testing Checklist

### Splash Screen:
- [ ] Logo displays correctly
- [ ] App name visible and clear
- [ ] Tagline readable
- [ ] Fade animation smooth
- [ ] Navigates to login after 3s
- [ ] No flash or jump

### Authentication:
- [ ] App starts at login (no auto-login)
- [ ] Can login successfully
- [ ] Dashboard loads after login
- [ ] Logout clears token
- [ ] Next open starts at splash
- [ ] No automatic re-login

### Flow:
- [ ] Splash → Login → Dashboard
- [ ] Logout → Login
- [ ] Re-open → Splash → Login
- [ ] Fresh install → Splash → Login

---

## 📝 Notes

**Why Disable Auto-Login?**
- Cleaner user experience
- Explicit authentication
- Better for demos
- Easier testing
- Security best practice

**When to Re-enable?**
If you want persistent login:
1. Uncomment `_checkAuthStatus()` in auth_provider.dart
2. Change initial state to `AsyncValue.loading()`
3. Update splash screen to check auth state

**Customization:**
- Adjust splash duration in `Future.delayed`
- Modify fade animation speed in `AnimationController`
- Change logo size/shadow as needed
- Update app name/tagline text

This provides a professional, polished app startup experience! 🚀
