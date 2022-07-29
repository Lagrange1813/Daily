//
//  JumpToWebVC.swift
//  Daily
//
//  Created by Zjt on 2022/7/29.
//

import UIKit
import WebKit

class JumpToWebVC: UIViewController {
    private let webView = WKWebView()
    private let toolBar = UIToolbar()
    var urlRequest: URLRequest?
    init(urlRequest: URLRequest) {
        self.urlRequest = urlRequest
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureToolbar()
        configureWebView()
        guard let urlRequest = urlRequest else { return }
        webView.load(urlRequest)
    }

    private func configureToolbar() {
        view.addSubview(toolBar)
        toolBar.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.bottom.equalToSuperview()
            make.trailing.equalToSuperview()
            make.height.equalTo(Constants.bottomInset + 50)
        }

        toolBar.backgroundColor = UIColor(hexString: "#F6F6F6")

        let button = UIButton()
        button.addTarget(self, action: #selector(clickReturnButton), for: .touchUpInside)

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

    @objc func clickReturnButton() {
        dismiss(animated: true)
    }

    private func configureWebView() {
        view.addSubview(webView)
        webView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.equalToSuperview()
            make.width.equalToSuperview()
            make.bottom.equalTo(toolBar.snp.top)
        }
    }
}
