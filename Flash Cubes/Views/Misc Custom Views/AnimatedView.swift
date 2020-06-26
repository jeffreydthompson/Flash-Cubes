//
//  AnimatedView.swift
//  Flash Cubes
//
//  Created by Jeffrey Thompson on 5/6/19.
//  Copyright © 2019 Jeffrey Thompson. All rights reserved.
//

import UIKit

class AnimatedView: UIImageView {

    enum Animation {
        case cube
        case cubeLogo
        case deck
    }
    
    let deckSpinAnimImgs: [UIImage] = {
        var imgs = [UIImage]()
        for index in 1...59 {
            if let img = UIImage(named: "imgDeckSpin\(index)"){
                imgs.append(img)
            }
        }
        return imgs
    }()
    
    let cubeSpinAnimImgs: [UIImage] = {
        var imgs = [UIImage]()
        for index in 1...59 {
            if let img = UIImage(named: "imgCubeSpin\(index)"){
                imgs.append(img)
            }
        }
        return imgs
    }()
    
    let cubeLogoSpinAnimImgs: [UIImage] = {
        var imgs = [UIImage]()
        for index in 1...60 {
            if let img = UIImage(named: "imgCubeLogoRotate\(index)"){
                imgs.append(img)
            }
        }
        return imgs
    }()
    
    var animation: Animation = .deck {
        didSet {
            switch self.animation {
            case .cube:
                self.animationImages = cubeSpinAnimImgs
                self.highlightedAnimationImages = cubeSpinAnimImgs
                self.animationDuration = TimeInterval(3)
            case .cubeLogo:
                self.animationImages = cubeLogoSpinAnimImgs
                self.highlightedAnimationImages = cubeLogoSpinAnimImgs
                self.animationDuration = TimeInterval(3)
            case .deck:
                self.animationImages = deckSpinAnimImgs
                self.highlightedAnimationImages = deckSpinAnimImgs
                self.animationDuration = TimeInterval(3)
            }
            
            self.startAnimating()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.translatesAutoresizingMaskIntoConstraints = false
        image = deckSpinAnimImgs.first
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
