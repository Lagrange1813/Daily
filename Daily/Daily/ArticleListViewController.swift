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
    let titleView = UIView()
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        configureTitleView()
        configureCollectionView()
        configureDataSource()
        
        var snapshot = NSDiffableDataSourceSnapshot<Int, Int>()
        snapshot.appendSections([0, 1])
        snapshot.appendItems([1, 2, 3, 4, 5], toSection: 0)
        snapshot.appendItems([6 ,7 ,8, 9, 10], toSection: 1)
        guard let dataSource = dataSource else {
            return
        }
        dataSource.apply(snapshot)
    }

}


extension ArticleListViewController {
    
    private func configureTitleView() {
        view.addSubview(titleView)
        titleView.translatesAutoresizingMaskIntoConstraints = false
        let constraints1 = [
            titleView.topAnchor.constraint(equalTo: view.topAnchor),
            titleView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            titleView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            titleView.bottomAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.topAnchor,
                constant: 44
            )
        ]
        view.addConstraints(constraints1)
        titleView.backgroundColor = .white
        let titleLabel = UILabel()
        titleLabel.text = "知乎日报"
        titleLabel.textAlignment = .center
        titleLabel.font = .preferredFont(forTextStyle: .headline)
        titleView.addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let constraints2 = [
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: titleView.bottomAnchor),
            titleLabel.centerXAnchor.constraint(equalTo: titleView.centerXAnchor),
            titleLabel.widthAnchor.constraint(equalToConstant: 200),
        ]
        view.addConstraints(constraints2)
        
    }
    
    private func configureCollectionView() {
        // Create Layout using Section Provider
        let layout = UICollectionViewCompositionalLayout() { sectionIndex, environment in
            // Top Section
            if sectionIndex == 0 {
                
                let topItem = NSCollectionLayoutItem(
                    layoutSize: NSCollectionLayoutSize(
                        widthDimension: .fractionalWidth(0.8),
                        heightDimension: .fractionalWidth(0.8)
                    )
                )
                
                let topGroup = NSCollectionLayoutGroup.horizontal(
                    layoutSize: NSCollectionLayoutSize(
                        widthDimension: .fractionalWidth(1),
                        heightDimension: .fractionalHeight(0.4)),
                    subitem: topItem,
                    count: 1
                )
                
                let topSection = NSCollectionLayoutSection(group: topGroup)
                topSection.orthogonalScrollingBehavior = .paging
                
                return topSection
            } else { //
                
                let listItem = NSCollectionLayoutItem(
                    layoutSize: NSCollectionLayoutSize(
                        widthDimension: .fractionalWidth(0.8),
                        heightDimension: .fractionalHeight(0.2)
                    )
                )
                
                let listGroup = NSCollectionLayoutGroup.vertical(
                    layoutSize: NSCollectionLayoutSize(
                        widthDimension: .fractionalWidth(1),
                        heightDimension: .fractionalHeight(1)
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
            collectionView.topAnchor.constraint(equalTo: titleView.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ]
        view.addConstraints(constraints)
    }
    
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
                    cell.textView.text = "\(indexPath)"
                    return cell
                    
                }
        })
    }
}


