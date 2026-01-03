const mongoose = require('mongoose');
require('dotenv').config();

mongoose.connect(process.env.MONGO_URI || 'mongodb://localhost:27017/dayflow');

const db = mongoose.connection;

db.on('error', console.error.bind(console, 'connection error:'));
db.once('open', async function () {
    console.log('\n=== Connected to MongoDB ===\n');

    try {
        // Check all collections
        const collections = await mongoose.connection.db.listCollections().toArray();
        console.log('📁 Collections:', collections.map(c => c.name).join(', '));

        // Check users
        const users = await mongoose.connection.db.collection('users').find({}).toArray();
        console.log('\n👤 USERS (' + users.length + '):');
        users.forEach(user => {
            console.log(JSON.stringify({
                _id: user._id,
                email: user.email,
                loginId: user.loginId,
                role: user.role,
                company: user.company
            }, null, 2));
        });

        // Check companies
        const companies = await mongoose.connection.db.collection('companies').find({}).toArray();
        console.log('\n🏢 COMPANIES (' + companies.length + '):');
        companies.forEach(company => {
            console.log(JSON.stringify({
                _id: company._id,
                name: company.name,
                initials: company.initials,
                email: company.email,
                hrUser: company.hrUser,
                employeeCount: company.employeeCount
            }, null, 2));
        });

        // Check employees
        const employees = await mongoose.connection.db.collection('employees').find({}).toArray();
        console.log('\n👥 EMPLOYEES (' + employees.length + '):');
        employees.forEach(emp => {
            console.log(JSON.stringify({
                _id: emp._id,
                firstName: emp.firstName,
                lastName: emp.lastName,
                user: emp.user,
                designation: emp.designation
            }, null, 2));
        });

    } catch (error) {
        console.error('Error:', error);
    } finally {
        await mongoose.connection.close();
        process.exit(0);
    }
});
