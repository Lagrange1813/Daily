//
//  ViewController.swift
//  Daily
//
//  Created by 张维熙 on 2022/7/25.
//

import UIKit

class ViewController: UIViewController {
	override func viewDidLoad() {
		super.viewDidLoad()
		view.backgroundColor = .blue

		Task.init {
			await ArticleManager.shared.getTodaysDate()
			let test = await ArticleManager.shared.getTodaysArticleAbstracts()
			do {
				var article = try await ArticleManager.shared.nextArticle(by: "9751080")
				article = try await ArticleManager.shared.nextArticle(by: "9751045")
				print(article)
			} catch {
				print(error)
			}
			
		}
	}
}
