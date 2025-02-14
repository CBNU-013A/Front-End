const express = require("express");
const bcrypt = require("bcryptjs");
const jwt = require("jsonwebtoken");
const User = require("../models/User");
const Keyword = require("../models/Keyword");

const router = express.Router();

// 회원가입 API
router.post("/register", async (req, res) => {
  try {
    const { name, email, password, birthdate } = req.body;
    // 🔹 이메일 중복 검사
    const existingUser = await User.findOne({ email });
    if (existingUser) {
      return res.status(400).json({ error: "이미 존재하는 이메일입니다." });
    }
    const hashedPassword = await bcrypt.hash(password, 10);
    const newUser = new User({
      name,
      email,
      password: hashedPassword,
      birthdate,
    });

    await newUser.save();
    res.status(201).json({ message: "회원가입 성공" });
  } catch (err) {
    res.status(500).json({ error: "회원가입 실패" });
  }
});

// 로그인 API
// 🔹 로그인 엔드포인트 확인
router.post("/login", async (req, res) => {
  try {
    const { email, password } = req.body;
    console.log(`📌 로그인 시도: 이메일=${email}`);

    const user = await User.findOne({ email });
    if (!user) {
      return res
        .status(404)
        .json({ success: false, error: "이메일이 존재하지 않습니다." });
    }

    const isMatch = await bcrypt.compare(password, user.password);
    if (!isMatch) {
      return res
        .status(400)
        .json({ success: false, error: "비밀번호가 틀렸습니다." });
    }

    const token = jwt.sign({ id: user._id }, process.env.JWT_SECRET, {
      expiresIn: "1h",
    });

    console.log(`✅ 로그인 성공: userId=${user._id}`);

    res.json({
      success: true,
      token,
      user: {
        id: user._id.toString(),
        name: user.name,
        email: user.email,
      },
    });
  } catch (error) {
    console.error("🚨 로그인 오류:", error);
    res.status(500).json({ success: false, error: "서버 오류 발생" });
  }
});

module.exports = router;
