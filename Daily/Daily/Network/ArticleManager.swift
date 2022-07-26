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

enum ArticleListType {
	case top
	case date
}

class ArticleManager {
	static var shared: ArticleManager {
		singleton
	}

	private var service = ArticleService()

	private var today: String?
	private var topList: [String] = []
	private var idList: [String] = []
	private var currentDate: String?
	
	private var colorDic: [String: UIColor] = [:]

	private var mode: ArticleListType = .date

	fileprivate init() {}

	private func getImage(url: String) async -> UIImage {
		async let data = service.getImage(url: url)
		return await UIImage(data: data) ?? UIImage(named: "Alternative") ?? UIImage()
	}

	private func convertColorString(_ origin: String) -> String {
		var sub = origin.suffix(6)
		sub = "#" + sub
		return String(sub)
	}
}

extension ArticleManager {
	public func getTodaysDate() async -> String {
		async let json = service.getTodaysJSON()
		let date = await json["date"].stringValue
		today = date
		return date
	}

	public func getTopArticleAbstracts() async -> [ArticleAbstract] {
		async let json = service.getTodaysJSON()
		var articles: [ArticleAbstract] = []

		if let articleArray = await json["top_stories"].array {
			for articleJson in articleArray {
				let article = ArticleAbstract(
					title: articleJson["title"].stringValue,
					hint: articleJson["hint"].stringValue,
					image: await getImage(url: articleJson["image"].stringValue),
					id: articleJson["id"].stringValue,
					charColor: UIColor(hexString: convertColorString(articleJson["image_hue"].stringValue))
				)
				articles.append(article)
			}
		}
		return articles
	}

	public func getTodaysArticleAbstracts() async -> [ArticleAbstract] {
		async let json = service.getTodaysJSON()
		var articles: [ArticleAbstract] = []

		if let articleArray = await json["stories"].array {
			for articleJson in articleArray {
				
				let id = articleJson["id"].stringValue
				let color = UIColor(hexString: convertColorString(articleJson["image_hue"].stringValue))
				
				let article = ArticleAbstract(
					title: articleJson["title"].stringValue,
					hint: articleJson["hint"].stringValue,
					image: await getImage(url: articleJson["images"].array?.first?.stringValue ?? ""),
					id: id,
					charColor: color
				)
				articles.append(article)
				idList.append(articleJson["id"].stringValue)
				colorDic[id] = color
			}
		}
		return articles
	}
}

extension ArticleManager {
	public func getArticleAbstracts(before date: String) async -> [ArticleAbstract] {
		async let json = service.getPastJSON(before: date)
		var articles: [ArticleAbstract] = []

		if let articleArray = await json["stories"].array {
			for articleJson in articleArray {
				let article = ArticleAbstract(
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
}

extension ArticleManager {
	public func setManagerMode(_ mode: ArticleListType) {
		self.mode = mode
	}
}

enum LastArticleError: Error {
	case outOfIndex
	case first
}

enum NextArticleError: Error {
	case notInside
	case outOfNumber
}

enum fetchBeforeDataError: Error {
	case cantFetch
}

extension ArticleManager {
	public func getArticle(by id: String) async throws -> (Article, Bool) {
		print(idList)
		async let json = service.getArticle(by: id)
		let signal = idList.firstIndex(of: id) == 0

		return try await (Article(
			title: json["title"].stringValue,
			body: json["body"].stringValue,
			image: await getImage(url: json["image"].stringValue),
			link: json["url"].stringValue,
			css: json["css"].arrayValue.map { $0.stringValue },
			charColor: colorDic[id] ?? .black
		), signal)
	}

	public func lastArticle(of id: String) async throws -> (String, Article, Bool) {
		var signal = false
		guard let index = idList.firstIndex(of: id),
		      index > 0 else { throw LastArticleError.outOfIndex }
		if index == 1 { signal = true }
		return (idList[index - 1], try await getArticle(by: idList[index - 1]).0, signal)
	}

	public func nextArticle(of id: String) async throws -> (String, Article) {
		guard let index = idList.firstIndex(of: id) else { throw NextArticleError.notInside }
		if index == idList.count - 3 {
			try await fetchNextDatesAbstract()
		}
		guard index < idList.count else { throw NextArticleError.outOfNumber }
		return (idList[index + 1], try await getArticle(by: idList[index + 1]).0)
	}

	public func fetchNextDatesAbstract() async throws {
		guard let today = today else { fatalError("Should Have!") }
		if currentDate == nil {
			let json = await service.getPastJSON(before: today)
			guard let articleArray = json["stories"].array else { throw fetchBeforeDataError.cantFetch }
			for articleJson in articleArray {
				idList.append(articleJson["id"].stringValue)
			}
			currentDate = json["date"].stringValue
		} else if let currentDate = currentDate {
			let json = await service.getPastJSON(before: currentDate)
			guard let articleArray = json["stories"].array else { throw fetchBeforeDataError.cantFetch }
			for articleJson in articleArray {
				idList.append(articleJson["id"].stringValue)
			}
		} else {
			fatalError("Should't Be Here!")
		}
	}
}

struct ArticleAbstract: Hashable {
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

struct Article {
	let title: String
	let body: String
	let image: UIImage
	let link: String
	let css: [String]
	let charColor: UIColor
}
