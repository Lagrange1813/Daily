//
// ArticleManager.swift
// Daily
//
// Created by 张维熙 on 2022/7/26.
//

import Foundation
import SwiftyJSON
import UIKit

let singleton = ArticleManager()

class ArticleManager {
	static var shared: ArticleManager {
		singleton
	}

	private var service = ArticleService()

	fileprivate init() {}

	func getTodaysAbstractArticles() async -> [AbstractArticle] {
		async let json = service.getTodaysJSON()
		var articles: [AbstractArticle] = []

		if let articleArray = await json["stories"].array {
			for articleJson in articleArray {
				let article = AbstractArticle(
					title: articleJson["title"].stringValue,
					hint: articleJson["hint"].stringValue,
					image: await getImage(url: articleJson["images"].array?.first?.stringValue ?? ""),
					id: articleJson["id"].stringValue,
					charColor: UIColor(hexString: convertColorString(articleJson["image_hue"].stringValue))
				)
				articles.append(article)
			}
		}
		return articles
	}

	func getTopArticles() async -> [AbstractArticle] {
		async let json = service.getTodaysJSON()
		var articles: [AbstractArticle] = []

		if let articleArray = await json["top_stories"].array {
			for articleJson in articleArray {
				let article = AbstractArticle(
					title: articleJson["title"].stringValue,
					hint: articleJson["hint"].stringValue,
					image: await getImage(url: articleJson["images"].array?.first?.stringValue ?? ""),
					id: articleJson["id"].stringValue,
					charColor: UIColor(hexString: convertColorString(articleJson["image_hue"].stringValue))
				)
				articles.append(article)
			}
		}
		return articles
	}

	func getImage(url: String) async -> UIImage {
		async let data = service.getImage(url: url)
		return await UIImage(data: data) ?? UIImage()
	}

	private func convertColorString(_ origin: String) -> String {
		var sub = origin.suffix(6)
		sub = "#" + sub
		return String(sub)
	}
}

struct AbstractArticle {
	/// 文章标题
	let title: String
	/// 相关信息 “spRachel雷切爾 · 3 分钟阅读” 或者 “作者 \/ 李霁琛”
	let hint: String
	/// 文章展示图
	var image: UIImage
	let id: String
	/// 特征色，顶部文章要用到
	let charColor: UIColor
}
