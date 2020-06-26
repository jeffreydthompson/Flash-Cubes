//
//  CubeDetailVC.swift
//  Flash Cubes
//
//  Created by Jeffrey Thompson on 5/4/19.
//  Copyright © 2019 Jeffrey Thompson. All rights reserved.
//

import UIKit

protocol CubeEditDelegate {
    func cubeEditDelegate(didSave cube: FlashCube)
}

class CubeDetailVC: UIViewController, CubeEditDelegate {
    
    enum ShowState {
        case graph
        case history
        case prompts
    }
    
    var backgroundImgView: UIImageView = {
        var img = UIImage(named: "imgBackgroundNoLogo")
        let imgView = UIImageView(image: img)
        imgView.contentMode = .scaleAspectFill
        imgView.translatesAutoresizingMaskIntoConstraints = false
        return imgView
    }()
    
    var flashCube: FlashCube! {
        didSet {
            if let prompts = self.flashCube.prompts {
                self.promptKeys = [String]()
                let sorted = prompts.sorted(by: {$0.key < $1.key})
                for (key, _) in sorted {
                    self.promptKeys.append(key)
                }
            }
            
            if let database = self.flashCube.reviewRecordDatabase?.database {
                self.reviewKeys = database.keys.sorted(by: { $0.fromPrompt < $1.fromPrompt })
            }
        }
    }
    var delegate: CubeDetailDelegate!
    
    var promptKeys: [String]!
    var reviewKeys: [ReviewRecordKey]? {
        didSet {
            if reviewKeys != nil {
                self.currentlySelectedKey = reviewKeys!.first
            }
        }
    }
    var currentlySelectedKey: ReviewRecordKey?
    
    var graphView = RetentionDecayGraph(frame: .zero)
    var picker: UIPickerView?
    
    var promptTableView: UITableView!
    let promptTableAccIdentifier = "CubeDetailVCPromptTable"
    var historyTableView: UITableView!
    let historyTableAccIdentifier = "CubeDetailVCHistoryTable"
    
    var showState: ShowState = .prompts
    
    var navButtonGraph: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setImage(UIImage(named: "iconGraphInactive"), for: .normal)
        btn.setImage(UIImage(named: "iconGraphActive"), for: .selected)
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()
    
    var navButtonHistory: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setImage(UIImage(named: "iconHistoryTableInactive"), for: .normal)
        btn.setImage(UIImage(named: "iconHistoryTableActive"), for: .selected)
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()
    
    var navButtonPrompts: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setImage(UIImage(named: "iconFlashCubesInactive"), for: .normal)
        btn.setImage(UIImage(named: "iconFlashCubesActive"), for: .selected)
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()
    
    var dateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateStyle = .medium
        df.timeStyle = .none
        return df
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.

        navButtonGraph.addTarget(self, action: #selector(navGraphOnPress), for: .touchUpInside)
        navButtonHistory.addTarget(self, action: #selector(navHistoryOnPress), for: .touchUpInside)
        navButtonPrompts.addTarget(self, action: #selector(navPromptOnPress), for: .touchUpInside)
        
        setupNavBar()
        setupBottomToolbar()
        initTables()
        //setupViews()
        layoutViews()
        setGraphData()
    }
    
    func setupNavBar(){
        //self.navigationController?.title = "Flash Cube Detail"
    }
    
    func setupBottomToolbar(){
        var items = [UIBarButtonItem]()
        
        let edit = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(onEditPress))
        let spacer = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        let trash = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(onTrashPress))
        
        items.append(trash)
        items.append(spacer)
        items.append(edit)
        
        self.navigationController?.isToolbarHidden = false
        self.toolbarItems = items
    }
    
    func setGraphData(){
        //graphView.retentionData
        if let database = flashCube.reviewRecordDatabase {
            
            var largestKeySize = 0
            var largestKey: ReviewRecordKey? = nil
            
            database.database.forEach({
                if largestKeySize < $0.value.count {
                    largestKeySize = $0.value.count
                    largestKey = $0.key
                }
            })
            
            if let key = largestKey {
                if let retentionData = database.getRetentionHistory(forKey: key) {
                    graphView.retentionData = retentionData
                }
            }
        }
    }
    
