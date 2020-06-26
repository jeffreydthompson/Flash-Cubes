//
//  SetupReviewPickerCell.swift
//  Flash Cubes
//
//  Created by Jeffrey Thompson on 5/21/19.
//  Copyright © 2019 Jeffrey Thompson. All rights reserved.
//

import UIKit

class SetupReviewPickerCell: UIView {

    enum PresentationType {
        case question
        case answer
    }
    
    enum Order {
        case primary
        case secondary
    }
    
    var presentationType: PresentationType = .question
    var order: Order = .primary
    var isActive = true

    var delegate: SetupReviewPickerDelegate!
    
    var primaryRowSelection: Int?
    var secondaryRowSelection: Int?
    
    var prompts: [String]!
    lazy var picker: UIPickerView = {
        let picker = UIPickerView(frame: .zero)
        picker.translatesAutoresizingMaskIntoConstraints = false
        picker.backgroundColor = .underlay
        picker.layer.cornerRadius = 20
        picker.layer.masksToBounds = true
        picker.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMaxXMaxYCorner]
        
        switch presentationType {
        case .question:
            picker.selectedRow(inComponent: 0)
        case .answer:
            picker.selectedRow(inComponent: 1)
        }
        
        return picker
    }()
    
    var toggleButton: UIButton = {
        let btn = UIButton(type: .custom)
        btn.titleLabel?.font = UIFont.boldSystemFont(ofSize: 80)
        btn.setTitleColor(.themeColor, for: .normal)
        btn.setTitle("＋", for: .normal)
        btn.addTarget(self, action: #selector(onButtonPress), for: .touchUpInside)
        btn.backgroundColor = .underlay
        btn.layer.cornerRadius = 20
        btn.layer.masksToBounds = true
        btn.layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner]
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()
    
    convenience init(promptNames: [String], presentationType: PresentationType, order: Order) {
        self.init(frame: .zero)
        self.prompts = promptNames
        self.presentationType = presentationType
        self.order = order
        switch order {
        case .primary:
            if presentationType == .answer {
                primaryRowSelection = 1
            }
        case .secondary:
            isActive = false
        }
        
        setupViews()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.translatesAutoresizingMaskIntoConstraints = false
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupViews() {
        
        self.subviews.forEach { (subView) in
            subView.subviews.forEach({ (subsubView) in subsubView.removeFromSuperview() })
            subView.removeFromSuperview()
        }

        let leftContainer = UIView(frame: .zero)
        leftContainer.translatesAutoresizingMaskIntoConstraints = false
        
        let rightContainer = UIView(frame: .zero)
        rightContainer.translatesAutoresizingMaskIntoConstraints = false
        
        self.addSubview(leftContainer)
        NSLayoutConstraint.activate([
            leftContainer.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            leftContainer.topAnchor.constraint(equalTo: self.topAnchor),
            leftContainer.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            leftContainer.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 0.25)
            ])
        
        self.addSubview(rightContainer)
        NSLayoutConstraint.activate([
            rightContainer.leadingAnchor.constraint(equalTo: leftContainer.trailingAnchor),
            rightContainer.topAnchor.constraint(equalTo: self.topAnchor),
            rightContainer.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            rightContainer.trailingAnchor.constraint(equalTo: self.trailingAnchor)
            ])
        
        switch self.order {
        case .primary:
            setupPrimaryView(leftContainer: leftContainer, rightContainer: rightContainer)
        case .secondary:
            setupSecondaryView(leftContainer: leftContainer, rightContainer: rightContainer)
        }
    }
    
    func setupPrimaryView(leftContainer: UIView, rightContainer: UIView) {
        
        let underLay = UIView(frame: .zero)
        underLay.translatesAutoresizingMaskIntoConstraints = false
        underLay.backgroundColor = .underlay
        underLay.layer.cornerRadius = 20
        underLay.layer.masksToBounds = true
        underLay.layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner]
        
        leftContainer.addSubview(underLay)
        NSLayoutConstraint.activate([
            underLay.leadingAnchor.constraint(equalTo: leftContainer.leadingAnchor, constant: 12),
            underLay.topAnchor.constraint(equalTo: leftContainer.topAnchor, constant: 6),
            underLay.bottomAnchor.constraint(equalTo: leftContainer.bottomAnchor, constant: -6),
            underLay.trailingAnchor.constraint(equalTo: leftContainer.trailingAnchor, constant: -6)
            ])
        
        rightContainer.addSubview(picker)
        
        picker.dataSource = self
        picker.delegate = self
        
        if let selection = primaryRowSelection {
            picker.selectRow(selection, inComponent: 0, animated: false)
        }
        
        NSLayoutConstraint.activate([
            picker.leadingAnchor.constraint(equalTo: rightContainer.leadingAnchor, constant: 6),
            picker.topAnchor.constraint(equalTo: rightContainer.topAnchor, constant: 6),
            picker.bottomAnchor.constraint(equalTo: rightContainer.bottomAnchor, constant: -6),
            picker.trailingAnchor.constraint(equalTo: rightContainer.trailingAnchor, constant: -12)
            ])
    }
    
    func setupSecondaryView(leftContainer: UIView, rightContainer: UIView) {
        
        leftContainer.addAndConstrain(view: toggleButton, top: 6, bottom: 6, left: 12, right: 6)
        
        if isActive {
            
            rightContainer.addAndConstrain(view: picker, top: 6, bottom: 6, left: 6, right: 12)
            
            picker.dataSource = self
            picker.delegate = self
            
            if let selection = secondaryRowSelection {
                picker.selectRow(selection, inComponent: 0, animated: false)
            }
            
        } else {
            
            let underLay = UIView(frame: .zero)
            underLay.translatesAutoresizingMaskIntoConstraints = false
            underLay.backgroundColor = .underlay
            underLay.layer.cornerRadius = 20
            underLay.layer.masksToBounds = true
            underLay.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMaxXMaxYCorner]
            
            rightContainer.addAndConstrain(view: underLay, top: 6, bottom: 6, left: 6, right: 12)
            
            let secondaryLabel = UILabel(frame: .zero)
            secondaryLabel.font = .body
            secondaryLabel.textColor = .white
            secondaryLabel.textAlignment = .center
            secondaryLabel.numberOfLines = 2
            secondaryLabel.text = AppText.addSecondaryPrompt
            
            rightContainer.addAndConstrain(view: secondaryLabel, top: 6, bottom: 6, left: 6, right: 12)
        }
    }
    
    @objc func onButtonPress() {
        isActive = !isActive
        toggleButton.isHighlighted = isActive
        delegate.setupReviewPicker(picker: self, secondaryDidChangeState: isActive)
        
        if isActive {
            toggleButton.setTitle("－", for: .normal)
        } else {
            toggleButton.setTitle("＋", for: .normal)
        }
        
        setupViews()
    }
}

extension SetupReviewPickerCell: UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return prompts.count
    }
    
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        
        let attributes: [NSAttributedString.Key : Any] = [
            NSAttributedString.Key.font : UIFont.body,
            NSAttributedString.Key.foregroundColor : UIColor.white
        ]
        
        return NSAttributedString(string: prompts[row], attributes: attributes)
    }
}

extension SetupReviewPickerCell: UIPickerViewDelegate {

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        switch self.order {
        case .primary:
            primaryRowSelection = row
        case .secondary:
            secondaryRowSelection = row
        }
        
        delegate.setupReviewPicker(picker: self, didSelectRowAt: row)
    }
}
