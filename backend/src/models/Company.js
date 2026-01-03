const mongoose = require('mongoose');

const CompanySchema = new mongoose.Schema({
    name: {
        type: String,
        required: [true, 'Please add a company name'],
        unique: true
    },
    initials: {
        type: String,
        required: [true, 'Please add company initials'],
        uppercase: true,
        maxlength: 4,
        minlength: 2
    },
    email: {
        type: String,
        required: [true, 'Please add company email']
    },
    phone: {
        type: String
    },
    logo: {
        type: String,
        default: 'default-logo.png'
    },
    hrUser: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'User'
    },
    employeeCount: {
        type: Number,
        default: 0
    },
    createdAt: {
        type: Date,
        default: Date.now
    }
});

module.exports = mongoose.model('Company', CompanySchema);