    func initTables(){
        promptTableView = UITableView(frame: .zero)
        promptTableView.accessibilityIdentifier = promptTableAccIdentifier
        promptTableView.translatesAutoresizingMaskIntoConstraints = false
        promptTableView.backgroundColor = .clear
        promptTableView.dataSource = self
        promptTableView.delegate = self
        promptTableView.separatorStyle = .none
        promptTableView.register(CubeDetailTableCell.self, forCellReuseIdentifier: CubeDetailTableCell.reuseIdentifier)
        
        historyTableView = UITableView(frame: .zero)
        historyTableView.accessibilityIdentifier = historyTableAccIdentifier
        historyTableView.translatesAutoresizingMaskIntoConstraints = false
        historyTableView.backgroundColor = .clear
        historyTableView.dataSource = self
        historyTableView.delegate = self
        historyTableView.separatorStyle = .none
        historyTableView.register(ReviewHistoryDetailTableCell.self, forCellReuseIdentifier: ReviewHistoryDetailTableCell.reuseIdentifier)
    }
    
    @objc func onEditPress(){
        let editCubeVC = CubeEditVC()
        editCubeVC.cube = self.flashCube
        editCubeVC.delegate = self
        self.navigationController?.pushViewController(editCubeVC, animated: true)
    }
    
    @objc func onTrashPress(){
        
        AlertService.sendUserDeleteWarningDialog(message: AppText.deleteWarningCube, to: self) {
            self.delegate.cubeDetail(didDelete: self.flashCube)
            self.navigationController?.popViewController(animated: true)
        }
        
    }
    
    func resetViews(){
        self.view.subviews.forEach { (subView) in
            subView.subviews.forEach({ (subSubView) in
                subSubView.removeFromSuperview()
            })
            subView.removeFromSuperview()
        }
    }
    
