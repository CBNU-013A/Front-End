const express = require('express');
const router = express.Router();
const locationController = require('../controller/locationController');

router.get('/location/:id', locationController.getLocationWithKeywords);

module.exports = router;