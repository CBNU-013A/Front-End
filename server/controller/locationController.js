const { Location } = require('../models/Location');

// 특정 Location의 keywords 가져오기
exports.getLocationWithKeywords = async (req, res) => {
  try {
    const location = await Location.findById(req.params.id).populate('keywords', 'text');
    if (!location) return res.status(404).json({ message: 'Location not found' });

    res.json(location);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};