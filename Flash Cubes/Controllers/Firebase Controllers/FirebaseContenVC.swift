//
//  FirebaseContenVC.swift
//  Flash Cubes
//
//  Created by Jeffrey Thompson on 6/6/19.
//  Copyright © 2019 Jeffrey Thompson. All rights reserved.
//

import UIKit

protocol SaveViewDelegate {
    func didSaveDeck(complete: Bool)
}

class FirebaseContenVC: UIViewController, SaveViewDelegate {

    var deck: DLCPrepDeck!
    
    var backgroundImgView: UIImageView = {
        var img = UIImage(named: "imgBackgroundNoLogo")
        let imgView = UIImageView(image: img)
        imgView.contentMode = .scaleAspectFill
        imgView.translatesAutoresizingMaskIntoConstraints = false
        return imgView
    }()
    
    var tableView: UITableView = {
        let tv = UITableView(frame: .zero)
        tv.backgroundColor = UIColor.clear
        tv.separatorStyle = .none
        tv.translatesAutoresizingMaskIntoConstraints = false
        return tv
    }()
    
    
    
    lazy var cellHeight: CGFloat = {
        
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
        
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupNavBar()
        setupViews()
        
        IAPService.shared.purchaseFailed = { [] (error) in
            
            if let error = error {
                print("\(#function) \(error.localizedDescription)")
                AlertService.sendUserAlertMessage(title: AppText.error, message: error.localizedDescription, to: self)
            }
        }
        
        IAPService.shared.purchasedCompletion = { [] () in
            //self.persistContent()
            self.initSave()
        }
        
        IAPService.shared.restoredCompletion = { productIdentifier in
            //
            self.initSave()
        }
    }
    
    func setupNavBar(){
        
        var title = AppText.download
        
        if let price = deck.price {
            if price > 0.01 {
                var localizedText = String(format: "$%.02f", price)
                
                if let iadId = deck.IAPid {
                    if let localizedPrice = IAPService.shared.localizedPrice(forIAPid: iadId) {
                        localizedText = localizedPrice
                    }
                }
                
                title = "\(AppText.buy) \(localizedText)"
            }
        }
        
        let buyButton = UIBarButtonItem(title: title, style: .plain, target: self, action: #selector(buyOnPress))
        self.navigationItem.rightBarButtonItems = [buyButton]
        
    }

    func setupViews(){
        
        view.addSubview(backgroundImgView)
        
        NSLayoutConstraint.activate([
            backgroundImgView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundImgView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            backgroundImgView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundImgView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
            ])
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(CubeTableCellNew.self, forCellReuseIdentifier: CubeTableCellNew.reuseIdentifier)
        
        view.addAndConstraintToExtents(view: tableView)
        
    }
    
    @objc func buyOnPress(){
        
        guard self.deck != nil else {return}
        
        if let price = deck.price {
            if price > 0.01 {
                if let id = deck.IAPid {
                    IAPService.shared.purchase(productId: id)
                    return
                }
            }
        }
        
        initSave()

    }
    
    func initSave() {
        let saveVC = SavingOverlayVC()
        saveVC.deck = self.deck!
        saveVC.delegate = self
        
        saveVC.modalPresentationStyle = .overCurrentContext
        
        self.navigationController?.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
        self.navigationController?.present(saveVC, animated: false, completion: nil)
        
        saveVC.initSave()
    }
    
    func didSaveDeck(complete: Bool) {
        
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



extension FirebaseContenVC: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        self.navigationItem.title = ""
    }
    
    func tableView(_ tableView: UITableView, didEndDisplayingHeaderView view: UIView, forSection section: Int) {
        self.navigationItem.title = deck.name
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = DLCTableHeader(frame: .zero)
        
        header.titleLabel.text = deck.name
        
        return header
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return cellHeight
    }
    
}

extension FirebaseContenVC: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return deck.flashCubes?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: CubeTableCellNew.reuseIdentifier, for: indexPath) as! CubeTableCellNew
        
        if let cube = deck.flashCubes?[indexPath.row] {
            cell.prompts = cube.prompts
            cell.name = cube.name
            cell.state = .dlc
            
        }
        
        DispatchQueue.main.async {
            cell.setupViews()
        }

        return cell
    }
    
}
