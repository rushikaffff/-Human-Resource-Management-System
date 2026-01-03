const Employee = require('../models/Employee');
const User = require('../models/User');

// @desc    Get current employee profile
// @route   GET /api/employees/me
// @access  Private (All)
exports.getMe = async (req, res) => {
    try {
        const employee = await Employee.findOne({ user: req.user.id }).populate('user', 'email role isVerified');
        if (!employee) {
            return res.status(404).json({ success: false, message: 'Employee profile not found' });
        }
        res.status(200).json({ success: true, data: employee });
    } catch (error) {
        res.status(500).json({ success: false, message: error.message });
    }
};

// @desc    Update current employee profile (Restricted fields)
// @route   PUT /api/employees/me
// @access  Private (Employee)
exports.updateMe = async (req, res) => {
    try {
        const allowedUpdates = ['phone', 'address', 'profilePicture'];
        const updates = Object.keys(req.body);
        const isValidOperation = updates.every((update) => allowedUpdates.includes(update));

        if (!isValidOperation) {
            return res.status(400).json({ success: false, message: 'Invalid updates! You can only update phone, address, and profile picture.' });
        }

        const employee = await Employee.findOneAndUpdate(
            { user: req.user.id },
            { $set: req.body },
            { new: true, runValidators: true }
        );

        res.status(200).json({ success: true, data: employee });
    } catch (error) {
        res.status(400).json({ success: false, message: error.message });
    }
};

// @desc    Get all employees
// @route   GET /api/employees
// @access  Private (HR Only)
exports.getEmployees = async (req, res) => {
    try {
        const employees = await Employee.find().populate('user', 'email role');
        res.status(200).json({ success: true, count: employees.length, data: employees });
    } catch (error) {
        res.status(500).json({ success: false, message: error.message });
    }
};

// @desc    Get employee by ID
// @route   GET /api/employees/:id
// @access  Private (HR Only)
exports.getEmployeeById = async (req, res) => {
    try {
        const employee = await Employee.findById(req.params.id).populate('user', 'email role');
        if (!employee) {
            return res.status(404).json({ success: false, message: 'Employee not found' });
        }
        res.status(200).json({ success: true, data: employee });
    } catch (error) {
        res.status(500).json({ success: false, message: error.message });
    }
};

// @desc    Update employee (Admin)
// @route   PUT /api/employees/:id
// @access  Private (HR Only)
exports.updateEmployee = async (req, res) => {
    try {
        const employee = await Employee.findByIdAndUpdate(req.params.id, req.body, {
            new: true,
            runValidators: true
        });

        if (!employee) {
            return res.status(404).json({ success: false, message: 'Employee not found' });
        }

        res.status(200).json({ success: true, data: employee });
    } catch (error) {
        res.status(400).json({ success: false, message: error.message });
    }
};
// @desc    Create new employee (HR Only)
// @route   POST /api/employees
// @access  Private (HR Only)
exports.createEmployee = async (req, res) => {
    try {
        console.log('📝 Create Employee Request Body:', JSON.stringify(req.body, null, 2));
        console.log('👤 User ID:', req.user.id);

        const {
            firstName,
            lastName,
            phone,
            designation,
            department,
            dateOfJoining,
            baseSalary,
            address
        } = req.body;

        // Get the HR user's company
        const hrUser = await User.findById(req.user.id).populate('company');
        if (!hrUser || !hrUser.company) {
            return res.status(400).json({ success: false, message: 'HR user must be associated with a company' });
        }

        const company = hrUser.company;

        // Generate Login ID: CompanyInitials + FirstName(2) + LastName(2) + Year(4) + Serial(4)
        // Example: GE30JO202420001
        const companyInitials = company.initials.toUpperCase();
        const firstNamePart = firstName.substring(0, 2).toUpperCase();
        const lastNamePart = lastName.substring(0, 2).toUpperCase();
        const yearPart = new Date().getFullYear().toString(); // Full 4-digit year

        // Get employee count for this year
        const startOfYear = new Date(new Date().getFullYear(), 0, 1);
        const employeesThisYear = await Employee.countDocuments({
            createdAt: { $gte: startOfYear }
        });

        const serialNumber = (employeesThisYear + 1).toString().padStart(4, '0');
        const loginId = `${companyInitials}${firstNamePart}${lastNamePart}${yearPart}${serialNumber}`;

        // Generate default password (can be auto-generated or set by HR)
        const defaultPassword = req.body.password || `Temp@${Math.random().toString(36).slice(-8)}`;

        // 1. Create User with loginId
        const user = await User.create({
            loginId,
            email: req.body.email || `${loginId}@${company.name.toLowerCase().replace(/\s/g, '')}.com`,
            password: defaultPassword,
            role: 'Employee',
            company: company._id,
            isVerified: true
        });

        // 2. Create Employee Profile
        const employee = await Employee.create({
            user: user._id,
            firstName,
            lastName,
            phone,
            designation,
            department,
            dateOfJoining,
            baseSalary,
            address,
            profilePicture: 'no-photo.jpg'
        });

        // Link employee profile to user
        user.employeeProfile = employee._id;
        await user.save();

        // Increment company employee count
        company.employeeCount += 1;
        await company.save();

        res.status(201).json({
            success: true,
            data: employee,
            loginCredentials: {
                loginId,
                password: defaultPassword,
                message: 'Share these credentials with the employee'
            }
        });

    } catch (error) {
        console.error('❌ Create Employee Error:', error.message);
        console.error('Full error:', error);
        if (error.code === 11000) {
            return res.status(400).json({ success: false, message: 'Duplicate field entered' });
        }
        res.status(400).json({ success: false, message: error.message });
    }
};
