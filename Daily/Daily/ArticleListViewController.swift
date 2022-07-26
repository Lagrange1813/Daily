//
//  ArticleListViewController.swift
//  Daily
//
//  Created by 闫润邦 on 2022/7/26.
//

import UIKit

class ArticleListViewController: UIViewController {

    var collectionView: UICollectionView?
    var dataSource: UICollectionViewDiffableDataSource<Int, AbstractArticle>?
    let pageControl = UIPageControl()
    var pageStack = [0]
    var todayArticles: [AbstractArticle] = []
    var topArticles: [AbstractArticle] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        title = "知乎日报"
        configureCollectionView()
        configureDataSource()
        fetchData()
        configurePageControl()
    }

}


extension ArticleListViewController {
    
    private func configurePageControl() {
        pageControl.currentPage = 0
        pageControl.numberOfPages = 5
        pageControl.pageIndicatorTintColor = .gray
        pageControl.currentPageIndicatorTintColor = .black
        guard let collectionView = collectionView else { return }
        pageControl.frame = CGRect(x: view.bounds.width - 175, y: view.bounds.width - 40, width: 175, height: 40)
        collectionView.addSubview(pageControl)
    }
    
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
                topSection.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 20, trailing: 0)
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
                        heightDimension: .fractionalHeight(0.6)
                    ),
                    subitem: listItem,
                    count: 5
                )
                
                let listSection = NSCollectionLayoutSection(group: listGroup)
                listSection.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 20, trailing: 0)
                let header = NSCollectionLayoutBoundarySupplementaryItem(
                    layoutSize: NSCollectionLayoutSize(
                        widthDimension: .fractionalWidth(1),
                        heightDimension: .absolute(20)
                    ),
                    elementKind: ArticleListHeaderView.reuseIdentifier,
                    alignment: .top
                )
                listSection.boundarySupplementaryItems = [header]
                return listSection
            }
        } // Create Layout End
        
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: layout)
        guard let collectionView = collectionView else { return }
        
        // Register Cells And Headers
        collectionView.register(ArticleTopListCell.self,
                                forCellWithReuseIdentifier: ArticleTopListCell.reuseIdentifier
        )
        collectionView.register(ArticleBottomListCell.self,
                                forCellWithReuseIdentifier: ArticleBottomListCell.reuseIdentifier)
        collectionView.register(ArticleListHeaderView.self,
                                forSupplementaryViewOfKind: ArticleListHeaderView.reuseIdentifier,
                                withReuseIdentifier: ArticleListHeaderView.reuseIdentifier)
        
        view.addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.delegate = self
        collectionView.bouncesZoom = true
        collectionView.bounces = true
        collectionView.showsVerticalScrollIndicator = false
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
                    cell.configureContents(with: itemIdentifier)
                    return cell
                    
                } else { // Bottom
                    
                    guard let cell = collectionView.dequeueReusableCell(
                        withReuseIdentifier: ArticleBottomListCell.reuseIdentifier,
                        for: indexPath
                    ) as? ArticleBottomListCell else { fatalError() }
                    cell.configureContents(with: itemIdentifier)
                    return cell
                    
                }
        })
        // Header Provider
        dataSource?.supplementaryViewProvider = { collectionView, kind, indexPath in
            guard let header = collectionView.dequeueReusableSupplementaryView(
                ofKind: ArticleListHeaderView.reuseIdentifier,
                withReuseIdentifier: ArticleListHeaderView.reuseIdentifier,
                for: indexPath) as? ArticleListHeaderView else { fatalError() }
            header.configureContents()
            return header
        } // Header Provider End
        
    } // Configure DataSource End
}

extension ArticleListViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard indexPath.section == 0 else { return }
        pageStack.append(indexPath.item)
        guard let last = pageStack.last else { return }
        pageControl.currentPage = last
        pageControl.removeFromSuperview()
        collectionView.addSubview(pageControl)
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard indexPath.section == 0 else { return }
        guard let last = pageStack.last else { return }
        if last == indexPath.item {
            pageStack.removeLast()
        }
        guard let page = pageStack.last else { return }
        pageControl.currentPage = page
    }
}


/// Fetching Data
extension ArticleListViewController {
    private func fetchData() {
        guard let dataSource = dataSource else { return }
        
        
        Task.init() { // Fetch Top Articles
            do {
                topArticles = try await ArticleManager.shared.getTopArticles()
                var snapshot = dataSource.snapshot()
                snapshot.appendSections([0])
                snapshot.appendItems(topArticles, toSection: 0)
                dataSource.apply(snapshot, animatingDifferences: true)
                pageControl.numberOfPages = todayArticles.count
            } catch {
                print(error)
            }
        } // Fetch Top Articles End
        
        Task.init() { // Fetch Today Articles
            do {
                todayArticles = try await ArticleManager.shared.getTodaysAbstractArticles()
                var snapshot = dataSource.snapshot()
                snapshot.appendSections([1])
                snapshot.appendItems(todayArticles, toSection: 1)
                dataSource.apply(snapshot)
                print("apply")
            } catch {
                print(error)
            }
        }
    }
}
