//
//  ArticleDetailView.swift
//  Daily
//
//  Created by Zjt on 2022/7/27.
//

import WebKit

class ArticleDetailView_T: WKWebView {
	public var willLoad = false
	public var isLoaded = false
	public var isFirst = false
	public var id: String = ""
	
	private var topBackground = UIView()
	private var imageView: UIImageView?
	private var titleLabel: UILabel?
	private var gradientView = GradientView(colors: [])
	
	var delegate: ArticleDetailViewDelegate?

	let imageHeight: CGFloat = 400

	init() {
		let script = "var meta = document.createElement('meta'); meta.setAttribute('name', 'viewport'); meta.setAttribute('content', 'width=device-width, user-scalable=no'); document.getElementsByTagName('head')[0].appendChild(meta);"
		let userScript = WKUserScript(source: script, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
		let controller = WKUserContentController()
		controller.addUserScript(userScript)
		let config = WKWebViewConfiguration()
		config.userContentController = controller
		super.init(frame: .zero, configuration: config)
		navigationDelegate = self
		configureView()
	}
	
	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError()
	}
	
	func configureView() {
//		scrollView.bounces = false
		scrollView.clipsToBounds = false
		scrollView.contentInsetAdjustmentBehavior = .never
		scrollView.automaticallyAdjustsScrollIndicatorInsets = false
		scrollView.contentInset = UIEdgeInsets(top: 200, left: 0, bottom: 0, right: 0)
		scrollView.alwaysBounceHorizontal = false
		scrollView.showsHorizontalScrollIndicator = false
		scrollView.showsVerticalScrollIndicator = false
		scrollView.backgroundColor = .clear
		
		imageView = UIImageView()
		titleLabel = UILabel()
		
		guard let imageView = imageView,
		      let titleLabel = titleLabel else { return }
		
		imageView.contentMode = .scaleAspectFill
		imageView.clipsToBounds = true
		
		topBackground.backgroundColor = .white
		topBackground.layer.cornerRadius = 20
		
		titleLabel.font = UIFont(name: "LXGWWenKai-Bold", size: 23)
		titleLabel.backgroundColor = .clear
		titleLabel.numberOfLines = 0
		titleLabel.lineBreakMode = .byWordWrapping
		titleLabel.textColor = .black
		
		scrollView.addSubview(imageView)
		imageView.snp.makeConstraints { make in
			make.centerX.equalToSuperview()
//			make.top.equalTo(scrollView.snp.top).offset(-200)
			make.bottom.equalTo(scrollView.snp.top).offset(210)
			make.height.equalTo(imageHeight)
			make.width.equalTo(Constants.width)
		}
		
//		imageView.addSubview(gradientView)
//		gradientView.snp.makeConstraints { make in
//			make.bottom.equalToSuperview()
//			make.centerX.equalToSuperview()
//			make.height.equalTo(imageHeight / 3)
//			make.width.equalToSuperview()
//		}
		
		imageView.addSubview(topBackground)
		topBackground.snp.makeConstraints { make in
			make.bottom.equalToSuperview().offset(40)
			make.leading.equalToSuperview().offset(10)
			make.trailing.equalToSuperview().offset(-10)
			make.height.equalTo(150)
		}
		
		let tint = UIView()
		tint.layer.cornerRadius = 3.5
		tint.backgroundColor = .systemGray3
		topBackground.addSubview(tint)
		tint.snp.makeConstraints { make in
			make.top.equalToSuperview().offset(10)
			make.centerX.equalToSuperview()
			make.width.equalTo(50)
			make.height.equalTo(7)
		}
		
		imageView.addSubview(titleLabel)
		titleLabel.snp.makeConstraints { make in
			make.bottom.equalToSuperview().inset(10)
			make.leading.equalToSuperview().offset(30)
			make.trailing.equalToSuperview().inset(30)
			make.height.equalTo(80)
		}
	}
	
	public func adjustImageView(_ handler: (UIImageView) -> Void) {
		guard let imageView = imageView else { return }
		handler(imageView)
	}
	
	public func setContent(id: String, title: String, image: UIImage, html: String, charColor: UIColor) {
		self.id = id
		imageView?.image = image
		titleLabel?.text = title
		gradientView.gradientLayer.colors = [
			UIColor(charColor, withNewAlpha: 0).cgColor,
			UIColor(charColor, withNewAlpha: 0.8).cgColor,
			UIColor(charColor, withNewAlpha: 1).cgColor,
		]
		loadHTMLString(html, baseURL: nil)
	}
	
	public func resetContent() {
		scrollView.setContentOffset(CGPoint(x: 0, y: -200), animated: false)
		imageView?.snp.updateConstraints { make in
			make.height.equalTo(imageHeight)
		}
		id = ""
		imageView?.image = UIImage()
		titleLabel?.text = ""
		loadHTMLString("", baseURL: nil)
		isLoaded = false
		willLoad = false
	}
}

extension ArticleDetailView_T: WKNavigationDelegate {
	func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
		webView.evaluateJavaScript("document.body.style.fontFamily = \"-apple-system\"")
	}

	func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction) async -> WKNavigationActionPolicy {
		if navigationAction.request.url == URL(string: "about:blank") {
			return .allow
		} else {
			delegate?.jumpToWeb(urlRequest: navigationAction.request)
		}
		return .cancel
	}
}

protocol ArticleDetailViewDelegate_T {
	func jumpToWeb(urlRequest: URLRequest)
}
