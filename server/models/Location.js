const mongoose = require("mongoose");

const sentimentSchema = new mongoose.Schema(
  {
    none: { type: Number, default: 0 },
    pos: { type: Number, default: 0 },
    neg: { type: Number, default: 0 },
    neu: { type: Number, default: 0 },
    total: { type: Number, default: 0 },
  },
  { _id: false }
);

const KeywordSchema = new mongoose.Schema(
  {
    name: { type: String, unique: true }, // 키워드 텍스트
    sentiment: sentimentSchema,
  },
  { _id: false }
);

module.exports =
  mongoose.models.Keyword || mongoose.model("Keyword", KeywordSchema);

const LocationSchema = new mongoose.Schema({
  //id: { type: String, required: true, unique: true }, // 고유한 ID
  name: { type: String, required: true, unique: true }, // 여행지 이름
  address: { type: String, required: true }, // 여행지 주소
  location: {
    latitude: { type: Number, required: true }, // 위도
    longitude: { type: Number, required: true }, // 경도
  },
  image: [{ type: String, required: false }],
  tell: { type: String, required: false }, // 전화번호
  keywords: [KeywordSchema], //키워드
  review: [{ type: String, required: false }], // 리뷰
  likes: { type: Number, default: 0 }, //좋아요
});

module.exports = mongoose.model("Location", LocationSchema);
