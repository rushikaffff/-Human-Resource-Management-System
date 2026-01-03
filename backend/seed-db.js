const mongoose = require('mongoose');
const bcrypt = require('bcryptjs');
require('dotenv').config();

// Import models
const User = require('./src/models/User');
const Company = require('./src/models/Company');
const Employee = require('./src/models/Employee');

async function seedDatabase() {
    try {
        await mongoose.connect(process.env.MONGO_URI || 'mongodb://localhost:27017/dayflow');
        console.log('\n✅ Connected to MongoDB\n');
        console.log('='.repeat(70));

        // Clear existing data
        console.log('\n🗑️  Clearing existing data...');
        await User.deleteMany({});
        await Company.deleteMany({});
        await Employee.deleteMany({});
        console.log('   ✓ All existing data cleared');

        console.log('\n📝 Creating demo data...\n');

        // 1. Create Demo Company
        console.log('1️⃣  Creating company: DayFlow Technologies');
        const company = await Company.create({
            name: 'DayFlow Technologies',
            initials: 'DF',
            email: 'hr@dayflow.com',
            phone: '+91 98765 43210',
            employeeCount: 0
        });
        console.log('   ✓ Company created:', company.name);

        // 2. Create HR/Admin User
        console.log('\n2️⃣  Creating HR Admin user');
        const hrPassword = await bcrypt.hash('admin123', 10);
        const hrUser = await User.create({
            email: 'admin@dayflow.com',
            password: hrPassword,
            role: 'HR',
            company: company._id,
            isVerified: true
        });

        company.hrUser = hrUser._id;
        await company.save();
        console.log('   ✓ HR User created');
        console.log(`   📧 Email: admin@dayflow.com`);
        console.log(`   🔑 Password: admin123`);

        // 3. Create Demo Employees
        console.log('\n3️⃣  Creating demo employees...');

        const employeesData = [
            {
                firstName: 'John',
                lastName: 'Doe',
                designation: 'Senior Developer',
                department: 'Engineering',
                phone: '+91 98765 11111',
                baseSalary: 75000,
                dateOfJoining: new Date('2023-01-15')
            },
            {
                firstName: 'Jane',
                lastName: 'Smith',
                designation: 'Product Manager',
                department: 'Product',
                phone: '+91 98765 22222',
                baseSalary: 85000,
                dateOfJoining: new Date('2023-03-20')
            },
            {
                firstName: 'Mike',
                lastName: 'Johnson',
                designation: 'UI/UX Designer',
                department: 'Design',
                phone: '+91 98765 33333',
                baseSalary: 65000,
                dateOfJoining: new Date('2023-06-10')
            },
            {
                firstName: 'Sarah',
                lastName: 'Williams',
                designation: 'QA Engineer',
                department: 'Engineering',
                phone: '+91 98765 44444',
                baseSalary: 60000,
                dateOfJoining: new Date('2023-08-01')
            },
            {
                firstName: 'David',
                lastName: 'Brown',
                designation: 'DevOps Engineer',
                department: 'Engineering',
                phone: '+91 98765 55555',
                baseSalary: 70000,
                dateOfJoining: new Date('2024-01-15')
            }
        ];

        let employeeCount = 0;
        const year = new Date().getFullYear();

        for (const empData of employeesData) {
            employeeCount++;

            // Generate Login ID
            const companyInitials = company.initials.toUpperCase();
            const firstNamePart = empData.firstName.substring(0, 2).toUpperCase();
            const lastNamePart = empData.lastName.substring(0, 2).toUpperCase();
            const serialNumber = employeeCount.toString().padStart(4, '0');
            const loginId = `${companyInitials}${firstNamePart}${lastNamePart}${year}${serialNumber}`;

            // Generate email and password
            const email = `${empData.firstName.toLowerCase()}.${empData.lastName.toLowerCase()}@dayflow.com`;
            const password = await bcrypt.hash('employee123', 10);

            // Create User
            const user = await User.create({
                loginId,
                email,
                password,
                role: 'Employee',
                company: company._id,
                isVerified: true
            });

            // Create Employee Profile
            const employee = await Employee.create({
                user: user._id,
                firstName: empData.firstName,
                lastName: empData.lastName,
                phone: empData.phone,
                designation: empData.designation,
                department: empData.department,
                dateOfJoining: empData.dateOfJoining,
                baseSalary: empData.baseSalary,
                profilePicture: 'no-photo.jpg',
                isActive: true
            });

            // Link employee to user
            user.employeeProfile = employee._id;
            await user.save();

            console.log(`   ✓ ${empData.firstName} ${empData.lastName}`);
            console.log(`     Login ID: ${loginId}`);
            console.log(`     Email: ${email}`);
            console.log(`     Password: employee123`);
            console.log(`     Role: ${empData.designation}`);
        }

        // Update company employee count
        company.employeeCount = employeeCount;
        await company.save();

        console.log(`\n   📊 Total employees created: ${employeeCount}`);

        // Display summary
        console.log('\n' + '='.repeat(70));
        console.log('\n✨ DATABASE SEEDED SUCCESSFULLY!\n');
        console.log('='.repeat(70));

        console.log('\n📋 DEMO CREDENTIALS:\n');

        console.log('👨‍💼 HR/Admin Login:');
        console.log('   Email:    admin@dayflow.com');
        console.log('   Password: admin123');
        console.log('   Role:     HR/Admin\n');

        console.log('👥 Employee Logins (all use password: employee123):\n');
        const users = await User.find({ role: 'Employee' }).populate('employeeProfile');
        for (const user of users) {
            if (user.employeeProfile) {
                console.log(`   ${user.employeeProfile.firstName} ${user.employeeProfile.lastName}`);
                console.log(`   Login ID: ${user.loginId}`);
                console.log(`   Email:    ${user.email}`);
                console.log(`   Role:     ${user.employeeProfile.designation}\n`);
            }
        }

        console.log('='.repeat(70));
        console.log('\n🚀 You can now login and test the application!');
        console.log('\n💡 Tips:');
        console.log('   - Login as HR to see admin dashboard');
        console.log('   - Login as employee to see employee view');
        console.log('   - Create attendance, leave requests, etc.');
        console.log('\n' + '='.repeat(70) + '\n');

    } catch (error) {
        console.error('\n❌ Error seeding database:', error);
    } finally {
        await mongoose.connection.close();
        process.exit(0);
    }
}

// Run the seed function
seedDatabase();
