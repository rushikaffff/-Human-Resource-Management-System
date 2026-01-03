const User = require('../models/User');
const Employee = require('../models/Employee');
const Company = require('../models/Company');
const generateToken = require('../utils/jwt.util');

// @desc    Register user (HR with Company)
// @route   POST /api/auth/register
// @access  Public
exports.register = async (req, res) => {
    try {
        const { email, password, role, companyName, companyInitials, companyPhone, adminName } = req.body;

        const userExists = await User.findOne({ email });

        if (userExists) {
            return res.status(400).json({ success: false, message: 'User already exists' });
        }

        // If registering as HR, create company first
        let company = null;
        if (role === 'HR') {
            // Check if company name exists
            const companyExists = await Company.findOne({ name: companyName });
            if (companyExists) {
                return res.status(400).json({ success: false, message: 'Company already registered' });
            }

            company = await Company.create({
                name: companyName,
                initials: companyInitials.toUpperCase(),
                email: email,
                phone: companyPhone,
                logo: req.body.logo || 'default-logo.png'
            });
        }

        // Create User
        const user = await User.create({
            email,
            password,
            role,
            company: company ? company._id : null
        });

        // Link company to HR user
        if (company) {
            company.hrUser = user._id;
            await company.save();
        }

        // For Employee role (though not used in signup now)
        if (user.role === 'Employee' && company) {
            await Employee.create({
                user: user._id,
                firstName: 'Pending',
                lastName: 'Update',
                designation: 'New Hire',
                department: 'Pending',
                phone: '0000000000',
                dateOfJoining: new Date(),
                baseSalary: 0
            });
        }

        res.status(201).json({
            success: true,
            _id: user._id,
            email: user.email,
            role: user.role,
            token: generateToken(user._id),
        });
    } catch (error) {
        res.status(400).json({ success: false, message: error.message });
    }
};

// @desc    Login user
// @route   POST /api/auth/login
// @access  Public
exports.login = async (req, res) => {
    try {
        const { email, password } = req.body;

        if (!email || !password) {
            return res.status(400).json({ success: false, message: 'Please provide an email/loginId and password' });
        }

        // Check for user by email or loginId
        const user = await User.findOne({
            $or: [{ email }, { loginId: email }] // email field can contain either email or loginId
        }).select('+password');

        if (user && (await user.matchPassword(password))) {
            res.json({
                success: true,
                _id: user._id,
                email: user.email,
                loginId: user.loginId,
                role: user.role,
                token: generateToken(user._id),
            });
        } else {
            res.status(401).json({ success: false, message: 'Invalid credentials' });
        }
    } catch (error) {
        res.status(400).json({ success: false, message: error.message });
    }
};

// @desc    Get current user
// @route   GET /api/auth/me
// @access  Private
exports.getMe = async (req, res) => {
    try {
        const user = await User.findById(req.user.id);
        res.status(200).json({ success: true, data: user });
    } catch (error) {
        res.status(500).json({ success: false, message: error.message });
    }
};

// @desc    Change password
// @route   PUT /api/auth/change-password
// @access  Private
exports.changePassword = async (req, res) => {
    try {
        const { currentPassword, newPassword } = req.body;

        if (!currentPassword || !newPassword) {
            return res.status(400).json({ success: false, message: 'Please provide current and new password' });
        }

        const user = await User.findById(req.user.id).select('+password');

        if (!user) {
            return res.status(404).json({ success: false, message: 'User not found' });
        }

        if (!(await user.matchPassword(currentPassword))) {
            return res.status(401).json({ success: false, message: 'Invalid current password' });
        }

        user.password = newPassword;
        await user.save();

        res.status(200).json({ success: true, message: 'Password updated successfully' });
    } catch (error) {
        res.status(500).json({ success: false, message: error.message });
    }
};
