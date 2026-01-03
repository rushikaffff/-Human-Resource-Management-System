const mongoose = require('mongoose');
require('dotenv').config();

mongoose.connect(process.env.MONGO_URI || 'mongodb://localhost:27017/dayflow');

const db = mongoose.connection;

db.on('error', console.error.bind(console, 'connection error:'));
db.once('open', async function () {
    console.log('\n=== Checking User-Company Links ===\n');

    try {
        const users = await mongoose.connection.db.collection('users').find({}).toArray();

        for (const user of users) {
            console.log('\n👤 User:', user.email);
            console.log('   Role:', user.role);
            console.log('   Company ID:', user.company);

            if (user.company) {
                const company = await mongoose.connection.db.collection('companies').findOne({ _id: user.company });
                if (company) {
                    console.log('   ✅ Company:', company.name, '(' + company.initials + ')');
                } else {
                    console.log('   ❌ Company NOT FOUND!');
                }
            } else {
                console.log('   ⚠️  NO COMPANY LINKED!');
            }
        }

    } catch (error) {
        console.error('Error:', error);
    } finally {
        await mongoose.connection.close();
        process.exit(0);
    }
});
