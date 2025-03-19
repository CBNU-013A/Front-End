const axios = require('axios');

// 카카오맵 API 키 설정
const KAKAO_API_KEY = 'YOUR_KAKAO_API_KEY';

// 카카오맵 API 호출 예제 함수
async function getKakaoMapData(query) {
    try {
        const response = await axios.get('https://dapi.kakao.com/v2/local/search/keyword.json', {
            headers: {
                Authorization: `KakaoAK ${KAKAO_API_KEY}`,
            },
            params: {
                query: query,
            },
        });

        return response.data;
    } catch (error) {
        console.error('Error fetching data from Kakao Map API:', error);
        throw error;
    }
}

// 테스트 호출
getKakaoMapData('카페')
    .then((data) => console.log(data))
    .catch((error) => console.error(error));