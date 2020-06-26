//
//  ProgressIndicator.swift
//  Flash Cubes
//
//  Created by Jeffrey Thompson on 5/6/19.
//  Copyright © 2019 Jeffrey Thompson. All rights reserved.
//

import UIKit

class ProgressIndicator: UIProgressView {

    override var progress: Float {
        didSet {
            let hue = CGFloat( (self.progress * self.progress) * 0.3)
            let progressColor =  UIColor(hue: hue, saturation: 0.75, brightness: 1.0, alpha: 1.0)
            self.progressTintColor = progressColor
        }
    }
   
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.translatesAutoresizingMaskIntoConstraints = false
        self.layer.cornerRadius = 1.5
        self.layer.masksToBounds = true
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
