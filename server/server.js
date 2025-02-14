const express = require("express");
const mongoose = require("mongoose");
const dotenv = require("dotenv");
require("dotenv").config();
const cors = require("cors");
const bodyParser = require("body-parser");
//const bcrypt = require("bcrypt");
const authRoutes = require("./routes/authRoutes");
const User = require("./models/User");
const Keyword = require("./models/Keyword");

dotenv.config(); //환경변수
const app = express();
app.use(express.json());
app.use(cors()); // 모든 요청을 허용
app.use(bodyParser.json()); // JSON 요청 파싱

//회원가입 (POST)
app.post("/register", async (req, res) => {
  try {
    console.log("📌 [서버] 회원가입 요청 도착");
    console.log("📌 [서버] 요청 데이터:", req.body); // ✅ 요청 데이터 출력

    const { name, email, password, birthdate } = req.body; //🔹 서버에서 받은 요청 데이터 확인

    if (!name || !email || !password || !birthdate) {
      console.log("🚨 모든 필드를 입력해야 합니다!");
      return res.status(400).json({ error: "모든 필드를 입력하세요." });
    }
    const existingUser = await User.findOne({ email });
    if (existingUser) {
      console.log("🚨 이미 존재하는 이메일:", email);
      return res.status(400).json({ error: "이미 존재하는 이메일입니다." });
    }
    // 생년월일 검증
    const parsedBirthdate = new Date(birthdate);
    if (isNaN(parsedBirthdate.getTime())) {
      console.log("🚨 잘못된 생년월일 값:", birthdate);
      return res.status(400).json({ error: "유효한 생년월일을 입력하세요." });
    }

    // 비밀번호 해싱 (서버에서 처리)
    const hashedPassword = await bcrypt.hash(password, 10);

    const newUser = new User({
      name,
      email,
      password: hashedPassword,
      birthdate: parsedBirthdate,
    });

    await newUser.save();
    res.status(201).json({ message: "회원가입 성공!" });
  } catch (error) {
    console.error("🚨 회원가입 중 오류 발생:", error.message); // 🔹 오류 메시지 출력
    res.status(500).json({ error: "회원가입 실패", details: error.message });
  }
});

// ✅ 특정 사용자의 키워드 목록 조회 API (필수)
app.get("/users/:userId/keywords", async (req, res) => {
  try {
    const { userId } = req.params;

    // 🔹 유저 ID가 유효한지 확인
    if (!mongoose.Types.ObjectId.isValid(userId)) {
      return res.status(400).json({ error: "유효하지 않은 userId입니다." });
    }

    // 🔹 해당 유저의 키워드 목록 가져오기
    const keywords = await Keyword.find({ userId });

    res.json(keywords);
  } catch (error) {
    console.error("🚨 키워드 조회 오류:", error);
    res.status(500).json({ error: "서버 오류 발생" });
  }
});

//키워드 추가 (POST)
app.post("/keywords", async (req, res) => {
  try {
    const { keyword, userId } = req.body; // 🔹 req.body에서 keyword 값을 가져옴

    if (!keyword || !userId) {
      return res.status(400).json({ error: "키워드, 유저 값이 필요합니다." });
    }

    // userId가 유효한 ObjectId인지 확인
    if (!mongoose.Types.ObjectId.isValid(userId)) {
      console.log("🚨 잘못된 userId:", userId);
      return res.status(400).json({ error: "유효한 userId를 입력하세요." });
    }

    const user = await User.findById(userId);
    if (!user) {
      return res.status(404).json({ error: "유저를 찾을 수 없습니다." });
    }

    const newKeyword = new Keyword({ keyword, userId, prefer: 1 });
    await newKeyword.save();

    user.keywords.push(newKeyword._id);
    await user.save();

    res.status(201).json(newKeyword);
  } catch (error) {
    console.error("키워드 저장 오류:", error);
    res.status(500).json({ error: "서버 오류 발생" });
  }
});

//키워드 삭제 (DELETE)
app.delete("/keywords/:keywordId", async (req, res) => {
  try {
    const { keywordId } = req.params;
    const { userId } = req.query; // 🔹 로그인된 사용자 ID 확인

    const keyword = await Keyword.findById(keywordId);
    if (!keyword) {
      return res.status(404).json({ error: "키워드를 찾을 수 없습니다." });
    }

    if (keyword.userId.toString() !== userId) {
      return res.status(403).json({ error: "권한이 없습니다." });
    }

    await Keyword.findByIdAndDelete(keywordId);
    res.json({ success: true });
  } catch (error) {
    console.error("🚨 키워드 삭제 오류:", error);
    res.status(500).json({ error: "서버 오류 발생" });
  }
});

// MongoDB 연결
mongoose
  .connect(process.env.MONGO_URI, {
    useNewUrlParser: true,
    useUnifiedTopology: true,
  })
  .then(() => console.log("MongoDB 연결 성공"))
  .catch((err) => {
    console.error("MongoDB 연결 실패:", err.message);
    process.exit(1);
  });

app.use("/api/auth", authRoutes);

const PORT = process.env.PORT || 5001;
app.listen(PORT, () => console.log(`서버 실행 중: http://localhost:${PORT}`));
