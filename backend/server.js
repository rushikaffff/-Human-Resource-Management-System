const express = require('express');
const dotenv = require('dotenv');
const morgan = require('morgan');
const helmet = require('helmet');
const cors = require('cors');
const connectDB = require('./src/config/database');

// Load env vars
dotenv.config();

// Connect to database
connectDB();

const app = express();

// Middleware
app.use(express.json());
app.use(cors());
app.use(helmet());
if (process.env.NODE_ENV === 'development') {
    app.use(morgan('dev'));
}

// Routes Placeholder
app.get('/', (req, res) => {
    res.send('API is running...');
});

// Routes Import (Will be added as they are created)
app.use('/api/auth', require('./src/routes/auth.routes'));
app.use('/api/employees', require('./src/routes/employee.routes'));
app.use('/api/attendance', require('./src/routes/attendance.routes'));
app.use('/api/leaves', require('./src/routes/leave.routes'));
app.use('/api/payroll', require('./src/routes/payroll.routes'));

const PORT = process.env.PORT || 5000;

app.listen(PORT, '0.0.0.0', () => {
    console.log(`Server running in ${process.env.NODE_ENV} mode on port ${PORT}`);
    console.log(`Server accessible at http://localhost:${PORT}`);
});

