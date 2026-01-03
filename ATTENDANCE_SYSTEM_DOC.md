# Attendance Management System - Complete Documentation

## 🎯 Overview

A comprehensive attendance tracking system with automatic calculations for work hours, extra hours, and payroll integration.

---

## 📐 Layout Structure

```
┌─────────────────────────────────────────────────────┐
│  Logo   HR Management              [Profile]        │  ← AppBar
├─────────────────────────────────────────────────────┤
│ 🏢Company  👥Employees  ⏰Attendance  📅Time Off    │  ← Tabs
├─────────────────────────────────────────────────────┤
│ [Search...]  [Date ▼]  [Day]                       │  ← Controls
├─────────────────────────────────────────────────────┤
│ Attendance Records              22 October 2025     │
├────────┬──────────┬──────────┬──────────┬──────────┤
│Employee│ Check In │Check Out │Work Hours│Extra Hrs │  ← Table Header
├────────┼──────────┼──────────┼──────────┼──────────┤
│John Doe│  10:00   │  19:00   │  09:00   │  01:00   │
│Jane S. │  10:00   │  14:00   │  03:00   │  00:00   │
└────────┴──────────┴──────────┴──────────┴──────────┘
```

---

## 🧩 Key Components

### 1. **Top Navigation Bar**

**Tabs:**
- 🏢 Company Logo
- 👥 Employees
- ⏰ **Attendance** (Highlighted)
- 📅 Time Off

