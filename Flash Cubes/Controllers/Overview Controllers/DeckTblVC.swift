//
//  DeckTblVC.swift
//  Flash Cubes
//
//  Created by Jeffrey Thompson on 4/26/19.
//  Copyright © 2019 Jeffrey Thompson. All rights reserved.
//

import UIKit

protocol DeckTblVwMenuDelegate {
    func deckTblVwMenu(sortBy: FlashCubeDeck.SortBy, order: FlashCubeDeck.SortOrder)
}

protocol CubeDetailDelegate {
    func cubeDetail(didEdit cube: FlashCube)
    func cubeDetail(didDelete cube: FlashCube)
}

protocol EditExistingDeckDelegate {
    mutating func editExistingDeck(didEdit name: String?, withChanges: [String : IndexPath?], withNew cellData: [EditExistingDeckVC.CellData])
}

class DeckTblVC: UIViewController, CubeDetailDelegate, EditExistingDeckDelegate, DeckTblVwMenuDelegate {
    
    let reuseIdentifier = "CubeTableCell"
    var delegate: DeckTableViewDelegate!
    
    var deck: FlashCubeDeck!
    var tableView: UITableView = {
        let tv = UITableView(frame: .zero)
        tv.backgroundColor = UIColor.clear
        tv.separatorStyle = .none
        tv.translatesAutoresizingMaskIntoConstraints = false
        return tv
    }()
    
    var backgroundImgView: UIImageView = {
        var img = UIImage(named: "imgBackgroundNoLogo")
        let imgView = UIImageView(image: img)
        imgView.contentMode = .scaleAspectFill
        imgView.translatesAutoresizingMaskIntoConstraints = false
        return imgView
    }()

    //    var label: UILabel = {
    //        var label = UILabel(frame: .zero)
    //        label.translatesAutoresizingMaskIntoConstraints = false
    //        label.font = .title
    //        label.textColor = .white
    //        label.textAlignment = .center
    //        label.numberOfLines = 2
    //        return label
    //    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        setupToolbar()
        setupNavBar()
        
