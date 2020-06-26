//
//  FirebaseSubFolderVC.swift
//  Flash Cubes
//
//  Created by Jeffrey Thompson on 6/4/19.
//  Copyright © 2019 Jeffrey Thompson. All rights reserved.
//

import UIKit

protocol DLCSessionDelegate {
    func dlcSession(didDownload deck: DLCPrepDeck)
}

class FirebaseSubFolderVC: UIViewController, DLCSessionDelegate {

    var subFolder: DatabaseSubFolder!
    
    var constrainingAnchor: NSLayoutDimension {
        get {
            return self.view.frame.width < self.view.frame.height ? self.view.widthAnchor : self.view.heightAnchor
        }
    }
    
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
    
    var loadingView: LoadingView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        setupViews()
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
    
    func dlcSession(didDownload: DLCPrepDeck) {
        
        // weird bug about background img loading from backgroung thread in next VC ??
        DispatchQueue.main.async {
            let firebaseContentVC = FirebaseContenVC()
            firebaseContentVC.deck = didDownload
            self.navigationController?.pushViewController(firebaseContentVC, animated: true)
        }
    }
}

extension FirebaseSubFolderVC: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = DLCTableHeader(frame: .zero)
        
        view.titleLabel.text = subFolder?.name ?? ""
        
        return view
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return DLCTableCell.cellHeight
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let content = subFolder.content?[indexPath.row] {
            
            DispatchQueue.main.async {
                self.loadingView = LoadingView(viewType: .loading)
                self.view.addSubview(self.loadingView!)
                
                NSLayoutConstraint.activate([
                    self.loadingView!.centerXAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.centerXAnchor),
                    self.loadingView!.centerYAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.centerYAnchor),
                    self.loadingView!.widthAnchor.constraint(equalTo: self.constrainingAnchor, multiplier: 0.7),
                    self.loadingView!.heightAnchor.constraint(equalTo: self.constrainingAnchor, multiplier: 0.7)
                    ])
            }
            
            let folderPath = subFolder.storageFolder
            let componentName = content.name
            
            if let filename = content.filename {
                let searchPath = Directory.dlc.url.appendingPathComponent(filename).path
                
                if let data = FileManager.default.contents(atPath: searchPath){
                    do {
                        let prepDeck = try PropertyListDecoder().decode(DLCPrepDeck.self, from: data)
                        
                        // weird bug about background img loading from backgroung thread in next VC ??
                        DispatchQueue.main.async {
                            self.loadingView?.removeFromSuperview()
                            let firebaseContentVC = FirebaseContenVC()
                            firebaseContentVC.deck = prepDeck
                            self.navigationController?.pushViewController(firebaseContentVC, animated: true)
                        }
                        
                        return
                        
                    } catch let error {
                        print("\(#function) \(error.localizedDescription)")
                    }
                }
            }
            
            let dlcSession = DLCSession(folderPath: folderPath, componentName: componentName)
            dlcSession.delegate = self
            dlcSession.downloadFirebaseDeck { (firebaseDeck, error) in
                if let error = error {
                    print("\(#function) \(error.localizedDescription)")
                }
                
                if let firebaseDeck = firebaseDeck {
                    var prepDeck = dlcSession.prepDeck(from: firebaseDeck)
                    prepDeck.price = content.price
                    prepDeck.IAPid = content.IAPid
                    
                    if let filename = content.filename {
                        let savePath = Directory.dlc.url.appendingPathComponent(filename).path
                        
                        do {
                            let data = try PropertyListEncoder().encode(prepDeck)
                            FileManager.default.createFile(atPath: savePath, contents: data, attributes: nil)
                        } catch let error {
                            print("\(#function) \(error.localizedDescription)")
                        }
                    }
                    
                    // weird bug about background img loading from backgroung thread in next VC ??
                    DispatchQueue.main.async {
                        self.loadingView?.removeFromSuperview()
                        let firebaseContentVC = FirebaseContenVC()
                        firebaseContentVC.deck = prepDeck
                        self.navigationController?.pushViewController(firebaseContentVC, animated: true)
                    }
                }
            }
            
        }
    }
    
}

extension FirebaseSubFolderVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return subFolder.content?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: DLCTableCell.reuseIdentifier, for: indexPath) as! DLCTableCell
        
        if let title = subFolder.content?[indexPath.row].name {
            cell.titleLabel.text = title
        }
        
        cell.detailLabel.text = AppText.free
        
        if let price = subFolder.content?[indexPath.row].price {
            if price > 0.01 {
                cell.detailLabel.text = String(format: "$%.02f", price)
            }
        }
        
        if let iadId = subFolder.content?[indexPath.row].IAPid {
            if let localizedPrice = IAPService.shared.localizedPrice(forIAPid: iadId) {
                cell.detailLabel.text = localizedPrice
            }
        }
        
        return cell
    }
}
