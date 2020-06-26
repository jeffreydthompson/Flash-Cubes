//
//  DeckCollMenuVC.swift
//  Flash Cubes
//
//  Created by Jeffrey Thompson on 6/3/19.
//  Copyright © 2019 Jeffrey Thompson. All rights reserved.
//

import UIKit

class DeckTblVwMenuVC: UIViewController {

    var delegate: DeckTblVwMenuDelegate!
    
    let options = [
        AppText.defaultText,
        AppText.sortNameAsc,
        AppText.sortNameDesc,
        AppText.sortDueAsc,
        AppText.sortDueDesc,
        AppText.sortRetAsc,
        AppText.sortRetDesc,
        AppText.sortProfAsc,
        AppText.sortProfDesc
    ]
    
    /*
     enum SortBy {
     case cubeDefaultIndex
     case cubeName
     case cubeRetention
     case cubeProficiency
     case nextReviewDate
     }
     */
    
    let functions: [String : (sortBy: FlashCubeDeck.SortBy, order: FlashCubeDeck.SortOrder)] = [
        AppText.defaultText : (sortBy: .cubeDefaultIndex, order: .ascending),
        AppText.sortNameAsc : (sortBy: .cubeName, order: .ascending),
        AppText.sortNameDesc : (sortBy: .cubeName, order: .descending),
        AppText.sortDueAsc : (sortBy: .nextReviewDate, order: .ascending),
        AppText.sortDueDesc : (sortBy: .nextReviewDate, order: .descending),
        AppText.sortRetAsc : (sortBy: .cubeRetention, order: .ascending),
        AppText.sortRetDesc : (sortBy: .cubeRetention, order: .descending),
        AppText.sortProfAsc : (sortBy: .cubeProficiency, order: .ascending),
        AppText.sortProfDesc : (sortBy: .cubeProficiency, order: .descending)
    ]
    
    var blurBackground: UIVisualEffectView = {
        let blurEffect = UIBlurEffect(style: .regular)
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.translatesAutoresizingMaskIntoConstraints = false
        blurView.layer.cornerRadius = 20
        blurView.layer.masksToBounds = true
        return blurView
    }()
    
    var underLayer: UIView = {
        let view = UIView(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 20
        view.layer.masksToBounds = true
        view.backgroundColor = UIColor.themeColor
        view.alpha = 0.7
        return view
    }()
    
    var sortLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = AppText.sortBy
        label.font = .title
        label.textColor = .white
        label.textAlignment = .center
        return label
    }()
    
    lazy var sortPickerView: UIPickerView = {
        let picker = UIPickerView(frame: .zero)
        picker.translatesAutoresizingMaskIntoConstraints = false
        picker.dataSource = self
        picker.delegate = self
        return picker
    }()
    
    lazy var sortContainer: UIView = {
        let view = UIView(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        
        //view.backgroundColor = .green
        
        view.addAndConstraintToExtents(view: underLayer)
        view.addAndConstraintToExtents(view: blurBackground)
        
        view.addSubview(sortLabel)
        
        NSLayoutConstraint.activate([
            sortLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            sortLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            sortLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 10),
            sortLabel.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.3)
            ])
        
        view.addSubview(sortPickerView)
        
        NSLayoutConstraint.activate([
            sortPickerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            sortPickerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            sortPickerView.topAnchor.constraint(equalTo: sortLabel.bottomAnchor),
            sortPickerView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
            ])
        
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        view.backgroundColor = .clear
        setupViews()
    }
    
    func setupViews(){
        
        view.addSubview(sortContainer)
        
        NSLayoutConstraint.activate([
            sortContainer.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 80),
            sortContainer.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 30),
            sortContainer.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -30),
            sortContainer.heightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.heightAnchor, multiplier: 0.25)
            ])
        
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.dismiss(animated: true, completion: nil)
    }

}

extension DeckTblVwMenuVC: UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return options.count
    }

}

extension DeckTblVwMenuVC: UIPickerViewDelegate {
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        let (sort, order) = functions[options[row]]!
        //self.delegate.deckCollMenu(sortBy: sort, order: order)
        self.delegate.deckTblVwMenu(sortBy: sort, order: order)
    }
    
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        
        let attributes: [NSAttributedString.Key : Any] = [
            NSAttributedString.Key.font : UIFont.body,
            NSAttributedString.Key.foregroundColor : UIColor.white
        ]
        
        return NSAttributedString(string: options[row], attributes: attributes)
    }
}
