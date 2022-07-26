//
//  ArticleService.swift
//  Daily
//
//  Created by 张维熙 on 2022/7/26.
//

import Alamofire
import SwiftyJSON

let url = "http://news-at.zhihu.com/api/4/news/latest"

class ArticleService {
	func test() {
		AF.request(url).response { response in
			debugPrint(response)
		}
	}
}

