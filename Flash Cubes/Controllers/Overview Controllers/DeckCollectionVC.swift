//
//  DeckCollectionVC.swift
//  Flash Cubes
//
//  Created by Jeffrey Thompson on 4/26/19.
//  Copyright © 2019 Jeffrey Thompson. All rights reserved.
//

import UIKit

protocol DeckCollMenuDelegate {
    func deckCollMenu(sortBy: DeckCollection.SortBy, order: DeckCollection.SortOrder)
}

protocol DeckTableViewDelegate {
    func deckTableViewDelegate(delete deck: FlashCubeDeck)
    func deckTableViewDelegate(didEdit deck: FlashCubeDeck)
    func deckTableViewDelegate(update deck: FlashCubeDeck)
}

protocol CreateNewDeckDelegate {
    func createNewDeck(didCreate deck: FlashCubeDeck) throws
}

protocol DLCUpdateDelegate {
    func didUpdate()
}

class DeckCollectionVC: UIViewController, DLCUpdateDelegate {

    //var deckCollection: DeckCollection!
    var programManager: ProgramManager!
    var collectionView: UICollectionView!
    
    var backgroundImgView: UIImageView = {
        var img = UIImage(named: "imgBackgroundNoLogo")
        let imgView = UIImageView(image: img)
        imgView.contentMode = .scaleAspectFill
        imgView.translatesAutoresizingMaskIntoConstraints = false
        return imgView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        setupNavBar()
        setupToolbar()
        initCollectionView()
        setupViews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        collectionView.reloadData()
        collectionView.visibleCells.forEach({
            ($0 as! DeckCollectionViewCell).deckAnimation.animation = .deck
        })
    }
    
    func setupNavBar(){
        
        let imgDownload = UIImage(named: "iconDownload")
        let btnDownload = UIButton(type: .custom)
        btnDownload.setImage(imgDownload, for: .normal)
        btnDownload.addTarget(self, action: #selector(downloadBtnOnPress), for: .touchUpInside)
        let barBtnDownload = UIBarButtonItem(customView: btnDownload)
        
        self.navigationItem.leftBarButtonItems = [barBtnDownload]
        
        let imgMenu = UIImage(named: "iconMenu")
        let btnMenu = UIButton(type: .custom)
        btnMenu.setImage(imgMenu, for: .normal)
        btnMenu.addTarget(self, action: #selector(menuBtnOnPress), for: .touchUpInside)
        let barBtnMenu = UIBarButtonItem(customView: btnMenu)
        
        //let sortAsc = UIBarButtonItem(title: "sort Asc", style: .plain, target: self, action: #selector(sortAscending))
        //let sortDesc = UIBarButtonItem(title: "sort Desc", style: .plain, target: self, action: #selector(sortDescending))
        self.navigationItem.rightBarButtonItems = [barBtnMenu]
        
    }
    
    func setupToolbar(){
        var items = [UIBarButtonItem]()
        //let random = UIBarButtonItem(title: "New Random Deck", style: .plain, target: self, action: #selector(makeNewRandomDeck))
        let add = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(onAddNewPress))//UIBarButtonItem(title: AppText.getText().addNew, style: .plain, target: self, action: #selector(onAddNewPress))
        let separator = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        
        //items.append(random)
        items.append(separator)
        items.append(add)
        
        self.navigationController?.isToolbarHidden = false
        self.toolbarItems = items
    }
    
    func initCollectionView(){
        
        let flowLayout = UICollectionViewFlowLayout.init()
        let inset = CGFloat(10)
        flowLayout.sectionInset = UIEdgeInsets(top: inset, left: inset, bottom: inset, right: inset)
        let itemSize: CGFloat = (view.safeAreaLayoutGuide.layoutFrame.width - (inset*2)) * 0.485
        flowLayout.itemSize = CGSize(width: itemSize, height: itemSize)
        flowLayout.minimumLineSpacing = (inset*2)
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = .clear
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        collectionView.register(DeckCollTitleCell.self, forCellWithReuseIdentifier: DeckCollTitleCell.reuseIdentifier)
        collectionView.register(DeckCollectionViewCell.self, forCellWithReuseIdentifier: DeckCollectionViewCell.reuseIdentifier)
    }
    
    func setupViews(){
        
        view.addSubview(backgroundImgView)
        
        NSLayoutConstraint.activate([
            backgroundImgView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundImgView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            backgroundImgView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundImgView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
            ])
        
        self.view.addSubview(collectionView)
        
        //let height = view.safeAreaLayoutGuide.layoutFrame.height * 0.7
        NSLayoutConstraint.activate([
            collectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor)
            ])
    }
    
