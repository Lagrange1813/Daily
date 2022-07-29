//
//  ArticleListCells.swift
//  Daily
//
//  Created by 闫润邦 on 2022/7/26.
//

import SnapKit
import UIKit

fileprivate let CornerRadius: CGFloat = 15

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
		contentView.backgroundColor = .white
		
		articleId = article.id
		
		imageView.image = article.image
		imageView.contentMode = .scaleAspectFill
		imageView.clipsToBounds = true
		imageView.layer.cornerRadius = CornerRadius
		contentView.addSubview(imageView)
		
		imageView.snp.makeConstraints { make in
			make.top.equalToSuperview().offset(5)
			make.trailing.equalToSuperview().offset(-5)
			make.leading.equalToSuperview().offset(5)
			make.height.equalTo(180).priority(800)
		}
        
		// Gradient Layer

//		let gradientColors = [
//			UIColor(article.charColor, withNewAlpha: 0).cgColor,
//			UIColor(article.charColor, withNewAlpha: 0.8).cgColor,
//			UIColor(article.charColor, withNewAlpha: 1).cgColor,
//		]
//
//		let gradientView = GradientView(colors: gradientColors)
//
//		contentView.addSubview(gradientView)
//
//		gradientView.snp.makeConstraints { make in
//			make.bottom.equalToSuperview()
//			make.centerX.equalToSuperview()
//			make.width.equalTo(Constants.width - 10)
//			make.height.equalTo(150)
//		}
        
		titleView.text = article.title
		titleView.font = UIFont(name: "LXGWWenKai-Bold", size: 18)
		titleView.backgroundColor = .clear
		titleView.numberOfLines = 0
		titleView.lineBreakMode = .byWordWrapping
		titleView.textColor = .black
//		titleView.translatesAutoresizingMaskIntoConstraints = false
		contentView.addSubview(titleView)
		
		titleView.snp.makeConstraints { make in
			make.leading.equalToSuperview().offset(15)
			make.top.equalTo(imageView.snp.bottom).offset(25)
			make.trailing.equalToSuperview().offset(-30)
			make.height.equalTo(50)
		}
        
		subtitleView.text = article.hint
		subtitleView.font = UIFont(name: "LXGWWenKaiMono-Regular", size: 13)
		subtitleView.backgroundColor = titleView.backgroundColor
		subtitleView.textColor = .gray
//		subtitleView.translatesAutoresizingMaskIntoConstraints = false
		contentView.addSubview(subtitleView)
		
		subtitleView.snp.makeConstraints { make in
			make.bottom.equalToSuperview().offset(-15)
			make.leading.equalToSuperview().offset(20)
			make.trailing.equalToSuperview().offset(-30)
			make.height.equalTo(30)
		}
        
//		let constraints = [
//			titleView.centerYAnchor.constraint(
//				equalTo: contentView.centerYAnchor,
//				constant: contentView.bounds.width / 4
//			),
//			titleView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
//			titleView.widthAnchor.constraint(equalTo: contentView.widthAnchor, constant: -20),
//			titleView.heightAnchor.constraint(equalToConstant: 80),
//
//			subtitleView.topAnchor.constraint(equalTo: titleView.bottomAnchor, constant: 10),
//			subtitleView.centerXAnchor.constraint(equalTo: titleView.centerXAnchor),
//			subtitleView.widthAnchor.constraint(equalTo: titleView.widthAnchor, constant: -20),
//			subtitleView.heightAnchor.constraint(equalToConstant: 20),
//		]
//		contentView.addConstraints(constraints)
		

		contentView.layer.cornerRadius = CornerRadius
		contentView.clipsToBounds = true
		
		indicator.frame = bounds
		contentView.addSubview(indicator)
	}
    
	override func layoutSubviews() {
		super.layoutSubviews()
	}
}

class ArticleMiddleListCell: ArticleListCell {
    static let reuseIdentifier = "article-middle-list-cell"
    
    func configureContents(withImage image: UIImage?, title: String) {
        imageView.image = image
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFit
        contentView.addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
        }

        
        titleView.text = title
        contentView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.top.equalToSuperview()
            make.bottom.equalToSuperview()
            make.width.equalToSuperview()
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        imageView.layer.cornerRadius = imageView.frame.size.width / 2
        imageView.layer.borderWidth = 1
    }
}

class ArticleBottomListCell: ArticleListCell {
	static let reuseIdentifier = "article-bottom-list-cell"
    
	func configureContents(with article: ArticleAbstract) {
		contentView.backgroundColor = .white
		contentView.layer.cornerRadius = CornerRadius
		contentView.clipsToBounds = true
		
		articleId = article.id
		
		imageView.image = article.image
		imageView.contentMode = .scaleAspectFit
		imageView.translatesAutoresizingMaskIntoConstraints = false
		imageView.layer.cornerRadius = CornerRadius
		imageView.clipsToBounds = true
		contentView.addSubview(imageView)
		
		imageView.snp.makeConstraints { make in
			make.trailing.equalToSuperview().inset(5)
			make.top.equalToSuperview().offset(5)
			make.height.width.equalTo(110)
		}
        
		titleView.text = article.title
		titleView.numberOfLines = 0
		titleView.textColor = .black
		titleView.lineBreakMode = .byWordWrapping
		titleView.font = UIFont(name: "LXGWWenKaiMono-Regular", size: 18)
		titleView.translatesAutoresizingMaskIntoConstraints = false
		contentView.addSubview(titleView)
		
		titleView.snp.makeConstraints { make in
			make.top.equalToSuperview().offset(15)
			make.leading.equalToSuperview().offset(20)
			make.trailing.equalTo(imageView.snp.leading).offset(-15)
			make.height.equalTo(60)
		}
        
		subtitleView.text = article.hint
		subtitleView.textColor = .systemGray
		subtitleView.font = .preferredFont(forTextStyle: .footnote)
		subtitleView.translatesAutoresizingMaskIntoConstraints = false
		contentView.addSubview(subtitleView)
        
		subtitleView.snp.makeConstraints { make in
			make.bottom.equalToSuperview().offset(-15)
			make.leading.equalToSuperview().offset(20)
			make.trailing.equalTo(imageView.snp.leading).offset(-15)
			make.height.equalTo(30)
		}
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

protocol PageControlDelegate {
    func pageControl(_ pageControl: PageControl, currentPageDidChangeTo now: Int)
}

class PageControl: UIPageControl {
    var delegate: PageControlDelegate?
    var lastPage: Int = 0
    init(delegate: PageControlDelegate?) {
        self.delegate = delegate
        super.init(frame: .zero)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        guard currentPage != lastPage else { return }
        lastPage = currentPage
        delegate?.pageControl(self, currentPageDidChangeTo: currentPage)
    }

}
