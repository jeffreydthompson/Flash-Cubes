//
//  CubeEditVC.swift
//  Flash Cubes
//
//  Created by Jeffrey Thompson on 5/4/19.
//  Copyright © 2019 Jeffrey Thompson. All rights reserved.
//

import UIKit

protocol EditCellDelegate {
    func editCell(didSendNew prompt: CubePrompt, for indexPath: IndexPath)
    func editCell(didTakeAudioFocusForPath indexPath: IndexPath)
    func editCellDidEndAudioFocus()
    func editCell(didDeletePromptFor indexPath: IndexPath)
}

class CubeEditVC: UIViewController, EditCellDelegate {

    struct TestPrompts {
        var prompts: [String : CubePrompt]!
    }
    
    var delegate: CubeEditDelegate!
    
    var cube: FlashCube?
    var tableView: UITableView!
    var nameTextField: UITextField = {
        let textField = UITextField(frame: .zero)
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.textAlignment = .center
        textField.borderStyle = .roundedRect
        textField.placeholder = AppText.newCubeName
        textField.autocapitalizationType = .sentences
        return textField
    }()
    
    //var testPrompts: TestPrompts!
    var editName: String?
    var editPrompts: TestPrompts!
    var keyArray: [String] = [String]()
    var trashDictionary: [String : Bool] = [String : Bool]()
    var isNewCube = false
    
    var backgroundImgView: UIImageView = {
        var img = UIImage(named: "imgBackgroundNoLogo")
        let imgView = UIImageView(image: img)
        imgView.contentMode = .scaleAspectFill
        imgView.translatesAutoresizingMaskIntoConstraints = false
        return imgView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelOnPress))
        
        setupToolbar()
        setupViews()
        //setupTestPrompts()
        setupPrompts()
        
        tableView.register(TextEditCell.self, forCellReuseIdentifier: TextEditCell.reuseIdentifier)
        tableView.register(AudioEditCell.self, forCellReuseIdentifier: AudioEditCell.reuseIdentifier)
        tableView.register(ImageEditCell.self, forCellReuseIdentifier: ImageEditCell.reuseIdentifier)
    }
    
    func setupPrompts(){
        guard let prompts = cube?.prompts else { return }
        
        editPrompts = TestPrompts()
        editPrompts.prompts = [String : CubePrompt]()
        
        for prompt in prompts {
            
            keyArray.append(prompt.key)
            
            switch prompt.value {
            case .text( _):
                editPrompts.prompts[prompt.key] = .text(nil)
            case .audio( _):
                editPrompts.prompts[prompt.key] = .audio(nil)
            case .image( _):
                editPrompts.prompts[prompt.key] = .image(nil)
            }
        }
    }
    
    func setupToolbar(){
        var items = [UIBarButtonItem]()
        
        let spacer = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        let save = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(saveOnPress))
        
        items.append(spacer)
        items.append(save)
        
        self.navigationController?.isToolbarHidden = false
        self.toolbarItems = items
    }
    
    func setupViews(){
        
        view.addSubview(backgroundImgView)
        
        NSLayoutConstraint.activate([
            backgroundImgView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundImgView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundImgView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            backgroundImgView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
            ])
        
        let titleContainer = UIView(frame: .zero)
        titleContainer.translatesAutoresizingMaskIntoConstraints = false

        titleContainer.addSubview(nameTextField)
        nameTextField.delegate = self
    
        nameTextField.text = self.cube?.name
        
        NSLayoutConstraint.activate([
            nameTextField.leadingAnchor.constraint(equalTo: titleContainer.leadingAnchor, constant: 32),
            nameTextField.trailingAnchor.constraint(equalTo: titleContainer.trailingAnchor, constant: -32),
            nameTextField.centerYAnchor.constraint(equalTo: titleContainer.centerYAnchor),
            nameTextField.heightAnchor.constraint(equalToConstant: 40)
            ])
        
        view.addSubview(titleContainer)
        
        NSLayoutConstraint.activate([
            titleContainer.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            titleContainer.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            titleContainer.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            titleContainer.heightAnchor.constraint(equalToConstant: view.safeAreaLayoutGuide.layoutFrame.height * 0.2)
            ])
        
        tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: titleContainer.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
            ])
    }
    
    @objc func cancelOnPress(){

        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func saveOnPress(){
        guard cube != nil else {return}
        
        tableView.visibleCells.forEach({
            if let cell = $0 as? TextEditCell {
                cell.textField.resignFirstResponder()
            }
        })
        
        var editsMade = false
        editPrompts.prompts.forEach({
            switch $0.value {
            case .audio(let audio):
                if audio != nil {
                    editsMade = true
                    cube?.prompts?[$0.key] = $0.value
                }
            case .text(let str):
                if str != nil {
                    editsMade = true
                    cube?.prompts?[$0.key] = $0.value
                }
            case .image(let img):
                if img != nil {
                    editsMade = true
                    cube?.prompts?[$0.key] = $0.value
                }
            }
        })
        
        if editName != nil {
            editsMade = true
            cube?.name = editName
        }
        
        if editsMade {
            if isNewCube {
                self.delegate.cubeEditDelegate(didSave: self.cube!)
                self.navigationController?.popViewController(animated: true)
            } else {
                AlertService.sendUserDialogMessage(title: AppText.notice, message: AppText.overwriteWarning, to: self) {
                    self.delegate.cubeEditDelegate(didSave: self.cube!)
                    self.navigationController?.popViewController(animated: true)
                }
            }
        } else {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        nameTextField.resignFirstResponder()
    }
    
    func editCell(didDeletePromptFor atIndexPath: IndexPath) {
        
        AlertService.sendUserDeleteWarningDialog(message: AppText.deleteWarningPrompt, to: self) {
            let key = self.keyArray[atIndexPath.row]
            
            self.trashDictionary[key] = true
            if let prompt = self.cube?.prompts![key] {
                switch prompt {
                case .text( _):
                    self.editPrompts.prompts[key] = .text(nil)
                case .audio( _):
                    self.editPrompts.prompts[key] = .audio(nil)
                case .image( _):
                    self.editPrompts.prompts[key] = .image(nil)
                }
            }
            
            DispatchQueue.main.async {
                self.tableView.reloadRows(at: [atIndexPath], with: .none)
            }
        }
    }
    
    func editCell(didSendNew prompt: CubePrompt, for indexPath: IndexPath) {
        let key = keyArray[indexPath.row]
        
        switch prompt {
        case .text(let str):
            editPrompts.prompts[key] = .text(str)
        case .audio(let data):
            editPrompts.prompts[key] = .audio(data)
        case .image(let img):
            editPrompts.prompts[key] = .image(img)
        }
    }
    
    func editCell(didTakeAudioFocusForPath indexPath: IndexPath) {
        // need to set all other cells inactive
        tableView.isScrollEnabled = false
        tableView.visibleCells.forEach({
            if let cell = $0 as? AudioEditCell {
                if cell.indexPath != indexPath {
                    cell.audioCellState = .disabled
                }
            }
        })
    }
    
    func editCellDidEndAudioFocus() {
        tableView.isScrollEnabled = true
        tableView.visibleCells.forEach({
            if let cell = $0 as? AudioEditCell {
                cell.audioCellState = .neutral
            }
        })
    }
}

extension CubeEditVC: UITextFieldDelegate {
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        editName = textField.text
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        editName = textField.text
        textField.resignFirstResponder()
        return true
    }
    
}

