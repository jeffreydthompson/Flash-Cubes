//
//  TextEditCell.swift
//  Flash Cubes
//
//  Created by Jeffrey Thompson on 5/4/19.
//  Copyright © 2019 Jeffrey Thompson. All rights reserved.
//

import UIKit

class TextEditCell: UITableViewCell {

    var delegate: EditCellDelegate!
    var indexPath: IndexPath!
    
    var titleLabel: UILabel!
    var textPrompt: String?
    
    var textField: UITextField! {
        didSet {
            DispatchQueue.main.async {
                self.trashButton.removeFromSuperview()
                if self.textField.text != nil && self.textField.text != "" {
                    self.addTrashCan()
                }
            }
        }
    }
    
    var trashButton: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setImage(UIImage(named: "iconTrashCan"), for: .normal)
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()
    
    static let cellHeight: CGFloat = (16 * 3) + (40 * 2)
    static let reuseIdentifier = "textEditCell"
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
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
        underlayer.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(touchUpInsideCell)))
        
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
        
        textField = UITextField(frame: .zero)
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.autocapitalizationType = .sentences
        textField.autocorrectionType = .no
        textField.clearsOnBeginEditing = false
        textField.backgroundColor = .white
        textField.borderStyle = .roundedRect
        textField.delegate = self
        //TODO affix to apptext file
        let placeHolderText = NSAttributedString(string: "Enter some text here, please")
        textField.attributedPlaceholder = placeHolderText
        
        contentView.addSubview(textField)
        
        NSLayoutConstraint.activate([
            textField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            textField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            textField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            textField.heightAnchor.constraint(equalToConstant: 40)
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
    
    @objc func touchUpInsideCell(){
        textField.resignFirstResponder()
    }

}

extension TextEditCell: UITextFieldDelegate {
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.resignFirstResponder()

        DispatchQueue.main.async {
            self.trashButton.removeFromSuperview()
            if self.textField.text != nil && self.textField.text != "" {
                self.addTrashCan()
            }
        }
        
        //self.delegate.editCell(didSendNew prompt: .text(textField.text), for indexPath: indexPath)
        self.delegate.editCell(didSendNew: .text(textField.text), for: indexPath)
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {

        return true
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        return false
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
}
