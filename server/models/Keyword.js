const mongoose = require("mongoose");

const KeywordSchema = new mongoose.Schema({
  id: { type: String, required: true, unique: true }, // 키워드 id
  text: { type: String, required: true }, // 키워드 텍스트
});

module.exports = mongoose.model("Keyword", KeywordSchema);

