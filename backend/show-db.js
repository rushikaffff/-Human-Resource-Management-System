const mongoose = require('mongoose');
require('dotenv').config();

async function viewDatabase() {
    try {
        await mongoose.connect(process.env.MONGO_URI || 'mongodb://localhost:27017/dayflow');
        console.log('\n✅ Connected to MongoDB Database\n');
        console.log('='.repeat(70));

        const db = mongoose.connection.db;

        // List all collections
        const collections = await db.listCollections().toArray();
        console.log('\n📁 COLLECTIONS FOUND:');
        collections.forEach((col, i) => {
            console.log(`   ${i + 1}. ${col.name}`);
        });

        // Count documents in each collection
        console.log('\n📊 COLLECTION COUNTS:');
        for (const col of collections) {
            const count = await db.collection(col.name).countDocuments();
            console.log(`   ${col.name}: ${count} document(s)`);
        }

        console.log('\n' + '='.repeat(70));

        // Show Users
        const users = await db.collection('users').find({}).toArray();
        console.log(`\n👤 USERS (${users.length}):`);
        console.log('-'.repeat(70));
        users.forEach((user, i) => {
            console.log(`\n${i + 1}. User:`);
            console.log(`   ID:       ${user._id}`);
            console.log(`   Email:    ${user.email || 'N/A'}`);
            console.log(`   Login ID: ${user.loginId || 'N/A'}`);
            console.log(`   Role:     ${user.role}`);
            console.log(`   Company:  ${user.company || 'N/A'}`);
            console.log(`   Verified: ${user.isVerified ? 'Yes' : 'No'}`);
        });

        // Show Companies
        const companies = await db.collection('companies').find({}).toArray();
        console.log(`\n\n🏢 COMPANIES (${companies.length}):`);
        console.log('-'.repeat(70));
        companies.forEach((company, i) => {
            console.log(`\n${i + 1}. Company:`);
            console.log(`   ID:             ${company._id}`);
            console.log(`   Name:           ${company.name}`);
            console.log(`   Initials:       ${company.initials}`);
            console.log(`   Email:          ${company.email}`);
            console.log(`   Phone:          ${company.phone || 'N/A'}`);
            console.log(`   HR User:        ${company.hrUser}`);
            console.log(`   Employee Count: ${company.employeeCount || 0}`);
        });

        // Show Employees
        const employees = await db.collection('employees').find({}).toArray();
        console.log(`\n\n👥 EMPLOYEES (${employees.length}):`);
        console.log('-'.repeat(70));
        employees.forEach((emp, i) => {
            console.log(`\n${i + 1}. Employee:`);
            console.log(`   ID:          ${emp._id}`);
            console.log(`   Name:        ${emp.firstName} ${emp.lastName}`);
            console.log(`   User ID:     ${emp.user}`);
            console.log(`   Designation: ${emp.designation || 'N/A'}`);
            console.log(`   Department:  ${emp.department || 'N/A'}`);
            console.log(`   Phone:       ${emp.phone || 'N/A'}`);
            console.log(`   Salary:      ₹${emp.baseSalary || 'N/A'}`);
            console.log(`   Active:      ${emp.isActive !== false ? 'Yes' : 'No'}`);
        });

        // Show other collections if they have data
        const otherCollections = collections.filter(c =>
            !['users', 'companies', 'employees'].includes(c.name)
        );

        for (const col of otherCollections) {
            const docs = await db.collection(col.name).find({}).limit(5).toArray();
            if (docs.length > 0) {
                console.log(`\n\n📄 ${col.name.toUpperCase()} (${docs.length} shown):`);
                console.log('-'.repeat(70));
                docs.forEach((doc, i) => {
                    console.log(`\n${i + 1}.`, JSON.stringify(doc, null, 2));
                });
            }
        }

        console.log('\n' + '='.repeat(70));
        console.log('\n✨ Database view complete!\n');

    } catch (error) {
        console.error('\n❌ Error:', error.message);
    } finally {
        await mongoose.connection.close();
        process.exit(0);
    }
}

viewDatabase();
