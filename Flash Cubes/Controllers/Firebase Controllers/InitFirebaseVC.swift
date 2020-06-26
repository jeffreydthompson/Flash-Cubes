//
//  InitFirebaseVC.swift
//  Flash Cubes
//
//  Created by Jeffrey Thompson on 6/4/19.
//  Copyright © 2019 Jeffrey Thompson. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class InitFirebaseVC: UIViewController {

    //private let enFolder = //"FolderCollection"
    
    var timeOutTimer: Timer?
    var timedOut = false {
        didSet {
            if self.timedOut {
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
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
    
    lazy var loadingView: LoadingView = {
        let view = LoadingView(viewType: .loading)
        return view
    }()
    
    var delegate: DLCUpdateDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        view.backgroundColor = .red
        
        timeOutTimer = Timer(fireAt: Date().addingTimeInterval(TimeInterval(10)), interval: TimeInterval(10), target: self, selector: #selector(timeOut), userInfo: nil, repeats: false)
        
        setupViews()
        firebaseLogin()
    }
    
    func setupViews(){
        
        view.addSubview(backgroundImgView)
        
        NSLayoutConstraint.activate([
            backgroundImgView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundImgView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            backgroundImgView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundImgView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
            ])
        
        view.addSubview(loadingView)
        
        NSLayoutConstraint.activate([
            loadingView.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            loadingView.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
            loadingView.widthAnchor.constraint(equalTo: constrainingAnchor, multiplier: 0.7),
            loadingView.heightAnchor.constraint(equalTo: constrainingAnchor, multiplier: 0.7)
            ])
    }
    
    @objc func timeOut(){
        self.timedOut = true
    }
    
    func firebaseLogin(){
        
        Auth.auth().signInAnonymously { (result, error) in
            
            if self.timedOut {
                return
            }
            
            self.timeOutTimer = nil
            
            if let error = error {
                print("\(#function) \(error.localizedDescription)")
                self.navigationController?.popViewController(animated: true)
            }
            
            if result != nil {
                Database.database().reference().child(AppText.firebaseFolder).observeSingleEvent(of: .value, with: { (snapshot) in
                    
                    guard let snapshotObject = snapshot.value as? NSObject else {return}
                    guard let array = snapshotObject as? [String : AnyObject] else {return}
                    
                    do {
                        let json = try JSONSerialization.data(withJSONObject: array, options: [])
                        //let folderCollection = try JSONDecoder().decode(FolderCollection.self, from: json)
                        let folderCollection = try JSONDecoder().decode(DatabaseFolderCollection.self, from: json)
                        
                        IAPService.shared.getProducts(productIDs: getIADProductIDs(folderCollection: folderCollection))
                        
                        let mainFolderVC = FirebaseFolderCollectionVC()
                        mainFolderVC.folderCollection = folderCollection
                        mainFolderVC.delegate = self.delegate
                        self.navigationController?.pushViewController(mainFolderVC, animated: true)
                        
                        //print("\(#function) \(folderCollection)")
                        
                    } catch let error {
                        print("\(#function) \(error.localizedDescription)")
                    }
                })
            }
        }
        
        func getIADProductIDs(folderCollection: DatabaseFolderCollection) -> Set<String> {
            var iapIds = Set<String>()
            if let folders = folderCollection.folders {
                for folder in folders {
                    if let subFolders = folder.subFolders {
                        for subFolder in subFolders {
                            if let contents = subFolder.content {
                                for content in contents {
                                    if let iapID = content.IAPid {
                                        iapIds.insert(iapID)
                                    }
                                }
                            }
                        }
                    }
                }
            }
            
            return iapIds
        }
        
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
