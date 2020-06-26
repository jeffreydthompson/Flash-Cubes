//
//  CreateNewDeckVC.swift
//  Flash Cubes
//
//  Created by Jeffrey Thompson on 5/6/19.
//  Copyright © 2019 Jeffrey Thompson. All rights reserved.
//

import UIKit

class EditExistingDeckVC: UIViewController, CreateDeckCellDelegate {
    
    struct CellData {
        var showState: DeckCreateTableCell.ShowState
        var promptOption: DeckCreateTableCell.PromptOption
        var text: String?
    }
    
    var textField: UITextField!
    
    private var cellDataArray = [CellData]()
    
    var editDelegate: EditExistingDeckDelegate!
    
    var tableView: UITableView = {
        let tblView = UITableView(frame: .zero)
        tblView.translatesAutoresizingMaskIntoConstraints = false
        tblView.backgroundColor = .clear
        tblView.separatorStyle = .none
        tblView.register(DeckCreateTableCell.self, forCellReuseIdentifier: DeckCreateTableCell.reuseidentifier)
        return tblView
    }()
    
    var backgroundImgView: UIImageView = {
        var img = UIImage(named: "imgBackgroundNoLogo")
        let imgView = UIImageView(image: img)
        imgView.contentMode = .scaleAspectFill
        imgView.translatesAutoresizingMaskIntoConstraints = false
        return imgView
    }()

    var deckToEdit: FlashCubeDeck!
    private var editDeck: FlashCubeDeck?
    var trackPromptNameChanges = [String : IndexPath?]()
    
