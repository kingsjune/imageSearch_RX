//
//  DetailViewModel.swift
//  KakaoImgSearch_RX
//
//  Created by BHJ on 2021/02/25.
//

import RxSwift

protocol DetailViewModelType {
    var outputs: DetailViewModelOutputs { get }
}

protocol DetailViewModelOutputs {
    var displaySiteName: Observable<String> { get }
    var dateTime: Observable<Date> { get }
    var imgUrlStr: Observable<String> { get }
}

final class DetailViewModel: DetailViewModelOutputs,DetailViewModelType {
    var dateTime: Observable<Date>
    var displaySiteName: Observable<String>
    var imgUrlStr: Observable<String>
    var outputs: DetailViewModelOutputs { return self }
    
    init(doc: Documents) {
        self.imgUrlStr = Observable.just(doc.image_url)
        self.dateTime = Observable.just(doc.datetime)
        self.displaySiteName = Observable.just(doc.display_sitename)
    }
}
