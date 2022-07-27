//
//  ArticleListViewController.swift
//  Daily
//
//  Created by 闫润邦 on 2022/7/26.
//

import UIKit
import Network

class ArticleListViewController: UIViewController {
	var collectionView: UICollectionView?
	var dataSource: UICollectionViewDiffableDataSource<String, ArticleAbstract>?
	let pageControl = UIPageControl()
	var pageStack = [0]
    var earliestDate = ""
    var dates = [""]
    let reloadButton = UIButton()
    let networkMonitor = NWPathMonitor()
    var lastNetworkStatus = NWPath.Status.unsatisfied
	var todayArticles: [ArticleAbstract] = []
	var topArticles: [ArticleAbstract] = []
    
	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view.
        view.backgroundColor = .white
        configureNetworkMonitor()
	}
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = false
    }
}

extension ArticleListViewController {
    
    func configureNetworkMonitor() {
        networkMonitor.pathUpdateHandler = { path in
            if path.status == .satisfied {
                print("have network")
                if self.lastNetworkStatus == .satisfied {
                    return
                }
                self.view.removeAllSubviews()
                self.configureSubviews()
//                self.networkMonitor.cancel()
            } else {
                print("no network")
                self.view.removeAllSubviews()
                self.configureReloadButton()
            }
            self.lastNetworkStatus = path.status
        }
        self.networkMonitor.start(queue: DispatchQueue.main)
    }
    
    private func configureReloadButton() {
        reloadButton.setTitle("无网络连接", for: .normal)
//        reloadButton.setImage(
//            UIImage(systemName: "antenna.radiowaves.left.and.right.slash")?.withTintColor(.white),
//            for: .normal
//        )
        reloadButton.translatesAutoresizingMaskIntoConstraints = false
        reloadButton.backgroundColor = .systemBlue
        reloadButton.layer.cornerRadius = 10
        view.addSubview(reloadButton)
        let constraints = [
            reloadButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            reloadButton.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            reloadButton.heightAnchor.constraint(equalToConstant: 44),
            reloadButton.widthAnchor.constraint(equalToConstant: view.bounds.width - 80)
        ]
        view.addConstraints(constraints)
    }
    
    private func configureSubviews() {
        configureCollectionView()
        configureDataSource()
        fetchData()
        configurePageControl()
    }
    
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
		let layout = UICollectionViewCompositionalLayout { sectionIndex, _ in
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
		                        forCellWithReuseIdentifier: ArticleTopListCell.reuseIdentifier)
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
    
    // Configure DataSource
	private func configureDataSource() {
		guard let collectionView = collectionView else { return }
        
        // Cell Provider
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
			}
		) // Cell Provider End
        
		// Header Provider
		dataSource?.supplementaryViewProvider = { collectionView, _, indexPath in
			guard let header = collectionView.dequeueReusableSupplementaryView(
				ofKind: ArticleListHeaderView.reuseIdentifier,
				withReuseIdentifier: ArticleListHeaderView.reuseIdentifier,
				for: indexPath
			) as? ArticleListHeaderView else { fatalError() }
            header.configureContents(with: self.dates[indexPath.section])
			return header
		} // Header Provider End
        
	} // Configure DataSource End
}

/// Collection View Delegate
extension ArticleListViewController: UICollectionViewDelegate {
	func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        // Should Fetch New Data
        guard let dataSource = dataSource else { return }
        let sectionNum = dataSource.numberOfSections(in: collectionView)
        let itemNumInLastSection = dataSource.collectionView(collectionView, numberOfItemsInSection: sectionNum - 1)
        if indexPath.section == sectionNum - 1 && indexPath.item == itemNumInLastSection - 1 {
            fetchNewData()
        }
        
        
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
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let article = dataSource?.itemIdentifier(for: indexPath) else { fatalError() }
        let detailVC = ArticleDetailViewController()
        detailVC.nowId = article.id
        navigationController?.pushViewController(detailVC, animated: true)
    }
}

/// Fetching Data
extension ArticleListViewController {
    
    private func fetchDate() {
        dates = [""]
        title = "知乎日报"
        Task.init() { // Fetch Date
            let yyyymmdd = await ArticleManager.shared.getTodaysDate()
            let todayMmdd = String(yyyymmdd.dropFirst(4))
            let mm = todayMmdd.dropLast(2)
            let dd = todayMmdd.dropFirst(2)
            title = "知乎日报 \(mm) \(dd)"
        }
    }
    
	private func fetchData() {
		guard let dataSource = dataSource else { return }
        
        fetchDate()
		dataSource.apply(NSDiffableDataSourceSnapshot<String, ArticleAbstract>())
        Task.init() {
            
            // Fetch Top Articles
			topArticles = await ArticleManager.shared.getTopArticleAbstracts()
			var snapshot = dataSource.snapshot()
			snapshot.appendSections(["top"])
			snapshot.appendItems(topArticles, toSection: "top")
			dataSource.apply(snapshot, animatingDifferences: true)
			pageControl.numberOfPages = topArticles.count
            
            earliestDate = await ArticleManager.shared.getTodaysDate()
            
			// Fetch Today Articles
            todayArticles = await ArticleManager.shared.getTodaysArticleAbstracts()
            dates.append(earliestDate)
            snapshot = dataSource.snapshot()
            snapshot.appendSections([earliestDate])
            snapshot.appendItems(todayArticles, toSection: earliestDate)
            dataSource.apply(snapshot)
            
		}
	}
    
    private func fetchNewData() {
        print("Fetch New Data")
        guard let dataSource = dataSource else { return }
        Task.init() {
            let newArticles = await ArticleManager.shared.getArticleAbstracts(before: earliestDate)
            earliestDate = getDate(before: earliestDate)
            dates.append(earliestDate)
            var snapshot = dataSource.snapshot()
            snapshot.appendSections([earliestDate])
            snapshot.appendItems(newArticles, toSection: earliestDate)
            dataSource.apply(snapshot, animatingDifferences: true)
        }
    }
    
    private func getDate(before now: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyymmdd"
        guard var nowDate = dateFormatter.date(from: now) else { fatalError() }
        nowDate = nowDate.dayBofre
        return dateFormatter.string(from: nowDate)
    }
}
