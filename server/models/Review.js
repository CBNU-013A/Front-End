const mongoose = require("mongoose");

const ReviewSchema = new mongoose.Schema({
  id: { type: String, required: true, unique: true }, // 리뷰 id
  text: [{ type: String, required: true }], // 텍스트 리뷰
  keywords: [{ type: mongoose.Schema.Types.ObjectId, ref: "Keyword" }], // 키워드 참조
});

module.exports = mongoose.model("Review", ReviewSchema);
