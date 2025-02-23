const mongoose = require("mongoose");
const dotenv = require("dotenv");

dotenv.config(); // .env 파일 로드

async function connectDB() {
  try {
    await mongoose.connect(process.env.MONGO_URI, {
      useNewUrlParser: true,
      useUnifiedTopology: true,
    });
    console.log("✅ MongoDB 연결 성공!");
  } catch (error) {
    console.error("❌ MongoDB 연결 실패:", error);
    process.exit(1);
  }
}

module.exports = connectDB;