//
//  Constants.swift
//  Daily
//
//  Created by 张维熙 on 2022/7/27.
//

import UIKit

enum Constants {
	static let bottomInset = UIApplication.shared.windows.first?.safeAreaInsets.bottom ?? 0
	static let width = UIScreen.main.bounds.width
	static var StatusBarHeight =
		UIApplication.shared.windows.first?.windowScene?.statusBarManager?.statusBarFrame.size.height ?? 0
	
}
