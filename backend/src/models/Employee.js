const mongoose = require('mongoose');

const EmployeeSchema = new mongoose.Schema({
    user: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'User',
        required: true,
        unique: true
    },
    firstName: {
        type: String,
        required: [true, 'Please add a first name']
    },
    lastName: {
        type: String,
        required: [true, 'Please add a last name']
    },
    phone: {
        type: String,
        required: [true, 'Please add a phone number']
    },
    designation: {
        type: String,
        required: true
    },
    department: {
        type: String,
        required: true
    },
    dateOfJoining: {
        type: Date,
        required: true
    },
    baseSalary: { // Basic salary for payroll calculation
        type: Number,
        required: true
    },
    profilePicture: {
        type: String, // URL to image
        default: 'no-photo.jpg'
    },
    address: {
        type: String
    },
    isActive: {
        type: Boolean,
        default: true
    }
}, { timestamps: true });

module.exports = mongoose.model('Employee', EmployeeSchema);
