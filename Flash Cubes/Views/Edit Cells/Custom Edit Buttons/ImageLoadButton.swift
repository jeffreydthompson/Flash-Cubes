//
//  ImageLoadButton.swift
//  Flash Cubes
//
//  Created by Jeffrey Thompson on 5/6/19.
//  Copyright © 2019 Jeffrey Thompson. All rights reserved.
//

import UIKit

class ImageLoadButton: UIButton {
    
    var imagePicker: UIImagePickerController?
    var navController: UINavigationController!
    var delegate: ImageCellDelegate!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.translatesAutoresizingMaskIntoConstraints = false
        
        self.layer.cornerRadius = 16
        self.layer.masksToBounds = true
        
        self.setImage(UIImage(named: "imgImageNil"), for: .normal)
        self.addTarget(self, action: #selector(onPress), for: .touchUpInside)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func onPress(){
        imagePicker = UIImagePickerController()
        imagePicker?.delegate = self
        imagePicker?.sourceType = UIImagePickerController.SourceType.photoLibrary
        imagePicker?.allowsEditing = false
        navController.present(imagePicker!, animated: true) {
            print("\(#function)")
        }
    }
}

extension ImageLoadButton: UIImagePickerControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        let imgURL = info[.imageURL] as! URL
        let img = UIImage(contentsOfFile: imgURL.path)
        if let image = img {
            DispatchQueue.main.async {
                self.setImage(image, for: .normal)
            }
        }
        
        delegate.imgDidFinishPicking(img: img)
        
        navController.dismiss(animated: true, completion: nil)
    }
}

extension ImageLoadButton: UINavigationControllerDelegate {
    
}