    func layoutViews() {
        
        view.addSubview(backgroundImgView)
        
        NSLayoutConstraint.activate([
            backgroundImgView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundImgView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            backgroundImgView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundImgView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
            ])
        
        let offset = CGFloat(110)//view.safeAreaLayoutGuide.layoutFrame.height * 0.1
        
        let topView = UIView(frame: .zero)
        topView.translatesAutoresizingMaskIntoConstraints = false
        
        let navView = UIView(frame: .zero)
        navView.translatesAutoresizingMaskIntoConstraints = false
        
        let buttonStack = UIStackView(arrangedSubviews: [navButtonPrompts, navButtonHistory, navButtonGraph])
        navButtonGraph.isSelected = false
        navButtonHistory.isSelected = false
        navButtonPrompts.isSelected = false
        
        switch showState {
        case .graph:
            
            navButtonGraph.isSelected = true
            
            graphView.translatesAutoresizingMaskIntoConstraints = false
            graphView.isOpaque = false
            
            picker = UIPickerView(frame: .zero)
            picker?.translatesAutoresizingMaskIntoConstraints = false
            picker?.backgroundColor = .clear
            picker?.dataSource = self
            picker?.delegate = self
            
            if let key = currentlySelectedKey {
                if let pickerRow = reviewKeys?.firstIndex(of: key) {
                    picker?.selectRow(pickerRow, inComponent: 0, animated: true)
                }
            }
            
            let pickerHeight = CGFloat(95)
            
            topView.addSubview(picker!)
            
            NSLayoutConstraint.activate([
                picker!.leadingAnchor.constraint(equalTo: topView.leadingAnchor),
                picker!.trailingAnchor.constraint(equalTo: topView.trailingAnchor),
                picker!.bottomAnchor.constraint(equalTo: topView.bottomAnchor),
                picker!.heightAnchor.constraint(equalToConstant: pickerHeight)
                ])
            
            if let key = currentlySelectedKey {
                if let retentionData = flashCube.reviewRecordDatabase?.getRetentionHistory(forKey: key) {
                    graphView.retentionData = retentionData
                }
                
                if let proficiencyData = flashCube.reviewRecordDatabase?.getProficiencyHistory(forKey: key) {
                    graphView.proficiencyData = proficiencyData
                }
                
                if let dueDate = flashCube.reviewRecordDatabase?.getDueDate(forKey: key) {
                    graphView.dueDate = dueDate
                }
            }
            
            let underLayer = UIView(frame: .zero)
            underLayer.backgroundColor = .underlay
            underLayer.translatesAutoresizingMaskIntoConstraints = false
            underLayer.layer.cornerRadius = 20
            underLayer.layer.masksToBounds = true
            
            topView.addSubview(underLayer)
            NSLayoutConstraint.activate([
                underLayer.leadingAnchor.constraint(equalTo: topView.leadingAnchor, constant: 16),
                underLayer.trailingAnchor.constraint(equalTo: topView.trailingAnchor, constant: -16),
                underLayer.topAnchor.constraint(equalTo: topView.topAnchor, constant: 16),
                underLayer.bottomAnchor.constraint(equalTo: picker!.topAnchor, constant: -16)
                ])
            
            topView.addSubview(graphView)
            //topView.constrainToExtents(view: graphView)
            
            NSLayoutConstraint.activate([
                graphView.leadingAnchor.constraint(equalTo: topView.leadingAnchor, constant: 16),
                graphView.trailingAnchor.constraint(equalTo: topView.trailingAnchor, constant: -16),
                graphView.topAnchor.constraint(equalTo: topView.topAnchor, constant: 36),
                graphView.bottomAnchor.constraint(equalTo: picker!.topAnchor, constant: -65)
                ])
            
            let retentionLabel = UILabel(frame: .zero)
            retentionLabel.textAlignment = .left
            retentionLabel.textColor = .graphRed
            retentionLabel.font = .body
            retentionLabel.translatesAutoresizingMaskIntoConstraints = false
            retentionLabel.text = AppText.retention
            
            let proficiencyLabel = UILabel(frame: .zero)
            proficiencyLabel.textAlignment = .right
            proficiencyLabel.textColor = .appleBlue
            proficiencyLabel.font = .body
            proficiencyLabel.translatesAutoresizingMaskIntoConstraints = false
            proficiencyLabel.text = AppText.proficiency
            
            topView.addSubview(retentionLabel)
            NSLayoutConstraint.activate([
                retentionLabel.leadingAnchor.constraint(equalTo: underLayer.leadingAnchor, constant: 30),
                retentionLabel.bottomAnchor.constraint(equalTo: underLayer.bottomAnchor, constant: -20),
                retentionLabel.widthAnchor.constraint(equalToConstant: 100),
                retentionLabel.heightAnchor.constraint(equalToConstant: 20)
                ])
            
            topView.addSubview(proficiencyLabel)
            NSLayoutConstraint.activate([
                proficiencyLabel.trailingAnchor.constraint(equalTo: underLayer.trailingAnchor, constant: -30),
                proficiencyLabel.bottomAnchor.constraint(equalTo: underLayer.bottomAnchor, constant: -20),
                proficiencyLabel.widthAnchor.constraint(equalToConstant: 100),
                proficiencyLabel.heightAnchor.constraint(equalToConstant: 20)
                ])
            
        case .history:
            navButtonHistory.isSelected = true
            
            topView.addSubview(historyTableView)
            //topView.constrainToExtents(view: historyTableView)
            
            NSLayoutConstraint.activate([
                historyTableView.leadingAnchor.constraint(equalTo: topView.leadingAnchor),
                historyTableView.trailingAnchor.constraint(equalTo: topView.trailingAnchor),
                historyTableView.bottomAnchor.constraint(equalTo: topView.bottomAnchor),
                historyTableView.topAnchor.constraint(equalTo: topView.topAnchor, constant: 40)
                ])
            
            let dateLabel = UILabel(frame: .zero)
            dateLabel.textColor = .darkGray
            dateLabel.backgroundColor = .underlay
            dateLabel.font = .body
            dateLabel.text = AppText.date
            dateLabel.textAlignment = .center
            dateLabel.translatesAutoresizingMaskIntoConstraints = false
            
            let retentionLabel = UILabel(frame: .zero)
            retentionLabel.textColor = .graphRed
            retentionLabel.backgroundColor = .underlay
            retentionLabel.font = .body
            retentionLabel.text = AppText.retention
            retentionLabel.textAlignment = .center
            retentionLabel.translatesAutoresizingMaskIntoConstraints = false
            
            let proficiencyLabel = UILabel(frame: .zero)
            proficiencyLabel.textColor = .appleBlue
            proficiencyLabel.backgroundColor = .underlay
            proficiencyLabel.font = .body
            proficiencyLabel.text = AppText.proficiency
            proficiencyLabel.textAlignment = .center
            proficiencyLabel.translatesAutoresizingMaskIntoConstraints = false
            
            topView.addSubview(dateLabel)
            NSLayoutConstraint.activate([
                dateLabel.leadingAnchor.constraint(equalTo: topView.leadingAnchor),
                dateLabel.topAnchor.constraint(equalTo: topView.topAnchor),
                dateLabel.bottomAnchor.constraint(equalTo: historyTableView.topAnchor),
                dateLabel.widthAnchor.constraint(equalToConstant: 100)
                ])
            
            topView.addSubview(proficiencyLabel)
            NSLayoutConstraint.activate([
                proficiencyLabel.trailingAnchor.constraint(equalTo: topView.trailingAnchor),
                proficiencyLabel.topAnchor.constraint(equalTo: topView.topAnchor),
                proficiencyLabel.bottomAnchor.constraint(equalTo: historyTableView.topAnchor),
                proficiencyLabel.widthAnchor.constraint(equalToConstant: 100)
                ])
            
            topView.addSubview(retentionLabel)
            NSLayoutConstraint.activate([
                retentionLabel.topAnchor.constraint(equalTo: topView.topAnchor),
                retentionLabel.bottomAnchor.constraint(equalTo: historyTableView.topAnchor),
                retentionLabel.leadingAnchor.constraint(equalTo: dateLabel.trailingAnchor),
                retentionLabel.trailingAnchor.constraint(equalTo: proficiencyLabel.leadingAnchor)
                ])
            
        case .prompts:
            navButtonPrompts.isSelected = true
            
            topView.addSubview(promptTableView)
            topView.constrainToExtents(view: promptTableView)
        }
        
        buttonStack.translatesAutoresizingMaskIntoConstraints = false
        buttonStack.axis = .horizontal
        buttonStack.distribution = .fillEqually
        
        navView.addSubview(buttonStack)
        navView.constrainToExtents(view: buttonStack)
        
        self.view.addSubview(navView)
        
        NSLayoutConstraint.activate([
            navView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            navView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            navView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            navView.heightAnchor.constraint(equalToConstant: offset)
            ])

        self.view.addSubview(topView)
        
        NSLayoutConstraint.activate([
            topView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            topView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            topView.bottomAnchor.constraint(equalTo: navView.topAnchor),
            topView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: offset)
            ])
        
//        let label = UILabel(frame: .zero)
//        label.translatesAutoresizingMaskIntoConstraints = false
//        label.font = .title
//        label.textColor = .white
//        label.textAlignment = .center
//        label.numberOfLines = 2
//
//        label.text = flashCube.name
        
