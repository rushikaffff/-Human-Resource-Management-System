# Employee Profile Screen - Comprehensive Documentation

## 🎯 Overview

A detailed employee profile view with complete salary information, role-based access control, and comprehensive employee data display.

---

## 📐 Layout Structure

```
┌─────────────────────────────────────────────────────┐
│ [←] Employee Profile                                │  ← AppBar
├──────────────┬──────────────────────────────────────┤
│   SIDEBAR    │  MAIN CONTENT                        │
│              │                                      │
│ 🏢 Company   │  ┌────────────────────────────────┐ │
│ 👥 Employees │  │  PROFILE HEADER                │ │
│ ⏰ Attendance │  │  [Photo] Name Info | Company   │ │
│ 📅 Time Off  │  └────────────────────────────────┘ │
│              │                                      │
│              │  [Resume] [Private Info] [Salary Info]│
│              │                                      │
│              │  TAB CONTENT                        │
│              │                                      │
└──────────────┴──────────────────────────────────────┘
```

---

## 🧩 Components

### 1. **Sidebar** (Desktop only, > 900px)

Navigation items:
- 🏢 Company Logo
- 👥 Employees
- ⏰ Attendance
- 📅 Time Off

**Design:**
- Width: 250px
- Background: Deep Navy (#052659)
- Logo at top
- White icons and text (#FFFFFF70)

---

### 2. **Profile Header Card**

**Left Section:**
- Profile picture (100px circle)
- Initials if no photo
- Name (28px, bold)
- Login ID
- Email
- Mobile

**Right Section:**
- Company name
- Department
-Manager
- Location

**Icons:** Badge, Email, Phone, Business, Apartment, Person, Location

---

### 3. **Tabs**

Three tabs with role-based visibility:

| Tab | Visible To | Content |
|-----|-----------|---------|
| **Resume** | All | About, Skills, Experience |
| **Private Info** | All | Private employee data |
| **Salary Info** | **Admin Only** | Detailed salary breakdown |

**Design:**
- White background
- Selected tab: Blue (#5483B3)
- Unselected: Transparent
- Full width, equal spacing

---

## 💰 Salary Info Tab (Admin Only)

### Warning Banner
```
🔒 Salary Info Tab Should Only Be Visible to Admin
```
Orange warning at top

### 1. **Wage Cards** (Gradient Blue)

Two cards showing:
- **Monthly Wage**: ₹50,000
- **Yearly Wage**: ₹6,00,000

Design: Gradient from Steel Blue to Soft Blue

### 2. **Working Details**

Two info cards:
- **No of working days in a week**: 5 days
- **Break time**: 1.0 hrs

Light blue background with border

### 3. **Salary Components**

Detailed breakdown with percentages:

| Component | Amount | Calculation | % |
|-----------|--------|-------------|---|
| **Basic Salary** | ₹25,000 | 50% of monthly wage | 50.0% |
| **House Rent Allowance** | ₹12,500 | 50% of basic salary | 25.0% |
| **Standard Allowance** | ₹3,167 | Fixed amount | 6.3% |
| **Performance Bonus** | ₹2,083 | 8.33% of basic salary | 4.2% |
| **Leave Travel Allowance** | ₹2,083 | 8.33% of basic salary | 4.2% |
| **Fixed Allowance** | ₹5,167 | Remaining amount | 10.3% |

**Total = Monthly Wage**

### Calculation Formula:

```dart
final monthlyWage = baseSalary; // e.g., ₹50,000
final yearlyWage = monthlyWage * 12;

// Components
final basicSalary = monthlyWage * 0.50;           // 50%
final hra = basicSalary * 0.50;                   // 50% of basic
final standardAllowance = 3167.0;                  // Fixed
final performanceBonus = basicSalary * 0.0833;    // 8.33%
final lta = basicSalary * 0.0833;                 // 8.33%
final fixedAllowance = monthlyWage - (basicSalary + hra + standardAllowance + performanceBonus + lta);
```

### 4. **Provident Fund (PF) Contribution**

Both calculated at **12% of Basic Salary**:

| Type | Amount | Calculation | % |
|------|--------|-------------|---|
| **Employee** | ₹3,000 | 12% of ₹25,000 | 12.00% |
| **Employer** | ₹3,000 | 12% of ₹25,000 | 12.00% |

**Color**: Green (#4CAF50)

### 5. **Tax Deductions**

| Tax Type | Amount |
|----------|--------|
| **Professional Tax** | ₹200 / month |

---

## 🎨 Design Specifications

### Colors

```css
Background:              #F5F5F5 (Light gray)
Cards:                   #FFFFFF (White)
Primary (Steel Blue):    #5483B3
Soft Blue:               #7DA0CA
Light Blue:              #C1E8FF
Deep Navy:               #052659
Gradient Start:          #5483B3
Gradient End:            #7DA0CA
PF Green:                #4CAF50
Warning Orange:          #FF9800
```

### Typography

- **Name**: 28px, Bold, Deep Navy
- **Section Titles**: 18px, Bold, Deep Navy
- **Labels**: 14px, Regular, Gray
- **Values**: 14px, Semibold, Deep Navy
- **Percentages**: 13px, Semibold, Steel Blue
- **Amount**: 20-24px, Bold

### Spacing

- Card Padding: 24px
- Section Spacing: 24px
- Row Spacing: 12px
- Small Gap: 8px
- Card Border Radius: 12px

---

## 🔐 Role-Based Access Control

### Admin View (isAdminView = true, role = 'HR')

**Can See:**
- ✅ Resume Tab
- ✅ Private Info Tab
- ✅ **Salary Info Tab** ← Exclusive
- ✅ All employee details
- ✅ Full salary breakdown
- ✅ PF contributions
- ✅ Tax deductions

### Employee View (role = 'Employee')

**Can See:**
- ✅ Resume Tab
- ✅ Private Info Tab
- ❌ **Salary Info Tab** ← Hidden
- ✅ Own profile details (read-only)

### Implementation:

```dart
final isAdmin = widget.isAdminView && authState.value?.role == 'HR';

// Filter tabs
final availableTabs = isAdmin 
    ? _tabs  // All tabs
    : _tabs.where((t) => t != 'Salary Info').toList();  // Exclude salary
```

---

## 📊 Resume Tab

**Sections:**

### 1. About
- Text description of employee
- Lorem ipsum placeholder

### 2. Skills
- Chip-based display
- Example: Flutter, Dart, JavaScript, Node.js, MongoDB
- Light blue background chips

### 3. Education & Experience
- Timeline view with bullets
- Each entry shows:
  - Title (e.g., "Senior Developer")
  - Company (e.g., "DayFlow Corp")
  - Period (e.g., "2023 - Present")

**Visual:** Blue circle bullets with connecting lines

---

## 📋 Private Info Tab

**Placeholder for:**
- Personal documents
- Emergency contacts
- Bank details
- ID proofs
- Address proof
- Family information

**Current:** Coming soon message

---

## 📱 Responsive Design

### Desktop (> 900px)
- ✅ Sidebar visible
- ✅ Two-column wage cards
- ✅ Wide salary component rows
- ✅ Comfortable spacing

### Tablet/Mobile (< 900px)
- ✅ No sidebar
- ✅ Stacked wage cards
- ✅ Scrollable content
- ✅ Compact rows
- ✅ Touch-friendly buttons

---

## 🔄 Navigation

### Opening Profile:

**From Dashboard:**
1. Click employee card
2. Navigates to `EmployeeProfileScreen`
3. Passes employee data
4. Sets `isAdminView = true`

**Back Button:**
1. AppBar has back arrow
2. Click to return to dashboard

### Tab Switching:
1. Click tab button
2. Tab highlights in blue
3. Content updates instantly
4. Smooth transition

---

## 💡 Calculations Explained

### Example: Monthly Wage = ₹50,000

```
Basic Salary (50%)               = ₹25,000
  ├─ HRA (50% of basic)          = ₹12,500
  ├─ Performance Bonus (8.33%)   = ₹2,083
  └─ LTA (8.33%)                 = ₹2,083
Standard Allowance (fixed)       = ₹3,167
Fixed Allowance (remaining)      = ₹5,167
                                  ──────────
TOTAL                            = ₹50,000

PF Employee (12% of basic)       = ₹3,000
PF Employer (12% of basic)       = ₹3,000
Professional Tax                 = ₹200
```

### Take Home Calculation:
```
Gross Salary                     = ₹50,000
- PF Employee                    = -₹3,000
- Professional Tax               = -₹200
                                  ──────────
Net Take Home                    = ₹46,800
```

---

## 🎯 Key Features

✅ **Comprehensive Salary Breakdown**
✅ **Role-Based Tab Visibility**
✅ **Automatic Percentage Calculations**
✅ **PF Contributions (Employee + Employer)**
✅ **Tax Deductions Display**
✅ **Working Days & Break Time**
✅ **Responsive Layout**
✅ **Professional Design**
✅ **Number Formatting** (Indian format: ₹50,000)
✅ **Gradient Wage Cards**
✅ **Clean Visual Hierarchy**

---

## 🚀 Future Enhancements

**Planned Features:**
- ⏳ Edit salary components
- ⏳ Salary history/revisions
- ⏳ Bonus calculation rules
- ⏳ Custom allowances
- ⏳ Multiple tax slabs
- ⏳ Salary slip generation
- ⏳ Export to PDF
- ⏳ Year-to-date summary
- ⏳ Comparison charts
- ⏳ Deduction rules engine

---

## 📖 Usage Example

```dart
// Navigate to employee profile
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => EmployeeProfileScreen(
      employee: employeeData,
      isAdminView: true,  // Only admin can see salary
    ),
  ),
);
```

---

## 🎨 UI/UX Highlights

**Professional:**
- Clean white cards
- Organized sections
- Clear labels

**Informative:**
- Detailed breakdowns
- Helpful percentages
- Visual separators

**Secure:**
- Role-based access
- Admin-only sections
- Warning indicators

**Responsive:**
- Mobile-friendly
- Touch-optimized
- Flexible layout

This comprehensive employee profile provides HR/Admin users with complete visibility into employee compensation while maintaining appropriate access controls!
