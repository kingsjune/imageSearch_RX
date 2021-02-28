//
//  ResultViewModel.swift
//  KakaoImgSearch_RX
//
//  Created by BHJ on 2021/02/24.
//

import Foundation
import RxSwift
import RxCocoa


protocol ViewModelOutputs {
    var errorMessage: Observable<SearchServiceError> { get }
}

class ResultViewModel : ViewModelOutputs  {
    var outputs: ViewModelOutputs { return self }
    var errorMessage: Observable<SearchServiceError>
    var error = PublishSubject<Error>()
    var rowViewModels = BehaviorRelay<[RowViewModel]>(value: [])
    var imgData = BehaviorSubject<ImgRequestData?>(value: nil)
    var isMorePage: Bool = false
    let disposeBag = DisposeBag()
    
    init() {
        errorMessage = error.map{ $0 as! SearchServiceError}
        
        imgData
            .flatMapLatest { info -> Observable<Result<(ResponseModel, ImgRequestData),SearchServiceError>> in
                if let info = info {
                    return APIManager.shared.requestImgData(info)
                        .catch { (err) -> Observable<Result<(ResponseModel, ImgRequestData), SearchServiceError>> in
                            self.error.onNext(err)
                            return Observable.empty()
                        }
                }
                return Observable.empty()
            }
            .subscribe(onNext: { res in
                switch res{
                    case.success((let result, let info)):
                        self.isMorePage = !result.meta.isEnd
                        if result.meta.totalCount > 0 && result.documents.count > 0 {
                            if info.page > 1 {
                                var value = self.rowViewModels.value
                                value.append(contentsOf: result.documents)
                                self.rowViewModels.accept(value)
                            } else {
                                self.rowViewModels.accept(result.documents)
                            }
                            
                        } else {
                            let value = NoResults(desc: "검색 결과가 없습니다.")
                            self.rowViewModels.accept([value])
                        }
                        break
                    case.failure(let err):
                        print(err)
                        break
                }
            })
            .disposed(by: disposeBag)
    }

}
extension ResultViewModel {
    func clearView() {
        rowViewModels.accept([])
    }
    // MARK: - 이미지 검색 요청
    func requestImageSearch(keyword: String, page: Int = 1) {
        let info = ImgRequestData(query: keyword, page: page)
        imgData.onNext(info)
    }

    func nextRequestImage(indexPath: IndexPath) {
        if let data = try? imgData.value(), self.isMorePage == true && indexPath.row == rowViewModels.value.count - 1 {
            print("Next Page Request \(data.page)")
            let newInfo = ImgRequestData(query: data.query, page: data.page + 1)
            imgData.onNext(newInfo)
        }
    }
  
}
