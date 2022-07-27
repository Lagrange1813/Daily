//
//  ArticleDetailViewController.swift
//  Daily
//
//  Created by Zjt on 2022/7/26.
//

import UIKit
import WebKit

enum Direction: Int {
    case last = 0
    case now = 1
    case next = 2
}

class ArticleDetailViewController: UIViewController {
    private var lastId = "0"
    var nowId = "9751055"
    private var NextId = "2"
    private var nowOffset = 2
    
    private var article: Article?
    private var toolBar: UIToolbar?
    private var scrollView: UIScrollView?
    private var webViews: [MyWebView] = []
    
    private let ScreenBounds = UIScreen.main.bounds
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.isHidden = true
        view.backgroundColor = .white
        //setUpView()
        setUpButton()
        test()
    }
    
    func test() {
        let webView = MyWebView(frame: CGRect(x: 0, y: -17, width: ScreenBounds.maxX, height: ScreenBounds.maxY-70))
        ConfigWebView(webView: webView, direction: .now)
        view.addSubview(webView)
    }
    
    private func setUpView() {
        scrollView = UIScrollView(frame: CGRect(x: 0.0, y: 0.0, width: ScreenBounds.maxX, height: ScreenBounds.maxY-70))
        scrollView?.contentSize = CGSize(width: ScreenBounds.maxX*5, height: 0)
        scrollView?.contentOffset.x = ScreenBounds.maxX*2
        scrollView?.delegate = self
        // scrollView?.showsHorizontalScrollIndicator = false
        scrollView?.isPagingEnabled = true
        if let scrollView = scrollView {
            view.addSubview(scrollView)
        }
        for i in 0 ... 4 {
            let webView = MyWebView(frame: CGRect(x: ScreenBounds.maxX*CGFloat(i-1), y: -17, width: ScreenBounds.maxX, height: ScreenBounds.maxY-70))
            scrollView?.addSubview(webView)
            webViews.append(webView)
        }
        ConfigWebView(webView: webViews[2], direction: .now)
        print(nowId)
        // ConfigWebView(webView: webViews[1], direction: .next)
        // NextId = ArticleManager.shared.getCurrentID() ?? nowId
        // print(NextId)
        // ConfigWebView(webView: webViews[3], direction: .last)
        // lastId = ArticleManager.shared.getCurrentID() ?? nowId
        // print(lastId)
    }

    private func ConfigWebView(webView: MyWebView, direction: Direction) {
        switch direction {
        case .last:
            Task {
                article = await ArticleManager.shared.lastArticle(of: nowId)
                guard let article = article else { return }
                let html = concatHTML(css: article.css, body: article.body)
                webView.ConfigView(title: article.title, image: article.image, html: html)
            }
        case .now:
            Task {
                article = await ArticleManager.shared.getArticle(by: nowId)
                guard let article = article else { return }
                let html = concatHTML(css: article.css, body: article.body)
                webView.ConfigView(title: article.title, image: article.image, html: html)
            }
        case .next:
            Task {
                try article = await ArticleManager.shared.nextArticle(of: nowId)
                guard let article = article else { return }
                let html = concatHTML(css: article.css, body: article.body)
                webView.ConfigView(title: article.title, image: article.image, html: html)
            }
        }
    }
    
    private func setUpButton() {
        toolBar = UIToolbar(frame: CGRect(x: 0.0, y: ScreenBounds.maxY-70, width: ScreenBounds.maxX, height: 49))
        guard let toolBar = toolBar else { return }
        view.addSubview(toolBar)
        toolBar.barTintColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        let image = UIImage(systemName: "return")
        let returnButton = UIBarButtonItem(image: image, style: .plain, target: self, action: #selector(clickReturn))
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: "barButtonItemClicked:", action: nil)
        toolBar.setItems([returnButton, flexibleSpace, flexibleSpace, flexibleSpace], animated: true)
    }

    @objc func clickReturn() {
        // navigationController?.toolbar.barTintColor = .white
        // navigationController?.toolbar.tintColor = .black
        navigationController?.popViewController(animated: true)
    }
                
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
            ConfigWebView(webView: webViews[3], direction: .last)
            lastId = ArticleManager.shared.getCurrentID() ?? nowId
            ConfigWebView(webView: webViews[1], direction: .next)
            NextId = ArticleManager.shared.getCurrentID() ?? nowId
            
        case ScreenBounds.maxX:
            if nowOffset == 1 { return }
            else if nowOffset == 2 {
                nowOffset = 1
                lastId = nowId
                nowId = NextId
                ConfigWebView(webView: webViews[0], direction: .next)
                NextId = ArticleManager.shared.getCurrentID() ?? nowId
                ConfigWebView(webView: webViews[3], direction: .next)
            } else {
                NextId = nowId
                nowId = lastId
                ConfigWebView(webView: webViews[2], direction: .last)
                lastId = ArticleManager.shared.getCurrentID() ?? nowId
            }
        case ScreenBounds.maxX*2:
            if nowOffset == 2 { return }
            else if nowOffset == 1 {
                nowOffset = 2
                NextId = nowId
                nowId = NextId
                ConfigWebView(webView: webViews[3], direction: .last)
                lastId = nowId
            } else {
                nowOffset = 2
                lastId = nowId
                nowId = NextId
                ConfigWebView(webView: webViews[1], direction: .next)
                NextId = ArticleManager.shared.getCurrentID() ?? nowId
            }
        case ScreenBounds.maxX*3:
            if nowOffset == 3 { return }
            nowOffset = 3
            NextId = nowId
            nowId = lastId
            ConfigWebView(webView: webViews[4], direction: .last)
            lastId = ArticleManager.shared.getCurrentID() ?? nowId
            ConfigWebView(webView: webViews[1], direction: .last)
        case 4*ScreenBounds.maxX:
            nowOffset = 2
            scrollView.contentOffset.x = ScreenBounds.maxX*2
            nowId = lastId
            ConfigWebView(webView: webViews[3], direction: .last)
            lastId = ArticleManager.shared.getCurrentID() ?? nowId
            ConfigWebView(webView: webViews[1], direction: .next)
            NextId = ArticleManager.shared.getCurrentID() ?? nowId
        default:
            return
        }
    }
}
extension UIScrollView: UIGestureRecognizerDelegate {
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        print("true")
        return true
    }
}