extension CubeEditVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        let key = keyArray[indexPath.row]
        
        switch cube!.prompts![key]!.type {
        case .text:
            return TextEditCell.cellHeight
        case .audio:
            return AudioEditCell.cellHeight
        case .image:
            return ImageEditCell.cellHeight
        }
    }
    
}

extension CubeEditVC: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //return testPrompts.prompts.count
        return cube?.prompts?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let key = keyArray[indexPath.row]
        
        switch cube!.prompts![key]!.type {
        case .text:
            return getTextCell(for: indexPath)
        case .audio:
            return getAudioCell(for: indexPath)
        case .image:
            return getImageCell(for: indexPath)
        }
        
    }
    
    func getTextCell(for indexPath: IndexPath) -> TextEditCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: TextEditCell.reuseIdentifier) as! TextEditCell
        
        let key = keyArray[indexPath.row]
        
        cell.delegate = self
        cell.indexPath = indexPath
        cell.titleLabel.text = key.capitalized
        
        let prompt = cube!.prompts![key]!
        switch prompt {
        case .text(let str):
            
            if let trashed = trashDictionary[key] {
                if trashed{break}
            }
            if let text = str {
                cell.textField.text = text
            }
        default:
            break
        }
        
        let editPrompt = editPrompts.prompts[key]!
        switch editPrompt {
        case .text(let str):
            if let text = str {
                cell.textField.text = text
            }
        default:
            break
        }
        
        return cell
        
    }
    
    func getAudioCell(for indexPath: IndexPath) -> AudioEditCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: AudioEditCell.reuseIdentifier) as! AudioEditCell
        
        let key = keyArray[indexPath.row]
        
        cell.delegate = self
        cell.indexPath = indexPath
        cell.titleLabel.text = key.capitalized

        let prompt = cube!.prompts![key]!
        switch prompt {
        case .audio(let data):
            
            if let trashed = trashDictionary[key] {
                if trashed {
                    cell.audioData = nil
                    break
                }
            }
            cell.audioData = data
        default:
            break
        }
        
        let editPrompt = editPrompts.prompts[key]!
        switch editPrompt {
        case .audio(let data):
            if let audioData = data {
                cell.audioData = audioData
            }
        default:
            break
        }
        
        return cell
    }
    
    func getImageCell(for indexPath: IndexPath) -> ImageEditCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: ImageEditCell.reuseIdentifier) as! ImageEditCell
        
        let key = keyArray[indexPath.row]
        
        cell.delegate = self
        cell.indexPath = indexPath
        cell.titleLabel.text = key.capitalized
        cell.navController = self.navigationController
        
        let prompt = cube!.prompts![key]!
        switch prompt {
        case .image(let img):
            
            if let trashed = trashDictionary[key] {
                if trashed {break}
            }
            if let image = img {
                cell.imageLoadButton?.setImage(image, for: .normal)
                cell.addTrashCan()
            }
            
        default:
            break
        }
        
        let editPrompt = editPrompts.prompts[key]!
        switch editPrompt {
        case .image(let img):
            if let image = img {
                cell.imageLoadButton?.setImage(image, for: .normal)
                cell.addTrashCan()
            }
        default:
            break
        }
        
        return cell
        
    }
    
}