        let label = CubeDetailTitleView(frame: .zero)
        label.titleLabel.text = flashCube.name
        label.retentionBar.progress = Float(flashCube.retention)
        label.proficiencyBar.progress = Float(flashCube.proficiency)
        label.setupViews()
        
        self.view.addSubview(label)
        
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            label.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            label.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            label.bottomAnchor.constraint(equalTo: topView.topAnchor)
            ])
    }
    
    func setupViews(){
        
        let topView = UIView(frame: .zero)
        topView.backgroundColor = .green
        topView.translatesAutoresizingMaskIntoConstraints = false
        let height = view.safeAreaLayoutGuide.layoutFrame.height * 0.25
        
        graphView.translatesAutoresizingMaskIntoConstraints = false
        graphView.isOpaque = false
        
        topView.addSubview(graphView)
        topView.constrainToExtents(view: graphView)
        
        let middleView = UIView(frame: .zero)
        //middleView.backgroundColor = .red
        middleView.translatesAutoresizingMaskIntoConstraints = false
        
        let bottomView = UIView(frame: .zero)
        //bottomView.backgroundColor = .blue
        bottomView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(topView)
        NSLayoutConstraint.activate([
            topView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            topView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            topView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            topView.heightAnchor.constraint(equalToConstant: height)
            ])
        
        middleView.addSubview(historyTableView)
        middleView.constrainToExtents(view: historyTableView)
//        NSLayoutConstraint.activate([
//            historyTableView.topAnchor.constraint(equalTo: middleView.bottomAnchor),
//            historyTableView.leadingAnchor.constraint(equalTo: middleView.leadingAnchor),
//            historyTableView.trailingAnchor.constraint(equalTo: middleView.trailingAnchor),
//            historyTableView.bottomAnchor.constraint(equalTo: middleView.bottomAnchor)
//            ])
        
        view.addSubview(middleView)
        NSLayoutConstraint.activate([
            middleView.topAnchor.constraint(equalTo: topView.bottomAnchor),
            middleView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            middleView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            middleView.heightAnchor.constraint(equalToConstant: height)
            //middleView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
            ])
        
        bottomView.addSubview(promptTableView)
        bottomView.constrainToExtents(view: promptTableView)
        
        //NSLayoutConstraint.activate([])
        
        view.addSubview(bottomView)
        NSLayoutConstraint.activate([
            bottomView.topAnchor.constraint(equalTo: middleView.bottomAnchor),
            bottomView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            bottomView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            bottomView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
            ])
    }
    
    @objc func navPromptOnPress(){
        showState = .prompts
        resetViews()
        layoutViews()
    }
    
    @objc func navHistoryOnPress(){
        showState = .history
        resetViews()
        layoutViews()
    }
    
    @objc func navGraphOnPress(){
        showState = .graph
        resetViews()
        layoutViews()
    }

    func cubeEditDelegate(didSave cube: FlashCube) {
        delegate.cubeDetail(didEdit: cube)
        self.flashCube = cube
        self.promptTableView.reloadData()
    }
}