    private var editPrompts = 0
    private var editName: String? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        setupCellDataSource()
        setupNavBar()
        setupToolbar()
        setupViews()
        
    }
    
    func setupCellDataSource(){
        
        editDeck = FlashCubeDeck(protoPrompts: deckToEdit.protoPrompts!)
        editDeck?.name = deckToEdit.name
        
        for (indexPathRow , value) in (editDeck?.protoPrompts?.enumerated())! {
            
            var promptOption: DeckCreateTableCell.PromptOption = .text
            
            switch value.value {
                
            case .audio( _):
                promptOption = .audio
            case .text( _):
                promptOption = .text
            case .image( _):
                promptOption = .image
                
            }

            cellDataArray.append(CellData(showState: .noEditPromptType, promptOption: promptOption, text: value.key))
            trackPromptNameChanges[value.key] = IndexPath(row: indexPathRow, section: 0)
        }
        
        if cellDataArray.count < 6 {
            cellDataArray.append(CellData(showState: .partial, promptOption: .text, text: nil))
        }
    }
    
    func setupNavBar(){}
    
    func setupToolbar(){
        var items = [UIBarButtonItem]()
        let continueBtn = UIBarButtonItem(title: AppText.save, style: .plain, target: self, action: #selector(saveOnPress))
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
        textField.backgroundColor = .white
        textField.borderStyle = .roundedRect
        textField.textAlignment = .center
        textField.delegate = self
        textField.font = UIFont.systemFont(ofSize: 20)
        textField.attributedPlaceholder = NSAttributedString(string: AppText.newDeckName)
        if editDeck != nil {
            textField.text = editDeck?.name
        }
        
        view.addSubview(textField)
        
        let offset = view.safeAreaLayoutGuide.layoutFrame.height * 0.1
        
        NSLayoutConstraint.activate([
            textField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: offset),
            textField.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            textField.widthAnchor.constraint(equalToConstant: 325),
            textField.heightAnchor.constraint(equalToConstant: 40)
            ])
        
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: textField.bottomAnchor, constant: 90),
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
            ])
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        textField.resignFirstResponder()
        tableView.visibleCells.forEach({($0 as! DeckCreateTableCell).cellTextfield.resignFirstResponder()})
    }
    
    @objc func saveOnPress() {
        
        textField.resignFirstResponder()
        tableView.visibleCells.forEach({
            if let cell = $0 as? DeckCreateTableCell {
                cell.cellTextfield.resignFirstResponder()
            }
        })
        
        guard let _ = textField.text, textField.text != "" else {
            AlertService.sendUserAlertMessage(title: AppText.notice, message: AppText.mustEnterDeckName, to: self)
            return
        }
        
        // check for missing prompt names
        cellDataArray.forEach {
            switch $0.showState {
            case .partial, .hidden:
                break
            default:
                guard let _ = $0.text, $0.text != "" else {
                    AlertService.sendUserAlertMessage(title: AppText.notice, message: AppText.mustEnterPromptName, to: self)
                    return
                }
                break
            }
        }
        
        //check for double names
        var checkDoubles = [String : Int]()
        cellDataArray.forEach({
            if let text = $0.text {
                if let amount = checkDoubles[text] {
                    checkDoubles[text] = amount + 1
                } else {
                    checkDoubles[text] = 1
                }
            }
        })
        
        checkDoubles.forEach({
            guard $0.value <= 1 else {
                AlertService.sendUserAlertMessage(title: AppText.notice, message: AppText.noDoublePromptNames, to: self)
                return
            }
        })

        print("\(#function) okay.. good to setup deck")
        
        AlertService.sendUserDialogMessage(title: AppText.notice, message: AppText.overwriteWarning, to: self) {
//        AlertService.sendUserDeleteWarningDialog(message: AppText.getText().learnedNew2, to: self) {
            if let name = self.editName {
                self.editDeck?.name = name
            }
            
            var newProtoPrompts = [String : CubePrompt]()
            self.cellDataArray.forEach({
                if $0.showState == .fullButton {
                    switch $0.promptOption {
                    case .text:
                        newProtoPrompts[$0.text!] = CubePrompt.text(nil)
                    case .audio:
                        newProtoPrompts[$0.text!] = CubePrompt.audio(nil)
                    case .image:
                        newProtoPrompts[$0.text!] = CubePrompt.image(nil)
                    }
                }
            })
            
            if !newProtoPrompts.isEmpty {
                self.editDeck?.protoPrompts = newProtoPrompts
            }
            
            var newDeckName: String? = nil
            if let text = self.textField.text {
                if text != self.deckToEdit.name {
                    newDeckName = text
                }
            }
            
            //self.editDelegate.editExistingDeck(didEdit: self.editDeck!, withChanges: self.trackPromptNameChanges, )
            self.editDelegate.editExistingDeck(didEdit: newDeckName, withChanges: self.trackPromptNameChanges, withNew: self.cellDataArray)
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    func createDeckCell(cellDidUpdatePromptOption withOption: DeckCreateTableCell.PromptOption, cellAt indexPath: IndexPath){

        cellDataArray[indexPath.row].promptOption = withOption
    }
    
    func createDeckCell(cellDidUpdateShowState withState: DeckCreateTableCell.ShowState, cellAt indexPath: IndexPath){

        switch withState {
        case .fullButton:
            
            if indexPath.row < cellDataArray.count {
                cellDataArray[indexPath.row] = CellData(showState: .fullButton, promptOption: .text, text: nil)
            }
            break
        case .partial:
            
            if indexPath.row < cellDataArray.count {
                
                var nonPartialCount = 0
                cellDataArray.forEach({
                    if $0.showState != .partial {
                        nonPartialCount += 1
                    }
                })
                
                if nonPartialCount <= 2 {
                    AlertService.sendUserAlertMessage(title: AppText.notice, message: AppText.atleastTwoSides, to: self)
                } else {
                    cellDataArray.remove(at: indexPath.row)
                    trackPromptNameChanges.forEach({
                        
                        if let thisRowForKey = $0.value?.row {
                            
                            if thisRowForKey == indexPath.row {
                                trackPromptNameChanges[$0.key] = nil
                            }
                            
                            if thisRowForKey > indexPath.row {
                                trackPromptNameChanges[$0.key] = IndexPath(row: thisRowForKey - 1, section: 0)
                            }
                        }
                    })
                }
            }
            break
        default:
            break
        }

        if cellDataArray.count < 6 {
            if let lastState = cellDataArray.last?.showState {
                if lastState != .partial {
                    cellDataArray.append(CellData(showState: .partial, promptOption: .text, text: nil))
                }
            }
        }
        
        tableView.reloadData()
    }
    
    func createDeckCell(cellDidUpdateTextField withString: String?, cellAt indexPath: IndexPath){
        
        // Check For Duplicates
        var checkForDuplicates = [String : Int]()
        tableView.visibleCells.forEach({
            if let cell = $0 as? DeckCreateTableCell {
                if let text = cell.cellTextfield.text {
                    if let amount = checkForDuplicates[text] {
                        checkForDuplicates[text] = amount + 1
                    } else {
                        checkForDuplicates[text] = 1
                    }
                }
            }
        })
        
        checkForDuplicates.forEach({
            if $0.value > 1 {
                AlertService.sendUserAlertMessage(title: AppText.notice, message: AppText.promptsCantBeSame, to: self)
                if let cell = tableView.cellForRow(at: indexPath) as? DeckCreateTableCell {
                    cell.cellTextfield.text = nil
                }
                return
            }
        })
        
        if indexPath.row < cellDataArray.count {
            cellDataArray[indexPath.row].text = withString
        }
    }
}

extension EditExistingDeckVC: UITextFieldDelegate {
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.resignFirstResponder()
        editName = textField.text
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

extension EditExistingDeckVC: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 0:
            return DeckCreateTableCell.cellHeight
        default:
            return 200
        }
    }
}

extension EditExistingDeckVC: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //return cellDataDictionary.count
        switch section {
        case 0:
            return cellDataArray.count
        default:
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: DeckCreateTableCell.reuseidentifier, for: indexPath) as! DeckCreateTableCell
            
            cell.showState = cellDataArray[indexPath.row].showState//self.cellDataDictionary[indexPath.row]!.showState
            cell.cellTextfield.text = cellDataArray[indexPath.row].text//self.cellDataDictionary[indexPath.row]?.text
            cell.option = cellDataArray[indexPath.row].promptOption //self.cellDataDictionary[indexPath.row]!.promptOption
            
            cell.indexPath = indexPath
            cell.delegate = self
            
            return cell
        default:
            let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
            cell.backgroundColor = .clear
            cell.contentView.backgroundColor = .clear
            cell.selectionStyle = .none
            return cell
        }
    }
}

