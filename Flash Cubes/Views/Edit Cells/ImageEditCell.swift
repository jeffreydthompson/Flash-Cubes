//
//  ImageEditCell.swift
//  Flash Cubes
//
//  Created by Jeffrey Thompson on 5/6/19.
//  Copyright © 2019 Jeffrey Thompson. All rights reserved.
//

import UIKit

protocol ImageCellDelegate {
    func imgDidFinishPicking(img: UIImage?)
}

class ImageEditCell: UITableViewCell, ImageCellDelegate {
    
    var delegate: EditCellDelegate!
    var indexPath: IndexPath!
    
    static let cellHeight: CGFloat = (16 * 3) + (150+40)
    static let reuseIdentifier = "imageEditCell"
    
    var titleLabel: UILabel!
    
    var imageLoadButton: ImageLoadButton?
    var trashButton: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setImage(UIImage(named: "iconTrashCan"), for: .normal)
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()
    
    var navController: UINavigationController! {
        didSet {
            imageLoadButton?.navController = self.navController
        }
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        contentView.subviews.forEach({$0.removeFromSuperview()})
        setupViews()
    }
    
    func setupViews(){
        self.backgroundColor = .clear
        contentView.backgroundColor = .clear
        
        let underlayer = UIView(frame: .zero)
        underlayer.translatesAutoresizingMaskIntoConstraints = false
        underlayer.backgroundColor = .underlay
        underlayer.layer.cornerRadius = 8
        underlayer.layer.masksToBounds = true
        
        contentView.addSubview(underlayer)
        
        NSLayoutConstraint.activate([
            underlayer.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            underlayer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            underlayer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            underlayer.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8)
            ])
        
        titleLabel = UILabel(frame: .zero)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = .title
        titleLabel.textAlignment = .left
        titleLabel.textColor = .white
        
        contentView.addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            titleLabel.widthAnchor.constraint(equalToConstant: 200),
            titleLabel.heightAnchor.constraint(equalToConstant: 40)
            ])
        
        imageLoadButton = ImageLoadButton()
        imageLoadButton?.delegate = self
        contentView.addSubview(imageLoadButton!)
        
        NSLayoutConstraint.activate([
            imageLoadButton!.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 12),
            imageLoadButton!.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            imageLoadButton!.widthAnchor.constraint(equalToConstant: 150),
            imageLoadButton!.heightAnchor.constraint(equalToConstant: 150)
            ])
    }
    
    func addTrashCan() {
        
        contentView.addSubview(trashButton)
        trashButton.addTarget(self, action: #selector(onTrashPress), for: .touchUpInside)
        
        NSLayoutConstraint.activate([
            trashButton.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            trashButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            trashButton.widthAnchor.constraint(equalToConstant: 40),
            trashButton.heightAnchor.constraint(equalToConstant: 40)
            ])
    }
    
    @objc func onTrashPress(){
        delegate.editCell(didDeletePromptFor: indexPath)
    }
    
    func imgDidFinishPicking(img: UIImage?) {
        
        DispatchQueue.main.async {
            self.trashButton.removeFromSuperview()
            if img != nil {
                self.addTrashCan()
            }
        }
        
        //delegate.editCell(didSendNew prompt: .image(img), for indexPath: indexPath)
        delegate.editCell(didSendNew: .image(img), for: indexPath)
    }
}
