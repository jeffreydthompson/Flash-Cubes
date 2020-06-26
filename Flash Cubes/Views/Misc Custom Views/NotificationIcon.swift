//
//  NotificationIcon.swift
//  Flash Cubes
//
//  Created by Jeffrey Thompson on 5/6/19.
//  Copyright © 2019 Jeffrey Thompson. All rights reserved.
//

import UIKit

class NotificationIcon: UIImageView {
    
    enum NotificationState {
        case neutral
        case new
        case pastDue
    }

    let imgNew = UIImage(named: "imgNew")!
    let imgPastDue = UIImage(named: "imgPastDue")!
    
    var notificationState: NotificationState = .neutral {
        didSet {
            DispatchQueue.main.async {
                switch self.notificationState {
                case .neutral:
                    self.image = nil
                case .new:
                    self.image = self.imgNew
                case .pastDue:
                    self.image = self.imgPastDue
                }
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.translatesAutoresizingMaskIntoConstraints = false
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
