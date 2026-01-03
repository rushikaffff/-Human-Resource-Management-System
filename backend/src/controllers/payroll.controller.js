const Payroll = require('../models/Payroll');
const Employee = require('../models/Employee');

// @desc    Get my payroll history
// @route   GET /api/payroll/my-slips
// @access  Private
exports.getMyPayroll = async (req, res) => {
    try {
        const employee = await Employee.findOne({ user: req.user.id });
        const payrolls = await Payroll.find({ employee: employee._id }).sort({ year: -1, month: -1 });
        res.status(200).json({ success: true, count: payrolls.length, data: payrolls });
    } catch (error) {
        res.status(500).json({ success: false, message: error.message });
    }
};

// @desc    Generate Payroll for Month (Simplified)
// @route   POST /api/payroll/generate
// @access  Private (HR)
exports.generatePayroll = async (req, res) => {
    try {
        const { month, year } = req.body;

        // Check if payroll already exists for this month
        const existingPayroll = await Payroll.findOne({ month, year });
        if (existingPayroll) {
            // For simplicity, we might allow regenerating or skipping
            // return res.status(400).json({ success: false, message: 'Payroll already initiated for this month' });
        }

        const employees = await Employee.find({ isActive: true });

        const payrollRecords = [];

        for (const emp of employees) {
            // Logic to calculate net salary based on attendance could go here
            // For now, we use base salary
            const netSalary = emp.baseSalary; // Placeholder calculation

            const payroll = await Payroll.create({
                employee: emp._id,
                month,
                year,
                baseSalary: emp.baseSalary,
                netSalary,
                status: 'Draft'
            });
            payrollRecords.push(payroll);
        }

        res.status(201).json({ success: true, count: payrollRecords.length, message: `Generated payroll for ${payrollRecords.length} employees`, data: payrollRecords });
    } catch (error) {
        res.status(500).json({ success: false, message: error.message });
    }
};

// @desc    Get all payroll records
// @route   GET /api/payroll
// @access  Private (HR)
exports.getAllPayroll = async (req, res) => {
    try {
        const payrolls = await Payroll.find().populate('employee', 'firstName lastName designation').sort({ year: -1, month: -1 });
        res.status(200).json({ success: true, count: payrolls.length, data: payrolls });
    } catch (error) {
        res.status(500).json({ success: false, message: error.message });
    }
};
