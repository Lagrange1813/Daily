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
    let collectionViewHorizontalOffset: CGFloat = 0
    var dataSource: UICollectionViewDiffableDataSource<String, ArticleAbstract>?
    let pageControl = UIPageControl()
//    var pageStack = [0]
    var nowPage = 2
    var earliestDate = ""
    var dates = [""]
    //用于无限轮播图片
    var isFirstTime:Bool = true
    //
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
        view.backgroundColor = UIColor(hexString: "#F3F3F3")
        configureNetworkMonitor()
        setupTimer()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = false
        setTitle()
        collectionView?.scrollToItem(at: IndexPath(item: 1, section: 0), at: .centeredHorizontally, animated: false)
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
        pageControl.currentPageIndicatorTintColor = .white
		
        guard let collectionView = collectionView else { return }
		
        collectionView.addSubview(pageControl)
		
		pageControl.snp.makeConstraints { make in
			make.trailing.equalTo(view.snp.trailing)
			make.top.equalToSuperview().offset(Constants.width - 30 - 50)
			make.width.equalTo(175)
			make.height.equalTo(50)
		}
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
                topItem.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 15, bottom: 0, trailing: 15)
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
		
		collectionView.backgroundColor = UIColor(hexString: "#F3F3F3")
        
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
        
        collectionView.delegate = self
        collectionView.bounces = true
        collectionView.showsVerticalScrollIndicator = false
        
		collectionView.snp.makeConstraints { make in
			make.top.equalToSuperview()
			make.leading.equalToSuperview().offset(collectionViewHorizontalOffset)
			make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
			make.trailing.equalToSuperview().inset(collectionViewHorizontalOffset)
		}
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
//        let collectionView = scrollView as! UICollectionView
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
            cell.imageView.snp.remakeConstraints { make in
                make.bottom.equalToSuperview()
                make.trailing.equalToSuperview()
                make.leading.equalToSuperview()
                make.height.equalTo(390 - y - 91)
            }
            
        }
    }
    //func collectionView

    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        if isFirstTime {
            collectionView.scrollToItem(at: IndexPath(item: 2, section: 0), at: .centeredHorizontally, animated: false)
            isFirstTime.toggle()
        }else if indexPath.section == 0 {
            if indexPath.item == 8 {
                nowPage = 2
                collectionView.scrollToItem(at: IndexPath(item: 2, section: 0), at: .centeredHorizontally, animated: false)
                return
            } else if indexPath.item == 0 {
                nowPage = 6
                collectionView.scrollToItem(at: IndexPath(item: 6, section: 0), at: .centeredHorizontally, animated: false)
                return
                
            }
        }
        
        // Should Fetch New Data
        guard let dataSource = dataSource else { return }
        
        if dataSource.isIndexPath(indexPath, lastOf: collectionView) {
            fetchNewData(setDate: true)
        }
        nowPage = indexPath.item
        guard indexPath.section == 0 else { return }
        switch nowPage {
        case 1: pageControl.currentPage = 4
        case 7: pageControl.currentPage = 0
        case 0: return
        case 8: return
        default:
            pageControl.currentPage = nowPage - 2
        }
		collectionView.bringSubviewToFront(pageControl)
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
//        guard indexPath.section == 0 else { return }
//        guard let last = pageStack.last else { return }
//        if last == indexPath.item {
//            pageStack.removeLast()
//        }
//        guard let page = pageStack.last else { return }
//        pageControl.currentPage = page-2
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        guard let article = dataSource?.itemIdentifier(for: indexPath) else { fatalError() }
//        let detailVC = ArticleDisplayViewController(id: article.id)
//        navigationController?.pushViewController(detailVC, animated: true)
        print(indexPath)
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
            guard let lastArticles = topArticles.last, let firstArticle = topArticles.first else { return }
            
            let leftSecondArticle = ArticleAbstract(title: lastArticles.title, hint: lastArticles.hint, image: lastArticles.image, id: "0", charColor: lastArticles.charColor)
            let leftFirstArticle = ArticleAbstract(title: "", hint: "", image: lastArticles.image, id: "0", charColor: lastArticles.charColor)
            
            topArticles.insert(leftSecondArticle, at: 0)
            topArticles.insert(leftFirstArticle, at: 0)
            let rightSecondArticle = ArticleAbstract(title: firstArticle.title, hint: firstArticle.hint, image: firstArticle.image, id: "", charColor: firstArticle.charColor)
            let rightFirstArticle = ArticleAbstract(title: "", hint: "", image: firstArticle.image, id: "", charColor: firstArticle.charColor)
            topArticles.append(rightSecondArticle)
            topArticles.append(rightFirstArticle)
            var snapshot = dataSource.snapshot()
            snapshot.appendSections(["top"])
            snapshot.appendItems(topArticles, toSection: "top")
            dataSource.apply(snapshot, animatingDifferences: true)
            topActivityIndicator.stopAnimating()
            pageControl.numberOfPages = topArticles.count - 4
            
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
//实现无限自动轮播
extension ArticleListViewController {
    func setupTimer() {
           let timer = Timer.scheduledTimer(timeInterval: 3, target: self, selector: #selector(showNextImage), userInfo: nil, repeats: true)
        RunLoop.main.add(timer, forMode: RunLoop.Mode.common)
        }
    @objc func showNextImage() {
        guard let collectionView = collectionView else { return }
        nowPage += 1
        if nowPage==8{
            nowPage = 3
        }
        collectionView.scrollToItem(at: IndexPath(item: nowPage, section: 0), at: .centeredHorizontally, animated: true)
        print(nowPage)
        
        
    }
}
