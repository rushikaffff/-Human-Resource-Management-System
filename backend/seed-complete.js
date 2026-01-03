const mongoose = require('mongoose');
const bcrypt = require('bcryptjs');
require('dotenv').config();

// Import models
const User = require('./src/models/User');
const Company = require('./src/models/Company');
const Employee = require('./src/models/Employee');
const Attendance = require('./src/models/Attendance');
const Leave = require('./src/models/Leave');
const Payroll = require('./src/models/Payroll');

async function seedCompleteDatabase() {
    try {
        await mongoose.connect(process.env.MONGO_URI || 'mongodb://localhost:27017/dayflow');
        console.log('\n✅ Connected to MongoDB\n');
        console.log('='.repeat(80));

        // Clear ALL existing data
        console.log('\n🗑️  Clearing ALL existing data...');
        await User.deleteMany({});
        await Company.deleteMany({});
        await Employee.deleteMany({});
        await Attendance.deleteMany({});
        await Leave.deleteMany({});
        await Payroll.deleteMany({});
        console.log('   ✓ All collections cleared\n');

        console.log('📝 Creating comprehensive demo data...\n');

        // ==================== 1. CREATE COMPANY ====================
        console.log('1️⃣  Creating Company: DayFlow Technologies');
        const company = await Company.create({
            name: 'DayFlow Technologies',
            initials: 'DF',
            email: 'hr@dayflow.com',
            phone: '+91 98765 43210',
            employeeCount: 0
        });
        console.log('   ✓ Company created\n');

        // ==================== 2. CREATE HR ADMIN ====================
        console.log('2️⃣  Creating HR Admin');
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
        console.log('   ✓ HR User: admin@dayflow.com / admin123\n');

        // ==================== 3. CREATE EMPLOYEES ====================
        console.log('3️⃣  Creating Employees...');

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
        const employees = [];
        const users = [];

        for (const empData of employeesData) {
            employeeCount++;

            // Generate Login ID
            const loginId = `DF${empData.firstName.substring(0, 2)}${empData.lastName.substring(0, 2)}${year}${employeeCount.toString().padStart(4, '0')}`.toUpperCase();
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

            user.employeeProfile = employee._id;
            await user.save();

            employees.push(employee);
            users.push(user);

            console.log(`   ✓ ${empData.firstName} ${empData.lastName} (${loginId})`);
        }

        company.employeeCount = employeeCount;
        await company.save();
        console.log(`   📊 Total employees: ${employeeCount}\n`);

        // ==================== 4. CREATE ATTENDANCE RECORDS ====================
        console.log('4️⃣  Creating Attendance Records...');

        let attendanceCount = 0;
        const today = new Date();

        // Create attendance for last 30 days
        for (let i = 0; i < 30; i++) {
            const date = new Date();
            date.setDate(today.getDate() - i);

            // Skip weekends
            if (date.getDay() === 0 || date.getDay() === 6) continue;

            for (const employee of employees) {
                // 80% attendance rate (some employees absent some days)
                if (Math.random() > 0.2) {
                    const checkInHour = 9 + Math.floor(Math.random() * 2); // 9-10 AM
                    const checkInMinute = Math.floor(Math.random() * 60);
                    const checkOutHour = 17 + Math.floor(Math.random() * 3); // 5-7 PM
                    const checkOutMinute = Math.floor(Math.random() * 60);

                    const checkIn = new Date(date);
                    checkIn.setHours(checkInHour, checkInMinute, 0);

                    const checkOut = new Date(date);
                    checkOut.setHours(checkOutHour, checkOutMinute, 0);

                    await Attendance.create({
                        employee: employee._id,
                        user: employee.user,
                        date: date,
                        checkIn: checkIn,
                        checkOut: checkOut,
                        status: 'Present',
                        workingHours: ((checkOutHour - checkInHour) + (checkOutMinute - checkInMinute) / 60).toFixed(2)
                    });

                    attendanceCount++;
                }
            }
        }

        console.log(`   ✓ Created ${attendanceCount} attendance records\n`);

        // ==================== 5. CREATE LEAVE REQUESTS ====================
        console.log('5️⃣  Creating Leave/Time-Off Requests...');

        const leaveTypes = ['Sick', 'Casual', 'Annual', 'Unpaid'];
        const leaveStatuses = ['Pending', 'Approved', 'Rejected'];
        let leaveCount = 0;

        for (const employee of employees) {
            // Create 2-4 leave requests per employee
            const numLeaves = 2 + Math.floor(Math.random() * 3);

            for (let i = 0; i < numLeaves; i++) {
                const startDate = new Date();
                startDate.setDate(today.getDate() + Math.floor(Math.random() * 60) - 30);

                const duration = 1 + Math.floor(Math.random() * 5); // 1-5 days
                const endDate = new Date(startDate);
                endDate.setDate(startDate.getDate() + duration - 1);

                const leaveType = leaveTypes[Math.floor(Math.random() * leaveTypes.length)];
                const status = leaveStatuses[Math.floor(Math.random() * leaveStatuses.length)];

                await Leave.create({
                    employee: employee._id,
                    leaveType: leaveType,
                    startDate: startDate,
                    endDate: endDate,
                    reason: `${leaveType} leave for ${duration} day(s)`,
                    status: status
                });

                leaveCount++;
            }
        }

        console.log(`   ✓ Created ${leaveCount} leave requests\n`);

        // ==================== 6. CREATE PAYROLL RECORDS ====================
        console.log('6️⃣  Creating Payroll Records...');

        let payrollCount = 0;

        // Create payroll for last 3 months
        for (let monthOffset = 0; monthOffset < 3; monthOffset++) {
            const payrollDate = new Date();
            payrollDate.setMonth(today.getMonth() - monthOffset);

            const monthNumber = payrollDate.getMonth() + 1; // 1-12
            const yearNumber = payrollDate.getFullYear();

            for (const employee of employees) {
                const baseSalary = employee.baseSalary;

                // Calculate deductions (PF + Tax)
                const pfDeduction = baseSalary * 0.12;
                const taxDeduction = baseSalary * 0.1;
                const totalDeductions = pfDeduction + taxDeduction;

                const netSalary = baseSalary - totalDeductions;

                await Payroll.create({
                    employee: employee._id,
                    month: monthNumber,
                    year: yearNumber,
                    baseSalary: baseSalary,
                    deductions: totalDeductions,
                    bonuses: 0,
                    netSalary: netSalary,
                    paymentDate: new Date(yearNumber, monthNumber, 1),
                    status: monthOffset === 0 ? 'Draft' : 'Paid'
                });

                payrollCount++;
            }
        }

        console.log(`   ✓ Created ${payrollCount} payroll records\n`);

        // ==================== SUMMARY ====================
        console.log('='.repeat(80));
        console.log('\n✨ DATABASE FULLY SEEDED WITH DEMO DATA!\n');
        console.log('='.repeat(80));

        console.log('\n📊 DATA SUMMARY:\n');
        console.log(`   Companies:        1`);
        console.log(`   Users:            ${users.length + 1} (1 HR + ${users.length} Employees)`);
        console.log(`   Employees:        ${employees.length}`);
        console.log(`   Attendance:       ${attendanceCount} records`);
        console.log(`   Leave Requests:   ${leaveCount} requests`);
        console.log(`   Payroll Records:  ${payrollCount} records`);

        console.log('\n🔐 LOGIN CREDENTIALS:\n');

        console.log('👨‍💼 HR/Admin:');
        console.log('   Email:    admin@dayflow.com');
        console.log('   Password: admin123\n');

        console.log('👥 Employees (Password: employee123 for all):\n');
        for (let i = 0; i < users.length; i++) {
            const user = users[i];
            await user.populate('employeeProfile');
            console.log(`   ${i + 1}. ${user.employeeProfile.firstName} ${user.employeeProfile.lastName}`);
            console.log(`      Login ID: ${user.loginId}`);
            console.log(`      Email:    ${user.email}`);
            console.log(`      Role:     ${user.employeeProfile.designation}\n`);
        }

        console.log('='.repeat(80));
        console.log('\n🚀 Ready to test! All features now have demo data:\n');
        console.log('   ✅ Employee Dashboard');
        console.log('   ✅ Attendance Records (last 30 days)');
        console.log('   ✅ Leave Requests (Pending, Approved, Rejected)');
        console.log('   ✅ Payroll History (last 3 months)');
        console.log('   ✅ Profile Management');
        console.log('\n' + '='.repeat(80) + '\n');

    } catch (error) {
        console.error('\n❌ Error:', error);
    } finally {
        await mongoose.connection.close();
        process.exit(0);
    }
}

seedCompleteDatabase();
