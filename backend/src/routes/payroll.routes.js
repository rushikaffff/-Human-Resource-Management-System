const express = require('express');
const {
    getMyPayroll,
    generatePayroll,
    getAllPayroll
} = require('../controllers/payroll.controller');
const { protect } = require('../middleware/auth.middleware');
const { authorize } = require('../middleware/role.middleware');

const router = express.Router();

router.use(protect);

router.get('/my-slips', getMyPayroll);

// HR Routes
router.post('/generate', authorize('HR'), generatePayroll);
router.get('/', authorize('HR'), getAllPayroll);

module.exports = router;
