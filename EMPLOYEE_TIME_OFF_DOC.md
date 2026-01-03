# Employee Self-Service Time Off - Complete Documentation

## 🎯 Overview

A self-service time-off management interface for employees to view their leave balance, request time off, and track their request history.

---

## 📐 Employee View Layout

```
┌─────────────────────────────────────────────┐
│ Logo  HR Management            [Profile]    │
├─────────────────────────────────────────────┤
│ 🏢Company  👥Employees  ⏰Attendance  📅TO  │ ← Time Off highlighted
├─────────────────────────────────────────────┤
│ [Time OFF] [Allocation]                     │
├─────────────────────────────────────────────┤
│ [Search...]                                 │
├─────────────────────────────────────────────┤
│ ┌──────────────────┐  ┌──────────────────┐ │
│ │ Paid Time Off    │  │ Sick Time Off    │ │
│ │ 24 Days Available│  │ 07 Days Available│ │ ← Employee Balance
│ └──────────────────┘  └──────────────────┘ │
├─────────────────────────────────────────────┤
│ My Time Off Requests                        │
├──────┬──────┬──────┬──────────┬────────────┤
│ Name │Start │ End  │Type      │Status      │
├──────┼──────┼──────┼──────────┼────────────┤
│ Me   │24/10 │29/10 │Paid Time │Pending     │
└──────┴──────┴──────┴──────────┴────────────┘
                                        [+ NEW]  ← FAB
```

---

## 📋 NEW Request Form

**Title:** Time Off Type Request

**Form Fields:**

### 1. Employee (Auto-filled, Disabled)
- **Value**: Current employee name
- **Icon**: Person (👤)
- **Background**: Grey (disabled state)
- **Purpose**: Shows who is making the request

### 2. Time Off Type * (Required)
- **Type**: Dropdown
- **Icon**: Category
- **Options**:
  - Paid Time Off
  - Sick Time Off
  - Unpaid Leaves
- **Default**: Paid Time Off

### 3. Validity Period * (Required)
- **Type**: Date Range Picker
- **Components**:
  - **Start Date**: Calendar picker
  - **End Date**: Calendar picker
- **Icons**: calendar_today, event
- **Validation**: End date must be after start date

### 4. Allocation (Auto-calculated)
- **Type**: Display only
- **Calculation**: (End Date - Start Date) + 1
- **Format**: "X Days" or "X Day"
- **Display**: Blue badge with white text
- **Icon**: Calculate
- **Updates**: Automatically when dates change

### 5. Attachment (Optional)
- **Purpose**: For sick leave certificate
- **Type**: File upload
- **Icon**: upload_file
- **States**:
  - Empty: "Click to upload file"
  - Uploaded: Shows file name with remove button
- **Note**: "For sick leave certificate"

### 6. Submit Button
- **Label**: "Submit Request"
- **Color**: Steel Blue
- **Size**: Full width, 56px height
- **Action**: Submit form and close dialog

---

## 🎨 Form Design Specification

### Colors:
```
AppBar Background:     Deep Navy (#052659)
AppBar Text:           White (#FFFFFF)
Form Background:       White (#FFFFFF)
Field Fill:            Light Grey (#F5F5F5)
Border:                Grey 300 (#E0E0E0)
Focus Border:          Steel Blue (#5483B3)
Button Background:     Steel Blue (#5483B3)
Button Text:           White (#FFFFFF)
Allocation Badge:      Steel Blue (#5483B3)
```

### Spacing:
```
Form Padding:          24px all sides
Field Spacing:         20px between fields
Section Spacing:       32px before submit
Border Radius:         12px (all elements)
Button Height:         56px
```

### Typography:
```
AppBar Title:          18px, Medium
Section Headers:       16px, Semi-bold
Field Labels:          14px, Regular
Input Text:            16px, Regular
Helper Text:           12px, Regular
Button Text:           18px, Bold
Allocation Value:      18px, Bold
```

---

## 📊 Leave Balance Display

