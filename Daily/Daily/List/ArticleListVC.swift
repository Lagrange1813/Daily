//
//  ArticleListViewController.swift
//  Daily
//
//  Created by 闫润邦 on 2022/7/26.
//

import Network
import UIKit

class ArticleListViewController: UIViewController {
    var collectionView: UICollectionView?
    var dataSource: UICollectionViewDiffableDataSource<String, ArticleAbstract>?
    let pageControl = UIPageControl()
    var pageStack = [0]
    var earliestDate = ""
    var dates = [""]
    var seletedDate: String = "" {
        didSet {
            // Todo after select date
            print(seletedDate)
            earliestDate = seletedDate
            dates = [""]
            var snapshot = NSDiffableDataSourceSnapshot<String, ArticleAbstract>()
            snapshot.appendSections(["top"])
            snapshot.appendItems(topArticles, toSection: "top")
            dataSource?.apply(snapshot)
            fetchNewData(setDate: false)
        }
    }

    let reloadButton = UIButton()
    let networkMonitor = NWPathMonitor()
    var lastNetworkStatus = NWPath.Status.unsatisfied
    var todayArticles: [ArticleAbstract] = []
    var topArticles: [ArticleAbstract] = []
    let bottomActivityIndicator = UIActivityIndicatorView(style: .medium)
    let topActivityIndicator = UIActivityIndicatorView(style: .large)
    let todayActivityIndicator = UIActivityIndicatorView(style: .medium)
    let datePicker = UIDatePicker()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        view.backgroundColor = .white
        configureNetworkMonitor()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = false
        setTitle()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        title = ""
        navigationController?.navigationBar.isHidden = true
    }
}

extension ArticleListViewController {
    func configureDatePicker() {
        datePicker.date = Date()
        datePicker.locale = Locale(identifier: "zh_CN")
        datePicker.datePickerMode = .date
        datePicker.maximumDate = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd"
        guard let minDate = dateFormatter.date(from: "20130520") else { fatalError() }
        datePicker.minimumDate = minDate
        datePicker.addTarget(self, action: #selector(datePickerValueChanged), for: .valueChanged)
        if #available(iOS 13.4, *) {
            datePicker.preferredDatePickerStyle = .compact
        }
        navigationController?.navigationBar.addSubview(datePicker)
        datePicker.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(5)
            make.centerY.equalToSuperview()
            make.width.equalTo(100)
            make.height.equalTo(50)
        }
    }

    @objc func datePickerValueChanged() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd"
        print(datePicker.date)
        seletedDate = dateFormatter.string(from: datePicker.date)
        navigationController?.dismiss(animated: false)
    }
    
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
        networkMonitor.start(queue: DispatchQueue.main)
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
            reloadButton.widthAnchor.constraint(equalToConstant: view.bounds.width - 80),
        ]
        view.addConstraints(constraints)
    }
    
    private func configureSubviews() {
        configureCollectionView()
        configureTopIndicator()
        configureTodayIndicator()
        configureDataSource()
        fetchData()
        configurePageControl()
        configureDatePicker()
    }
    
    private func configureTopIndicator() {
        topActivityIndicator.translatesAutoresizingMaskIntoConstraints = false
        guard let collectionView = collectionView else { return }
        collectionView.addSubview(topActivityIndicator)
        let constraints = [
            topActivityIndicator.topAnchor.constraint(equalTo: collectionView.topAnchor),
            topActivityIndicator.heightAnchor.constraint(equalToConstant: view.bounds.width),
            topActivityIndicator.centerXAnchor.constraint(equalTo: collectionView.centerXAnchor),
            topActivityIndicator.widthAnchor.constraint(equalToConstant: view.bounds.width),
        ]
        collectionView.addConstraints(constraints)
    }
    
    private func configureTodayIndicator() {
        todayActivityIndicator.translatesAutoresizingMaskIntoConstraints = false
        guard let collectionView = collectionView else { return }
        collectionView.addSubview(todayActivityIndicator)
        let constraints = [
            todayActivityIndicator.topAnchor.constraint(
                equalTo: topActivityIndicator.bottomAnchor,
                constant: 50
            ),
            todayActivityIndicator.heightAnchor.constraint(equalToConstant: 50),
            todayActivityIndicator.centerXAnchor.constraint(equalTo: collectionView.centerXAnchor),
            todayActivityIndicator.widthAnchor.constraint(equalToConstant: 50),
        ]
        collectionView.addConstraints(constraints)
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
                
                let footer = NSCollectionLayoutBoundarySupplementaryItem(
                    layoutSize: NSCollectionLayoutSize(
                        widthDimension: .fractionalWidth(1),
                        heightDimension: .absolute(20)
                    ),
                    elementKind: AriticleListFooterView.reuseIdentifier,
                    alignment: .bottom
                )
                
                listSection.boundarySupplementaryItems = [header, footer]
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
        collectionView.register(AriticleListFooterView.self,
                                forSupplementaryViewOfKind: AriticleListFooterView.reuseIdentifier,
                                withReuseIdentifier: AriticleListFooterView.reuseIdentifier)
        
        view.addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.delegate = self
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
                    cell.configureContents(withArticle: itemIdentifier, indicator: self.topActivityIndicator)
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
        
        // Header/Footer Provider
        dataSource?.supplementaryViewProvider = { collectionView, kind, indexPath in
            if kind == ArticleListHeaderView.reuseIdentifier { // Header
                guard let header = collectionView.dequeueReusableSupplementaryView(
                    ofKind: ArticleListHeaderView.reuseIdentifier,
                    withReuseIdentifier: ArticleListHeaderView.reuseIdentifier,
                    for: indexPath
                ) as? ArticleListHeaderView else { fatalError() }
                header.configureContents(with: self.dates[indexPath.section])
                return header
            } else { // Footer
                guard let footer = collectionView.dequeueReusableSupplementaryView(
                    ofKind: AriticleListFooterView.reuseIdentifier,
                    withReuseIdentifier: AriticleListFooterView.reuseIdentifier,
                    for: indexPath
                ) as? AriticleListFooterView else { fatalError() }
                footer.configureContents(with: self.bottomActivityIndicator)
                guard let dataSource = self.dataSource else {
                    return footer
                }
                
                let lastSection = dataSource.lastIndexPath(of: collectionView).section
                guard indexPath.section == lastSection else {
                    return footer
                }
                self.bottomActivityIndicator.startAnimating()
                return footer
            }
        } // Header/Footer Provider End
    } // Configure DataSource End
}

