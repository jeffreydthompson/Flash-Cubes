//
//  CubeDetailTableCell.swift
//  Flash Cubes
//
//  Created by Jeffrey Thompson on 5/14/19.
//  Copyright © 2019 Jeffrey Thompson. All rights reserved.
//

import UIKit

class CubeDetailTableCell: UITableViewCell {
    
    static let reuseIdentifier = "CubeDetailTableCell"
    
    private let underLayer: UIView = {
        let view = UIView(frame: .zero)
        view.backgroundColor = .underlay
        view.layer.cornerRadius = 20
        view.layer.masksToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let label: UILabel = {
        let lbl = UILabel(frame: .zero)
        lbl.font = .body
        lbl.textColor = .white
        lbl.translatesAutoresizingMaskIntoConstraints = false
        //lbl.text = "Error. Title not set"
        lbl.numberOfLines = 2
        return lbl
    }()
    
    var prompt: CubePrompt!

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.backgroundColor = .clear
        self.contentView.backgroundColor = .clear
        self.selectionStyle = .none
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        self.contentView.subviews.forEach({$0.removeFromSuperview()})
    }
    
    static func getHeight(forPrompt ofType: CubePrompt) -> CGFloat {
        switch ofType {
        case .text( _):
            return 64
        default:
            return 132
        }
    }
    
    func setupViews(){
        
        self.contentView.addSubview(underLayer)
        
        NSLayoutConstraint.activate([
            underLayer.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 6),
            underLayer.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -6),
            underLayer.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 6),
            underLayer.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: -6)
            ])
        
        self.contentView.addSubview(label)
        
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 16),
            label.widthAnchor.constraint(equalTo: self.contentView.widthAnchor, multiplier: 0.45),
            label.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 16),
            label.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: -16)
            ])
        
        switch prompt! {
        case .text(let text):
            
            let textLabel = UILabel(frame: .zero)
            textLabel.font = .body
            textLabel.textColor = .white
            textLabel.textAlignment = .right
            textLabel.numberOfLines = 2
            textLabel.translatesAutoresizingMaskIntoConstraints = false
            textLabel.text = (text ?? "...")
            
            self.contentView.addSubview(textLabel)
            
            NSLayoutConstraint.activate([
                textLabel.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -16),
                textLabel.widthAnchor.constraint(equalTo: self.contentView.widthAnchor, multiplier: 0.45),
                textLabel.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 10),
                textLabel.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: -10)
                ])
            
        case .audio(let data):
            
            let audioBtn = AudioButton(frame: .zero)
            audioBtn.audioData = data
            audioBtn.translatesAutoresizingMaskIntoConstraints = false
            
            self.contentView.addSubview(audioBtn)
            
            NSLayoutConstraint.activate([
                audioBtn.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -16),
                audioBtn.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor),
                audioBtn.widthAnchor.constraint(equalToConstant: 100),
                audioBtn.heightAnchor.constraint(equalToConstant: 100)
                ])
            
        case .image(let img):
            
            let imageView = UIImageView(frame: .zero)
            if let img = img {
                imageView.image = img
            } else {
                imageView.image = UIImage(named: "imgImageNil")
            }
            imageView.translatesAutoresizingMaskIntoConstraints = false
            imageView.layer.cornerRadius = 10
            imageView.layer.masksToBounds = true
            
            self.contentView.addSubview(imageView)
            
            NSLayoutConstraint.activate([
                imageView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -16),
                imageView.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor),
                imageView.widthAnchor.constraint(equalToConstant: 100),
                imageView.heightAnchor.constraint(equalToConstant: 100)
                ])
        }
    }
}
