//
//  KakaoImgSearch_RXTests.swift
//  KakaoImgSearch_RXTests
//
//  Created by BHJ on 2021/02/24.
//
import Foundation
import XCTest
import Nimble
import RxTest

@testable import KakaoImgSearch_RX

class KakaoImgSearch_RXTests: XCTestCase {
    
    var resModel: ResultViewModel!
    var viewModel: DetailViewModelType!
    var imageData = ImgRequestData(query: "제주", page: 1 ,size: 1)
    
    override func setUp() {
        resModel = ResultViewModel()
    }
    
    func testApi() {

    var resultOfTask: Result<(ResponseModel, ImgRequestData),SearchServiceError>?

    let expectation = XCTestExpectation(description: "API가 제대로 동작하지 않아요.")

     APIManager.shared.request(imageData) { (res) in
        resultOfTask = res
        expectation.fulfill()
     }
        wait(for: [expectation], timeout: 5)
        XCTAssertNotNil(resultOfTask)
    }
    
    func testNextPage() {
        var isMore = resModel.isMorePage
        isMore = true
        expect(isMore).to(
            beTrue(),
            description: "더이상 보여줄 페이지가 없습니다.."
        )
    }
}
