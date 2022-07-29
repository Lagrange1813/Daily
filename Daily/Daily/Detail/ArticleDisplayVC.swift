//
//  ArticleDisplayVC.swift
//  Daily
//
//  Created by Zjt on 2022/7/27.
//

import SnapKit
import UIKit

class ArticleDisplayViewController: UIViewController {
	private var id: String

	private var toolBar: UIView?
	private var switchingView: UIScrollView?
	private var webView: ArticleDetailView?

	private var blurView: UIVisualEffectView?
	private var statusBarBackgroundView: UIView?

	private var webViewArray: [ArticleDetailView] = [
		ArticleDetailView(),
		ArticleDetailView(),
		ArticleDetailView()
	]

	private var isChanged: Bool = false
	private var currentIndex: Int = 1
	private var isLoading: Bool = false

	private var noLeft: Bool = false
	private var noRight: Bool = false

	init(id: String) {
		self.id = id
		super.init(nibName: nil, bundle: nil)
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		navigationController?.navigationBar.isHidden = true
		view.backgroundColor = .white
        
        for i in 0 ..< 3 {
            webViewArray[i].delegate = self
        }

		Task {
			await ArticleManager.shared.getTodaysDate()
			await ArticleManager.shared.getTodaysArticleAbstracts()
		}

		configureToolbar()
		configureSwitchingView()
		configureTopView()

		for (index, _) in webViewArray.enumerated() {
			configureWebView(at: index)
		}

		setContent()

		for i in 0 ..< 3 {
			webViewArray[i].scrollView.delegate = self
		}
	}

	func configureTopView() {
		// blurView
		let blur = UIBlurEffect(style: UIBlurEffect.Style.regular)
		blurView = UIVisualEffectView(effect: blur)

		statusBarBackgroundView = UIView()
		guard let blurView = blurView,
		      let statusBarBackgroundView = statusBarBackgroundView else { return }

		view.addSubview(blurView)
		blurView.snp.makeConstraints { make in
			make.leading.equalToSuperview()
			make.trailing.equalToSuperview()
			make.top.equalToSuperview()
			make.height.equalTo(60)
		}

		let layer = CAGradientLayer()
		layer.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 60)
		layer.colors = [UIColor(white: 0, alpha: 1).cgColor,
		                UIColor(white: 0, alpha: 1).cgColor,
		                UIColor(white: 0, alpha: 0).cgColor]
		layer.startPoint = CGPoint(x: 0.0, y: 0.0)
		layer.endPoint = CGPoint(x: 0.0, y: 1.0)
		blurView.layer.mask = layer

		// statusBarBackgroundView
		view.addSubview(statusBarBackgroundView)
		statusBarBackgroundView.backgroundColor = .white
		statusBarBackgroundView.snp.makeConstraints { make in
			make.leading.equalToSuperview()
			make.trailing.equalToSuperview()
			make.top.equalToSuperview()
			make.height.equalTo(40)
		}
		statusBarBackgroundView.isHidden = true
	}

	private func configureToolbar() {
		toolBar = UIToolbar()

		guard let toolBar = toolBar else { return }

		view.addSubview(toolBar)
		toolBar.snp.makeConstraints { make in
			make.leading.equalToSuperview()
			make.bottom.equalToSuperview()
			make.trailing.equalToSuperview()
			make.height.equalTo(Constants.bottomInset + 50)
		}

		toolBar.backgroundColor = UIColor(hexString: "#F6F6F6")

		let button = UIButton()
		button.addTarget(self, action: #selector(returnBtnFunc), for: .touchUpInside)

		let origin = UIImage(systemName: "return")?.withTintColor(.black, renderingMode: .alwaysOriginal)
		let highlight = origin?.withTintColor(.systemGray, renderingMode: .alwaysOriginal)

		button.setImage(origin, for: .normal)
		button.setImage(highlight, for: .highlighted)

		toolBar.addSubview(button)
		button.snp.makeConstraints { make in
			make.leading.equalToSuperview().offset(10)
			make.top.equalToSuperview().offset(5)
			make.width.equalTo(50)
			make.height.equalTo(50)
		}
	}

	private func configureSwitchingView() {
		switchingView = UIScrollView()

		guard let switchingView = switchingView,
		      let toolBar = toolBar else { return }

		view.addSubview(switchingView)
		switchingView.snp.makeConstraints { make in
			make.top.equalToSuperview()
			make.leading.equalToSuperview()
			make.bottom.equalTo(toolBar.snp.top)
			make.trailing.equalToSuperview()
		}
		view.layoutIfNeeded()

		switchingView.delegate = self
		switchingView.contentSize = CGSize(width: 3 * Constants.width,
		                                   height: switchingView.bounds.height)
		switchingView.showsHorizontalScrollIndicator = false
		switchingView.bounces = false
		switchingView.isPagingEnabled = true

		setSwitchingViewContentOffset()
	}

	private func configureWebView(at index: Int) {
		guard index <= 2, index >= 0 else { return }

		guard let switchingView = switchingView else { return }

		let webView = webViewArray[index]

		switchingView.addSubview(webView)
		webView.snp.makeConstraints { make in
			make.top.equalToSuperview()
			make.leading.equalToSuperview().offset(Constants.width * CGFloat(index))
			make.width.height.equalToSuperview()
		}
	}

	func setContent() {
		Task {
			let article = await ArticleManager.shared.getArticle(by: self.id)
			let html = concatHTML(css: article.css, body: article.body)
			webViewArray[1].setContent(id: self.id, title: article.title, image: article.image, html: html)
			webViewArray[1].isLoaded = true
		}
	}

	private func concatHTML(css: [String], body: String) -> String {
		var htmlString =
			"""
			<html>
			<head>
			"""
		css.forEach { htmlString += "<link rel=\"stylesheet\" href=\($0)>" }
		htmlString +=
			"""
			  <style>
			  </style>
			</head>
			<body>
			\(body)
			</body>
			</html>
			"""
		return htmlString
	}
}

