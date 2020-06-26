//
//  CreateDeckStepOneVC.swift
//  Flash Cubes
//
//  Created by Jeffrey Thompson on 5/6/19.
//  Copyright © 2019 Jeffrey Thompson. All rights reserved.
//

import UIKit

class CreateNewDeckVC: UIViewController {

    var textField: UITextField!
    
    var backgroundImgView: UIImageView = {
        var img = UIImage(named: "imgBackground")
        let imgView = UIImageView(image: img)
        imgView.contentMode = .scaleAspectFill
        imgView.translatesAutoresizingMaskIntoConstraints = false
        return imgView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupNavBar()
        setupToolbar()
        setupViews()
    }
    
    func setupNavBar(){}
    
    func setupToolbar(){
        var items = [UIBarButtonItem]()
        let continueBtn = UIBarButtonItem(title: AppText.getText().continueTxt, style: .plain, target: self, action: #selector(continueOnPress))
        let separator = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        
        items.append(separator)
        items.append(continueBtn)
        items.append(separator)
        
        self.navigationController?.isToolbarHidden = false
        self.toolbarItems = items
    }

    func setupViews(){
        view.addSubview(backgroundImgView)
        
        NSLayoutConstraint.activate([
            backgroundImgView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundImgView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            backgroundImgView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundImgView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
            ])
        
        textField = UITextField(frame: .zero)
        textField.translatesAutoresizingMaskIntoConstraints = false
        //textField.layer.cornerRadius = 6
        //textField.layer.masksToBounds = true
        textField.backgroundColor = .white
        textField.borderStyle = .roundedRect
        textField.textAlignment = .center
        textField.delegate = self
        //textField.font = .title
        textField.attributedPlaceholder = NSAttributedString(string: AppText.getText().newDeckName)
        
        view.addSubview(textField)
        
        let offset = view.safeAreaLayoutGuide.layoutFrame.height * 0.1
        
        NSLayoutConstraint.activate([
            textField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: offset),
            textField.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            textField.widthAnchor.constraint(equalToConstant: 325),
            textField.heightAnchor.constraint(equalToConstant: 40)
            ])
    }
    
    @objc func continueOnPress() {
        if let text = textField.text {
            if text != "" {
                // load next VC
                return
            }
        }
        
        AlertService.sendUserAlertMessage(title: AppText.getText().notice, message: AppText.getText().mustEnterDeckName, to: self)
    }
}

extension CreateNewDeckVC: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
}
