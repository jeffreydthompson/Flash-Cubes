//
//  SetupReviewSettingsVC.swift
//  
//
//  Created by Jeffrey Thompson on 6/21/19.
//

import UIKit

class SetupReviewSettingsVC: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    var maxReviewLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = AppText.maximumNewAtOneTime
        label.numberOfLines = 2
        label.textColor = .white
        label.textAlignment = .center
        return label
    }()
    
    lazy var picker: UIPickerView = {
        let picker = UIPickerView(frame: .zero)
        picker.translatesAutoresizingMaskIntoConstraints = false
        picker.dataSource = self
        picker.delegate = self
        return picker
    }()
    
    var currentReviewAmount = 7
    
    var delegate: SetupReviewOptionsDelegate!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        setupViews()
    }
    
    func setupViews(){
        self.view.backgroundColor = .clear
        
        let container = UIView(frame: .zero)
        container.translatesAutoresizingMaskIntoConstraints = false
        container.backgroundColor = .themeColor
        
        container.layer.cornerRadius = 20
        container.layer.masksToBounds = true
        
        view.addSubview(container)
        
        NSLayoutConstraint.activate([
            container.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            container.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 50),
            container.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            container.heightAnchor.constraint(equalToConstant: 250)
            ])
        
        container.addSubview(maxReviewLabel)
        
        NSLayoutConstraint.activate([
            maxReviewLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            maxReviewLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            maxReviewLabel.topAnchor.constraint(equalTo: container.topAnchor, constant: 10),
            maxReviewLabel.heightAnchor.constraint(equalToConstant: 80)
            ])
        
        container.addSubview(picker)
        
        NSLayoutConstraint.activate([
            picker.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 20),
            picker.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -20),
            picker.topAnchor.constraint(equalTo: maxReviewLabel.bottomAnchor, constant: 10),
            picker.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -10)
            ])

        picker.selectRow(currentReviewAmount - 1, inComponent: 0, animated: false)
        
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onViewTap)))
    }
    
    @objc func onViewTap(){
        self.dismiss(animated: false, completion: nil)
    }

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 25
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        delegate.setupReviewOptions(choseReviewAmount: row + 1)
    }
    
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        
        let attributes: [NSAttributedString.Key : Any] = [
            NSAttributedString.Key.font : UIFont.body,
            NSAttributedString.Key.foregroundColor : UIColor.white
        ]
        
        return NSAttributedString(string: "\(row + 1)", attributes: attributes)
    }
}
