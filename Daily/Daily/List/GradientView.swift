//
//  GradientView.swift
//  Daily
//
//  Created by 张维熙 on 2022/7/29.
//

import UIKit

class GradientView: UIView {
	var gradientLayer = CAGradientLayer()
	
	init(colors: [CGColor]) {
		super.init(frame: .zero)
		gradientLayer.colors = colors
		layer.removeAllSubLayers()
		layer.addSublayer(gradientLayer)
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override var bounds: CGRect {
		didSet {
			gradientLayer.bounds = bounds
		}
	}
	
//	override var center: CGPoint {
//		didSet {
//			gradientLayer.position
//		}
//	}
}
