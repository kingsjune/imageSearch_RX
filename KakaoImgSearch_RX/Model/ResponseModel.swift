//
//  ResponseModel.swift
//  KakaoImgSearch_RX
//
//  Created by BHJ on 2021/02/24.
//

import Foundation

protocol RowViewModel { }

struct ResponseModel : Codable {
    let meta : Meta
    let documents: [Documents]
}

struct NoResults: RowViewModel {
    var desc: String
    
    init(desc: String) {
        self.desc = desc
    }
}
