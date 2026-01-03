const express = require('express');
const {
    checkIn,
    checkOut,
    getMyAttendance,
    getAllAttendance
} = require('../controllers/attendance.controller');
const { protect } = require('../middleware/auth.middleware');
const { authorize } = require('../middleware/role.middleware');

const router = express.Router();

router.use(protect);

router.post('/check-in', checkIn);
router.post('/check-out', checkOut);
router.get('/me', getMyAttendance);

// HR Routes
router.get('/', authorize('HR'), getAllAttendance);

module.exports = router;
