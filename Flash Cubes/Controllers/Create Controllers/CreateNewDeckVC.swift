//
//  CreateNewDeckVC.swift
//  Flash Cubes
//
//  Created by Jeffrey Thompson on 5/6/19.
//  Copyright © 2019 Jeffrey Thompson. All rights reserved.
//

import UIKit

protocol CreateDeckCellDelegate {
    func createDeckCell(cellDidUpdatePromptOption withOption: DeckCreateTableCell.PromptOption, cellAt indexPath: IndexPath)
    func createDeckCell(cellDidUpdateShowState withState: DeckCreateTableCell.ShowState, cellAt indexPath: IndexPath)
    func createDeckCell(cellDidUpdateTextField withString: String?, cellAt indexPath: IndexPath)
}

class CreateNewDeckVC: UIViewController, CreateDeckCellDelegate {
    
    struct CellData {
        var showState: DeckCreateTableCell.ShowState
        var promptOption: DeckCreateTableCell.PromptOption
        var text: String?
    }
    
    var textField: UITextField!
    var cellDataDictionary = [Int : CellData]() {
        didSet {
            print(self.cellDataDictionary as Any)
        }
    }
    
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
    
    var editDeck: FlashCubeDeck?
    var delegate: CreateNewDeckDelegate!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        setupCellDataSource()
        setupNavBar()
        setupToolbar()
        setupViews()
        
    }
    
    func setupCellDataSource(){
        if editDeck == nil {
            cellDataDictionary[0] = CellData(showState: .immutable, promptOption: .text, text: nil)
            cellDataDictionary[1] = CellData(showState: .immutable, promptOption: .text, text: nil)
            cellDataDictionary[2] = CellData(showState: .partial, promptOption: .text, text: nil)
            cellDataDictionary[3] = CellData(showState: .hidden, promptOption: .text, text: nil)
            cellDataDictionary[4] = CellData(showState: .hidden, promptOption: .text, text: nil)
            cellDataDictionary[5] = CellData(showState: .hidden, promptOption: .text, text: nil)
        } else {
            
            for (index, value) in (editDeck?.protoPrompts?.enumerated())! {
                
                var promptOption: DeckCreateTableCell.PromptOption = .text
                
                switch value.value {
                    
                case .audio( _):
                    promptOption = .audio
                case .text( _):
                    promptOption = .text
                case .image( _):
                    promptOption = .image
                    
                }
                
                cellDataDictionary[index] = CellData(showState: .fullButton, promptOption: promptOption, text: value.key)
            }
            
            let countSnapshot = cellDataDictionary.count
            
            for index in countSnapshot ..< 6 {
                switch index {
                case countSnapshot:
                    cellDataDictionary[index] = CellData(showState: .partial, promptOption: .text, text: nil)
                    break
                default:
                    cellDataDictionary[index] = CellData(showState: .hidden, promptOption: .text, text: nil)
                    break
                }
            }
        }
    }
    
    func setupNavBar(){}
    
    func setupToolbar(){
        var items = [UIBarButtonItem]()
        let continueBtn = UIBarButtonItem(title: AppText.saveNewDeck, style: .plain, target: self, action: #selector(continueOnPress))
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
    
    @objc func continueOnPress() {
        
        textField.resignFirstResponder()
        tableView.visibleCells.forEach({($0 as! DeckCreateTableCell).cellTextfield.resignFirstResponder()})
        
        guard let _ = textField.text, textField.text != "" else {
            AlertService.sendUserAlertMessage(title: AppText.notice, message: AppText.mustEnterDeckName, to: self)
            return
        }
        
        self.cellDataDictionary.forEach({
            
            switch $0.value.showState {
            case .partial, .hidden:
                break
            default:
                guard let _ = $0.value.text, $0.value.text != "" else {
                    AlertService.sendUserAlertMessage(title: AppText.notice, message: AppText.mustEnterPromptName, to: self)
                    return
                }
            }
        })
        
        //check for doubles:
        var checkDoubles = [String : Int]()
        self.cellDataDictionary.forEach({

            switch $0.value.showState {
            case .partial, .hidden:
                break
            default:
                if let text = $0.value.text {
                    if let amount = checkDoubles[text] {
                        checkDoubles[text] = amount + 1
                    } else {
                        checkDoubles[text] = 1
                    }
                }
            }
            
            checkDoubles.forEach({
                guard $0.value <= 1 else {
                    AlertService.sendUserAlertMessage(title: AppText.notice, message: AppText.noDoublePromptNames, to: self)
                    return
                }
            })
        })
        
        var protoPrompts = [String : CubePrompt]()
        
        self.cellDataDictionary.forEach({
            switch $0.value.showState {
            case .partial, .hidden:
                break
            default:
                var prompt: CubePrompt? = nil
                let key = $0.value.text!
                let value = $0.value.promptOption
                switch value {
                case .text:
                    prompt = .text(nil)
                case .audio:
                    prompt = .audio(nil)
                case .image:
                    prompt = .image(nil)
                }
                
                protoPrompts[key] = prompt
            }
        })
        
        let newDeck = FlashCubeDeck(protoPrompts: protoPrompts)
        newDeck.name = textField.text!

        do {
            try delegate.createNewDeck(didCreate: newDeck)
            self.navigationController?.popViewController(animated: true)
        } catch let error {
            AlertService.sendUserAlertMessage(title: AppText.error, message: error.localizedDescription, to: self)
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    func createDeckCell(cellDidUpdatePromptOption withOption: DeckCreateTableCell.PromptOption, cellAt indexPath: IndexPath){
        self.cellDataDictionary[indexPath.row]?.promptOption = withOption
    }
    
    func createDeckCell(cellDidUpdateShowState withState: DeckCreateTableCell.ShowState, cellAt indexPath: IndexPath){
        
        self.cellDataDictionary[indexPath.row]?.showState = withState
        
        var updatePrecedingRow = false
        switch withState {
        case .fullButton:
            if let state = cellDataDictionary[indexPath.row - 1]?.showState {
                if state != .immutable {
                    cellDataDictionary[indexPath.row - 1]?.showState = .fullNoButton
                    updatePrecedingRow = true
                }
            }
            cellDataDictionary[indexPath.row + 1]?.showState = .partial
        case .partial:
            if let state = cellDataDictionary[indexPath.row - 1]?.showState {
                if state != .immutable {
                    cellDataDictionary[indexPath.row - 1]?.showState = .fullButton
                    updatePrecedingRow = true
                }
            }
            cellDataDictionary[indexPath.row + 1]?.showState = .hidden
        default:
            break
        }
        
        let nextIndexPathRow = indexPath.row + 1
        var updateIndexPaths = [indexPath]
        if nextIndexPathRow <= 5 {
            let nextIndexPath = IndexPath(row: nextIndexPathRow, section: indexPath.section)
            updateIndexPaths.append(nextIndexPath)
        }
        
        if updatePrecedingRow {
            let previousIndexPath = IndexPath(row: indexPath.row - 1, section: indexPath.section)
            updateIndexPaths.append(previousIndexPath)
        }
        
        tableView.reloadRows(at: updateIndexPaths, with: .none)
    }
    
    func createDeckCell(cellDidUpdateTextField withString: String?, cellAt indexPath: IndexPath){
        self.cellDataDictionary[indexPath.row]?.text = withString
    }
}

extension CreateNewDeckVC: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

extension CreateNewDeckVC: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return DeckCreateTableCell.cellHeight
    }
    
}

extension CreateNewDeckVC: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 6
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: DeckCreateTableCell.reuseidentifier, for: indexPath) as! DeckCreateTableCell
        
        cell.showState = self.cellDataDictionary[indexPath.row]!.showState
        cell.cellTextfield.text = self.cellDataDictionary[indexPath.row]?.text
        cell.option = self.cellDataDictionary[indexPath.row]!.promptOption
        
        cell.indexPath = indexPath
        cell.delegate = self
    
        return cell
    }
}

