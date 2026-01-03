const Attendance = require('../models/Attendance');
const Employee = require('../models/Employee');

// @desc    Check In
// @route   POST /api/attendance/check-in
// @access  Private
exports.checkIn = async (req, res) => {
    try {
        const employee = await Employee.findOne({ user: req.user.id });
        if (!employee) {
            return res.status(404).json({ success: false, message: 'Employee profile not found' });
        }

        const today = new Date();
        today.setHours(0, 0, 0, 0);

        const existingAttendance = await Attendance.findOne({
            employee: employee._id,
            date: today
        });

        if (existingAttendance) {
            return res.status(400).json({ success: false, message: 'Already checked in for today' });
        }

        const attendance = await Attendance.create({
            employee: employee._id,
            date: today,
            checkIn: new Date(),
            status: 'Present'
        });

        res.status(201).json({ success: true, data: attendance });
    } catch (error) {
        res.status(500).json({ success: false, message: error.message });
    }
};

// @desc    Check Out
// @route   POST /api/attendance/check-out
// @access  Private
exports.checkOut = async (req, res) => {
    try {
        const employee = await Employee.findOne({ user: req.user.id });
        if (!employee) {
            return res.status(404).json({ success: false, message: 'Employee profile not found' });
        }

        const today = new Date();
        today.setHours(0, 0, 0, 0);

        const attendance = await Attendance.findOne({
            employee: employee._id,
            date: today
        });

        if (!attendance) {
            return res.status(400).json({ success: false, message: 'Have not checked in yet' });
        }

        if (attendance.checkOut) {
            return res.status(400).json({ success: false, message: 'Already checked out' });
        }

        attendance.checkOut = new Date();

        // Calculate work hours (in hours)
        const diffMs = attendance.checkOut - attendance.checkIn;
        const diffHrs = diffMs / (1000 * 60 * 60);
        attendance.workHours = parseFloat(diffHrs.toFixed(2));

        if (attendance.workHours < 4) {
            attendance.status = 'Half-day'; // Example logic
        }

        await attendance.save();

        res.status(200).json({ success: true, data: attendance });
    } catch (error) {
        res.status(500).json({ success: false, message: error.message });
    }
};

// @desc    Get my attendance history
// @route   GET /api/attendance/me
// @access  Private
exports.getMyAttendance = async (req, res) => {
    try {
        const employee = await Employee.findOne({ user: req.user.id });
        const attendance = await Attendance.find({ employee: employee._id }).sort({ date: -1 });
        res.status(200).json({ success: true, count: attendance.length, data: attendance });
    } catch (error) {
        res.status(500).json({ success: false, message: error.message });
    }
};

// @desc    Get all attendance (HR) (Optional query params for filtering)
// @route   GET /api/attendance
// @access  Private (HR)
exports.getAllAttendance = async (req, res) => {
    try {
        const attendance = await Attendance.find().populate('employee', 'firstName lastName designation').sort({ date: -1 });
        res.status(200).json({ success: true, count: attendance.length, data: attendance });
    } catch (error) {
        res.status(500).json({ success: false, message: error.message });
    }
};
