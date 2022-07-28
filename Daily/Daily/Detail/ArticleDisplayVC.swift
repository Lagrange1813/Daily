//
//  ArticleDisplayVC.swift
//  Daily
//
//  Created by Zjt on 2022/7/27.
//

import UIKit

class ArticleDisplayViewController: UIViewController {
	private var toolBar: UIView?
	private var switchingView: UIScrollView?
	private var webView: ArticleDetailView?

	private var webViewArray: [ArticleDetailView] = [
		ArticleDetailView(),
		ArticleDetailView(),
		ArticleDetailView()
	]
	
	private var isChanged: Bool = false
	private var currentIndex: Int = 1

//	init(id: String) {
//		super.init(nibName: nil, bundle: nil)
//
//	}

	override func viewDidLoad() {
		super.viewDidLoad()
		navigationController?.navigationBar.isHidden = true
		view.backgroundColor = .white

		Task {
			await ArticleManager.shared.getTodaysDate()
			await ArticleManager.shared.getTodaysArticleAbstracts()
			
			let webViewAtRight = webViewArray[2]
			do {
				if let article = try await ArticleManager.shared.nextArticle(of: "9751095") {
					let html = concatHTML(css: article.css, body: article.body)
					webViewAtRight.setContent(title: article.title, image: article.image, html: html)
				}
			} catch {
				print(error)
			}
			
			let webViewAtLeft = webViewArray[0]
			if let article = try await ArticleManager.shared.lastArticle(of: "9751095") {
				let html = concatHTML(css: article.css, body: article.body)
				webViewAtLeft.setContent(title: article.title, image: article.image, html: html)
			}
		}

		configureToolbar()
		configureSwitchingView()

		for (index, _) in webViewArray.enumerated() {
			configureWebView(at: index)
		}
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

//		webView = ArticleDetailView()
		let webView = webViewArray[index]

		guard let switchingView = switchingView else { return }
//		      let webView = webView

		switchingView.addSubview(webView)
		webView.snp.makeConstraints { make in
			make.top.equalToSuperview()
			make.leading.equalToSuperview().offset(Constants.width * CGFloat(index))
			make.width.height.equalToSuperview()
		}

		setContent()
	}

	func setContent() {
//		guard let webView = webView else { return }
		let webViewAtCenter = webViewArray[1]
		Task {
			let article = await ArticleManager.shared.getArticle(by: "9751095")
			let html = concatHTML(css: article.css, body: article.body)
			webViewAtCenter.setContent(title: article.title, image: article.image, html: html)
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
	func setSwitchingViewContentOffset() {
		guard let switchingView = switchingView else { return }
		switchingView.setContentOffset(CGPoint(x: Constants.width, y: 0), animated: false)
	}

	func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
		guard let switchingView = switchingView else { return }
		
		let index = index(at: switchingView.contentOffset.x + Constants.width/2)
		if index == currentIndex {
			print("No")
		} else if index < 1 {
			print("Left")
			moveToLeft()
		} else if index > 1 {
			print("Right")
			moveToRight()
		} else {
			fatalError()
		}
	}
	
	func index(at position: CGFloat) -> Int {
		Int(position / Constants.width)
	}
	
	func moveToRight() {
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
	}

	func moveToLeft() {
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
	}
}

extension ArticleDisplayViewController {
	@objc func returnBtnFunc() {
		print("return")
	}
}
