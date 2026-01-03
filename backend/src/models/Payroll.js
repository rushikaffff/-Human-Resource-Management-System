const mongoose = require('mongoose');

const PayrollSchema = new mongoose.Schema({
    employee: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'Employee',
        required: true
    },
    month: {
        type: Number,
        required: true // 1-12
    },
    year: {
        type: Number,
        required: true
    },
    baseSalary: {
        type: Number,
        required: true
    },
    deductions: {
        type: Number,
        default: 0
    },
    bonuses: {
        type: Number,
        default: 0
    },
    netSalary: {
        type: Number,
        required: true
    },
    status: {
        type: String,
        enum: ['Draft', 'Paid'],
        default: 'Draft'
    },
    paymentDate: {
        type: Date
    }
}, { timestamps: true });

module.exports = mongoose.model('Payroll', PayrollSchema);
