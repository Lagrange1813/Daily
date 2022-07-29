//
//  ArticleListCells.swift
//  Daily
//
//  Created by 闫润邦 on 2022/7/26.
//

import UIKit
import SnapKit

class ArticleListCell: UICollectionViewCell {
    let imageView = UIImageView()
    let titleView = UILabel()
    let subtitleView = UILabel()
    let gradientLayer = CAGradientLayer()
    var gradientLayerPosition: CGPoint?
    var articleId = ""
}

class ArticleTopListCell: ArticleListCell {
	static let reuseIdentifier = "article-top-list-cell"
    
    func configureContents(withArticle article: ArticleAbstract, indicator: UIActivityIndicatorView) {

        
        articleId = article.id
		imageView.image = article.image
		imageView.contentMode = .scaleAspectFill
		imageView.clipsToBounds = true
		contentView.addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.bottom.equalToSuperview()
            make.trailing.equalToSuperview()
            make.leading.equalToSuperview()
            make.height.equalToSuperview()
        }
        
        // Gradient Layer

        let gradientColors = [
            UIColor(article.charColor, withNewAlpha: 0).cgColor,
            UIColor(article.charColor, withNewAlpha: 0.8).cgColor,
            UIColor(article.charColor, withNewAlpha: 1).cgColor,
        ]
        
        let gradientView = GradientView(colors: gradientColors)
        
        contentView.addSubview(gradientView)
		
		gradientView.snp.makeConstraints { make in
			make.bottom.equalToSuperview()
			make.centerX.equalToSuperview()
			make.width.equalTo(Constants.width - 10)
			make.height.equalTo(150)
		}
        
		titleView.text = article.title
		titleView.font = UIFont(name: "LXGWWenKai-Bold", size: 20)
		titleView.backgroundColor = .clear
		titleView.numberOfLines = 0
		titleView.lineBreakMode = .byCharWrapping
		titleView.textColor = .white
		titleView.translatesAutoresizingMaskIntoConstraints = false
		contentView.addSubview(titleView)
        
		subtitleView.text = article.hint
		subtitleView.font = UIFont(name: "LXGWWenKaiMono-Regular", size: 15)
		subtitleView.backgroundColor = titleView.backgroundColor
		subtitleView.textColor = titleView.textColor
		subtitleView.translatesAutoresizingMaskIntoConstraints = false
		contentView.addSubview(subtitleView)
        
		let constraints = [
			titleView.centerYAnchor.constraint(
				equalTo: contentView.centerYAnchor,
				constant: contentView.bounds.width / 4
			),
			titleView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
			titleView.widthAnchor.constraint(equalTo: contentView.widthAnchor, constant: -20),
			titleView.heightAnchor.constraint(equalToConstant: 80),
			
			subtitleView.topAnchor.constraint(equalTo: titleView.bottomAnchor, constant: 10),
			subtitleView.centerXAnchor.constraint(equalTo: titleView.centerXAnchor),
			subtitleView.widthAnchor.constraint(equalTo: titleView.widthAnchor, constant: -20),
			subtitleView.heightAnchor.constraint(equalToConstant: 20),
		]
		contentView.addConstraints(constraints)
        indicator.frame = bounds
        contentView.addSubview(indicator)

		contentView.layer.cornerRadius = 20
		contentView.clipsToBounds = true
		
	}
    
	override func layoutSubviews() {
		super.layoutSubviews()
	}
}

class ArticleBottomListCell: ArticleListCell {
	static let reuseIdentifier = "article-bottom-list-cell"
    
	func configureContents(with article: ArticleAbstract) {
        articleId = article.id
        
		titleView.text = article.title
		titleView.numberOfLines = 0
		titleView.textColor = .black
		titleView.lineBreakMode = .byCharWrapping
		titleView.font = UIFont(name: "LXGWWenKaiMono-Regular", size: 20)
		titleView.translatesAutoresizingMaskIntoConstraints = false
		contentView.addSubview(titleView)
        
		subtitleView.text = article.hint
		subtitleView.textColor = .systemGray
		subtitleView.font = .preferredFont(forTextStyle: .footnote)
		subtitleView.translatesAutoresizingMaskIntoConstraints = false
		contentView.addSubview(subtitleView)
        
		imageView.image = article.image
		imageView.contentMode = .scaleAspectFit
		imageView.translatesAutoresizingMaskIntoConstraints = false
		contentView.addSubview(imageView)
        
		let constraints = [
			titleView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
			//            titleView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5),
			titleView.heightAnchor.constraint(equalToConstant: 60),
			titleView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 5),
			titleView.widthAnchor.constraint(equalToConstant: contentView.bounds.width * 3.8 / 5.0),
			
			subtitleView.topAnchor.constraint(equalTo: titleView.bottomAnchor),
			subtitleView.heightAnchor.constraint(equalToConstant: 22),
			subtitleView.leadingAnchor.constraint(equalTo: titleView.leadingAnchor),
			subtitleView.trailingAnchor.constraint(equalTo: titleView.trailingAnchor),
			
			imageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
			imageView.heightAnchor.constraint(equalToConstant: contentView.bounds.width / 5.0),
			imageView.widthAnchor.constraint(equalTo: imageView.heightAnchor),
			imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -5),
		]
		contentView.addConstraints(constraints)
	}
    
	override func layoutSubviews() {
		super.layoutSubviews()
	}
}

class ArticleListHeaderView: UICollectionReusableView {
	static let reuseIdentifier = "article-list-header-view"
	let dateLabel = UILabel()
    
    func configureContents(with mmdd: String) {
		dateLabel.text = mmdd
		dateLabel.textColor = .darkGray
		dateLabel.font = .preferredFont(forTextStyle: .subheadline)
		addSubview(dateLabel)
		dateLabel.frame = bounds
	}
}

class AriticleListFooterView: UICollectionReusableView {
    static let reuseIdentifier = "article-list-footer-view"
    
    func configureContents(with activityIndicator: UIActivityIndicatorView) {
        removeAllSubviews()
        addSubview(activityIndicator)
        activityIndicator.frame = bounds
    }
}
