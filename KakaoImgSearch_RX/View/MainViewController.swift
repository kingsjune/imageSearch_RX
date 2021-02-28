//
//  ViewController.swift
//  KakaoImgSearch_RX
//
//  Created by BHJ on 2021/02/24.
//

import UIKit
import RxSwift
import Kingfisher

private let imgReuseIdentifier = "ImageCell"

class MainViewController: UIViewController   {
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var noResultView: UIView!
    @IBOutlet weak var noResultLabel: UILabel!
    
    let disposeBag = DisposeBag()
    
    let viewModel = ResultViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.sectionInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        collectionView.setCollectionViewLayout(flowLayout, animated: true)
        
        collectionView.delegate  = self
        collectionView.register(UINib(nibName: "ImageCell", bundle: nil), forCellWithReuseIdentifier: imgReuseIdentifier)
        
        noResultView.isHidden = false
        collectionView.isHidden = true

        bind()
        
    }
    
    func bind()  {
        
        searchBar.rx.text.orEmpty
            .map({ text -> String in
                return text.trimmingCharacters(in: .whitespacesAndNewlines)
            })
            .filter({ text -> Bool in
                let isEmpty = text.isEmpty
                
                if isEmpty == true {
                    self.viewModel.clearView()
                    self.noResultLabel.text = "검색어를 입력하세요."
                    self.noResultView.isHidden = false
                    self.collectionView.isHidden = true
                }
                
                return true
            })
            .debounce(.milliseconds(1000), scheduler: MainScheduler())
            .distinctUntilChanged({ (str1, str2) -> Bool in
                return str1 == str2 ? (str1 == "" ? false : true) : false
            })
            .subscribe(onNext: { (keyword) in
                if(!keyword.isEmpty){
                    self.viewModel.requestImageSearch(keyword: keyword)
                }
            })
            .disposed(by: disposeBag)
        
        collectionView.rx
            .willDisplayCell
            .subscribe { cell, indexPath in
                self.viewModel.nextRequestImage(indexPath: indexPath)
            }
            .disposed(by: disposeBag)
        
        
        viewModel.rowViewModels.bind(to: collectionView.rx.items(cellIdentifier: imgReuseIdentifier, cellType: ImageCell.self)){idx,item,cell in
            if item is Documents{
                self.noResultView.isHidden = true
                self.collectionView.isHidden = false
                guard let document = item as? Documents else { return }
                cell.imgView.kf.setImage(with: URL(string: document.thumbnail_url), placeholder: UIImage(named: "placeholder"))
                
            }else{
                guard let descInfo = item as? NoResults else { return }
                self.noResultLabel.text = descInfo.desc
                self.noResultView.isHidden = false
                self.collectionView.isHidden = true
            }
        }
        .disposed(by: disposeBag)
        
        collectionView.rx
            .modelSelected(Documents.self)
            .subscribe(onNext: { documentInfo in
                let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                guard let dvc = storyBoard.instantiateViewController(withIdentifier: "DetailVC") as? DetailViewController else{
                    return
                }
                dvc.setViewModel(DetailViewModel(doc: documentInfo))
                self.present(dvc, animated: true, completion: nil)
            })
            .disposed(by: disposeBag)
        
        //output
        // 에러 처리
        viewModel.outputs.errorMessage
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] error in
                let ac = UIAlertController(title: "\(error)", message: error.errorDescription, preferredStyle: .alert)
                ac.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self?.present(ac, animated: true)
            })
            .disposed(by: disposeBag)
    }
}

extension MainViewController : UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let flowLayout = collectionViewLayout as! UICollectionViewFlowLayout
        let numberofItem: CGFloat = 3
        let collectionViewWidth = self.collectionView.bounds.width
        let extraSpace = (numberofItem - 1) * flowLayout.minimumInteritemSpacing
        let inset = flowLayout.sectionInset.right + flowLayout.sectionInset.left
        let width = Int((collectionViewWidth - extraSpace - inset) / numberofItem)
        return CGSize(width: width, height: width)
    }
    
}
