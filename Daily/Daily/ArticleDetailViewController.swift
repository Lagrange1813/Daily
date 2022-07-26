//
//  ArticleDetailViewController.swift
//  Daily
//
//  Created by Zjt on 2022/7/26.
//

import UIKit
import WebKit
import SwiftUI
import Alamofire
import SwiftyJSON
enum Direction: Int {
    case last = 0
    case now = 1
    case next = 2
}

class ArticleDetailViewController: UIViewController {
    let url = "http://news-at.zhihu.com/api/4/news/9751055"
    var lastId = 0
    var nowId = 1
    var NextId = 2
    var nowOffset = 2
    
    //var webView: WKWebView?
    var toolBar: UIToolbar?
    let ScreenBounds = UIScreen.main.bounds
    var scrollView: UIScrollView?
    var webViews:[WKWebView]=[]
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.isHidden = true
        view.backgroundColor = .white
        setUpView()
        setUpButton()
        AF.request(url).response { response in
            debugPrint(response)
        }

    }
    
    func setUpView() {
         scrollView=UIScrollView(frame: CGRect(x: 0.0, y: 0.0, width: self.ScreenBounds.maxX, height: self.ScreenBounds.maxY-70))
        scrollView?.contentSize = CGSize(width: self.ScreenBounds.maxX*5, height: 0)
        scrollView?.contentOffset.x = ScreenBounds.maxX*2
        scrollView?.delegate=self
        //scrollView?.showsHorizontalScrollIndicator = false
        scrollView?.isPagingEnabled = true
        if let scrollView = scrollView {
            view.addSubview(scrollView)
        }
        for i in 0...4 {
            let  webView = WKWebView(frame: CGRect(x:ScreenBounds.maxX * CGFloat((i-1)), y: 0.0, width: ScreenBounds.maxX, height: ScreenBounds.maxY-70))
            //webView.loadHTMLString("<html><body><p>Hello\(i)!</p></body></html>", baseURL: nil)
            scrollView?.addSubview(webView)
            webViews.append(webView)
        }
        nowId = 0
        _ = ConfigWebView(webView: webViews[1], direction: .now)
        nowId = 2
        _ = ConfigWebView(webView: webViews[3], direction: .now)
        nowId = 1
        _ = ConfigWebView(webView: webViews[2], direction: .now)
    }
    func ConfigWebView(webView: WKWebView, direction: Direction)->Int{

        webView.loadHTMLString("<html><body><p>Hello!\(nowId)</p></body></html>", baseURL: nil)
        if direction == .next{
            return nowId+1
        }
        return nowId - 1
    }
    
    func setUpButton() {
        toolBar = UIToolbar.init(frame: CGRect(x: 0.0, y: ScreenBounds.maxY-70, width: ScreenBounds.maxX, height: 49))
        guard let toolBar = toolBar else { return }
        view.addSubview(toolBar)
        toolBar.barTintColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        let image = UIImage(systemName: "return")
        let returnButton = UIBarButtonItem(image: image, style: .plain, target: self, action: #selector(clickReturn))
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: "barButtonItemClicked:", action: nil)
        toolBar.setItems([returnButton,flexibleSpace, flexibleSpace, flexibleSpace], animated: true)
        
        
    }
    @objc func clickReturn() {
        //navigationController?.toolbar.barTintColor = .white
        //navigationController?.toolbar.tintColor = .black
        navigationController?.popViewController(animated: true)
    }
                
//                //若body存在 拼接body与css后加载
//    private func concatHTML(css: [String], body: String) -> String {
//        var html = "<html>"
//
//        html += "<head>"
//        css.forEach { html += "<link rel=\"stylesheet\" href=\($0)>" }
//        html += "<style>img{max-width:320px !important;}</style>"
//        html += "</head>"
//
//        html += "<body>"
//        html += body
//        html += "</body>"
//
//        html += "</html>"
//
//        return html
//           }
}
extension ArticleDetailViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        print(scrollView.contentOffset.x)
        let offset=scrollView.contentOffset.x
        switch offset {
        case 0:
            
            nowOffset = 2
            scrollView.contentOffset.x = ScreenBounds.maxX*2
            nowId = lastId
            lastId = ConfigWebView(webView: webViews[1], direction: .last)
            NextId = ConfigWebView(webView: webViews[3], direction: .next)
            
        case ScreenBounds.maxX:
            if nowOffset == 1 { return }
            nowOffset = 1
            NextId = nowId
            nowId = lastId
            lastId = ConfigWebView(webView: webViews[0], direction: .last)
            _ = ConfigWebView(webView: webViews[3], direction: .last)
        case ScreenBounds.maxX*2:
            if nowOffset==2 { return }
            else if nowOffset == 1 {
                nowOffset = 2
                lastId = nowId
                nowId = NextId
                NextId = ConfigWebView(webView: webViews[3], direction: .next)
            } else {
                nowOffset = 2
                NextId = nowId
                nowId = lastId
                lastId = ConfigWebView(webView: webViews[1], direction: .last)
            }
        case ScreenBounds.maxX*3:
            if nowOffset == 3 { return }
            nowOffset = 3
            lastId = nowId
            nowId = NextId
            lastId = ConfigWebView(webView: webViews[4], direction: .next)
            _ = ConfigWebView(webView: webViews[1], direction: .next)
        case 4*ScreenBounds.maxX:
            nowOffset = 2
            scrollView.contentOffset.x = ScreenBounds.maxX*2
            nowId = NextId
            lastId = ConfigWebView(webView: webViews[1], direction: .last)
            NextId = ConfigWebView(webView: webViews[3], direction: .next)
            
            
            
        default:
            return
        }
    }
    
    
}
