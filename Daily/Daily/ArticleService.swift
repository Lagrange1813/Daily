//
//  ArticleService.swift
//  Daily
//
//  Created by 张维熙 on 2022/7/26.
//

import Alamofire
import SwiftyJSON

private enum URLList {
	static let today = "http://news-at.zhihu.com/api/4/news/latest"
}

class ArticleService {
	func getTodaysJSON(handler: ((JSON) -> Void)?) {
		AF.request(URLList.today).response { response in
			if let result = try? response.result.get() {
				handler?(JSON(result))
			}
		}
	}
}
