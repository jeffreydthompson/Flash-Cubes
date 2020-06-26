//
//  ReviewSettingsVC.swift
//  Flash Cubes
//
//  Created by Jeffrey Thompson on 5/28/19.
//  Copyright © 2019 Jeffrey Thompson. All rights reserved.
//

import UIKit

class ReviewSettingsVC: UIViewController {
    
    var currentAudioSpeed: AudioPlaybackSpeed!
    
    var audioSpeedLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = AppText.audioPlaybackSpeed
        label.textColor = .white
        label.textAlignment = .center
        return label
    }()
    
    lazy var btnSlowSpeed: UIButton = {
        let button = UIButton(frame: .zero)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("0.5x", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.addTarget(self, action: #selector(setSlow), for: .touchUpInside)
        return button
    }()
    
    lazy var btnNormalSpeed: UIButton = {
        let button = UIButton(frame: .zero)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("1.0x", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.addTarget(self, action: #selector(setNormal), for: .touchUpInside)
        return button
    }()
    
    lazy var btnFastSpeed: UIButton = {
        let button = UIButton(frame: .zero)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("1.5x", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.addTarget(self, action: #selector(setFast), for: .touchUpInside)
        return button
    }()
    
    var delegate: ReviewSettingsDelegate!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupViews()
    }
    
    func setupViews(){
        self.view.backgroundColor = .clear
        
        let audioSpeedContainer = UIView(frame: .zero)
        audioSpeedContainer.translatesAutoresizingMaskIntoConstraints = false
        audioSpeedContainer.backgroundColor = .themeColor
        
        audioSpeedContainer.layer.cornerRadius = 20
        audioSpeedContainer.layer.masksToBounds = true
        
        view.addSubview(audioSpeedContainer)
        
        NSLayoutConstraint.activate([
            audioSpeedContainer.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            audioSpeedContainer.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 50),
            audioSpeedContainer.widthAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor, multiplier: 0.6),
            audioSpeedContainer.heightAnchor.constraint(equalToConstant: 100)
            ])
        
        audioSpeedContainer.addSubview(audioSpeedLabel)
        
        NSLayoutConstraint.activate([
            audioSpeedLabel.leadingAnchor.constraint(equalTo: audioSpeedContainer.leadingAnchor),
            audioSpeedLabel.trailingAnchor.constraint(equalTo: audioSpeedContainer.trailingAnchor),
            audioSpeedLabel.topAnchor.constraint(equalTo: audioSpeedContainer.topAnchor),
            audioSpeedLabel.heightAnchor.constraint(equalTo: audioSpeedContainer.heightAnchor, multiplier: 0.5)
            ])
        
        audioSpeedContainer.addSubview(btnSlowSpeed)
        
        NSLayoutConstraint.activate([
            btnSlowSpeed.leadingAnchor.constraint(equalTo: audioSpeedContainer.leadingAnchor),
            btnSlowSpeed.bottomAnchor.constraint(equalTo: audioSpeedContainer.bottomAnchor),
            btnSlowSpeed.widthAnchor.constraint(equalTo: audioSpeedContainer.widthAnchor, multiplier: 0.3),
            btnSlowSpeed.heightAnchor.constraint(equalTo: audioSpeedContainer.heightAnchor, multiplier: 0.5)
            ])
        
        audioSpeedContainer.addSubview(btnNormalSpeed)
        
        NSLayoutConstraint.activate([
            btnNormalSpeed.centerXAnchor.constraint(equalTo: audioSpeedContainer.centerXAnchor),
            btnNormalSpeed.bottomAnchor.constraint(equalTo: audioSpeedContainer.bottomAnchor),
            btnNormalSpeed.widthAnchor.constraint(equalTo: audioSpeedContainer.widthAnchor, multiplier: 0.3),
            btnNormalSpeed.heightAnchor.constraint(equalTo: audioSpeedContainer.heightAnchor, multiplier: 0.5)
            ])
        
        audioSpeedContainer.addSubview(btnFastSpeed)
        
        NSLayoutConstraint.activate([
            btnFastSpeed.trailingAnchor.constraint(equalTo: audioSpeedContainer.trailingAnchor),
            btnFastSpeed.bottomAnchor.constraint(equalTo: audioSpeedContainer.bottomAnchor),
            btnFastSpeed.widthAnchor.constraint(equalTo: audioSpeedContainer.widthAnchor, multiplier: 0.3),
            btnFastSpeed.heightAnchor.constraint(equalTo: audioSpeedContainer.heightAnchor, multiplier: 0.5)
            ])
        
        switch currentAudioSpeed! {
        case .slow:
            btnSlowSpeed.setTitleColor(.actionOrange, for: .normal)
        case .normal:
            btnNormalSpeed.setTitleColor(.actionOrange, for: .normal)
        case .fast:
            btnFastSpeed.setTitleColor(.actionOrange, for: .normal)
        }
        
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onViewTap)))
    }
    
    @objc func onViewTap(){
        self.dismiss(animated: false, completion: nil)
    }
    
    @objc func setSlow(){
        btnSlowSpeed.setTitleColor(.actionOrange, for: .normal)
        btnNormalSpeed.setTitleColor(.white, for: .normal)
        btnFastSpeed.setTitleColor(.white, for: .normal)
        delegate.reviewSettings(didChange: .slow)
    }
    @objc func setNormal(){
        btnSlowSpeed.setTitleColor(.white, for: .normal)
        btnNormalSpeed.setTitleColor(.actionOrange, for: .normal)
        btnFastSpeed.setTitleColor(.white, for: .normal)
        delegate.reviewSettings(didChange: .normal)
    }
    @objc func setFast(){
        btnSlowSpeed.setTitleColor(.white, for: .normal)
        btnNormalSpeed.setTitleColor(.white, for: .normal)
        btnFastSpeed.setTitleColor(.actionOrange, for: .normal)
        delegate.reviewSettings(didChange: .fast)
    }
}
