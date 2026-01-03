const Leave = require('../models/Leave');
const Employee = require('../models/Employee');

// @desc    Apply for leave
// @route   POST /api/leaves
// @access  Private
exports.applyLeave = async (req, res) => {
    try {
        const { leaveType, startDate, endDate, reason } = req.body;

        const employee = await Employee.findOne({ user: req.user.id });
        if (!employee) {
            return res.status(404).json({ success: false, message: 'Employee profile not found' });
        }

        const leave = await Leave.create({
            employee: employee._id,
            leaveType,
            startDate,
            endDate,
            reason
        });

        res.status(201).json({ success: true, data: leave });
    } catch (error) {
        res.status(400).json({ success: false, message: error.message });
    }
};

// @desc    Get my leave requests
// @route   GET /api/leaves/my-requests
// @access  Private
exports.getMyLeaves = async (req, res) => {
    try {
        const employee = await Employee.findOne({ user: req.user.id });
        const leaves = await Leave.find({ employee: employee._id }).sort({ createdAt: -1 });
        res.status(200).json({ success: true, count: leaves.length, data: leaves });
    } catch (error) {
        res.status(500).json({ success: false, message: error.message });
    }
};

// @desc    Get all leave requests (HR)
// @route   GET /api/leaves
// @access  Private (HR)
exports.getAllLeaves = async (req, res) => {
    try {
        const leaves = await Leave.find().populate('employee', 'firstName lastName designation').sort({ createdAt: -1 });
        res.status(200).json({ success: true, count: leaves.length, data: leaves });
    } catch (error) {
        res.status(500).json({ success: false, message: error.message });
    }
};

// @desc    Update leave status (Approve/Reject)
// @route   PUT /api/leaves/:id/status
// @access  Private (HR)
exports.updateLeaveStatus = async (req, res) => {
    try {
        const { status, adminComments } = req.body;

        if (!['Approved', 'Rejected'].includes(status)) {
            return res.status(400).json({ success: false, message: 'Invalid status' });
        }

        const leave = await Leave.findById(req.params.id);

        if (!leave) {
            return res.status(404).json({ success: false, message: 'Leave request not found' });
        }

        leave.status = status;
        leave.adminComments = adminComments;
        leave.approvedBy = req.user.id;

        await leave.save();

        res.status(200).json({ success: true, data: leave });
    } catch (error) {
        res.status(500).json({ success: false, message: error.message });
    }
};
