//
//  AlertService.swift
//  Flash Cubes
//
//  Created by Jeffrey Thompson on 5/6/19.
//  Copyright © 2019 Jeffrey Thompson. All rights reserved.
//

import Foundation
import UIKit


struct AlertService {
    
    private static var isiPad: Bool {
        get {
           return UIDevice.current.model == "iPad"
        }
    }
    
    static func sendUserAlertMessage(title: String, message: String, to viewController: UIViewController){
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.actionSheet)
        alert.addAction(UIAlertAction(title: AppText.ok, style: UIAlertAction.Style.default, handler: nil))
        
        if isiPad {
            if let popoverController = alert.popoverPresentationController {
                popoverController.sourceView = viewController.view
                popoverController.sourceRect = CGRect(x: viewController.view.bounds.midX, y: viewController.view.bounds.midY, width: 0, height: 0)
                popoverController.permittedArrowDirections = []
            }
        }
        
        viewController.present(alert, animated: true, completion: nil)
    }
    
    static func sendUserDeleteWarningDialog(message: String, to viewController: UIViewController, completion: @escaping () -> Void) {
        
        let dialog = UIAlertController(title: AppText.warning, message: message, preferredStyle: .actionSheet)
        let okAction = UIAlertAction(title: AppText.delete, style: .destructive) { ( _) in
            completion()
        }
        let cancelAction = UIAlertAction(title: AppText.cancel, style: .cancel, handler: nil)
        dialog.addAction(okAction)
        dialog.addAction(cancelAction)
        
        if isiPad {
            if let popoverController = dialog.popoverPresentationController {
                popoverController.sourceView = viewController.view
                popoverController.sourceRect = CGRect(x: viewController.view.bounds.midX, y: viewController.view.bounds.midY, width: 0, height: 0)
                popoverController.permittedArrowDirections = []
            }
        }
        
        viewController.present(dialog, animated: true, completion: nil)
    }
    
    static func sendUserDialogMessage(title: String, message: String, to viewController: UIViewController, completion: @escaping () -> Void){
        let dialog = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
        let okAction = UIAlertAction(title: AppText.ok, style: .default, handler: { (action:UIAlertAction!) in
            completion()
        })
        let cancelAction = UIAlertAction(title: AppText.cancel, style: .cancel, handler: nil)
        dialog.addAction(okAction)
        dialog.addAction(cancelAction)
        
        if isiPad {
            if let popoverController = dialog.popoverPresentationController {
                popoverController.sourceView = viewController.view
                popoverController.sourceRect = CGRect(x: viewController.view.bounds.midX, y: viewController.view.bounds.midY, width: 0, height: 0)
                popoverController.permittedArrowDirections = []
            }
        }
        
        viewController.present(dialog, animated: true, completion: nil)
    }
    
    static func sendUserDialogMessageWithImage(title: String, message: String, buttonText: String, withImage: UIImage?, to viewController: UIViewController, completion: @escaping () -> Void){
        
        let dialog = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
        let okAction = UIAlertAction(title: buttonText, style: .default, handler: { (action:UIAlertAction!) in
            completion()
        })
        let cancelAction = UIAlertAction(title: AppText.cancel, style: .cancel, handler: nil)
        if let image = withImage {
            let imgView = UIImageView(image: image)
            dialog.view.addSubview(imgView)
            imgView.center = dialog.view.center
        }
        dialog.addAction(okAction)
        dialog.addAction(cancelAction)
        
        if isiPad {
            if let popoverController = dialog.popoverPresentationController {
                popoverController.sourceView = viewController.view
                popoverController.sourceRect = CGRect(x: viewController.view.bounds.midX, y: viewController.view.bounds.midY, width: 0, height: 0)
                popoverController.permittedArrowDirections = []
            }
        }
        
        viewController.present(dialog, animated: true, completion: nil)
        
    }
    
}
