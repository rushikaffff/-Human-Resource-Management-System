const express = require('express');
const {
    applyLeave,
    getMyLeaves,
    getAllLeaves,
    updateLeaveStatus
} = require('../controllers/leave.controller');
const { protect } = require('../middleware/auth.middleware');
const { authorize } = require('../middleware/role.middleware');

const router = express.Router();

router.use(protect);

router.post('/', applyLeave);
router.get('/my-requests', getMyLeaves);

// HR Routes
router.get('/', authorize('HR'), getAllLeaves);
router.put('/:id/status', authorize('HR'), updateLeaveStatus);

module.exports = router;