extension CubeDetailVC: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        if tableView.accessibilityIdentifier == promptTableAccIdentifier {
            
            let view = UIView()
            view.backgroundColor = .themeColor
            
            let title = UILabel(frame: .zero)
            title.text = "\(self.flashCube.name ?? ""): \(AppText.prompts)"
            title.textColor = .white
            title.translatesAutoresizingMaskIntoConstraints = false
            title.textAlignment = .center
            
            view.addSubview(title)
            view.constrainToExtents(view: title)
            
            view.heightAnchor.constraint(equalToConstant: 40).isActive = true
            
            return view
        }
        
        if tableView.accessibilityIdentifier == historyTableAccIdentifier {
            
            if let key = reviewKeys?[section] {
                
                let view = ReviewHistoryTableHeader()
                view.titleLabel.text = "\(key.fromPrompt) - \(key.toPrompt)"
                
                if let dueDate = flashCube.reviewRecordDatabase?.getDueDate(forKey: key) {
                    if Date() > dueDate {
                        view.dueDate = dueDate
                        view.setupViews()
                        view.heightAnchor.constraint(equalToConstant: 80).isActive = true
                    } else {
                        view.setupViews()
                        view.heightAnchor.constraint(equalToConstant: 40).isActive = true
                    }
                } else {
                    view.setupViews()
                    view.heightAnchor.constraint(equalToConstant: 40).isActive = true
                }

                return view
//                let view = UIView()
//                view.backgroundColor = .themeColor
//
//                let title = UILabel(frame: .zero)
//                title.text = "\(key.fromPrompt) to \(key.toPrompt)"
//                title.textColor = .white
//                title.translatesAutoresizingMaskIntoConstraints = false
//                title.textAlignment = .center
//
//                view.addSubview(title)
//                view.constrainToExtents(view: title)
//
//                if let dueDate = flashCube.reviewRecordDatabase?.getDueDate(forKey: key) {
//                    if Date() > dueDate {
//
//                        let dueContainer = UIView(frame: .zero)
//                        dueContainer.translatesAutoresizingMaskIntoConstraints = false
//
//                        view.addSubview(dueContainer)
//
//                        NSLayoutConstraint.activate([
//                            dueContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor),
//                            dueContainer.centerYAnchor.constraint(equalTo: view.centerYAnchor),
//                            dueContainer.widthAnchor.constraint(equalToConstant: 30),
//                            dueContainer.heightAnchor.constraint(equalToConstant: 30)
//                            ])
//
//                        let img = UIImage(named: "imgPastDue")
//                        let imgView = UIImageView(image: img)
//                        imgView.translatesAutoresizingMaskIntoConstraints = false
//
//                        dueContainer.addSubview(imgView)
//                        dueContainer.constrainToExtents(view: imgView)
//                    }
//                }
//
//                view.heightAnchor.constraint(equalToConstant: 40).isActive = true
//
//                return view
            }
        }
        
        return nil
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if tableView.accessibilityIdentifier == promptTableAccIdentifier {
            
            let key = self.promptKeys[indexPath.row]
            let prompt = flashCube.prompts?[key]
            return CubeDetailTableCell.getHeight(forPrompt: prompt!)
        }
        
        if tableView.accessibilityIdentifier == historyTableAccIdentifier {
            return ReviewHistoryDetailTableCell.cellHeight
        }
        
        return 0
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if tableView.accessibilityIdentifier == promptTableAccIdentifier {
            return 1
        }
        
        if tableView.accessibilityIdentifier == historyTableAccIdentifier {
            return flashCube.reviewRecordDatabase?.database.keys.count ?? 0
        }
        
        return 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if tableView.accessibilityIdentifier == promptTableAccIdentifier {
            return flashCube.prompts?.count ?? 0
        }
        
        if tableView.accessibilityIdentifier == historyTableAccIdentifier {
            
            if let key = reviewKeys?[section] {
                return flashCube.reviewRecordDatabase?.database[key]?.filter({$0.validReviewTime == true}).count ?? 0
            }
        }
        
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if tableView.accessibilityIdentifier == promptTableAccIdentifier {
            let cell = tableView.dequeueReusableCell(withIdentifier: CubeDetailTableCell.reuseIdentifier, for: indexPath) as! CubeDetailTableCell
            
            let key = self.promptKeys[indexPath.row]
            cell.label.text = key
            cell.prompt = flashCube.prompts?[key]
            
            cell.setupViews()
            
            return cell
        }
        
        if tableView.accessibilityIdentifier == historyTableAccIdentifier {
            let cell = tableView.dequeueReusableCell(withIdentifier: ReviewHistoryDetailTableCell.reuseIdentifier, for: indexPath) as! ReviewHistoryDetailTableCell
            
            
            if let key = reviewKeys?[indexPath.section] {
                if let recordHistory = flashCube.reviewRecordDatabase?.getProficiencyHistory(forKey: key) {
                    
                    cell.dateLabel.text = dateFormatter.string(from: recordHistory[indexPath.row].onDate)
                    let percentage = Int(recordHistory[indexPath.row].proficiency * 100)
                    cell.proficientLabel.text = "\(percentage)%"
                }
                
                if let retentionHistory = flashCube.reviewRecordDatabase?.getRetentionHistory(forKey: key) {
                    let retention = Int(retentionHistory[indexPath.row].retention * 100)
                    cell.retentionLabel.text = "\(retention)%"
                }
            }
            
            return cell
        }
        
        return UITableViewCell()
    }
}

