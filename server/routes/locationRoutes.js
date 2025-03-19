const express = require("express");
const router = express.Router();
const locationController = require("../controller/locationController");
router.post("/location", locationController.getLocationWithKeywords);
router.get("/location", locationController.getLocationWithKeywords);

module.exports = router;