        //print("\(#function) \(deck.name) \(deck.deckSubFolder)")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        tableView.reloadData()
        setupViews()
    }
    
    func setupNavBar() {
        
        //self.navigationController?.title = "Deck Overview"
        
        let imgMenu = UIImage(named: "iconMenu")
        let btnMenu = UIButton(type: .custom)
        btnMenu.setImage(imgMenu, for: .normal)
        btnMenu.addTarget(self, action: #selector(menuBtnOnPress), for: .touchUpInside)
        let barBtnMenu = UIBarButtonItem(customView: btnMenu)
        
        let newBarBtn = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(newCubeOnPress))
        self.navigationItem.rightBarButtonItems = [newBarBtn, barBtnMenu]
    }
    
    func setupToolbar() {
        var items = [UIBarButtonItem]()
        let edit = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(editOnPress))
        let review = UIBarButtonItem(title: AppText.reviewDeck, style: .plain, target: self, action: #selector(reviewOnPress))
        
        let attributes: [NSAttributedString.Key : Any] = [
            NSAttributedString.Key.font : UIFont.title,
            NSAttributedString.Key.foregroundColor : UIColor.white
        ]
        
        review.setTitleTextAttributes(attributes, for: .normal)
        let trash = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(trashOnPress))
        let separator = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        items.append(trash)
        items.append(separator)
        items.append(review)
        items.append(separator)
        items.append(edit)
        self.navigationController?.isToolbarHidden = false
        self.toolbarItems = items
    }
    
    func setupViews(){
        
        //let offset = CGFloat(125)
        
        view.addSubview(backgroundImgView)
        
        NSLayoutConstraint.activate([
            backgroundImgView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundImgView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            backgroundImgView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundImgView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
            ])
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(CubeTableCell.self, forCellReuseIdentifier: reuseIdentifier)
        tableView.register(DeckTblVTitleCell.self, forCellReuseIdentifier: DeckTblVTitleCell.reuseIdentifier)
        tableView.register(CubeTableCellNew.self, forCellReuseIdentifier: CubeTableCellNew.reuseIdentifier)
        view.addSubview(tableView)
        
        //let height = view.safeAreaLayoutGuide.layoutFrame.height * 0.6
        //view.addConstraintsWithFormat(format: "H:|[v0]|", views: tableView)
        //view.addConstraintsWithFormat(format: "V:[v0(\(height-50))]-50-|", views: tableView)
        
        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor)
            //tableView.heightAnchor.constraint(equalToConstant: height)
            ])
        
        //        view.addSubview(label)
        //        label.text = deck.name?.capitalized ?? "no name"
        //
        //        NSLayoutConstraint.activate([
        //            label.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
        //            label.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
        //            label.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
        //            label.bottomAnchor.constraint(equalTo: tableView.topAnchor)
        //            ])
    }
    
    func calculateHeightForCells() -> CGFloat {
        /*var textSum = 0
        var imgSum = 0
        
        self.deck.protoPrompts?.forEach({
            switch $0.value.typeId {
            case 0: // text
                textSum += 1
            default: //image audio
                imgSum += 1
            }
        })
        
        var sum = 8 + (((imgSum + 2)/3) * 68) + (textSum * 48)
        if sum < 140 {sum = 140}
        
        var height: CGFloat = 32
        
        if let imgItems = self.deck.protoPrompts?.filter({$0.value.type != .text}).count {
            let rows = (imgItems / 3) + 1
            height += CGFloat(rows * 60)
        }
        
        if let txtItems = self.deck.protoPrompts?.filter({$0.value.type == .text}).count {
            height += CGFloat(txtItems * 30)
        }
        
        return CGFloat(height)*/
        
        var textSum = 0
        var imgSum = 0
        
        self.deck.protoPrompts?.forEach({
            switch $0.value.typeId {
            case 0: // text
                textSum += 1
            default: //image audio
                imgSum += 1
            }
        })
        
        let imgSizeAndBuffer = (UIDevice.current.model == "iPad") ? 128 : 68
        var sum = 8 + (((imgSum + 2)/3) * imgSizeAndBuffer) + (textSum * 48)
        if sum < 140 {sum = 140}
        
        return CGFloat(sum)
    }
    
    @objc func reviewOnPress() {
        
        let setupReviewVC = SetupReviewVC()
        setupReviewVC.deck = self.deck
        self.navigationController?.pushViewController(setupReviewVC, animated: true)
        
    }
    
    @objc func newCubeOnPress() {
        
        let newCube = FlashCube(prompts: self.deck.protoPrompts!)
        let createCubeVC = CubeEditVC()
        createCubeVC.delegate = self
        createCubeVC.cube = newCube
        createCubeVC.isNewCube = true
        self.navigationController?.pushViewController(createCubeVC, animated: true)
        
    }
    
    @objc func menuBtnOnPress() {
        let menuVC = DeckTblVwMenuVC()
        menuVC.delegate = self
        menuVC.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
        
        self.navigationController?.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
        self.navigationController?.present(menuVC, animated: true, completion: nil)
    }
    
    @objc func editOnPress() {
        
        let editDeckVC = EditExistingDeckVC()//CreateNewDeckVC()
        editDeckVC.deckToEdit = self.deck
        editDeckVC.editDelegate = self
        self.navigationController?.pushViewController(editDeckVC, animated: true)
    }
    
    @objc func trashOnPress() {
        AlertService.sendUserDeleteWarningDialog(message: AppText.deleteWarningDeck, to: self) {
            self.delegate.deckTableViewDelegate(delete: self.deck)
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    //MARK: Custom delegates:
    
    func cubeDetail(didDelete cube: FlashCube) {
        
        do {
            
            try deck.delete(cube: cube)
            delegate.deckTableViewDelegate(update: deck)
            tableView.reloadData()
            
        } catch let error {
            print("\(#function) \(error.localizedDescription)")
        }
        
    }
    
    func cubeDetail(didEdit cube: FlashCube) {
        //print("\(#function) \(cube as Any)")
        deck.flashCubes?.forEach({
            if $0.key == cube.fileName {
                deck.flashCubes?[$0.key] = cube
                do {
                    try deck.saveCube(forKey: $0.key, with: nil)
                    if let row = deck.cubeFileNames?.firstIndex(of: $0.key) {
                        let indexPath = IndexPath(row: row, section: 0)
                        tableView.reloadRows(at: [indexPath], with: .none)
                    }
                    
                } catch let error {
                    print("\(#function) \(error)")
                }
            }
        })
    }
    
    func deckTblVwMenu(sortBy: FlashCubeDeck.SortBy, order: FlashCubeDeck.SortOrder) {

        deck.sort(by: sortBy, order: order) {
            
            // need to delegate up to collection view? to save the deck??
            self.tableView.reloadData()
        }
    }
    
    func editExistingDeck(didEdit name: String?, withChanges: [String : IndexPath?], withNew cellData: [EditExistingDeckVC.CellData]) {
        //print("\(#function) Received deck: \(deck.name as Any) \(deck.protoPrompts as Any)")
        //print("\(#function) Deck in this class's memory: \(self.deck.name as Any) \(self.deck.protoPrompts as Any)")
        print("New Deck name: \(name ?? "NO CHANGES")")
        //print("\(#function) withChanges: \(withChanges as Any)")
        
        if let name = name {
            self.deck.name = name
            DispatchQueue.main.async {
                self.tableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: UITableView.RowAnimation.none)
                //self.label.text = self.deck.name
            }
        }
        
        var rowsUsed = [Int]()
        
        // changing the names of and deleting existing prompts
        self.deck.protoPrompts?.forEach({
            if let optional = withChanges[$0.key] {
                if let indexPath = optional {
                    
                    let oldKey = $0.key
                    
                    guard let newKey = cellData[indexPath.row].text else {
                        print("Error!")
                        return
                    }
                    
                    print("\(oldKey) becomes \(newKey)")
                    self.deck.protoPrompts?.switchKey(fromKey: oldKey, toKey: newKey)
                    
                    self.deck.flashCubes?.forEach({ cube in
                        self.deck.flashCubes?[cube.key]?.prompts?.switchKey(fromKey: oldKey, toKey: newKey)
                    })
                    
                    rowsUsed.append(indexPath.row)
                }
            } else {
                
                let oldKey = $0.key
                
                print("\(oldKey) was deleted")
                self.deck.protoPrompts?.removeValue(forKey: oldKey)
                
                self.deck.flashCubes?.forEach({ cube in
                    self.deck.flashCubes?[cube.key]?.prompts?.removeValue(forKey: oldKey)
                })
            }
        })
        
        // adding new prompts
        for (index, value) in cellData.enumerated() {
            if value.showState == .partial {
                continue
            }
            if !rowsUsed.contains(index) {
                print("\(value.text as Any) is a new prompt")
                
                var prompt: CubePrompt?
                switch value.promptOption {
                case .text:
                    prompt = .text(nil)
                case .audio:
                    prompt = .audio(nil)
                case .image:
                    prompt = .image(nil)
                }
                
                self.deck.protoPrompts?[value.text!] = prompt!
                
                self.deck.flashCubes?.forEach({ cube in
                    self.deck.flashCubes?[cube.key]?.prompts?[value.text!] = prompt!
                })
            }
        }
        
        self.deck.saveAll()
        delegate.deckTableViewDelegate(didEdit: self.deck)
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
}

extension DeckTblVC: CubeEditDelegate {
    //MARK: CubeEditDelegate
    func cubeEditDelegate(didSave cube: FlashCube) {
        do {
            try deck.submit(cube: cube)
            delegate.deckTableViewDelegate(didEdit: self.deck)
            tableView.reloadData()
        } catch let error {
            print("\(#function) \(error)")
        }
    }
}

extension DeckTblVC: UITableViewDelegate {
    //MARK: UITableViewDelegate
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            self.navigationItem.title = ""
        }
    }
    
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            self.navigationItem.title = deck.name
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        switch indexPath.section {
        case 0:
            return DeckTblVTitleCell.heightForCell
        default:
//
//            if let cell = tableView.cellForRow(at: indexPath) as? CubeTableCellNew {
//                return cell.cellHeight
//            } else {
//                return 100
//            }
            return calculateHeightForCells()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        switch indexPath.section {
        case 0:
            return
        default:
            if let key = deck.cubeFileNames?[indexPath.row] {
                if let cube = deck.flashCubes?[key] {
                    let cubeDetailVC = CubeDetailVC()
                    cubeDetailVC.flashCube = cube
                    cubeDetailVC.delegate = self
                    self.navigationController?.pushViewController(cubeDetailVC, animated: true)
                    //let testRecordsVC = TestRecordsTblVC()
                    //testRecordsVC.cube = cube
                    //self.navigationController?.pushViewController(testRecordsVC, animated: true)
                }
            }
        }
    }
}

