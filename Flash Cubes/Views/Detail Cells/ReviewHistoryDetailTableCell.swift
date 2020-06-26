//
//  ReviewHistoryDetailTableCell.swift
//  Flash Cubes
//
//  Created by Jeffrey Thompson on 5/14/19.
//  Copyright © 2019 Jeffrey Thompson. All rights reserved.
//

import UIKit

class ReviewHistoryDetailTableCell: UITableViewCell {
    
    static let reuseIdentifier = "ReviewHistoryDetailTableCell"
    static let cellHeight: CGFloat = 56
    
    private let underLayer: UIView = {
        let view = UIView(frame: .zero)
        view.backgroundColor = .underlay
        view.layer.cornerRadius = 20
        view.layer.masksToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let dateLabel: UILabel = {
        let lbl = UILabel(frame: .zero)
        lbl.font = .body
        lbl.textColor = UIColor.darkGrayText
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()
    
    let proficientLabel: UILabel = {
        let lbl = UILabel(frame: .zero)
        lbl.font = .body
        lbl.textColor = .appleBlue
        lbl.textAlignment = .right
        lbl.translatesAutoresizingMaskIntoConstraints = false
        //lbl.text = "Error. Title not set"
        return lbl
    }()
    
    let retentionLabel: UILabel = {
        let lbl = UILabel(frame: .zero)
        lbl.font = .body
        lbl.textColor = .graphRed
        lbl.textAlignment = .center
        lbl.translatesAutoresizingMaskIntoConstraints = false
        //lbl.text = "Error. Title not set"
        return lbl
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.backgroundColor = .clear
        self.contentView.backgroundColor = .clear
        self.selectionStyle = .none
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        self.contentView.subviews.forEach({$0.removeFromSuperview()})
        setupViews()
    }
    
    func setupViews() {
        self.contentView.addSubview(underLayer)
        contentView.constrain(withConstant: 6, view: underLayer)
        
//        NSLayoutConstraint.activate([
//            underLayer.leadingAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.leadingAnchor, constant: 6),
//            underLayer.trailingAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.trailingAnchor, constant: -6),
//            underLayer.topAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.topAnchor, constant: 6),
//            underLayer.bottomAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.bottomAnchor, constant: -6)
//            ])
        
        self.contentView.addSubview(dateLabel)
        
        NSLayoutConstraint.activate([
            dateLabel.leadingAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            dateLabel.widthAnchor.constraint(equalToConstant: 110),
            dateLabel.topAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.topAnchor, constant: 6),
            dateLabel.bottomAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.bottomAnchor, constant: -6)
            ])
        
        self.contentView.addSubview(proficientLabel)
        
        NSLayoutConstraint.activate([
            proficientLabel.trailingAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            proficientLabel.widthAnchor.constraint(equalToConstant: 90),
            proficientLabel.topAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.topAnchor, constant: 6),
            proficientLabel.bottomAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.bottomAnchor, constant: -6)
            ])
        
        self.contentView.addSubview(retentionLabel)
        
        NSLayoutConstraint.activate([
            retentionLabel.topAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.topAnchor, constant: 6),
            retentionLabel.bottomAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.bottomAnchor, constant: -6),
            retentionLabel.leadingAnchor.constraint(equalTo: dateLabel.trailingAnchor),
            retentionLabel.trailingAnchor.constraint(equalTo: proficientLabel.leadingAnchor)
            ])
    }
}
