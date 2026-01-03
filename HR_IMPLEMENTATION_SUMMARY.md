# DayFlow HRMS - HR Functions Implementation Summary

## Overview
Implemented a complete HR management system with auto-generated login IDs, company registration, and employee management features following the provided UI mockups.

## Color Theme
- Light Blue: #C1E8FF
- Soft Blue: #7DA0CA  
- Steel Blue: #5483B3
- Deep Navy: #052659
- Darkest Navy: #021024

## Key Features Implemented

### 1. **Company Registration (Signup)**
**Backend Changes:**
- Created new `Company` model (`backend/src/models/Company.js`)
  - Stores company name, initials, email, phone, logo
  - Tracks employee count
  - Links to HR user

- Updated `User` model to include:
  - `loginId` field for auto-generated employee IDs
  - `company` reference to link users to companies

- Updated `register` endpoint in `auth.controller.js`:
  - Creates Company record for HR registration
  - Links HR user to company

**Frontend Changes:**
- Complete redesign of `signup_screen.dart`:
  - Added fields: Company Name, Company Initials, Admin Name, Email, Phone, Password, Confirm Password
  - Includes logo upload placeholder
  - Added `registerCompany()` method to auth provider
  - Proper validation for all fields

### 2. **Auto-Generated Login IDs**
**Format:** `COMPANYINITIALS` + `FirstName(2 letters)` + `LastName(2 letters)` + `Year(2 digits)` + `SerialNumber(4 digits)`

**Example:** `GEJD020320001`
- GE = Company Initials
- JD = John Doe (first 2 letters of first name + first 2 letters of last name)
- 03 = Year 2023
- 0001 = First employee of the year

**Backend Implementation:**
- Updated `createEmployee` in `employee.controller.js`:
  - Auto-generates unique login IDs based on format above
  - Generates random default password
  - Creates both User and Employee records
  - Returns login credentials in response
  - Increments company employee count

- Updated `login` in `auth.controller.js`:
  - Supports login with both email AND loginId
  - Returns loginId in response

### 3. **Employee Creation (HR Only)**
**Backend:**
- POST `/api/employees` endpoint creates:
  1. User account with auto-generated loginId
  2. Employee profile with all details
  3. Auto-generated email if not provided: `{loginId}@{companyname}.com`
  4. Random secure password

- Response includes:
  ```json
  {
    "success": true,
    "data": { employee details },
    "loginCredentials": {
      "loginId": "GEJD020320001",
      "password": "Temp@xyz123",
      "message": "Share these credentials with the employee"
    }
  }
  ```

**Frontend:**
- Updated `employee_list.dart`:
  - Removed email/password fields from creation form
  - Added validation for required fields
  - Shows generated credentials in dialog after employee creation
  - Displays: Login ID, Password, and note to change password
  - Refreshes employee list automatically

### 4. **Logout Functionality**
**Fixed:**
- Logout button in admin dashboard calls `ref.read(authProvider.notifier).logout()`
- `logout()` method clears:
  - `jwt_token` from secure storage
  - `user_role` from secure storage
  - Sets auth state to null
- `splash_screen.dart` listens to auth state and redirects to login when null
- Navigation automatically redirects to `/login` on logout

## API Endpoints Summary

### Authentication
- `POST /api/auth/register` - Register HR with company
  - Body: { email, password, role, companyName, companyInitials, companyPhone, adminName }
  - Creates Company and HR User

- `POST /api/auth/login` - Login with email or loginId
  - Body: { email (or loginId), password }
  - Returns: { _id, email, loginId, role, token }

- `GET /api/auth/me` - Get current user info

### Employees (HR Only)
- `POST /api/employees` - Create employee with auto-generated loginId
  - Body: { firstName, lastName, phone, designation, department, baseSalary, dateOfJoining, address }
  - Returns employee data + login credentials

- `GET /api/employees` - Get all employees
- `GET /api/employees/:id` - Get employee by ID
- `PUT /api/employees/:id` - Update employee
- `GET /api/employees/me` - Get my employee profile
- `PUT /api/employees/me` - Update my profile (limited fields)

## Database Models

### Company
```javascript
{
  name: String (unique),
  initials: String (2-4 chars),
  email: String,
  phone: String,
  logo: String,
  hrUser: ObjectId (ref User),
  employeeCount: Number,
  createdAt: Date
}
```

### User
```javascript
{
  loginId: String (unique, for employees),
  email: String (unique),
  password: String (hashed),
  role: 'Employee' | 'HR',
  company: ObjectId (ref Company),
  isVerified: Boolean,
  employeeProfile: ObjectId (ref Employee),
  createdAt: Date
}
```

### Employee
```javascript
{
  user: ObjectId (ref User),
  firstName: String,
  lastName: String,
  phone: String,
  designation: String,
  department: String,
  dateOfJoining: Date,
  baseSalary: Number,
  address: String,
  profilePicture: String,
  isActive: Boolean
}
```

## Testing Instructions

### 1. Register a Company
1. Go to Signup page
2. Fill in:
   - Company Name (e.g., "Global Enterprises")
   - Company Initials (e.g., "GE")
   - Admin Name
   - Email
   - Phone
   - Password
   - Confirm Password
3. Click "Sign Up"
4. Should redirect to Admin Dashboard

### 2. Create an Employee
1. Navigate to "Employees" from admin dashboard
2. Click the (+) floating action button
3. Fill in employee details:
   - First Name: John
   - Last Name: Doe
   - Phone: 1234567890
   - Designation: Developer
   - Department: Engineering
   - Base Salary: 50000
   - Address: Optional
4. Click "Create Employee"
5. A dialog will show:
   - Login ID: e.g., GEJO030320001
   - Password: e.g., Temp@xyz123
6. Share these credentials with the employee

### 3. Employee Login
1. Logout from HR account
2. Go to Login page
3. Enter the generated Login ID and Password
4. Should redirect to Employee Dashboard

### 4. Logout
1. Click logout button in AppBar
2. Should redirect to login page

## Files Modified

### Backend
1. `backend/src/models/Company.js` - NEW
2. `backend/src/models/User.js` - Added loginId, company
3. `backend/src/controllers/auth.controller.js` - Company registration, loginId support
4. `backend/src/controllers/employee.controller.js` - Auto-generate loginId
5. `backend/src/models/Employee.js` - No changes needed

### Frontend
1. `lib/presentation/screens/auth/signup_screen.dart` - Complete redesign
2. `lib/presentation/screens/admin/employee_list.dart` - Updated employee creation
3. `lib/logic/providers/auth_provider.dart` - Added registerCompany method
4. `lib/data/services/employee_service.dart` - Return response data
5. `lib/config/theme.dart` - Already had correct colors

## Next Steps (As per Design Mockups)

1. **Dashboard Improvements:**
   - Employee cards grid layout
   - Profile dropdown menu with "My Profile" and "Log Out"
   - Avatar/profile picture support

2. **Employee Profile View:**
   - Resume tab
   - Private Info tab
   - Salary Info tab
   - Security tab (change password)

3. **Attendance Management:**
   - Check In/Check Out functionality
   - Date/day navigation
   - Work hours tracking
   - Status indicators (On-time, Late, Absent)

4. **Payroll/Salary Components:**
   - Wage types
   - Salary components (HRA, Basic, Allowances, etc.)
   - Automatic salary calculation
   - Component configuration

## Notes
- Login IDs are auto-generated and cannot be changed
- Passwords should be changed by employees on first login (to be implemented)
- Company initials are used for all employee login IDs
- Serial number resets each year
- HR users login with email, Employees with loginId
