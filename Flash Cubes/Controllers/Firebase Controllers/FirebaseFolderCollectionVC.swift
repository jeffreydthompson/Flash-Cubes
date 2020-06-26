//
//  FirebaseFolderCollectionVC.swift
//  Flash Cubes
//
//  Created by Jeffrey Thompson on 6/4/19.
//  Copyright © 2019 Jeffrey Thompson. All rights reserved.
//

import UIKit

class FirebaseFolderCollectionVC: UIViewController {
    
    //var folderCollection: FolderCollection!
    var folderCollection: DatabaseFolderCollection!
    var delegate: DLCUpdateDelegate?
    
    var backgroundImgView: UIImageView = {
        var img = UIImage(named: "imgBackgroundNoLogo")
        let imgView = UIImageView(image: img)
        imgView.contentMode = .scaleAspectFill
        imgView.translatesAutoresizingMaskIntoConstraints = false
        return imgView
    }()
    
    lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.backgroundColor = .clear
        tableView.register(DLCTableCell.self, forCellReuseIdentifier: DLCTableCell.reuseIdentifier)
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.

        IAPService.shared.restoredCompletion = { productIdentifier in
            self.purchasesRestored(productIdentifier: productIdentifier)
        }
        
        setupToolbar()
        setupViews()
    }
    
    func setupToolbar(){
        var items = [UIBarButtonItem]()
        
        let separator = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let restoreButton = UIBarButtonItem(title: AppText.restorePurchases, style: .plain, target: self, action: #selector(restorePurchases))

        items.append(separator)
        items.append(restoreButton)
        items.append(separator)
        
        self.navigationController?.isToolbarHidden = false
        self.toolbarItems = items
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if isMovingFromParent {
            self.navigationController?.viewControllers.forEach({
                if $0.isKind(of: DeckCollectionVC.self) {
                    self.navigationController?.popToViewController($0, animated: true)
                }
            })
        }
    }
    
    func setupViews(){
        view.addAndConstraintToExtents(view: backgroundImgView)
        
        NSLayoutConstraint.activate([
            backgroundImgView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundImgView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            backgroundImgView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundImgView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
            ])
        
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
            ])
    }
    
    @objc func restorePurchases(){
        IAPService.shared.restore()
    }
    
    func purchasesRestored(productIdentifier: String){
        print("\(#function) : \(productIdentifier)")
        
        folderCollection?.folders?.forEach({ folder in
            folder.subFolders?.forEach({ subfolder in
                subfolder.content?.forEach({ content in
                    if let id = content.IAPid {
                        if id == productIdentifier {
                            
                            let folderPath = subfolder.storageFolder
                            let componentName = content.name
                            
                            print("     begin download from: \(content.filename ?? "")")
                            
                            let dlcSession = DLCSession(folderPath: folderPath, componentName: componentName)
                            
                            dlcSession.downloadFirebaseDeck { (firebaseDeck, error) in
                                if let error = error {
                                    print("\(#function) \(error.localizedDescription)")
                                }
                                
                                if let firebaseDeck = firebaseDeck {
                                    var prepDeck = dlcSession.prepDeck(from: firebaseDeck)
                                    prepDeck.price = content.price
                                    prepDeck.IAPid = content.IAPid
                                    
                                    DLCPrepManager.prepDeckToFile(prepDeck: prepDeck) { (error) in
                                        if let error = error {
                                            print("\(#function) \(error.localizedDescription)")
                                        }
                                    
                                        self.delegate?.didUpdate()
                                    }
                                }
                            }
                        }
                    }
                })
            })
        })
        
        self.navigationController?.viewControllers.forEach({
            
            if $0.isKind(of: DeckCollectionVC.self) {
                if let vc = $0 as? DeckCollectionVC {
                    vc.programManager.updateDeckCollection(completion: {
                        self.navigationController?.popToViewController(vc, animated: true)
                    })
                }
            }
        })
    }
}

extension FirebaseFolderCollectionVC: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = DLCTableHeader(frame: .zero)
        
        view.titleLabel.text = AppText.categories
        
        return view
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return DLCTableCell.cellHeight
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let subFolder = folderCollection.folders?[indexPath.row] {
            //print("\(#function) selected: \(title)")
            
            let mainFolderVC = FirebaseMainFolderVC()
            mainFolderVC.mainFolder = subFolder
            self.navigationController?.pushViewController(mainFolderVC, animated: true)
        }
    }
    
}

extension FirebaseFolderCollectionVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return folderCollection.folders?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: DLCTableCell.reuseIdentifier, for: indexPath) as! DLCTableCell
        
        if let title = folderCollection.folders?[indexPath.row].name {
            cell.titleLabel.text = title
        }
        
        return cell
    }
}


class DLCTableCell: UITableViewCell {
    
    static let reuseIdentifier = "DLCTableCell"
    static let cellHeight: CGFloat = 60
    
    var underLayer: UIView = {
        let layer = UIView(frame: .zero)
        layer.backgroundColor = .underlay
        layer.layer.cornerRadius = 15.0
        layer.layer.masksToBounds = true
        return layer
    }()
    
    var titleLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.font = .body
        label.textColor = .white
        label.textAlignment = .left
        label.numberOfLines = 1
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var detailLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.font = .bodyBold
        label.textColor = .white
        label.textAlignment = .right
        label.numberOfLines = 1
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        contentView.subviews.forEach({$0.removeFromSuperview()})
        setupViews()
    }
    
    func setupViews(){
        contentView.addAndConstrain(view: underLayer, top: 8, bottom: 8, left: 16, right: 16)
        
        contentView.addSubview(titleLabel)
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.leadingAnchor, constant: 24),
            titleLabel.centerYAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.centerYAnchor),
            titleLabel.heightAnchor.constraint(equalToConstant: 30),
            titleLabel.widthAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.widthAnchor, multiplier: 0.7)
            ])
        
        contentView.addSubview(detailLabel)
        NSLayoutConstraint.activate([
            detailLabel.trailingAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.trailingAnchor, constant: -24),
            detailLabel.centerYAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.centerYAnchor),
            detailLabel.heightAnchor.constraint(equalToConstant: 30),
            detailLabel.widthAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.widthAnchor, multiplier: 0.25)
            ])
    }
}

class DLCTableHeader: UIView {
    
    var underLayer: UIView = {
        let layer = UIView(frame: .zero)
        layer.backgroundColor = .themeColor
        layer.layer.cornerRadius = 15.0
        layer.layer.masksToBounds = true
        return layer
    }()
    
    var titleLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .body
        label.textAlignment = .center
        label.textColor = .white
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupViews(){
        self.backgroundColor = .clear
        
        addAndConstrain(view: underLayer, top: 8, bottom: 8, left: 16, right: 16)
        
        addAndConstraintToExtents(view: titleLabel)
        
        heightAnchor.constraint(equalToConstant: 60).isActive = true
    }
    
}