extension ArticleDisplayViewController: UIScrollViewDelegate {
	func scrollViewDidScroll(_ scrollView: UIScrollView) {
		if scrollView.contentOffset.y < 0 {
			if scrollView == webViewArray[1].scrollView {
				webViewArray[1].adjustImageView {
					$0.snp.updateConstraints { make in
						make.height.equalTo(400 - scrollView.contentOffset.y - 200)
					}
				}
			}
		}

		if let blurView = blurView,
		   let statusBarBackgroundView = statusBarBackgroundView
		{
			if scrollView.contentOffset.y < 200 {
				blurView.isHidden = false
				statusBarBackgroundView.isHidden = true
			} else {
				blurView.isHidden = true
				statusBarBackgroundView.isHidden = false
			}
		}

		// MARK: - SwichingView

		guard let switchingView = switchingView else { return }
		guard scrollView == switchingView else { return }

		if noLeft {
			print("noLeft")
			if scrollView.contentOffset.x < Constants.width {
				scrollView.setContentOffset(CGPoint(x: Constants.width, y: 0),
				                            animated: false)
			}
		}

		if noRight {
			print("noRight")
			if scrollView.contentOffset.x > Constants.width {
				scrollView.setContentOffset(CGPoint(x: Constants.width, y: 0),
				                            animated: false)
			}
		}

		let gesture = scrollView.panGestureRecognizer
		switch gesture.state {
		case .cancelled:
			print("cancel")
		case .failed:
			print("fail")
		case .changed:
			print("changed")
			let index = getRelativeOffset(at: switchingView.contentOffset.x + Constants.width / 2)
			if index == currentIndex {
				//
			} else if index < 1 {
				if webViewArray[0].isLoaded == false {
					Task {
						if let data = await ArticleManager.shared.lastArticle(of: self.id) {
							let html = concatHTML(css: data.1.css, body: data.1.body)
							webViewArray[0].setContent(id: data.0, title: data.1.title, image: data.1.image, html: html)
							webViewArray[0].isLoaded = true
						}
					}
				}

			} else if index > 1 {
				if webViewArray[2].isLoaded == false {
					Task {
						do {
							if let data = try await ArticleManager.shared.nextArticle(of: self.id) {
								let html = concatHTML(css: data.1.css, body: data.1.body)
								webViewArray[2].setContent(id: data.0, title: data.1.title, image: data.1.image, html: html)
								webViewArray[2].isLoaded = true
							}
						} catch {
							print(error)
						}
					}
				}
			} else {
				fatalError()
			}
		default:
			break
		}
	}

	func getRelativeOffset(at positon: CGFloat) -> Int {
		let datum = Constants.width * 3 / 2
		if positon < datum {
			return 0
		} else if positon > datum {
			return 2
		} else {
			return 1
		}
	}

	func setSwitchingViewContentOffset() {
		guard let switchingView = switchingView else { return }
		switchingView.setContentOffset(CGPoint(x: Constants.width, y: 0), animated: false)
	}

	func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
		guard scrollView == switchingView else { return }
		print("done")
		guard let switchingView = switchingView else { return }

		let index = index(at: switchingView.contentOffset.x + Constants.width / 2)
		if index == currentIndex {
			//
		} else if index < 1 {
			moveToLeft()
		} else if index > 1 {
			moveToRight()
		} else {
			fatalError()
		}
	}

	func index(at position: CGFloat) -> Int {
		Int(position / Constants.width)
	}

	func moveToRight() {
		id = webViewArray[2].id
		webViewArray[2].snp.updateConstraints { make in
			make.leading.equalToSuperview().offset(Constants.width)
		}
		setSwitchingViewContentOffset()
		webViewArray[1].snp.updateConstraints { make in
			make.leading.equalToSuperview()
		}
		webViewArray[0].snp.updateConstraints { make in
			make.leading.equalToSuperview().offset(Constants.width * CGFloat(2))
		}
		view.layoutIfNeeded()

		let temp = webViewArray[0]
		webViewArray[0] = webViewArray[1]
		webViewArray[1] = webViewArray[2]
		webViewArray[2] = temp

		webViewArray[2].resetContent()

		if webViewArray[1].isLoaded == false {
			noRight = true
//			setContent()
		} else {
			noLeft = false
			noRight = false
		}
	}

	func moveToLeft() {
		id = webViewArray[0].id
		webViewArray[0].snp.updateConstraints { make in
			make.leading.equalToSuperview().offset(Constants.width)
		}
		setSwitchingViewContentOffset()
		webViewArray[1].snp.updateConstraints { make in
			make.leading.equalToSuperview().offset(Constants.width * CGFloat(2))
		}
		webViewArray[2].snp.updateConstraints { make in
			make.leading.equalToSuperview()
		}
		view.layoutIfNeeded()

		let temp = webViewArray[2]
		webViewArray[2] = webViewArray[1]
		webViewArray[1] = webViewArray[0]
		webViewArray[0] = temp

		webViewArray[0].resetContent()

		if webViewArray[1].isLoaded == false {
			noLeft = true
//			setContent()
		} else {
			noLeft = false
			noRight = false
		}
	}
}

extension ArticleDisplayViewController {
	@objc func returnBtnFunc() {
		navigationController?.popViewController(animated: true)
	}
}
extension ArticleDisplayViewController: ArticleDetailViewDelegate {
    func jumpToWeb(urlRequest: URLRequest) {
        let jumpToWebVC = JumpToWebVC(urlRequest: urlRequest)
        present(jumpToWebVC, animated: true)
        print("present")
        
    }
}
