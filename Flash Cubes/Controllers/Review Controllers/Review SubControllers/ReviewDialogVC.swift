//
//  ReviewDialogVC.swift
//  Flash Cubes
//
//  Created by Jeffrey Thompson on 5/28/19.
//  Copyright © 2019 Jeffrey Thompson. All rights reserved.
//

import UIKit

class ReviewDialogVC: UIViewController {
    
    enum DialogType {
        case newFinished
        case overdueFinished
        case quitPressed
    }
    
    var dialogType: DialogType!
    var delegate: ReviewDialogDelegate!
    
    var messageLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 3
        label.textAlignment = .center
        label.textColor = .white
        return label
    }()
    
    lazy var btnQuit: UIButton = {
        let btn = UIButton(type: .custom)
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.backgroundColor = .underlay
        btn.layer.cornerRadius = 10
        btn.layer.masksToBounds = true
        btn.setTitle(AppText.quit, for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.addTarget(self, action: #selector(quitOnPress), for: .touchUpInside)
        return btn
    }()
    
    lazy var btnContinue: UIButton = {
        let btn = UIButton(type: .custom)
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.backgroundColor = .underlay
        btn.layer.cornerRadius = 10
        btn.layer.masksToBounds = true
        btn.setTitle(AppText.continueTxt, for: .normal)
        btn.addTarget(self, action: #selector(continueOnPress), for: .touchUpInside)
        return btn
    }()
    
    lazy var btnCancel: UIButton = {
        let btn = UIButton(type: .custom)
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.backgroundColor = .underlay
        btn.layer.cornerRadius = 10
        btn.layer.masksToBounds = true
        btn.setTitle(AppText.cancel, for: .normal)
        btn.addTarget(self, action: #selector(cancelOnPress), for: .touchUpInside)
        return btn
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        setupViews()
    }
    
    func setupViews(){
        
        if dialogType == nil {return}
        
        view.backgroundColor = UIColor.init(white: 0.7, alpha: 0.3)
        
        let container = UIView(frame: .zero)
        container.translatesAutoresizingMaskIntoConstraints = false
        container.layer.cornerRadius = 20
        container.layer.masksToBounds = true
        container.backgroundColor = .themeColor
        
        view.addSubview(container)
        
        NSLayoutConstraint.activate([
            container.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            container.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            container.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.75),
            container.heightAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.75)
            ])
        
        container.addSubview(messageLabel)
        
        NSLayoutConstraint.activate([
            messageLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 20),
            messageLabel.topAnchor.constraint(equalTo: container.topAnchor, constant: 20),
            messageLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -20),
            messageLabel.bottomAnchor.constraint(equalTo: container.centerYAnchor)
            ])
        
        
        switch dialogType! {
        case .newFinished:
            messageLabel.text = AppText.newStackFinished
        case .overdueFinished:
            messageLabel.text = AppText.overDueFinished
        case .quitPressed:
            messageLabel.text = AppText.quitReview
        }
        
        container.addSubview(btnQuit)
        
        NSLayoutConstraint.activate([
            btnQuit.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 20),
            btnQuit.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -20),
            btnQuit.trailingAnchor.constraint(equalTo: container.centerXAnchor, constant: -10),
            btnQuit.topAnchor.constraint(equalTo: container.centerYAnchor, constant: 20)
            ])
        
        switch dialogType! {
        case .newFinished, .overdueFinished:
            
            container.addSubview(btnContinue)
            
            NSLayoutConstraint.activate([
                btnContinue.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -20),
                btnContinue.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -20),
                btnContinue.leadingAnchor.constraint(equalTo: container.centerXAnchor, constant: 10),
                btnContinue.topAnchor.constraint(equalTo: container.centerYAnchor, constant: 20)
                ])
            
        case .quitPressed:
            
            container.addSubview(btnCancel)
            
            NSLayoutConstraint.activate([
                btnCancel.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -20),
                btnCancel.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -20),
                btnCancel.leadingAnchor.constraint(equalTo: container.centerXAnchor, constant: 10),
                btnCancel.topAnchor.constraint(equalTo: container.centerYAnchor, constant: 20)
                ])
        }
        
    }
    
    @objc func cancelOnPress(){
        self.dismiss(animated: true) {
            self.delegate?.reviewDialog(userOpted: false)
        }
    }
    
    @objc func quitOnPress(){
        
        self.dismiss(animated: true) {
            self.delegate?.reviewDialog(didQuit: true)
        }
    }
    
    @objc func continueOnPress(){
        
        self.dismiss(animated: true) {
            self.delegate?.reviewDialog(didQuit: false)
        }
        
    }
}
