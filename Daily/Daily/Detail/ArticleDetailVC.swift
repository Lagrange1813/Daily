//
//  ArticleDetailViewController.swift
//  Daily
//
//  Created by Zjt on 2022/7/26.
//

import SnapKit
import UIKit
import WebKit

enum Direction: Int {
	case last = 0
	case now = 1
	case next = 2
}

class ArticleDetailViewController: UIViewController {
	private let url = "http://news-at.zhihu.com/api/4/news/9751055"
	private var lastId = "0"
	var nowId = "9751055"
	private var NextId = "2"
	private var nowOffset = 2
	private var article: Article?
	private var toolBar: UIView?
	private var scrollView: UIScrollView?
	private var topImageViews: [UIImageView] = []
	private var webViews: [ArticleDetailView] = []
	private let ScreenBounds = UIScreen.main.bounds

	override func viewDidLoad() {
		super.viewDidLoad()
		navigationController?.navigationBar.isHidden = true
//		navigationController?.navigationBar.isTranslucent = true
		view.backgroundColor = .white

		configureToolbar()
		configureWebView()
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
		button.addTarget(self, action: #selector(clickReturn), for: .touchUpInside)

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

	private func configureWebView() {
		guard let toolBar = toolBar else { return }

		let detail = ArticleDetailView()
		view.addSubview(detail)
		detail.snp.makeConstraints { make in
			make.top.equalToSuperview()
			make.leading.equalToSuperview()
			make.bottom.equalTo(toolBar.snp.top)
			make.trailing.equalToSuperview()
		}

		configWebView(webView: detail, direction: .now)
	}

	private func configWebView(webView: ArticleDetailView, direction: Direction) {
		switch direction {
		case .last:
			Task {
				article = await ArticleManager.shared.lastArticle(of: nowId)
				guard let article = article else { return }
				let html = concatHTML(css: article.css, body: article.body)
				webView.setContent(title: article.title, image: article.image, html: html)
			}
		case .now:
			Task {
				article = await ArticleManager.shared.getArticle(by: nowId)
				guard let article = article else { return }
				let html = concatHTML(css: article.css, body: article.body)
				webView.setContent(title: article.title, image: article.image, html: html)
			}
		case .next:
			Task {
				try article = await ArticleManager.shared.nextArticle(of: nowId)
				guard let article = article else { return }
				let html = concatHTML(css: article.css, body: article.body)
				webView.setContent(title: article.title, image: article.image, html: html)
			}
		}
		Task {
			article = await ArticleManager.shared.getArticle(by: "9751055")
			guard let article = article else { return }
			let html = concatHTML(css: article.css, body: article.body)
			webView.setContent(title: article.title, image: article.image, html: html)
		}
	}

	@objc func clickReturn() {
		// navigationController?.toolbar.barTintColor = .white
		// navigationController?.toolbar.tintColor = .black
		navigationController?.popViewController(animated: true)
	}

	// 若body存在 拼接body与css后加载
	private func concatHTML(css: [String], body: String) -> String {
		var html = "<html>"
		html += "<head>"
		css.forEach { html += "<link rel=\"stylesheet\" href=\($0)>" }
		html += "<style>img{max-width:320px !important;}</style>"
		html += "</head>"
		html += "<body>"
		html += body
		html += "</body>"

		html += "</html>"

		return html
	}
}

extension ArticleDetailViewController: UIScrollViewDelegate {
	func scrollViewDidScroll(_ scrollView: UIScrollView) {
		print(scrollView.contentOffset.x)
		let offset = scrollView.contentOffset.x
		switch offset {
		case 0:

			nowOffset = 2
			scrollView.contentOffset.x = ScreenBounds.maxX*2
			nowId = NextId
			configWebView(webView: webViews[3], direction: .last)
			lastId = ArticleManager.shared.getCurrentID() ?? nowId
			configWebView(webView: webViews[1], direction: .next)
			NextId = ArticleManager.shared.getCurrentID() ?? nowId

		case ScreenBounds.maxX:
			if nowOffset == 1 { return }
			else if nowOffset == 2 {
				nowOffset = 1
				lastId = nowId
				nowId = NextId
				configWebView(webView: webViews[0], direction: .next)
				NextId = ArticleManager.shared.getCurrentID() ?? nowId
				configWebView(webView: webViews[3], direction: .next)
			} else {
				NextId = nowId
				nowId = lastId
				configWebView(webView: webViews[2], direction: .last)
				lastId = ArticleManager.shared.getCurrentID() ?? nowId
			}
		case ScreenBounds.maxX*2:
			if nowOffset == 2 { return }
			else if nowOffset == 1 {
				nowOffset = 2
				NextId = nowId
				nowId = NextId
				configWebView(webView: webViews[3], direction: .last)
				lastId = nowId
			} else {
				nowOffset = 2
				lastId = nowId
				nowId = NextId
				configWebView(webView: webViews[1], direction: .next)
				NextId = ArticleManager.shared.getCurrentID() ?? nowId
			}
		case ScreenBounds.maxX*3:
			if nowOffset == 3 { return }
			nowOffset = 3
			NextId = nowId
			nowId = lastId
			configWebView(webView: webViews[4], direction: .last)
			lastId = ArticleManager.shared.getCurrentID() ?? nowId
			configWebView(webView: webViews[1], direction: .last)
		case 4*ScreenBounds.maxX:
			nowOffset = 2
			scrollView.contentOffset.x = ScreenBounds.maxX*2
			nowId = lastId
			configWebView(webView: webViews[3], direction: .last)
			lastId = ArticleManager.shared.getCurrentID() ?? nowId
			configWebView(webView: webViews[1], direction: .next)
			NextId = ArticleManager.shared.getCurrentID() ?? nowId
		default:
			return
		}
	}
}
