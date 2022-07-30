//
//  Extension.swift
//  Daily
//
//  Created by 张维熙 on 2022/7/26.
//

import UIKit
import SwiftUI

extension UIColor {
	convenience init(hexString: String) {
		let hex = hexString.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
		var int = UInt64()
		Scanner(string: hex).scanHexInt64(&int)
		let a, r, g, b: UInt64
		switch hex.count {
		case 3: // RGB (12-bit)
			(a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
		case 6: // RGB (24-bit)
			(a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
		case 8: // ARGB (32-bit)
			(a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
		default:
			(a, r, g, b) = (255, 0, 0, 0)
		}
		self.init(red: CGFloat(r) / 255, green: CGFloat(g) / 255, blue: CGFloat(b) / 255, alpha: CGFloat(a) / 255)
	}
    
    convenience init(_ color: UIColor, withNewAlpha newAlpha: Float) {
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        color.getRed(&r, green: &g, blue: &b, alpha: &a)
        self.init(red: r, green: g, blue: b, alpha: CGFloat(newAlpha))
    }
}

extension Date {
    var dayBofre: Date {
        Calendar.current.date(byAdding: .day, value: -1, to: self) ?? Date.distantPast
    }
    
    var dayAfter: Date {
        Calendar.current.date(byAdding: .day, value: 1, to: self) ?? Date.distantPast
    }
}

extension UIView {
    func removeAllSubviews() {
        self.subviews.forEach() { subview in
            subview.removeFromSuperview()
        }
    }
}

extension CALayer {
    func removeAllSubLayers() {
        guard let sublayers = self.sublayers else { return }
        sublayers.forEach() { sublayer in
            sublayer.removeFromSuperlayer()
        }
    }
}

extension UICollectionViewDiffableDataSource {
    func lastIndexPath(of collectionView: UICollectionView) -> IndexPath {
        let lastSection = numberOfSections(in: collectionView) - 1
        let lastItem = self.collectionView(collectionView, numberOfItemsInSection: lastSection) - 1
        return IndexPath(item: lastItem, section: lastSection)
    }
    
    func isIndexPath(_ indexPath: IndexPath, lastOf collectionView: UICollectionView) -> Bool {
        let lastIndexPath = lastIndexPath(of: collectionView)
        return indexPath.section == lastIndexPath.section && indexPath.item == lastIndexPath.item
    }
}