extension DeckTblVC: UITableViewDataSource {
    //MARK: UITableViewDataSource
    
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        switch section {
        case 0:
            return 1
        default:
            return deck.cubeFileNames?.count ?? 0
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch indexPath.section {
        case 0:
            
            let cell = tableView.dequeueReusableCell(withIdentifier: DeckTblVTitleCell.reuseIdentifier, for: indexPath) as! DeckTblVTitleCell
            
            cell.titleLabel.text = deck.name
            cell.retentionBar.progress = Float(deck.retention)
            cell.proficiencyBar.progress = Float(deck.proficiency)
            
            return cell
            
        default:
            
            let cell = tableView.dequeueReusableCell(withIdentifier: CubeTableCellNew.reuseIdentifier, for: indexPath) as! CubeTableCellNew
            
            if let key = deck.cubeFileNames?[indexPath.row] {
                
                if let cube = deck.flashCubes?[key] {
                    
                    cell.prompts = cube.prompts
                    cell.name = cube.name
                    //cell.retention = cube.retention
                    //cell.proficiency = cube.proficiency
                    
                    cell.retention = cube.getRetentionFor(reviewRecords: self.deck.allReviewRecordKeys ?? [ReviewRecordKey]())
                    cell.proficiency = cube.getProficiencyFor(reviewRecords: self.deck.allReviewRecordKeys ?? [ReviewRecordKey]())
                    
                    switch cube.reviewState {
                    case .neutral:
                        break
                    case .new:
                        cell.isNew = true
                    case .reviewIsDue:
                        cell.isPastDue = true
                        
                    }
                }
            }
            
            cell.setupViews()
            
            return cell
            
            /*
            let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! CubeTableCell
            
            //cell.nameLabel.text = "No name"
            var pastDue = false
            var new = false
            
            if let key = deck.cubeFileNames?[indexPath.row] {
                
                if let cube = deck.flashCubes?[key] {
                    
                    cell.prompts = cube.prompts
                    
                    cell.nameLabel.text = cube.name
                    
                    cell.progress = cube.proficiency
                    
                    switch cube.reviewState {
                    case .new:
                        new = true
                    case .reviewIsDue:
                        pastDue = true
                    default:
                        break
                    }
                }
            }
            
            cell.setupViews()
            if pastDue {cell.setPastDue()}
            if new {cell.setNew()}
            cell.selectionStyle = .none
            
            return cell*/
        }
    }
}


