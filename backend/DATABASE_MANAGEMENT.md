# Database Management Commands

## View Database Contents
```bash
node view-db.js
```

## Check User-Company Links
```bash
node check-links.js
```

## Clear Database (Reset Everything)
```bash
node clear-db.js
```

## MongoDB Compass (GUI Tool)
If you want a visual interface:
1. Download MongoDB Compass: https://www.mongodb.com/try/download/compass
2. Connect to: `mongodb://localhost:27017`
3. Select database: `dayflow`
4. Browse collections: users, companies, employees, leaves, attendances

## Troubleshooting 400 Errors

### Common Causes:
1. **HR user not linked to company** - Check with `node check-links.js`
2. **Missing required fields** - Check backend error logs
3. **Validation errors** - Check the error message in browser console

### View Backend Logs:
The backend terminal will show detailed error messages. Look for:
- `❌ Create Employee Error:`
- Any MongoDB validation errors

### Test Company Registration:
1. Go to `/signup` page
2. Fill all company registration fields
3. Check if user is created with company link

### Test Employee Creation:
1. Login as HR
2. Go to Employees page
3. Click (+) button
4. Fill employee details
5. Check backend logs for errors

## Database Structure

### Users Collection
```javascript
{
  _id: ObjectId,
  loginId: String (for employees),
  email: String,
  password: String (hashed),
  role: 'HR' | 'Employee',
  company: ObjectId (ref to companies),
  isVerified: Boolean,
  employeeProfile: ObjectId (ref to employees)
}
```

### Companies Collection
```javascript
{
  _id: ObjectId,
  name: String,
  initials: String,
  email: String,
  phone: String,
  logo: String,
  hrUser: ObjectId (ref to users),
  employeeCount: Number
}
```

### Employees Collection
```javascript
{
  _id: ObjectId,
  user: ObjectId (ref to users),
  firstName: String,
  lastName: String,
  phone: String,
  designation: String,
  department: String,
  dateOfJoining: Date,
  baseSalary: Number,
  address: String,
  profilePicture: String
}
```
