//
//  ArticleListViewController.swift
//  Daily
//
//  Created by 闫润邦 on 2022/7/26.
//

import UIKit

class ArticleListViewController: UIViewController {

    var collectionView: UICollectionView?
    var dataSource: UICollectionViewDiffableDataSource<Int, Int>?
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        title = "知乎日报"
        configureCollectionView()
        configureDataSource()
        
        var snapshot = NSDiffableDataSourceSnapshot<Int, Int>()
        snapshot.appendSections([0, 1, 2])
        snapshot.appendItems([1, 2, 3, 4, 5], toSection: 0)
        snapshot.appendItems([6 ,7 ,8, 9, 10], toSection: 1)
        snapshot.appendItems([11 ,12 ,13, 14, 15], toSection: 1)
        guard let dataSource = dataSource else {
            return
        }
        dataSource.apply(snapshot)
    }

}


extension ArticleListViewController {
    
    
    private func configureCollectionView() {
        // Create Layout using Section Provider
        let layout = UICollectionViewCompositionalLayout() { sectionIndex, environment in
            if sectionIndex == 0 { // Top Section

                
                let topItem = NSCollectionLayoutItem(
                    layoutSize: NSCollectionLayoutSize(
                        widthDimension: .fractionalWidth(1),
                        heightDimension: .fractionalWidth(1)
                    )
                )
                topItem.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 5, bottom: 0, trailing: 5)
                let topGroup = NSCollectionLayoutGroup.horizontal(
                    layoutSize: NSCollectionLayoutSize(
                        widthDimension: .fractionalWidth(1),
                        heightDimension: .fractionalWidth(1)
                    ),
                    subitem: topItem,
                    count: 1
                )
                
                let topSection = NSCollectionLayoutSection(group: topGroup)
                topSection.orthogonalScrollingBehavior = .paging
                
                return topSection
            } else { // Bottom Section
                
                let listItem = NSCollectionLayoutItem(
                    layoutSize: NSCollectionLayoutSize(
                        widthDimension: .fractionalWidth(1),
                        heightDimension: .fractionalHeight(0.2)
                    )
                )
                listItem.contentInsets = NSDirectionalEdgeInsets(top: 5, leading: 0, bottom: 5, trailing: 0)
                let listGroup = NSCollectionLayoutGroup.vertical(
                    layoutSize: NSCollectionLayoutSize(
                        widthDimension: .fractionalWidth(1),
                        heightDimension: .fractionalHeight(0.8)
                    ),
                    subitem: listItem,
                    count: 5
                )
                
                let listSection = NSCollectionLayoutSection(group: listGroup)
                return listSection
            }
        } // Create Layout End
        
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: layout)
        guard let collectionView = collectionView else { return }
        collectionView.register(ArticleTopListCell.self,
                                forCellWithReuseIdentifier: ArticleTopListCell.reuseIdentifier
        )
        collectionView.register(ArticleBottomListCell.self,
                                forCellWithReuseIdentifier: ArticleBottomListCell.reuseIdentifier)
        
        view.addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        let constraints = [
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ]
        view.addConstraints(constraints)
    } // Configure CollectionView End
    
    private func configureDataSource() {
        guard let collectionView = collectionView else { return }
        dataSource = UICollectionViewDiffableDataSource(
            collectionView: collectionView,
            cellProvider: { _, indexPath, itemIdentifier in
                
                if indexPath.section == 0 { // Top
                    
                    guard let cell = collectionView.dequeueReusableCell(
                        withReuseIdentifier: ArticleTopListCell.reuseIdentifier,
                        for: indexPath
                    ) as? ArticleTopListCell else { fatalError() }
                    cell.configureContents()
                    return cell
                    
                } else { // Bottom
                    
                    guard let cell = collectionView.dequeueReusableCell(
                        withReuseIdentifier: ArticleBottomListCell.reuseIdentifier,
                        for: indexPath
                    ) as? ArticleBottomListCell else { fatalError() }
                    cell.configureContents()
                    return cell
                    
                }
        })
    }
}


