# Quick Reference - DayFlow HRMS

## 🔑 Login ID Format
```
COMPANYINITIALS + FirstName(2) + LastName(2) + Year(4) + Serial(4)

Example:
- Company: "Global Enterprises" → Initials: "GE"
- Employee: John Doe joining in 2024
- Serial: 0001 (first employee of year)
- Result: GE30JO202420001
          ^^  ^^  ^^^^  ^^^^
          |   |   |     |
Company --+   |   |     +-- Serial Number
   FirstName--+   |
      LastName----+
           Year---+
```

## 📊 Database Scripts

```bash
# View all database records
node view-db.js

# Check if users are linked to companies
node check-links.js

# Clear entire database (with confirmation)
node clear-db.js
```

## 🔍 Debugging 400 Errors

1. **Check Backend Logs**: Look for `❌ Create Employee Error:`
2. **Check Request Body**: Look for `📝 Create Employee Request Body:`
3. **Verify User ID**: Look for `👤 User ID:`

Common Issues:
- HR user not linked to company
- Missing required fields
- Invalid data format

## 🎨 Color Palette
```
Light Blue: #C1E8FF
Soft Blue:  #7DA0CA  
Steel Blue: #5483B3
Deep Navy:  #052659
Dark Navy:  #021024
Purple:     #9B59B6 (buttons)
```

## 🚀 Quick Test Flow

1. **Signup** → Company + HR account created
2. **Login as HR** → Access admin dashboard
3. **Create Employee** → Get Login ID & Password
4. **Logout** → Exit HR account
5. **Login as Employee** → Use generated credentials

## 📁 Key Files

**Backend:**
- `src/models/User.js` - User model with loginId
- `src/models/Company.js` - Company model
- `src/controllers/employee.controller.js` - Employee creation
- `src/controllers/auth.controller.js` - Auth logic

**Frontend:**
- `lib/presentation/screens/auth/signup_screen.dart` - Signup UI
- `lib/presentation/screens/auth/login_screen.dart` - Login UI
- `lib/logic/providers/auth_provider.dart` - Auth state
- `lib/presentation/screens/admin/employee_list.dart` - Add employee

## ⚡ Auto-Generation Features

✅ **Login IDs** - Auto-generated for employees  
✅ **Passwords** - Auto-generated, can be changed  
✅ **Company Initials** - Derived from company name  
✅ **Email** - Generated if not provided: `{loginid}@{company}.com`

## 📞 Support

Run `node view-db.js` to see current database state.
Check backend terminal for detailed error messages.
