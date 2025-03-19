/****************************************************
 *  setDB.js
 *
 *  - 서버(server.js)와 분리된 독립 스크립트
 *  - Location에 저장된 문자열 키워드를 Keyword DB에 추가
 *  - 이후 Location의 keywords 필드를 Keyword ObjectId 배열로 업데이트
 ****************************************************/
require("dotenv").config();
const mongoose = require("mongoose");
const isLikelyObjectId = /^[0-9a-f]{24}$/i;

// (1) Mongoose 모델 불러오기
const Location = require("./models/Location");
const Keyword = require("./models/Keyword");

// (2) 동기화 로직 함수
async function syncAllLocationsToKeywords() {
  console.log("🔸 DB 동기화 시작: Location의 keywords를 Keyword DB로 반영...");

  // (A) 전체 Location 문서 불러오기
  const allLocations = await Location.find({});

  // (B) 각 Location에 대해 처리
  for (const location of allLocations) {
    // location.keywords가 문자열 배열이라고 가정
    const keywordTexts = location.keywords || [];
    const uniqueKeywordTexts = [...new Set(keywordTexts)];
    //const newKeywordIds = [];

    for (const text of uniqueKeywordTexts) {
      // 1) 이미 Keyword DB에 있는지 확인
      if (isLikelyObjectId.test(text)) {
        console.log(`⚠️ Skip because looks like ObjectId: ${text}`);
        continue;
      }
      let existing = await Keyword.findOne({ text });
      // 2) 없으면 새로 생성
      if (!existing) {
        existing = new Keyword({ text });
        await existing.save();
        console.log(`✅ 키워드 새로 생성: '${text}' -> _id=${existing._id}`);
      }
      // 3) 배열에 ObjectId 푸시
      //newKeywordIds.push(existing._id);
    }

    // // (C) Location 문서의 keywords 필드를 ObjectId 배열로 교체
    // if (newKeywordIds.length > 0) {
    //   location.keywords = newKeywordIds;
    //   await location.save();
    //   console.log(`🔹 Location '${location.name}' updated with Keyword IDs`);
    // }
  }

  console.log("✅ DB 동기화 완료!");
}

// (3) MongoDB 연결 후 동기화 실행
async function main() {
  try {
    const MONGODB_URI = process.env.MONGO_URI;
    if (!MONGODB_URI) {
      console.error(
        "❌ MONGO_URI가 설정되지 않았습니다. .env 파일을 확인하세요."
      );
      process.exit(1);
    }

    // DB 연결
    await mongoose.connect(MONGODB_URI);
    console.log("✅ MongoDB 연결 성공");

    // 동기화 로직 실행
    await syncAllLocationsToKeywords();
  } catch (error) {
    console.error("🚨 동기화 과정에서 오류 발생:", error);
  } finally {
    // DB 연결 종료 후 프로세스 종료
    await mongoose.connection.close();
    console.log("🔒 MongoDB 연결 종료");
    process.exit(0);
  }
}

// (4) 스크립트 실행
main();
