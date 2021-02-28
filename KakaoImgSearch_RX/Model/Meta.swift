//
//  Meta.swift
//  KakaoImgSearch_RX
//
//  Created by BHJ on 2021/02/24.
//

import Foundation

struct Meta: Codable {
    let totalCount: Int
    let pageableCount: Int
    let isEnd: Bool
    
    enum CodingKeys: String, CodingKey {
        case totalCount = "total_count"
        case pageableCount = "pageable_count"
        case isEnd = "is_end"
    }
}
