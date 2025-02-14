const mongoose = require("mongoose");

const KeywordSchema = new mongoose.Schema({
  keyword: { type: String, required: true },
  userId: { type: mongoose.Schema.Types.ObjectId, ref: "User", required: true }, // ✅ userId 필드 추가
  prefer: { type: Number, default: 1 },
});

module.exports = mongoose.model("Keyword", KeywordSchema);