**Design:**
- Selected tab: Blue background (#5483B3)
- Icons with labels
- Horizontal scroll on mobile
- FilterChip style

### 2. **Controls Bar**

**Search Bar:**
- Searchable by employee name
- Icon: Search (🔍)
- Real-time filtering
- Placeholder: "Search employee..."

**Date Selector:**
- Calendar icon
- Date picker dialog
- Format: "dd MMM yyyy" (e.g., "22 October 2025")
- Dropdown indicator

**Day Selector:**
- Event icon
- Displays day name
- Format: "EEEE" (e.g., "Wednesday")
- Auto-updates with date

### 3. **Attendance Table**

**Columns:**
1. **Employee** - Name with avatar
2. **Check In** - Time (HH:mm format)
3. **Check Out** - Time (HH:mm format)
4. **Work Hours** - Green badge
5. **Extra Hours** - Orange badge

**Mobile View:**
- Card-based layout
- Employee avatar + name
- Stacked info items
- Icon indicators

---

## ⚙️ Automatic Calculations

### Work Hours Formula:

```dart
Total Time = Check Out - Check In
Work Hours = Total Time - Break Duration
```

**Example:**
```
Check In:   10:00
Check Out:  19:00
Total:      09:00
Break:      -01:00
Work Hours: 08:00
```

### Extra Hours Formula:

```dart
Standard Work Hours = 8:00
Extra Hours = Work Hours - Standard Work Hours (if positive)
```

**Example:**
```
Work Hours:  09:00
Standard:    -08:00
Extra Hours:  01:00
```

### Payable Days Calculation:

```dart
if (workHours >= 4 hours)  → 1.0 day  (Full day)
if (workHours >= 2 hours)  → 0.5 day  (Half day)
if (workHours < 2 hours)   → 0.0 day  (No pay)
```

**Usage in Payroll:**
```dart
// Monthly payable days
final totalDays = attendanceRecords
    .map((record) => record.payableDays)
    .fold(0.0, (sum, days) => sum + days);

// Deduct from salary
final salaryPerDay = monthlySalary / 26; // 26 working days
final unpaidDays = 26 - totalDays;
final deduction = salaryPerDay * unpaidDays;
```

---

## 🔐 Role-Based Views

### Admin/HR View:
- ✅ **See all employees** attendance for selected day
- ✅ Search across all employees
- ✅ Export attendance data
- ✅ Edit attendance records
- ✅ View attendance reports

**Default View:** Current day, all employees

### Employee View:
- ✅ **See own attendance** for current month
- ✅ Day-wise breakdown
- ✅ Check in/out times
- ✅ Total work hours

**Default View:** Current month, own records

---

## 📊 Attendance Record Model

```dart
class AttendanceRecord {
  String employeeName;
  DateTime checkIn;
  DateTime? checkOut;
  Duration breakDuration;  // Default: 1 hour
  
  // Auto-calculated fields:
  String checkInFormatted;      // "10:00"
  String checkOutFormatted;     // "19:00"
  Duration totalTime;           // 9 hours
  Duration workHours;           // 8 hours (minus break)
  Duration extraHours;          // 1 hour
  String workHoursFormatted;    // "08:00"
  String extraHoursFormatted;   // "01:00"
  double payableDays;           // 1.0, 0.5, or 0.0
}
```

---

## 📱 Responsive Design

### Desktop (> 600px):
- ✅ Full table view
- ✅ Single row controls
- ✅ All columns visible
- ✅ Wider spacing
- ✅ Search + Date + Day in one row

### Mobile (< 600px):
- ✅ Card-based layout
- ✅ Stacked controls (Search, then Date/Day)
- ✅ Compact avatars
- ✅ Icon indicators
- ✅ Touch-friendly buttons
- ✅ Scrollable content

---

## 🎨 Color Coding

```
Check In/Out:     Default (Black text)
Work Hours Badge: Green (#4CAF50)
Extra Hours Badge: Orange (#FF9800)
Selected Tab:     Steel Blue (#5483B3)
Avatars:         Soft Blue (#7DA0CA)
Empty State:      Grey (#BDBDBD)
```

---

## 💼 Payroll Integration

### Monthly Attendance Summary:

```dart
// Calculate total payable days for month
double calculateMonthlyPayableDays(List<AttendanceRecord> records) {
  return records
      .map((r) => r.payableDays)
      .fold(0.0, (sum, days) => sum + days);
}

// Calculate unpaid leave deduction
double calculateUnpaidDeduction(
  double monthlySalary,
  double payableDays,
  int workingDays,
) {
  final salaryPerDay = monthlySalary / workingDays;
  final unpaidDays = workingDays - payableDays;
  return salaryPerDay * unpaidDays;
}
```

### Example Payroll Calculation:

```
Monthly Salary:     ₹50,000
Working Days:       26 days
Attended Days:      24.5 days (includes half-days)
Unpaid Days:        1.5 days

Salary Per Day:     ₹50,000 / 26 = ₹1,923
Deduction:          ₹1,923 × 1.5 = ₹2,885
Net Payable:        ₹50,000 - ₹2,885 = ₹47,115
```

---

## 🔄 Data Flow

### Admin Flow:
1. Navigate to Attendance tab
2. Select date (default: today)
3. View all employees
4. Search specific employee (optional)
5. See attendance records
6. Export/Print (future)

### Employee Flow:
1. Navigate to Attendance tab
2. View current month (default)
3. See own day-wise attendance
4. Check work hours and extra hours
5. Verify payable days

---

## ⏱️ Time Calculations Explained

### Standard Work Day:
```
Scheduled Hours:   09:00 - 18:00 (9 hours)
Break Time:        1 hour
Work Hours:        8 hours
```

### Example Scenarios:

**Scenario 1: Normal Day**
```
Check In:   09:00
Check Out:  18:00
Total:      09:00
Break:      01:00
Work:       08:00
Extra:      00:00
Payable:    1.0 day
```

**Scenario 2: Overtime**
```
Check In:   09:00
Check Out:  20:00
Total:      11:00
Break:      01:00
Work:       10:00
Extra:      02:00
Payable:    1.0 day
```

**Scenario 3: Half Day**
```
Check In:   09:00
Check Out:  14:00
Total:      05:00
Break:      01:00
Work:       04:00
Extra:      00:00
Payable:    0.5 day
```

**Scenario 4: Short Day**
```
Check In:   09:00
Check Out:  11:00
Total:      02:00
Break:      00:00
Work:       02:00
Extra:      00:00
Payable:    0.5 day
```

**Scenario 5: Very Short (No Pay)**
```
Check In:   09:00
Check Out:  10:30
Total:      01:30
Break:      00:00
Work:       01:30
Extra:      00:00
Payable:    0.0 day
```

---

## 📈 Future Enhancements

### Phase 1 (Current):
- ✅ View attendance list
- ✅ Search employees
- ✅ Date selection
- ✅ Auto-calculate hours
- ✅ Payable days logic

### Phase 2 (Planned):
- ⏳ Check-in/Check-out functionality
- ⏳ Real-time status updates
- ⏳ Geolocation verification
- ⏳ Late arrival notifications
- ⏳ Early departure alerts

### Phase 3 (Advanced):
- ⏳ Attendance reports (PDF/Excel)
- ⏳ Analytics dashboard
- ⏳ Attendance trends
- ⏳ Regularization requests
- ⏳ Bulk attendance import

### Phase 4 (Integration):
- ⏳ Biometric integration
- ⏳ Mobile app check-in
- ⏳ Leave integration
- ⏳ Shift management
- ⏳ Overtime approval workflow

---

## 🎯 Key Features

✅ **Automatic Calculations**
   - Work hours
   - Extra hours
   - Payable days

✅ **Role-Based Access**
   - Admin: All employees
   - Employee: Own records

✅ **Smart Search**
   - Real-time filtering
   - Case-insensitive

✅ **Date Controls**
   - Date picker
   - Day display
   - Easy navigation

✅ **Responsive UI**
   - Desktop table view
   - Mobile card view
   - Touch-friendly

✅ **Payroll Ready**
   - Payable days calculation
   - Unpaid leave deduction
   - Monthly summary logic

---

## 🔗 API Integration (Future)

### Get Attendance Records:
```javascript
GET /api/attendance?date=2026-01-03
GET /api/attendance/employee/:id?month=1&year=2026
```

### Create Attendance:
```javascript
POST /api/attendance/check-in
POST /api/attendance/check-out
```

### Update Attendance:
```javascript
PUT /api/attendance/:id
```

### Attendance Reports:
```javascript
GET /api/attendance/report?startDate=2026-01-01&endDate=2026-01-31
GET /api/attendance/summary/:employeeId
```

---

## 📝 Notes

**Important Considerations:**

1. **Break Time**: Configured per employee or company-wide
2. **Working Schedule**: Based on assigned attendance policy
3. **Holidays**: Attendance not required, deducted separately
4. **Leaves**: Approved leaves count as paid days
5. **Unpaid Leaves**: Reduce payable days count
6. **Extra Hours**: Can be compensated or added to leave balance

**Payslip Impact:**
- Attendance directly affects monthly salary
- Missing days = salary deduction
- Extra hours = overtime pay (if applicable)
- Leave balance = based on attendance compliance

This comprehensive attendance system provides complete visibility and automation for workforce management! 🚀
