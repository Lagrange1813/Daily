//
//  ArticleListViewController.swift
//  Daily
//
//  Created by 闫润邦 on 2022/7/26.
//

import UIKit

class ArticleListViewController: UIViewController {

    var collectionView: UICollectionView!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        configureCollectionView()
    }

}


extension ArticleListViewController {
    private func configureCollectionView() {
        
        // Create Layout using Section Provider
        let layout = UICollectionViewCompositionalLayout() { sectionIndex, environment in
            
            
            // Top Section
            if sectionIndex == 0 {
                
                let topItem = NSCollectionLayoutItem(
                    layoutSize: NSCollectionLayoutSize(
                        widthDimension: .fractionalWidth(0.8),
                        heightDimension: .fractionalHeight(1)
                    )
                )
                
                let topGroup = NSCollectionLayoutGroup.horizontal(
                    layoutSize: <#T##NSCollectionLayoutSize#>,
                    subitem: <#T##NSCollectionLayoutItem#>,
                    count: <#T##Int#>
                )
                
            }
            

        }
    }
}
