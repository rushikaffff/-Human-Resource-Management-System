# Time Off Management System - Complete Documentation

## 🎯 Overview

A comprehensive time-off request system with role-based access control, allowing admins to manage requests and employees to view their own records.

---

## 📐 Layout Structure

```
┌─────────────────────────────────────────────┐
│ Logo  HR Management            [Profile]    │
├─────────────────────────────────────────────┤
│ 🏢Company  👥Employees  ⏰Attendance  📅TO  │ ← Time Off highlighted
├─────────────────────────────────────────────┤
│ [Time OFF] [Allocation]           [+ NEW]   │ ← Sub-tabs + NEW button
├─────────────────────────────────────────────┤
│ [Search...]                                 │
├─────────────────────────────────────────────┤
│ ┌──────────────────┐  ┌──────────────────┐ │
│ │ Paid Time Off    │  │ Sick Time Off    │ │ ← Category Cards
│ │ 28 Days Available│  │ 07 Days Available│ │
│ └──────────────────┘  └──────────────────┘ │
├─────────────────────────────────────────────┤
│ Time Off Requests            [Admin View]   │
├─────┬──────┬──────┬─────────┬──────┬──────┤
│Name │Start │ End  │Type     │Status│Action│ ← Table Header
├─────┼──────┼──────┼─────────┼──────┼──────┤
│Emp  │25/10 │29/10 │Paid Time│Pend. │[✓][✗]│ ← Request Row
└─────┴──────┴──────┴─────────┴──────┴──────┘
                                        [+ NEW]  ← FAB
```

---

## 🧩 Components

### 1. **Top Navigation**
- Company Logo
- Employees
- Attendance
- **Time Off** (highlighted in blue)

### 2. **Sub-Tabs**
- **Time OFF** - Main view with requests
- **Allocation** - Configure allocations

### 3. **NEW Button**
- Floating Action Button
-  Creates new time-off request
- Prominent blue background

### 4. **Search Bar**
- Filter by employee name
- Real-time filtering
- Case-insensitive

### 5. **Time-Off Categories**

**Paid Time Off:**
- Blue gradient card
- Beach icon
- Shows: 28 Days Available
- Large, bold number

**Sick Time Off:**
- Orange gradient card
- Hospital icon
- Shows: 07 Days Available
- Large, bold number

### 6. **Requests Table**

**Columns:**
1. **Name** - Employee name
2. **Start Date** - Format: dd/MM/yyyy
3. **End Date** - Format: dd/MM/yyyy
4. **Time Off Type** - Badge (Blue/Orange)
5. **Status** - Badge (Green/Orange/Red)
6. **Actions** - Approve/Reject buttons (Admin only)

---

## 🔐 Role-Based Access

### Admin/HR Officer View:

**Can See:**
- ✅ All employees' time-off requests
- ✅ Approve/Reject buttons for pending requests
- ✅ All categories and allocations
- ✅ Badge: "Admin View - All Employees"

**Actions:**
- Approve requests (green check button)
- Reject requests (red X button)
- View all requests
- Search any employee
- Create requests for employees

### Employee View:

**Can See:**
- ✅ Own time-off requests only
- ✅ Own time-off balance
- ✅ Status of submitted requests
- ✅ Badge: "My Requests"

**Cannot See:**
- ❌ Other employees' requests
- ❌ Approve/Reject buttons
- ❌ Admin functions

**Actions:**
- View own requests
- Create new request
- Check time-off balance

---

## 📊 Time-Off Categories

