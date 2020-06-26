//
//  DeckTblVTitleCell.swift
//  Flash Cubes
//
//  Created by Jeffrey Thompson on 5/31/19.
//  Copyright © 2019 Jeffrey Thompson. All rights reserved.
//

import UIKit

class DeckTblVTitleCell: UITableViewCell {
    
    static let reuseIdentifier = "DeckTblVTitleCell"
    static let heightForCell: CGFloat = CGFloat(150)
    
    var titleLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.font = .title
        label.textColor = .white
        label.textAlignment = .center
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var retentionLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.text = "\(AppText.retention):"
        label.font = .body
        label.textColor = .graphRed
        label.textAlignment = .left
        label.numberOfLines = 1
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var proficiencyLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.text = "\(AppText.proficiency):"
        label.font = .body
        label.textColor = .appleBlue
        label.textAlignment = .left
        label.numberOfLines = 1
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var retentionBar: UIProgressView = {
        var bar = UIProgressView(progressViewStyle: .default)
        bar.translatesAutoresizingMaskIntoConstraints = false
        bar.layer.cornerRadius = 1.5
        bar.layer.masksToBounds = true
        bar.tintColor = UIColor.graphRed
        return bar
    }()
    
    var proficiencyBar: UIProgressView = {
        var bar = UIProgressView(progressViewStyle: .default)
        bar.translatesAutoresizingMaskIntoConstraints = false
        bar.layer.cornerRadius = 1.5
        bar.layer.masksToBounds = true
        bar.tintColor = UIColor.appleBlue
        return bar
    }()
    
    lazy var retentionStack: UIView = {
        
        let view = UIView(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .underlay
        view.layer.cornerRadius = 10
        view.layer.masksToBounds = true
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        
        view.addSubview(retentionLabel)
        
        NSLayoutConstraint.activate([
            retentionLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 5),
            retentionLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            retentionLabel.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.45),
            retentionLabel.heightAnchor.constraint(equalToConstant: 20)
            ])
        
        view.addSubview(self.retentionBar)
        
        NSLayoutConstraint.activate([
            retentionBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -5),
            retentionBar.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            retentionBar.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.55),
            retentionBar.heightAnchor.constraint(equalToConstant: 3)
            ])
        
        return view
    }()
    
    lazy var proficiencyStack: UIView = {
        
        let view = UIView(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .underlay
        view.layer.cornerRadius = 10
        view.layer.masksToBounds = true
        view.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        
        view.addSubview(proficiencyLabel)
        
        NSLayoutConstraint.activate([
            proficiencyLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 5),
            proficiencyLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            proficiencyLabel.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.45),
            proficiencyLabel.heightAnchor.constraint(equalToConstant: 20)
            ])
        
        view.addSubview(self.proficiencyBar)
        
        NSLayoutConstraint.activate([
            proficiencyBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -5),
            proficiencyBar.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            proficiencyBar.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.55),
            proficiencyBar.heightAnchor.constraint(equalToConstant: 3)
            ])
        
        return view
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        self.contentView.subviews.forEach({
            $0.removeFromSuperview()
        })
        setupViews()
    }
    
    func setupViews(){
        
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        
        contentView.addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.trailingAnchor),
            titleLabel.topAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.topAnchor),
            titleLabel.heightAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.heightAnchor, multiplier: 0.5)
            ])
        
        contentView.addSubview(retentionStack)
        
        NSLayoutConstraint.activate([
            retentionStack.widthAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.widthAnchor, multiplier: 0.7),
            retentionStack.centerXAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.centerXAnchor),
            retentionStack.topAnchor.constraint(equalTo: titleLabel.bottomAnchor),
            retentionStack.heightAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.heightAnchor, multiplier: 0.2)
            ])
        
        contentView.addSubview(proficiencyStack)
        
        NSLayoutConstraint.activate([
            proficiencyStack.widthAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.widthAnchor, multiplier: 0.7),
            proficiencyStack.centerXAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.centerXAnchor),
            proficiencyStack.topAnchor.constraint(equalTo: retentionStack.bottomAnchor),
            proficiencyStack.heightAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.heightAnchor, multiplier: 0.2)
            ])
    }
}
