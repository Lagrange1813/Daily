//
//  ArticleDetailView.swift
//  Daily
//
//  Created by Zjt on 2022/7/27.
//

import WebKit

class ArticleDetailView: WKWebView {
	var imageView: UIImageView?
	var titleLabel: UILabel?

	let imageHeight: CGFloat = 400

	init() {
		let script = "var meta = document.createElement('meta'); meta.setAttribute('name', 'viewport'); meta.setAttribute('content', 'width=device-width'); document.getElementsByTagName('head')[0].appendChild(meta);"
		let userScript = WKUserScript(source: script, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
		let controller = WKUserContentController()
		controller.addUserScript(userScript)
		let config = WKWebViewConfiguration()
		config.userContentController = controller
		super.init(frame: .zero, configuration: config)
		configureView()
	}
	
	required init?(coder: NSCoder) {
		fatalError()
	}
	
	func configureView() {
		scrollView.contentInsetAdjustmentBehavior = .never
		scrollView.automaticallyAdjustsScrollIndicatorInsets = false
		scrollView.contentInset = UIEdgeInsets(top: 200, left: 0, bottom: 0, right: 0)
		
		imageView = UIImageView()
		titleLabel = UILabel()
		
		guard let imageView = imageView,
			  let titleLabel = titleLabel else { return }
		
		imageView.contentMode = .scaleAspectFill
		imageView.clipsToBounds = true
		
		titleLabel.font = UIFont(name: "LXGWWenKai-Bold", size: 23)
		titleLabel.backgroundColor = .clear
		titleLabel.numberOfLines = 0
		titleLabel.lineBreakMode = .byCharWrapping
		titleLabel.textColor = .white
		
		scrollView.addSubview(imageView)
		imageView.snp.makeConstraints { make in
			make.centerX.equalToSuperview()
			make.top.equalTo(scrollView.snp.top).offset(-200)
			make.height.equalTo(imageHeight)
			make.width.equalTo(Constants.width)
		}
		
		imageView.addSubview(titleLabel)
		titleLabel.snp.makeConstraints { make in
			make.bottom.equalToSuperview().inset(20)
			make.leading.equalToSuperview().offset(20)
			make.trailing.equalToSuperview().inset(20)
			make.height.equalTo(80)
		}
	}
	
	func setContent(title: String, image: UIImage, html: String) {
		imageView?.image = image
		titleLabel?.text = title
		loadHTMLString(html, baseURL: nil)
	}
}
