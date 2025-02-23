const mongoose = require("mongoose");
const connectDB = require("./database"); // DB 연결 코드
const Location = require("./models/Location");

async function insertLocation() {
  await connectDB(); // MongoDB 연결

  try {
    const sampleLocation = [
      {
        id: "loc001",
        name: "서울 타워",
        address: "서울특별시 용산구 남산공원길 105",
        location: {
          latitude: 37.5511694,
          longitude: 126.9882266,
        },
        tell: "02-7722-2023",
        keywords: [],
        review: [],
      },
      {
        id: "loc002",
        name: "경복궁",
        address: "서울특별시 종로구 사직로 161",
        location: {
          latitude: 37.579617,
          longitude: 126.977041,
        },
        tell: "02-7370-0000",
        keywords: [],
        review: [],
      },
      {
        id: "loc003",
        name: "제주 성산일출봉",
        address: "제주특별자치도 서귀포시 성산읍 성산리",
        location: {
          latitude: 33.458915,
          longitude: 126.943828,
        },
        tell: "064-710-7923",
        keywords: ["자연", "산"],
        review: ["성산일출봉 리뷰1", "성산일출봉 리뷰2", "성산일출봉 리뷰3"],
      },
      {
        id: "loc004",
        name: "부산 해운대해수욕장",
        address: "부산광역시 해운대구 우동",
        location: {
          latitude: 35.158698,
          longitude: 129.160384,
        },
        tell: "051-749-7601",
        keywords: [],
        review: [],
      },
      {
        id: "loc005",
        name: "강원도 설악산 국립공원",
        address: "강원특별자치도 속초시 설악동",
        location: {
          latitude: 38.119444,
          longitude: 128.465833,
        },
        tell: "033-636-7700",
        keywords: [],
        review: [],
      },
      {
        id: "loc006",
        name: "전주 한옥마을",
        address: "전라북도 전주시 완산구 기린대로 99",
        location: {
          latitude: 35.815005,
          longitude: 127.151733,
        },
        tell: "063-281-1511",
        keywords: [],
        review: [],
      },
      {
        id: "loc007",
        name: "인천 차이나타운",
        address: "인천광역시 중구 차이나타운로 49번길",
        location: {
          latitude: 37.474231,
          longitude: 126.616521,
        },
        tell: "032-760-6487",
        keywords: [],
        review: [],
      },
      {
        id: "loc008",
        name: "광안대교",
        address: "부산광역시 수영구 광안해변로 219",
        location: {
          latitude: 35.153127,
          longitude: 129.118596,
        },
        tell: "051-780-0000",
        keywords: [],
        review: [],
      },
      {
        id: "loc009",
        name: "경주 불국사",
        address: "경상북도 경주시 불국로 385",
        location: {
          latitude: 35.79015,
          longitude: 129.332979,
        },
        tell: "054-746-9913",
        keywords: [],
        review: [],
      },
      {
        id: "loc010",
        name: "남해 독일마을",
        address: "경상남도 남해군 삼동면 독일로 14",
        location: {
          latitude: 34.825142,
          longitude: 128.070786,
        },
        tell: "055-860-3300",
        keywords: [],
        review: [],
      },
    ];

    // ✅ map의 모든 비동기 작업이 완료될 때까지 기다리기 위해 Promise.all 사용
    await Promise.all(
      sampleLocation.map(async (location) => {
        try {
          const updatedLocation = await Location.findOneAndUpdate(
            { id: location.id }, // 검색 조건: id가 동일한 경우
            location, // 업데이트할 데이터
            { new: true, upsert: true } // `new: true`는 업데이트 후 결과 반환, `upsert: true`는 없으면 새로 추가
          );

          if (updatedLocation) {
            console.log(
              `✅ 장소 저장 완료 (업데이트 또는 추가됨): ${location.name}`
            );
          }
        } catch (error) {
          console.error("❌ 장소 저장 실패:", error);
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

insertLocation();
