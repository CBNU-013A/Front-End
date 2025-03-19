const { Location } = require('../models/Location');
const Keyword = require('../models/Keyword');
/**
 * Location DB에서 keywords(문자열)를 가져와
 * Keyword 컬렉션에 저장 (이미 존재하면 재사용)
 * 그리고 Location의 keywords 필드를 "문자열 배열" 대신
 * Keyword 문서들의 ObjectId 배열로 교체/저장
 */

// 특정 Location의 keywords 가져오기
exports.getLocationWithKeywords = async (req, res) => {
  try {
    const {id} =req.params;
    //id로 location 찾기
    const location = await Location
    .findById(req.params.locationId)
    .populate("keywords" ,"text"); 
    if (!location) return res.status(404).json({ message: 'Location not found' });


    //Location이 가진 문자열 키워드 배열
    const locationKeywords = location.keywords;
    const keywordObjectIds = [];
    
    for(const keywordText of locationKeywords){
      //이미 키워드 DB에 존재하는 경우
      let existingKeyword = await Keyword.findOne({ text : keywordText});
      if(!existingKeyword){
        existingKeyword = new Keyword({text : keywordText});
        await existingKeyword.save(); //없는 경우 새로 저장
      }
      //배열에 objectid 넣기
      keywordObjectIds.push(existingKeyword._id);
    }

    //Location의 keywords 필드를 ObjectId 배열로 교체 (문자열 대신 참조)
    location.keywords = keywordObjectIds;

    //응답
    res.status(200).json({
      message: "Location.keywords -> Keyword DB",
      data : location,
    });

  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};