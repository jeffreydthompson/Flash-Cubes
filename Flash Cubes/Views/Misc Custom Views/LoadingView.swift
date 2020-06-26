//
//  LoadingView.swift
//  Flash Cubes
//
//  Created by Jeffrey Thompson on 6/7/19.
//  Copyright © 2019 Jeffrey Thompson. All rights reserved.
//

import UIKit

class LoadingView: UIView {
    
    enum ViewType {
        case loading
        case saving
    }
    
    var constrainingAnchor: NSLayoutDimension {
        get {
            return self.frame.width < self.frame.height ? self.widthAnchor : self.heightAnchor
        }
    }
    
    var blurBackground: UIVisualEffectView = {
        let blurEffect = UIBlurEffect(style: .regular)
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.translatesAutoresizingMaskIntoConstraints = false
        blurView.layer.cornerRadius = 20
        blurView.layer.masksToBounds = true
        return blurView
    }()
    
    var animatedImg: AnimatedView = {
        let view = AnimatedView(frame: .zero)
        view.animation = .cubeLogo
        return view
    }()
    
    lazy var label: UILabel = {
        let lbl = UILabel(frame: .zero)
        lbl.font = UIFont.bodyBold
        lbl.textColor = .white
        lbl.textAlignment = .center
        lbl.translatesAutoresizingMaskIntoConstraints = false
        switch self.viewType {
            case .loading:
                lbl.text = loadingText[0]
            case .saving:
                lbl.text = savingText[0]
        }
        lbl.numberOfLines = 1
        return lbl
    }()
    
    var viewType: ViewType = .loading
    
    var timer: Timer?
    
    var textSelector = 0
    let loadingText = [
        "\(AppText.loading)   ",
        "\(AppText.loading).  ",
        "\(AppText.loading).. ",
        "\(AppText.loading)..."
    ]
    
    let savingText = [
        "\(AppText.saving)   ",
        "\(AppText.saving).  ",
        "\(AppText.saving).. ",
        "\(AppText.saving)..."
    ]

    convenience init(viewType: ViewType) {
        self.init(frame: .zero)
        
        self.viewType = viewType
        setupViews()
        //timer = //Timer(timeInterval: TimeInterval(1), target: self, selector: #selector(timerFire), userInfo: nil, repeats: true)
        timer = Timer.scheduledTimer(timeInterval: TimeInterval(0.5), target: self, selector: #selector(timerFire), userInfo: nil, repeats: true)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        translatesAutoresizingMaskIntoConstraints = false
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupViews(){
        
        addAndConstraintToExtents(view: blurBackground)
        
        addSubview(animatedImg)
        
        NSLayoutConstraint.activate([
            animatedImg.centerXAnchor.constraint(equalTo: centerXAnchor),
            animatedImg.topAnchor.constraint(equalTo: topAnchor, constant: 25),
            animatedImg.heightAnchor.constraint(equalTo: constrainingAnchor, multiplier: 0.6),
            animatedImg.widthAnchor.constraint(equalTo: constrainingAnchor, multiplier: 0.6)
            ])
        
        addSubview(label)
        
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: leadingAnchor),
            label.trailingAnchor.constraint(equalTo: trailingAnchor),
            label.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -25),
            label.heightAnchor.constraint(equalToConstant: 25)
            ])
    }
    
    @objc func timerFire(){
        
        DispatchQueue.main.async {
            
            switch self.viewType {
            case .loading:
                self.label.text = self.loadingText[self.textSelector]
            case .saving:
                self.label.text = self.savingText[self.textSelector]
            }

            self.textSelector += 1
            if self.textSelector >= self.loadingText.count {
                self.textSelector = 0
            }
        }
    }
    
}
