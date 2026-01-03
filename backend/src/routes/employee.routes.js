const express = require('express');
const {
    getMe,
    updateMe,
    getEmployees,
    getEmployeeById,
    updateEmployee,
    createEmployee
} = require('../controllers/employee.controller');
const { protect } = require('../middleware/auth.middleware');
const { authorize } = require('../middleware/role.middleware');

const router = express.Router();

router.use(protect); // All routes below are protected

router.get('/me', getMe);
router.put('/me', updateMe);

// HR Routes
router.post('/', authorize('HR'), createEmployee);
router.get('/', authorize('HR'), getEmployees);
router.get('/:id', authorize('HR'), getEmployeeById);
router.put('/:id', authorize('HR'), updateEmployee);

module.exports = router;
