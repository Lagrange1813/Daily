//
//  TopimageView.swift
//  Daily
//
//  Created by Zjt on 2022/7/27.
//

import UIKit
import WebKit

class MyWebView: UIView {
    var imageView: UIImageView?
    var titleLabel: UILabel?
    var webView: WKWebView?
    var imageHeigh = 235.0

    override init(frame: CGRect) {
        super .init(frame: frame)
        viewInit()
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    func viewInit() {
        let (x,y,width,height) = (frame.minX,frame.minY,frame.width,frame.height)
        imageView = UIImageView(frame: CGRect(x: x, y: y, width: width, height: imageHeigh))
        let jScript = "var meta = document.createElement('meta'); meta.setAttribute('name', 'viewport'); meta.setAttribute('content', 'width=device-width'); document.getElementsByTagName('head')[0].appendChild(meta);"
        let wkUScript = WKUserScript(source: jScript, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
        let wkUController = WKUserContentController()
        wkUController.addUserScript(wkUScript)
        let wkWebConfig = WKWebViewConfiguration()
        wkWebConfig.userContentController = wkUController
        webView = WKWebView(frame: frame,configuration: wkWebConfig)
        
        titleLabel = UILabel()
        
        guard let imageView = imageView,let titleLabel = titleLabel,let webView = webView else { return }
        
        addSubview(webView)
        webView.scrollView.addSubview(imageView)
        imageView.addSubview(titleLabel)
        
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        
        titleLabel.font = UIFont(name: "LXGWWenKai-Bold", size: 20)
        titleLabel.backgroundColor = .clear
        titleLabel.numberOfLines = 0
        titleLabel.lineBreakMode = .byCharWrapping
        titleLabel.textColor = .white
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.centerYAnchor.constraint(
            equalTo: imageView.centerYAnchor,
            constant: imageView.bounds.width / 6
        ).isActive = true
        titleLabel.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        titleLabel.widthAnchor.constraint(equalTo: widthAnchor, constant: -20).isActive = true
        titleLabel.heightAnchor.constraint(equalToConstant: 80).isActive = true
    }
    func ConfigView(title: String, image: UIImage, html: String) {
        imageView?.image = image
        titleLabel?.text = title
        webView?.loadHTMLString(html, baseURL: nil)
    }

}