/// Collection View Delegate
extension ArticleListViewController: UICollectionViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let y = scrollView.contentOffset.y
        if y < -91 {
            let indexPath = IndexPath(item: pageControl.currentPage, section: 0)
            let cell = collectionView?.cellForItem(at: indexPath) as? ArticleTopListCell
            guard let cell = cell else { return }
            let gradientLayer = cell.gradientLayer
            if let position = cell.gradientLayerPosition {
                print(position)
                gradientLayer.position = CGPoint(x: position.x, y: position.y-y-91)
				view.layoutIfNeeded()
            }
            let imageView = cell.imageView
            cell.imageView.snp.remakeConstraints { make in
                make.bottom.equalToSuperview()
                make.trailing.equalToSuperview()
                make.leading.equalToSuperview()
                make.height.equalTo(390 - y - 91)
            }
            
        }
    }

    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        // Should Fetch New Data
        guard let dataSource = dataSource else { return }
        
        if dataSource.isIndexPath(indexPath, lastOf: collectionView) {
            fetchNewData(setDate: true)
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
        let detailVC = ArticleDisplayViewController(id: article.id)
        navigationController?.pushViewController(detailVC, animated: true)
    }
}

/// Fetching Data
extension ArticleListViewController {
    private func fetchDate() {
        dates = [""]
        title = "知乎日报"
        Task { // Fetch Date
            let yyyymmdd = await ArticleManager.shared.getTodaysDate()
            let todayMmdd = String(yyyymmdd.dropFirst(4))
            let mm = todayMmdd.dropLast(2)
            let dd = todayMmdd.dropFirst(2)
            title = "知乎日报 \(mm) \(dd)"
        }
    }
    
    private func setTitle() {
        title = "知乎日报"
        Task { // Fetch Date
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
        Task {
            // Fetch Top Articles
            topActivityIndicator.startAnimating()
            todayActivityIndicator.startAnimating()
            topArticles = await ArticleManager.shared.getTopArticleAbstracts()
            var snapshot = dataSource.snapshot()
            snapshot.appendSections(["top"])
            snapshot.appendItems(topArticles, toSection: "top")
            dataSource.apply(snapshot, animatingDifferences: true)
            topActivityIndicator.stopAnimating()
            pageControl.numberOfPages = topArticles.count
            
            earliestDate = await ArticleManager.shared.getTodaysDate()
            
            // Fetch Today Articles
            todayArticles = await ArticleManager.shared.getTodaysArticleAbstracts()
            dates.append(earliestDate)
            snapshot = dataSource.snapshot()
            snapshot.appendSections([earliestDate])
            snapshot.appendItems(todayArticles, toSection: earliestDate)
            dataSource.apply(snapshot)
            todayActivityIndicator.stopAnimating()
        }
    }
    
    private func fetchNewData(setDate: Bool) {
        print("Fetch New Data")
        guard let dataSource = dataSource else { return }
        guard let collectionView = collectionView else { return }
        Task {
            bottomActivityIndicator.startAnimating()
            let newArticles = await ArticleManager.shared.getArticleAbstracts(before: earliestDate)
            if setDate {
                earliestDate = getDate(before: earliestDate)
            }
            dates.append(earliestDate)
            guard let footer = dataSource.collectionView(collectionView, viewForSupplementaryElementOfKind: AriticleListFooterView.reuseIdentifier,
                                                         at: dataSource.lastIndexPath(of: collectionView)) as? AriticleListFooterView
            else {
                fatalError()
            }
            bottomActivityIndicator.stopAnimating()
            footer.removeAllSubviews()
            
            var snapshot = dataSource.snapshot()
            snapshot.appendSections([earliestDate])
            snapshot.appendItems(newArticles, toSection: earliestDate)
            dataSource.apply(snapshot, animatingDifferences: true)
        }
    }
    
    private func getDate(before now: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd"
        guard var nowDate = dateFormatter.date(from: now) else { fatalError() }
        nowDate = nowDate.dayBofre
        return dateFormatter.string(from: nowDate)
    }
}
