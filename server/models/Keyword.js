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