extension CubeDetailVC: UITableViewDelegate {
    
}

extension CubeDetailVC: UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return reviewKeys?.count ?? 0
    }
    
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        
        let text = "\(reviewKeys?[row].fromPrompt ?? "") - \(reviewKeys?[row].toPrompt ?? "")"
        let attributes: [NSAttributedString.Key : Any] = [
            NSAttributedString.Key.font : UIFont.title,
            NSAttributedString.Key.foregroundColor : UIColor.white
        ]
        let string = NSAttributedString(string: text, attributes: attributes)
        return string
    }
}

extension CubeDetailVC: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if let key = reviewKeys?[row] {
            self.currentlySelectedKey = key
        }
        self.resetViews()
        self.layoutViews()
    }
}

class CubeDetailTitleView: UIView {
    
    var titleLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.font = .title
        label.textColor = .white
        label.textAlignment = .center
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var retentionLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.text = "\(AppText.retention):"
        label.font = .body
        label.textColor = .graphRed
        label.textAlignment = .left
        label.numberOfLines = 1
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var proficiencyLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.text = "\(AppText.proficiency):"
        label.font = .body
        label.textColor = .appleBlue
        label.textAlignment = .left
        label.numberOfLines = 1
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var retentionBar: UIProgressView = {
        var bar = UIProgressView(progressViewStyle: .default)
        bar.translatesAutoresizingMaskIntoConstraints = false
        bar.layer.cornerRadius = 1.5
        bar.layer.masksToBounds = true
        bar.tintColor = UIColor.graphRed
        return bar
    }()
    
