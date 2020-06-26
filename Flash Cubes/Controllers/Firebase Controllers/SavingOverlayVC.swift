//
//  SavingOverlayVC.swift
//  Flash Cubes
//
//  Created by Jeffrey Thompson on 6/10/19.
//  Copyright © 2019 Jeffrey Thompson. All rights reserved.
//

import UIKit

class SavingOverlayVC: UIViewController {

    var deck: DLCPrepDeck!
    var delegate: SaveViewDelegate!
    
    var constrainingAnchor: NSLayoutDimension {
        get {
            return self.view.frame.width < self.view.frame.height ? self.view.widthAnchor : self.view.heightAnchor
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupViews()
    }
    
    func setupViews(){
        let loadingView = LoadingView(viewType: .saving)
        view.addSubview(loadingView)
        
        NSLayoutConstraint.activate([
            loadingView.centerXAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.centerXAnchor),
            loadingView.centerYAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.centerYAnchor),
            loadingView.widthAnchor.constraint(equalTo: constrainingAnchor, multiplier: 0.7),
            loadingView.heightAnchor.constraint(equalTo: constrainingAnchor, multiplier: 0.7)
            ])
    }
    
    func initSave(){
        
        guard deck != nil else {return}
        
        DLCPrepManager.prepDeckToFile(prepDeck: deck) { (error) in
            
            if let error = error {
                print("\(#function) \(error.localizedDescription)")
            }
            
            self.dismiss(animated: false, completion: {
                
                self.delegate.didSaveDeck(complete: error == nil)
            })
        }
    }
}