### Paid Time Off:
- **Color**: Blue (#2196F3)
- **Icon**: Beach access (🏖️)
- **Admin View**: 28 Days Available
- **Employee View**: **24 Days Available**
- **Gradient**: Blue to lighter blue

### Sick Time Off:
- **Color**: Orange (#FF9800)
- **Icon**: Hospital (🏥)
- **Days**: 07 Days Available
- **Gradient**: Orange to lighter orange

---

## 🔄 Request Workflow

### Employee Flow:
```
1. Navigate to Time Off tab
2. View current balance:
   - Paid: 24 days
   - Sick: 7 days
3. Click NEW button (FAB)

4. Form opens - "Time Off Type Request"

5. Fill form:
   ✓ Employee: [Auto-filled] - You
   ✓ Type: Select from dropdown
   ✓ Start Date: Pick from calendar
   ✓ End Date: Pick from calendar
   ✓ Allocation: [Auto-shows] X Days
   ✓ Attachment: Upload if needed

6. Click "Submit Request"

7. Form closes
8. Success message: "Time off request submitted: X days"
9. Request appears in table with "Pending" status
10. Wait for admin approval
```

---

## ⚙️ Auto-Calculation Logic

### Allocation Calculation:
```dart
int calculateDays(DateTime start, DateTime end) {
  return end.difference(start).inDays + 1;
}

Examples:
Start: 25/10/2025  End: 29/10/2025  → 5 Days
Start: 01/11/2025  End: 01/11/2025  → 1 Day
Start: 10/12/2025  End: 20/12/2025  → 11 Days
```

### Display Format:
```dart
String allocationText = '$days ${days == 1 ? 'Day' : 'Days'}';

1 → "1 Day"
5 → "5 Days"  
```

---

## ✅ Form Validation

### Rules:
1. **Time Off Type**: Required (dropdown default selected)
2. **Start Date**: Required, must be today or future
3. **End Date**: Required, must be >= Start Date
4. **Allocation**: Auto-calculated (no validation needed)
5. **Attachment**: Optional

### Error Messages:
- No dates: "Please select validity period" (red SnackBar)
- Form invalid: Standard validation messages

### Success Message:
- "Time off request submitted: X days" (green SnackBar)

---

## 📱 Responsive Behavior

### Desktop:
- Form width: Max 500px
- Form height: Max 700px
- Side-by-side date pickers
- Full-width submit button
- Clean padding and spacing

### Mobile:
- Full-screen dialog
- Stacked date pickers
- Touch-friendly buttons
- Scrollable content
- Same functionality

---

## 🔐 Employee Restrictions

### Can Do:
✅ View own leave balance
✅ Create new time-off requests
✅ View own request history
✅ See request status
✅ Upload attachments

### Cannot Do:
❌ View other employees' requests
❌ Approve/Reject requests
❌ Edit balance
❌ Delete submitted requests
❌ View admin functions

---

## 📂 File Attachment

### Purpose:
- Upload sick leave certificate
- Support documentation
- Medical proof

### Current State:
- Mock implementation
- Shows file name when "uploaded"
- Remove button appears
- Coming soon message

### Future Implementation:
```dart
// Will use file_picker package
import 'package:file_picker/file_picker.dart';

Future<void> _pickFile() async {
  FilePickerResult? result = await FilePicker.platform.pickFiles(
    type: FileType.custom,
    allowedExtensions: ['pdf', 'jpg', 'png'],
  );
  
  if (result != null) {
    setState(() {
      _attachmentName = result.files.single.name;
      _attachmentPath = result.files.single.path;
    });
  }
}
```

---

## 🎯 Time Off Types

### 1. Paid Time Off:
- **Purpose**: Vacation, personal days
- **Balance**: 24 days (for employee)
- **Approval**: Required
- **Carry Forward**: Yes (policy dependent)

### 2. Sick Time Off:
- **Purpose**: Medical leave
- **Balance**: 7 days
- **Approval**: Required
- **Document**: Certificate may be required

### 3. Unpaid Leaves:
- **Purpose**: Extended leave without pay
- **Balance**: No limit
- **Approval**: Required
- **Impact**: Salary deduction

---

## 💼 Business Logic

### Balance Deduction:
```
After approval:
Paid Balance = Current Balance - Requested Days

Example:
Current: 24 days
Request: 5 days
After approval: 24 - 5 = 19 days
```

### Request Status Flow:
```
1. Employee submits → Status: Pending
2. Admin reviews → Can Approve or Reject
3. Approved → Status: Approved, Balance deducted
4. Rejected → Status: Rejected, No deduction
```

---

## 🎨 Visual Elements

### Form AppBar:
- Dark navy background
- White text
- Close button (X)
- Title centered

### Date Picker Cards:
- Light grey background
- Calendar icons
- Label + Value layout
- Rounded corners
- Border on all sides

### Allocation Display:
- Light blue background
- Icon + Label on left
- Badge value on right
- Full-width container
- Prominent display

### Attachment Upload:
- File icon in blue circle
- Upload text/filename
- Remove button when uploaded
- Helper text below label

---

## 📊 Request History Table

### Employee View Columns:
1. **Name**: Own name (all rows same)
2. **Start Date**: dd/MM/yyyy format
3. **End Date**: dd/MM/yyyy format
4. **Time Off Type**: Colored badge
5. **Status**: Colored badge (Pending/Approved/Rejected)

### No Action Buttons:
- Employees cannot approve/reject
- Only view status
- Table is read-only

---

## ✨ Key Features

✅ **Self-Service Portal**
   - Employees manage own requests
   - View personal balance
   - Track request status

✅ **Easy Request Creation**
   - Simple form layout
   - Auto-filled employee
   - Dropdown selection
   - Visual date pickers

✅ **Auto-Calculation** 
   - Real-time day calculation
   - Updates on date change
   - Clear display

✅ **Document Support**
   - Attachment upload
   - File name display
   - Remove option

✅ **Clean UI**
   - Professional design
   - Intuitive layout
   - Mobile-friendly
   - Validation feedback

✅ **Status Tracking**
   - Pending requests visible
   - Approved/Rejected history
   - Color-coded status

This employee self-service interface provides a complete time-off management experience with minimal friction and maximum clarity! 🎯