### Paid Time Off (PTO):
- **Color**: Blue (#2196F3)
- **Icon**: Beach access
- **Allocation**: 28 days/year
- **Usage**: Vacation, personal days
- **Calculation**: Accrued monthly or annually

### Sick Time Off:
- **Color**: Orange (#FF9800)
- **Icon**: Hospital
- **Allocation**: 7 days/year
- **Usage**: Medical/health reasons
- **Carry Forward**: May have different rules

### Additional Categories (Future):
- Casual Leave
- Maternity/Paternity Leave
- Bereavement Leave
- Unpaid Leave
- Compensatory Off

---

## 📋 Request Status System

### Pending:
- **Color**: Orange
- **Badge**: "Pending"
- **Shows**: Approve/Reject buttons (Admin)
- **Action Required**: Awaiting admin approval

### Approved:
- **Color**: Green
- **Badge**: "Approved"
- **Shows**: No action buttons
- **Confirmed**: Employee can take time off

### Rejected:
- **Color**: Red
- **Badge**: "Rejected"
- **Shows**: No action buttons
- **Result**: Request denied

---

## ⚙️ Request Workflow

### Employee Flow:
1. Click **NEW** button
2. Fill request form:
   - Select time-off type
   - Choose start date
   - Choose end date
   - Add reason (optional)
3. Submit request
4. Status: **Pending**
5. Wait for admin approval

### Admin Flow:
1. View time-off requests
2. See pending requests
3. Review employee request:
   - Check dates
   - Verify balance
   - Consider workload
4. Decision:
   - Click **Approve** (✓) → Status: Approved
   - Click **Reject** (✗) → Status: Rejected
5. Employee notified

---

## 💼 Business Logic

### Balance Calculation:
```dart
Available Days = Allocated Days - Used Days - Pending Days

Example:
Paid Time Off:
- Allocated: 28 days
- Used: 10 days
- Pending: 5 days
- Available: 28 - 10 - 5 = 13 days
```

### Request Duration:
```dart
Duration = (End Date - Start Date) + 1

Example:
Start: 25/10/2025
End: 29/10/2025
Duration: (29 - 25) + 1 = 5 days
```

### Validation Rules:
- ✅ Cannot exceed available balance
- ✅ Cannot overlap with existing approved requests
- ✅ Cannot request past dates
- ✅ End date must be after start date
- ✅ Minimum 1 day request

---

## 📱 Responsive Design

### Desktop (> 600px):
- Full table layout
- Category cards side-by-side
- All columns visible
- Approve/Reject buttons inline

### Mobile (< 600px):
- Card-based layout
- Category cards stacked
- Request cards with all info
- Approve/Reject buttons full-width
- Search bar full-width

---

## 🎨 Visual Design

### Colors:
```
Paid Time Off:       Blue (#2196F3)
Sick Time Off:       Orange (#FF9800)
Approved Status:     Green (#4CAF50)
Pending Status:      Orange (#FF9800)
Rejected Status:     Red (#F44336)
Selected Tab:        Steel Blue (#5483B3)
Floating Button:     Steel Blue (#5483B3)
```

### Typography:
- **Page Title**: 20px, Bold
- **Category Title**: 16px, Semi-bold
- **Days Available**: 24px, Bold
- **Table Headers**: 13px, Semi-bold
- **Request Data**: 14px, Medium
- **Status Badges**: 12px, Semi-bold

---

## 🔄 Data Model

```dart
class TimeOffRequest {
  String employeeName;
  DateTime startDate;
  DateTime endDate;
  String timeOffType;  // "Paid Time Off" or "Sick Time Off"
  String status;       // "Pending", "Approved", "Rejected"
  
  // Auto-calculated
  String startDateFormatted;  // "25/10/2025"
  String endDateFormatted;    // "29/10/2025"
  int durationInDays;         // 5
}
```

---

## 📑 Features List

### Current Features:
✅ **Role-Based Views**
   - Admin: All employees
   - Employee: Own records only

✅ **Sub-Tabs**
   - Time OFF (main view)
   - Allocation (configuration)

✅ **Time-Off Categories**
   - Paid Time Off (28 days)
   - Sick Time Off (7 days)

✅ **Request Management**
   - View requests table
   - Search functionality
   - Status badges

✅ **Admin Actions**
   - Approve button (green)
   - Reject button (red)
   - Visible for pending only

✅ **NEW Request**
   - Floating button
   - Opens request form

✅ **Responsive Design**
   - Desktop table view
   - Mobile card view

---

## 🚀 Future Enhancements

### Phase 1:
- ⏳ Complete NEW request form
- ⏳ Calendar integration
- ⏳ Conflict detection

### Phase 2:
- ⏳ Email notifications
- ⏳ Balance history
- ⏳ Team calendar view

### Phase 3:
- ⏳ Approval workflows
- ⏳ Delegation rules
- ⏳ Custom leave types

### Phase 4:
- ⏳ Analytics dashboard
- ⏳ Export reports
- ⏳ Mobile app integration

---

## 📖 Usage Examples

### Employee Requesting Leave:
1. Click **NEW** button
2. Select "Paid Time Off"
3. Start: 25/10/2025
4. End: 29/10/2025
5. Submit
6. Status: Pending
7. Wait for approval

### Admin Approving Request:
1. View Time Off tab
2. See pending request
3. Review: 5 days requested
4. Check: Employee has 13 days available
5. Click **Approve** ✓
6. Status changes to: Approved
7. Employee can proceed with leave

### Admin Rejecting Request:
1. View pending request
2. Reason: Insufficient coverage
3. Click **Reject** ✗
4. Status: Rejected
5. Employee notified

---

## 💡 Business Rules

### Balance Management:
- Allocated annually
- Can be pro-rated for new joiners
- May have carry-forward limits
- Separate pools for different types

### Approval Authority:
- Direct manager: First approver
- HR: Final approver (optional)
- Auto-approve: For certain types (optional)

### Notifications:
- Employee: On submit, approve, reject
- Admin: On new request
- Manager: On team member request

### Integration:
- Attendance: Auto-mark as leave
- Payroll: Calculate leave deductions
- Calendar: Block employee availability

---

## ✅ Key Highlights

✅ **Clean Interface** - Professional, intuitive design
✅ **Role-Sensitive** - Different views for admin/employee
✅ **Real-Time Search** - Filter requests instantly
✅ **Visual Categories** - Gradient cards with icons
✅ **Action Buttons** - Approve/Reject with colors
✅ **Status Badges** - Color-coded for clarity
✅ **Responsive** - Works on all devices
✅ **Floating NEW** - Easy request creation

This comprehensive time-off system provides complete leave management with proper access controls and intuitive workflows! 🎯
