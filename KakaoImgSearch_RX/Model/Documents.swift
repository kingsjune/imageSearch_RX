//
//  Documents.swift
//  KakaoImgSearch_RX
//
//  Created by BHJ on 2021/02/24.
//

import Foundation

struct Documents: Codable ,RowViewModel {
    var collection: String
    var datetime: Date
    var display_sitename: String
    var doc_url: String
    var height: Int
    var image_url: String
    var thumbnail_url: String
    var width: Int
    
    private enum CodingKeys: String, CodingKey {
        case collection = "collection"
        case thumbnail_url = "thumbnail_url"
        case image_url = "image_url"
        case width = "width"
        case height = "height"
        case display_sitename = "display_sitename"
        case doc_url = "doc_url"
        case datetime = "datetime"
         
    }
    
        init(from decoder: Decoder) throws {
            let values = try decoder.container(keyedBy: CodingKeys.self)
            self.collection = try values.decode(String.self, forKey: .collection)
    
            let dateString = try values.decode(String.self, forKey: .datetime)
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
    
            if let datetime = dateFormatter.date(from: dateString) {
                self.datetime = datetime
            } else {
                throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: [CodingKeys.datetime],
                                                                        debugDescription: "시간 데이터 포맷 에러"))
            }
    
            self.display_sitename = try values.decode(String.self, forKey: .display_sitename)
            self.doc_url = try values.decode(String.self, forKey: .doc_url)
            self.height = try values.decode(Int.self, forKey: .height)
            self.image_url = try values.decode(String.self, forKey: .image_url)
            self.thumbnail_url = try values.decode(String.self, forKey: .thumbnail_url)
            self.width = try values.decode(Int.self, forKey: .width)
        }
    
}
