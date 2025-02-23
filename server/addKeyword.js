const mongoose = require("mongoose");
const connectDB = require("./database"); // DB 연결 코드
const Key = require("./models/Keyword"); // Key 모델 불러오기
const Keyword = require("./models/Keyword");

async function insertKeywords() {
  await connectDB(); // MongoDB 연결

  try {
    const sampleKeywords = [
      { id: "k1", text: "힐링" },
      { id: "k2", text: "자연" },
      { id: "k3", text: "여행" },
      { id: "k4", text: "등산" },
      { id: "k5", text: "바다" },
      { id: "k6", text: "맛집" },
      { id: "k7", text: "휴식" },
      { id: "k8", text: "사진" },
      { id: "k9", text: "역사" },
      { id: "k10", text: "문화" },
      { id: "k11", text: "캠핑" },
      { id: "k12", text: "음악" },
      { id: "k13", text: "예술" },
      { id: "k14", text: "영화" },
      { id: "k15", text: "독서" },
      { id: "k16", text: "운동" },
      { id: "k17", text: "피트니스" },
      { id: "k18", text: "요가" },
      { id: "k19", text: "자전거" },
      { id: "k20", text: "러닝" },
      { id: "k21", text: "명상" },
      { id: "k22", text: "쇼핑" },
      { id: "k23", text: "패션" },
      { id: "k24", text: "카페" },
      { id: "k25", text: "베이킹" },
      { id: "k26", text: "요리" },
      { id: "k27", text: "디자인" },
      { id: "k28", text: "기술" },
      { id: "k29", text: "코딩" },
      { id: "k30", text: "게임" },
      { id: "k31", text: "드라이브" },
      { id: "k32", text: "펫" },
      { id: "k33", text: "산책" },
      { id: "k34", text: "사진촬영" },
      { id: "k35", text: "공예" },
      { id: "k36", text: "여가" },
      { id: "k37", text: "자기계발" },
      { id: "k38", text: "봉사활동" },
      { id: "k39", text: "재테크" },
      { id: "k40", text: "인테리어" },
    ];

    const keywordPromises = sampleKeywords.map(async (keyword) => {
      const existingKeyword = await Keyword.findOne({ id: keyword.id });
      if (!existingKeyword) {
        const newKeyword = new Keyword(keyword);
        await newKeyword.save();
        console.log(`✅ 키워드 추가 완료: ${keyword.text}`);
      } else {
        console.log(`⚠️ 이미 존재하는 키워드: ${keyword.text}`);
      }
    });

    await Promise.all(keywordPromises); // 병렬 실행 최적화
  } catch (error) {
    console.error("❌ 키워드 추가 실패:", error);
  } finally {
    mongoose.connection.close(); // 연결 종료
  }
}

insertKeywords();
