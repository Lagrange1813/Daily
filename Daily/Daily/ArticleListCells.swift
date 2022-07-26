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
    
    func configureContents() {
        imageView.image = UIImage(systemName: "square.and.arrow.down")
        imageView.frame = contentView.bounds
        imageView.contentMode = .scaleAspectFit
        
        contentView.addSubview(imageView)
        
        titleView.text = "主标题"
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
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
}

class ArticleBottomListCell: UICollectionViewCell {
    static let reuseIdentifier = "article-bottom-list-cell"
    let textView = UITextView()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.addSubview(textView)
        textView.frame = contentView.bounds
    }
}
