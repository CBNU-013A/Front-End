const mongoose = require("mongoose");
const fs = require("fs");
const path = require("path");
const connectDB = require("./database"); // MongoDB 연결
const Location = require("./models/Location");

async function insertLocation() {
  try {
    await connectDB(); // MongoDB 연결

    // JSON 파일 읽기
    const filePath = path.join(__dirname, "json", "location.json");
    const data = fs.readFileSync(filePath, "utf-8");
    const sampleLocation = JSON.parse(data);

    console.log(`📌 [서버] ${sampleLocation.length}개의 장소 데이터 로드 완료`);

    // ✅ map의 모든 비동기 작업이 완료될 때까지 기다리기 위해 Promise.all 사용
    await Promise.all(
      sampleLocation.map(async (location) => {
        try {
          const updatedLocation = await Location.findOneAndUpdate(
            { name: location.name }, // 🔹 검색 조건 (ID 기준)
            location, // 업데이트할 데이터
            { new: true, upsert: true, runValidators: true } // ✅ 없으면 삽입 (upsert), 있으면 업데이트
          );

          if (updatedLocation) {
            console.log(
              `✅ 장소 저장 완료 (업데이트 또는 추가됨): ${location.name}`
            );
          }
        } catch (error) {
          console.error(`❌ 장소 저장 실패 (${location.name}):`, error);
        }
      })
    );
  } catch (error) {
    console.error("❌ 전체 과정 중 오류 발생:", error);
  } finally {
    mongoose.connection.close(); // 연결 종료
    console.log("✅ MongoDB 연결 종료");
  }
}

// 함수 실행
insertLocation();
