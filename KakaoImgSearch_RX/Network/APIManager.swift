//
//  APIManager.swift
//  KakaoImgSearch_RX
//
//  Created by BHJ on 2021/02/24.
//

import Foundation
import RxSwift
import RxAlamofire
import Alamofire


struct ImgRequestData {
    enum SortType: String {
        case accuracy = "accuracy"
        case recency = "recency"
    }
    var query: String
    var sort: SortType = .accuracy
    var page: Int = 1
    var size: Int = 30
    
    init(query: String) {
        self.query = query
    }
    init(query: String, page: Int) {
        self.query = query
        self.page = page
    }
    init(query: String, page: Int, size: Int) {
        self.query = query
        self.page = page
        self.size = size
    }
}

enum SearchServiceError: LocalizedError {
    case invalidURL
    case invalidJSON
    case networkError
    
    var message: String {
        switch self {
            case .invalidJSON :
                return "데이터를 불러올 수 없습니다."
            case .invalidURL :
                return "유효하지 않은 URL 입니다."
            case .networkError:
                return "네트워크 상태를 확인하세요."
        }
    }
    public var errorDescription: String? { return message }
}

public class APIManager {
    
    static let shared = APIManager()
    private let searchUrl = "https://dapi.kakao.com/v2/search/image"
    let restApiKey = "0a2cbf9466e8ec1863bd045b49f4df45"
    
    func request(_ data : ImgRequestData , onComplete: @escaping (Result<(ResponseModel, ImgRequestData),SearchServiceError>)->Void) {
        AF.request(searchUrl,
                   method:.get,
                   parameters: ["query": data.query,
                                "sort": data.sort,
                                "page": data.page,
                                "size": data.size],
                   headers:  ["Authorization": "KakaoAK \(self.restApiKey)"])
            .validate()
            .responseJSON { (response) in
                switch response.result{
                    case.success:
                        do{
                            let res = try JSONDecoder().decode(ResponseModel.self, from: response.data!)
                            onComplete(.success((res,data)))
                        }
                        catch {
                            onComplete(.failure(.invalidJSON))
                        }
                        break
                    case.failure:
                        onComplete(.failure(.networkError))
                        break
                    }
            }
    }
    
    func requestImgData(_ info: ImgRequestData) -> Observable<Result<(ResponseModel, ImgRequestData),SearchServiceError>> {
        guard !self.restApiKey.isEmpty else {
            return Observable.error(SearchServiceError.invalidURL)
        }
        print("query = \(info.query), page = \(info.page)")
        return Observable.create { emitter in
            self.request(info) { res in
                switch res {
                    case .success:
                        emitter.onNext(res)
                        emitter.onCompleted()
                    case.failure(let err):
                        emitter.onError(err)
                }
            }
            return Disposables.create()
        }
    }
}
