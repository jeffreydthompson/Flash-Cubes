//
//  DeckCollectionViewCell.swift
//  Flash Cubes
//
//  Created by Jeffrey Thompson on 4/26/19.
//  Copyright © 2019 Jeffrey Thompson. All rights reserved.
//

import UIKit

class DeckCollectionViewCell: UICollectionViewCell {
    
    static let reuseIdentifier = "deckCollectionCell"
    
    var nameLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .body
        label.textColor = .themeColor
        label.textAlignment = .center
        label.numberOfLines = 2
        return label
    }()
    
    var underLayer: UIView = {
        let layer = UIView(frame: .zero)
        layer.translatesAutoresizingMaskIntoConstraints = false
        layer.backgroundColor = UIColor(white: 1.0, alpha: 0.5)
        layer.layer.cornerRadius = 10.0
        layer.layer.masksToBounds = true
        return layer
    }()
    
    var deckAnimation: AnimatedView = {
        let view = AnimatedView(frame: .zero)
        view.animation = .deck
        return view
    }()
    
    var progressIndicator: ProgressIndicator = {
        return ProgressIndicator(frame: .zero)
    }()
    
    var retentionBar: UIProgressView = {
        let bar = UIProgressView(frame: .zero)
        bar.translatesAutoresizingMaskIntoConstraints = false
        bar.tintColor = UIColor.graphRed
        bar.layer.cornerRadius = 1.5
        bar.layer.masksToBounds = true
        return bar
    }()
    
    var proficiencyBar: UIProgressView = {
        let bar = UIProgressView(frame: .zero)
        bar.translatesAutoresizingMaskIntoConstraints = false
        bar.tintColor = UIColor.appleBlue
        bar.layer.cornerRadius = 1.5
        bar.layer.masksToBounds = true
        return bar
    }()
    
    var notificationIcon: NotificationIcon = {
       return NotificationIcon(frame: .zero)
    }()
    
    override open var isSelected: Bool
        {
        set {
            
        }
        
        get {
            return super.isSelected
        }
    }
    
    override open var isHighlighted: Bool
        {
        set {
            
        }
        
        get {
            return super.isHighlighted
        }
    }
    
    override func awakeFromNib() {
        
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        //self.contentView.backgroundColor = UIColor.blue
        setupViews()
    }
    
    override func prepareForReuse() {
        //self.contentView.subviews.forEach({$0.removeFromSuperview()})
        clearAll()
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func clearAll() {
        //self.subviews.forEach({$0.removeFromSuperview()})
        self.contentView.subviews.forEach({$0.removeFromSuperview()})
    }
    
    public func setupViews(){
        
        self.backgroundColor = .clear
        self.contentView.backgroundColor = .clear
        
        contentView.addSubview(underLayer)
        //addConstraintsWithFormat(format: "H:|[v0]|", views: underLayer)
        //addConstraintsWithFormat(format: "V:|[v0]|", views: underLayer)
        contentView.constrainToExtents(view: underLayer)
        
        contentView.addSubview(nameLabel)
        
        //addConstraintsWithFormat(format: "H:|-10-[v0]-10-|", views: nameLabel)
        //addConstraintsWithFormat(format: "V:[v0(50)]-18-|", views: nameLabel)
        
        NSLayoutConstraint.activate([
            nameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            nameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            nameLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -18),
            nameLabel.heightAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.3)
            ])
        
        contentView.addSubview(deckAnimation)
        
        NSLayoutConstraint.activate([
            deckAnimation.topAnchor.constraint(equalTo: contentView.topAnchor),
            deckAnimation.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            deckAnimation.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.6),//(equalToConstant: 130),
            deckAnimation.heightAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.6)//(equalToConstant: 130)
            ])
        
        self.addSubview(notificationIcon)
        notificationIcon.notificationState = .pastDue
        
        NSLayoutConstraint.activate([
            notificationIcon.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 6),
            notificationIcon.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 6),
            notificationIcon.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.15),
            notificationIcon.heightAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.15)
            ])
        
        /*self.addSubview(progressIndicator)
        
        NSLayoutConstraint.activate([
            progressIndicator.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            progressIndicator.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            progressIndicator.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -3),
            progressIndicator.heightAnchor.constraint(equalToConstant: 3)
            ])*/
        
        contentView.addSubview(proficiencyBar)
        
        NSLayoutConstraint.activate([
            proficiencyBar.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            proficiencyBar.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            proficiencyBar.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -6),
            proficiencyBar.heightAnchor.constraint(equalToConstant: 3)
            ])
        
        contentView.addSubview(retentionBar)
        
        NSLayoutConstraint.activate([
            retentionBar.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            retentionBar.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            retentionBar.bottomAnchor.constraint(equalTo: proficiencyBar.topAnchor, constant: -3),
            retentionBar.heightAnchor.constraint(equalToConstant: 3)
            ])
    }
}
