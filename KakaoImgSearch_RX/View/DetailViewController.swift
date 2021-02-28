//
//  DetailViewController.swift
//  KakaoImgSearch_RX
//
//  Created by BHJ on 2021/02/25.
//

import UIKit
import RxSwift
import SnapKit

class DetailViewController: UIViewController {
    
    var scrollView = UIScrollView()
    var viewModel : DetailViewModelType!
    let disposeBag = DisposeBag()
    var imageView : UIImageView =  {
       var iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.layer.masksToBounds = true
        return iv
    }()
    
    var displaySiteLabel = UILabel()
    var dateTimeLabel = UILabel()

    func setViewModel(_ vm :DetailViewModel){
        self.viewModel = vm
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bind()
    }
    
    func bind()  {
        viewModel.outputs.imgUrlStr
            .observe(on: ConcurrentMainScheduler.instance)
            .map{URL(string:$0)}
            .filter{$0 != nil}
            .map{$0!}
            .map{try Data(contentsOf: $0)}
            .map{UIImage(data: $0)}
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: {img in
                self.setUI(img!)
            })
            .disposed(by: disposeBag)
        
        viewModel.outputs.displaySiteName
            .observe(on: MainScheduler.instance)
            .bind(to: displaySiteLabel.rx.text)
            .disposed(by: disposeBag)

        viewModel.outputs.dateTime
            .observe(on: MainScheduler.instance)
            .map{
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy년 MM월 dd일"
                return dateFormatter.string(from: $0)
            }
            .bind(to: dateTimeLabel.rx.text)
            .disposed(by: disposeBag)

    }
    
    func setUI(_ img : UIImage)  {

        self.imageView.image = img

        self.view.addSubview(scrollView) // 메인뷰에
        scrollView.snp.makeConstraints {
            $0.top.left.right.bottom.equalToSuperview()
        }
        
        [imageView,displaySiteLabel, dateTimeLabel].forEach { scrollView.addSubview($0) }
        
        imageView.snp.makeConstraints {
            $0.top.equalTo(self.scrollView.snp_topMargin)
            $0.width.equalToSuperview()
            $0.height.equalTo(500)
        }
     
        displaySiteLabel.snp.makeConstraints{
            $0.top.equalTo(imageView.snp.bottom).offset(5)
            $0.left.equalToSuperview().offset(7)
            $0.right.equalToSuperview().offset(-7)
        }
        dateTimeLabel.snp.makeConstraints{
            $0.top.equalTo(displaySiteLabel.snp.bottom).offset(5)
            $0.left.equalToSuperview().offset(7)
            $0.right.equalToSuperview().offset(-7)
            $0.bottom.equalToSuperview().offset(-10)
        }

        imageView.snp.updateConstraints {
            $0.height.equalTo( self.getAspectRatio(CGSize(width: self.view.frame.size.width, height: img.size.height), img))
        }

    }
    
    func getAspectRatio(_ cellImageFrame:CGSize, _ downloadedImage: UIImage)->CGFloat
    {
        let widthOffset = downloadedImage.size.width - cellImageFrame.width
        let widthOffsetPercentage = (widthOffset*100)/downloadedImage.size.width
        let heightOffset = (widthOffsetPercentage * downloadedImage.size.height)/100
        let effectiveHeight = downloadedImage.size.height - heightOffset
        return effectiveHeight
//        /*if 이미지가 길경우* Test/
//        return effectiveHeight + 1000
    }

}
