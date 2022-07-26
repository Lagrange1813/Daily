//
// ArticleService.swift
// Daily
//
// Created by 张维熙 on 2022/7/26.
//

import Alamofire
import Foundation
import SwiftyJSON

private enum URLList {
	static let today = "http://news-at.zhihu.com/api/4/news/latest"
}

class ArticleService {
	func getTodaysJSON() async -> JSON {
		async let result = AF.request(URLList.today).serializingData().result
		switch await result {
		case .success(let data):
			return JSON(data)
		case .failure(let error):
			print(error)
		}
		return JSON()
	}
	
	func getImage(url: String) async -> Data {
		async let test = AF.request(url).serializingData().result
		switch await test {
		case .success(let data):
			return data
		case .failure(let failure):
			print(failure)
		}
		return Data()
	}
}