    @objc func downloadBtnOnPress(){
        
        let initFirebaseVC = InitFirebaseVC()
        initFirebaseVC.delegate = self
        self.navigationController?.pushViewController(initFirebaseVC, animated: false)
        
    }
    
    @objc func menuBtnOnPress(){
        let menuVC = DeckCollMenuVC()
        menuVC.delegate = self
        menuVC.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
        
        self.navigationController?.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
        self.navigationController?.present(menuVC, animated: true, completion: nil)
    }
    
    private func sortByNameAscending(){
        
        programManager.deckCollection?.sort(by: .deckName, order: .ascending, completion: {
            
            self.programManager.saveDeckCollection()
            self.collectionView.reloadData()
            
        })
        
    }

    private func sortByNameDescending(){
        
        programManager.deckCollection?.sort(by: .deckName, order: .descending, completion: {

            self.programManager.saveDeckCollection()
            self.collectionView.reloadData()

        })
    }
    
    func didUpdate(){
        programManager.updateDeckCollection {
            self.collectionView.reloadData()
        }
    }
    
    @objc func onAddNewPress() {
        let createNewDeckVC = CreateNewDeckVC()
        createNewDeckVC.delegate = self
        self.navigationController?.pushViewController(createNewDeckVC, animated: true)
    }
    
    @objc func makeNewRandomDeck() {
        let deck = DeckTestManager.shared.getRandomDeck(ofSize: nil)
        DeckTestManager.shared.save(deck: deck, withName: deck.deckSubFolder)
        
        programManager.deckCollection?.searchAndLoadDecks()
        collectionView.reloadData()
        programManager.saveDeckCollection()
    }
}

extension DeckCollectionVC: DeckCollMenuDelegate {
    //MARK: DeckCollMenuDelegate
    func deckCollMenu(sortBy: DeckCollection.SortBy, order: DeckCollection.SortOrder) {
        programManager.deckCollection?.sort(by: sortBy, order: order, completion: {
            
            self.programManager.saveDeckCollection()
            self.collectionView.reloadData()
            
        })
    }
}

extension DeckCollectionVC: CreateNewDeckDelegate {
    //MARK: CreateNewDeckDelegate
    
    func createNewDeck(didCreate deck: FlashCubeDeck) throws {
        do {
            try programManager.deckCollection?.submit(new: deck)
            programManager.saveDeckCollection()
            collectionView.reloadData()
        } catch let error {
            throw error
        }
    }
}

extension DeckCollectionVC: DeckTableViewDelegate {
    //MARK: DeckTableViewDelegate
    
    func deckTableViewDelegate(update deck: FlashCubeDeck) {
        
        collectionView.reloadData()
        do {
            try programManager.deckCollection?.saveDeck(forKey: deck.deckSubFolder)
        } catch let error {
            print("\(#function) \(error.localizedDescription)")
        }
        
    }
    
    func deckTableViewDelegate(delete deck: FlashCubeDeck) {
        do {
            try programManager.deckCollection?.deleteDeck(forFileName: deck.deckSubFolder)
            collectionView.reloadData()
            programManager.saveDeckCollection()
        } catch let error {
            print("error: \(error)")
        }
    }
    
    func deckTableViewDelegate(didEdit deck: FlashCubeDeck) {
        do {
            try programManager.deckCollection?.saveDeck(forKey: deck.deckSubFolder)
            collectionView.reloadData()
        } catch let error {
            print("\(error)")
        }
    }
}

