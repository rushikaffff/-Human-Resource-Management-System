const mongoose = require('mongoose');
require('dotenv').config();

mongoose.connect(process.env.MONGO_URI || 'mongodb://localhost:27017/dayflow');

const db = mongoose.connection;

db.on('error', console.error.bind(console, 'connection error:'));
db.once('open', async function () {
    console.log('\n⚠️  WARNING: This will DELETE ALL DATA! ⚠️\n');

    const readline = require('readline').createInterface({
        input: process.stdin,
        output: process.stdout
    });

    readline.question('Type "DELETE" to confirm: ', async (answer) => {
        if (answer === 'DELETE') {
            try {
                await mongoose.connection.db.collection('users').deleteMany({});
                await mongoose.connection.db.collection('companies').deleteMany({});
                await mongoose.connection.db.collection('employees').deleteMany({});
                await mongoose.connection.db.collection('leaves').deleteMany({});
                await mongoose.connection.db.collection('attendances').deleteMany({});
                await mongoose.connection.db.collection('payrolls').deleteMany({});

                console.log('\n✅ All collections cleared!');
            } catch (error) {
                console.error('Error:', error);
            }
        } else {
            console.log('\n❌ Cancelled');
        }

        await mongoose.connection.close();
        readline.close();
        process.exit(0);
    });
});
