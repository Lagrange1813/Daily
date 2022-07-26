//
//  ArticleManager.swift
//  Daily
//
//  Created by 张维熙 on 2022/7/26.
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

	func getTodaysAbstractArticles() async throws -> [AbstractArticle] {
		return try await withCheckedThrowingContinuation { continuation in
			service.getTodaysJSON { json in
				var results: [AbstractArticle] = []
				if let articleArray = json["stories"].array {
					articleArray.forEach {
						let article = AbstractArticle(
							title: $0["title"].stringValue,
							hint: $0["hint"].stringValue,
							id: $0["id"].stringValue,
							charColor: UIColor(hexString: self.convertColorString($0["image_hue"].stringValue))
						)
						results.append(article)
					}
					continuation.resume(returning: results)
				}
			}
		}
	}

	func getTopArticles() async throws -> [AbstractArticle] {
		return try await withCheckedThrowingContinuation { continuation in
			service.getTodaysJSON { json in
				var results: [AbstractArticle] = []
				if let articleArray = json["top_stories"].array {
					articleArray.forEach {
						let article = AbstractArticle(
							title: $0["title"].stringValue,
							hint: $0["hint"].stringValue,
							id: $0["id"].stringValue,
							charColor: UIColor(hexString: self.convertColorString($0["image_hue"].stringValue))
						)
						results.append(article)
					}
					continuation.resume(returning: results)
				}
			}
		}
	}

	private func convertColorString(_ origin: String) -> String {
		var sub = origin.suffix(6)
		sub = "#" + sub
		return String(sub)
	}
}

struct AbstractArticle: Hashable {
	/// 文章标题
	let title: String
	/// 相关信息 “spRachel雷切爾 · 3 分钟阅读” 或者 “作者 \/ 李霁琛”
	let hint: String
	/// 文章展示图
//	let image: UIImage?
	let id: String
	/// 特征色，顶部文章要用到
	let charColor: UIColor
}