extension DeckCollectionVC: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        if indexPath.section == 0 {
            let img = UIImage(named: "imgLogo")
            let imgView = UIImageView(frame: CGRect(x: 0, y: 0, width: 38, height: 38))
            imgView.contentMode = .scaleAspectFit
            imgView.image = img
            self.navigationItem.titleView = imgView
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            self.navigationItem.titleView = nil
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if indexPath.section == 0 {return}
        
        if let key = self.programManager.deckCollection?.deckFileNames?[indexPath.row] {
            //print(self.programManager.deckCollection?.deckCollection?[key]?.name as Any)
            if let deck = self.programManager.deckCollection?.deckCollection?[key] {
                let deckVC = DeckTblVC()//DeckVCCollectionView()
                deckVC.deck = deck
                deckVC.delegate = self
                self.navigationController?.pushViewController(deckVC, animated: true)
            }
        }
    }
}

extension DeckCollectionVC: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if section == 0 {return 1}
        return programManager.deckCollection?.deckFileNames?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        switch indexPath.section {
        case 0:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: DeckCollTitleCell.reuseIdentifier, for: indexPath) as! DeckCollTitleCell
            
            
            
            return cell
        default:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: DeckCollectionViewCell.reuseIdentifier, for: indexPath) as! DeckCollectionViewCell
            
            cell.nameLabel.text = AppText.noName
            if let key = programManager.deckCollection?.deckFileNames?[indexPath.row] {
                
                if let deck = programManager.deckCollection?.deckCollection?[key] {
                    cell.nameLabel.text = deck.name?.capitalized
                    //cell.progressIndicator.progress = Float(deck.getDeckProgress())
                    cell.retentionBar.progress = Float(deck.retention)
                    cell.proficiencyBar.progress = Float(deck.proficiency)
                    
                    switch deck.reviewState {
                    case .neutral:
                        cell.notificationIcon.notificationState = .neutral
                    case .new:
                        cell.notificationIcon.notificationState = .new
                    case .pastDue:
                        cell.notificationIcon.notificationState = .pastDue
                    }
                }
            }
            
            return cell
        }
    }
    
}

extension DeckCollectionVC: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        switch indexPath.section {
        case 0:
            let height = view.safeAreaLayoutGuide.layoutFrame.height * 0.2
            let width = view.safeAreaLayoutGuide.layoutFrame.width * 0.95
            return CGSize(width: width, height: height)
        default:
            var itemSize: CGFloat = 0
            // multiplier for iPhone 2 column: 0.485
            // multiplier for iPad 3 column: 0.31
            if UIDevice.current.model == "iPad" {
                itemSize = (view.safeAreaLayoutGuide.layoutFrame.width-20) * 0.31
            } else {
                itemSize = (view.safeAreaLayoutGuide.layoutFrame.width-20) * 0.485
            }
            return CGSize(width: itemSize, height: itemSize)
        }
    }
    
}

class DeckCollTitleCell: UICollectionViewCell {
    
    static let reuseIdentifier = "DeckCollTitleCell"
    
    var container: UIView = {
        let view = UIView(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 10
        view.layer.masksToBounds = true
        return view
    }()
    
    var logoImgView: UIImageView = {
        let img = UIImage(named: "imgLogo")
        let imgView = UIImageView(image: img)
        imgView.translatesAutoresizingMaskIntoConstraints = false
        return imgView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        //translatesAutoresizingMaskIntoConstraints = false
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupViews(){
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        
        contentView.addSubview(container)
        contentView.constrain(withConstant: 10, view: container)
        
        container.addSubview(logoImgView)
        
        NSLayoutConstraint.activate([
            logoImgView.widthAnchor.constraint(equalTo: container.heightAnchor, multiplier: 0.8),
            logoImgView.heightAnchor.constraint(equalTo: container.heightAnchor, multiplier: 0.8),
            logoImgView.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            logoImgView.centerYAnchor.constraint(equalTo: container.centerYAnchor)
            ])
        
        container.backgroundColor = .clear
    }
}
