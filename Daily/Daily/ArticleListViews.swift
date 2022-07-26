//
//  ArticleListCells.swift
//  Daily
//
//  Created by 闫润邦 on 2022/7/26.
//

import UIKit

class ArticleTopListCell: UICollectionViewCell {
    static let reuseIdentifier = "article-top-list-cell"
    
    let imageView = UIImageView()
    let titleView = UILabel()
    let subtitleView = UILabel()
    
    func configureContents(_ id: Int) {
        imageView.image = UIImage(systemName: "square.and.arrow.down")
        imageView.frame = contentView.bounds
        imageView.contentMode = .scaleAspectFit
        
        contentView.addSubview(imageView)
        
        titleView.text = "主标题\(id)"
        titleView.font = .preferredFont(forTextStyle: .largeTitle)
        titleView.backgroundColor = .clear
        titleView.textColor = .orange
        titleView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(titleView)
        
        subtitleView.text = "副标题"
        subtitleView.font = .preferredFont(forTextStyle: .subheadline)
        subtitleView.backgroundColor = titleView.backgroundColor
        subtitleView.textColor = titleView.textColor
        subtitleView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(subtitleView)
        
        let constraints = [
            titleView.centerYAnchor.constraint(
                equalTo: contentView.centerYAnchor,
                constant: contentView.bounds.width / 5
            ),
            titleView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            titleView.widthAnchor.constraint(equalTo: contentView.widthAnchor, constant: -20),
            titleView.heightAnchor.constraint(equalToConstant: contentView.bounds.width / 10),
            
            subtitleView.topAnchor.constraint(equalTo: titleView.bottomAnchor, constant: 10),
            subtitleView.centerXAnchor.constraint(equalTo: titleView.centerXAnchor),
            subtitleView.widthAnchor.constraint(equalTo: titleView.widthAnchor, constant: -20),
            subtitleView.heightAnchor.constraint(equalToConstant: contentView.bounds.width / 20),
        ]
        contentView.addConstraints(constraints)
        
        layer.cornerRadius = 10
        layer.borderWidth = 1

    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
}

class ArticleBottomListCell: UICollectionViewCell {
    static let reuseIdentifier = "article-bottom-list-cell"
    let titleView = UILabel()
    let subtitleView = UILabel()
    let imageView = UIImageView()
    
    func configureContents() {
        titleView.text = "文章标题1231231231231231231312312312399999999"
        titleView.numberOfLines = 0
        titleView.textColor = .black
        titleView.lineBreakMode = .byCharWrapping
        titleView.font = .preferredFont(forTextStyle: .title3)
        titleView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(titleView)
        
        subtitleView.text = "footnote"
        subtitleView.textColor = .systemGray
        subtitleView.font = .preferredFont(forTextStyle: .footnote)
        subtitleView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(subtitleView)
        
        imageView.image = UIImage(systemName: "square.and.arrow.down")
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
    
    func configureContents() {
        dateLabel.text = "日期"
        dateLabel.textColor = .darkGray
        dateLabel.font = .preferredFont(forTextStyle: .title2)
        addSubview(dateLabel)
        dateLabel.frame = bounds
    }
}