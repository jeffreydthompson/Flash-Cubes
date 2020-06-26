//
//  CubeCell.swift
//  Flash Cubes
//
//  Created by Jeffrey Thompson on 4/26/19.
//  Copyright © 2019 Jeffrey Thompson. All rights reserved.
//

import UIKit

class CubeCollectionViewCell: UICollectionViewCell {
    
    var nameLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.font = .title
        label.textColor = .themeColor
        label.textAlignment = .center
        label.numberOfLines = 3
        return label
    }()
    
    var underLayer: UIView = {
        let layer = UIView(frame: .zero)
        layer.backgroundColor = UIColor(white: 1.0, alpha: 0.5)
        layer.layer.cornerRadius = 10.0
        layer.layer.masksToBounds = true
        return layer
    }()
    
    var cubeSpinImage: UIImageView?
    var cubeProgress: UIProgressView?
    var notificationsIcon: UIImageView?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func clearAll(){
        self.subviews.forEach({$0.removeFromSuperview()})
    }
    
    public func setupViews(){
        self.backgroundColor = UIColor.blue
        
//        addSubview(nameLabel)
//        addConstraintsWithFormat(format: "H:|-10-[v0]-10-|", views: nameLabel)
//        addConstraintsWithFormat(format: "V:[v0(30)]-10-|", views: nameLabel)
        
        
    }
}