    var proficiencyBar: UIProgressView = {
        var bar = UIProgressView(progressViewStyle: .default)
        bar.translatesAutoresizingMaskIntoConstraints = false
        bar.layer.cornerRadius = 1.5
        bar.layer.masksToBounds = true
        bar.tintColor = UIColor.appleBlue
        return bar
    }()
    
    lazy var retentionStack: UIView = {
        
        let view = UIView(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .underlay
        view.layer.cornerRadius = 10
        view.layer.masksToBounds = true
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        
        view.addSubview(retentionLabel)
        
        NSLayoutConstraint.activate([
            retentionLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 5),
            retentionLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            retentionLabel.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.45),
            retentionLabel.heightAnchor.constraint(equalToConstant: 20)
            ])
        
        view.addSubview(self.retentionBar)
        
        NSLayoutConstraint.activate([
            retentionBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -5),
            retentionBar.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            retentionBar.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.55),
            retentionBar.heightAnchor.constraint(equalToConstant: 3)
            ])
        
        return view
    }()
    
    lazy var proficiencyStack: UIView = {
        
        let view = UIView(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .underlay
        view.layer.cornerRadius = 10
        view.layer.masksToBounds = true
        view.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        
        view.addSubview(proficiencyLabel)
        
        NSLayoutConstraint.activate([
            proficiencyLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 5),
            proficiencyLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            proficiencyLabel.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.45),
            proficiencyLabel.heightAnchor.constraint(equalToConstant: 20)
            ])
        
        view.addSubview(self.proficiencyBar)
        
        NSLayoutConstraint.activate([
            proficiencyBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -5),
            proficiencyBar.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            proficiencyBar.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.55),
            proficiencyBar.heightAnchor.constraint(equalToConstant: 3)
            ])
        
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        translatesAutoresizingMaskIntoConstraints = false
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupViews(){
        
        addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor),
            titleLabel.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            titleLabel.heightAnchor.constraint(equalTo: safeAreaLayoutGuide.heightAnchor, multiplier: 0.5)
            ])
        
        addSubview(retentionStack)
        
        NSLayoutConstraint.activate([
            retentionStack.widthAnchor.constraint(equalTo: safeAreaLayoutGuide.widthAnchor, multiplier: 0.7),
            retentionStack.centerXAnchor.constraint(equalTo: safeAreaLayoutGuide.centerXAnchor),
            retentionStack.topAnchor.constraint(equalTo: titleLabel.bottomAnchor),
            retentionStack.heightAnchor.constraint(equalTo: safeAreaLayoutGuide.heightAnchor, multiplier: 0.2)
            ])
        
        addSubview(proficiencyStack)
        
        NSLayoutConstraint.activate([
            proficiencyStack.widthAnchor.constraint(equalTo: safeAreaLayoutGuide.widthAnchor, multiplier: 0.7),
            proficiencyStack.centerXAnchor.constraint(equalTo: safeAreaLayoutGuide.centerXAnchor),
            proficiencyStack.topAnchor.constraint(equalTo: retentionStack.bottomAnchor),
            proficiencyStack.heightAnchor.constraint(equalTo: safeAreaLayoutGuide.heightAnchor, multiplier: 0.2)
            ])
    }
}
