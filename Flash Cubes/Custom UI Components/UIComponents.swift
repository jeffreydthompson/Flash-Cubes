//
//  UIComponents.swift
//  Flash Cubes
//
//  Created by Jeffrey Thompson on 4/23/19.
//  Copyright © 2019 Jeffrey Thompson. All rights reserved.
//

import Foundation
import UIKit

class UnderLayerView: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.translatesAutoresizingMaskIntoConstraints = false
        self.layer.cornerRadius = 20
        self.layer.masksToBounds = true
        self.backgroundColor = .underlay
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension UIView {
    
    func addAndConstraintToExtents(view: UIView) {
        view.translatesAutoresizingMaskIntoConstraints = false
        
        self.addSubview(view)
        
        NSLayoutConstraint.activate([
            view.leadingAnchor.constraint(equalTo: self.safeAreaLayoutGuide.leadingAnchor),
            view.trailingAnchor.constraint(equalTo: self.safeAreaLayoutGuide.trailingAnchor),
            view.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor),
            view.bottomAnchor.constraint(equalTo: self.safeAreaLayoutGuide.bottomAnchor)
            ])
    }
    
    func constrainToExtents(view: UIView) {
        view.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            view.leadingAnchor.constraint(equalTo: self.safeAreaLayoutGuide.leadingAnchor),
            view.trailingAnchor.constraint(equalTo: self.safeAreaLayoutGuide.trailingAnchor),
            view.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor),
            view.bottomAnchor.constraint(equalTo: self.safeAreaLayoutGuide.bottomAnchor)
            ])
    }
    
    func addAndConstrain(view: UIView, top: CGFloat, bottom: CGFloat, left: CGFloat, right: CGFloat) {
        view.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(view)
        
        NSLayoutConstraint.activate([
            view.leadingAnchor.constraint(equalTo: self.safeAreaLayoutGuide.leadingAnchor, constant: left),
            view.trailingAnchor.constraint(equalTo: self.safeAreaLayoutGuide.trailingAnchor, constant: -right),
            view.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor, constant: top),
            view.bottomAnchor.constraint(equalTo: self.safeAreaLayoutGuide.bottomAnchor, constant: -bottom)
            ])
    }
    
    func constrain(withConstant offset: CGFloat, view: UIView) {
        
        view.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            view.leadingAnchor.constraint(equalTo: self.safeAreaLayoutGuide.leadingAnchor, constant: offset),
            view.trailingAnchor.constraint(equalTo: self.safeAreaLayoutGuide.trailingAnchor, constant: -offset),
            view.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor, constant: offset),
            view.bottomAnchor.constraint(equalTo: self.safeAreaLayoutGuide.bottomAnchor, constant: -offset)
            ])
    }
    
    func addConstraintsWithFormat(format: String, views: UIView...) {
        var viewsDictionary = [String : UIView]()
        for (index, view) in views.enumerated() {
            let key = "v\(index)"
            viewsDictionary[key] = view
            view.translatesAutoresizingMaskIntoConstraints = false
        }
        
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: format, options: NSLayoutConstraint.FormatOptions(), metrics: nil, views: viewsDictionary))
    }
}

extension UIColor {
    
    static let underlay: UIColor = {
       return UIColor.init(white: 1.0, alpha: 0.4)
    }()
    
    static let themeColor : UIColor = {
        let red   = CGFloat(0.235)
        let green = CGFloat(0.314)
        let blue  = CGFloat(0.514)
        let color = UIColor(red: red, green: green, blue: blue, alpha: CGFloat(1.0))
        return color
    }()
    
    static let graphRed : UIColor = {
        let red   = CGFloat(208.8 / 255.0)
        let green = CGFloat(2.0 / 255.0)
        let blue  = CGFloat(27.0 / 255.0)
        let color = UIColor(red: red, green: green, blue: blue, alpha: CGFloat(1.0))
        return color
    }()
    
    static let appleBlue : UIColor = {
        let red   = CGFloat(0)
        let green = CGFloat(122.0 / 255)
        let blue  = CGFloat(1)
        let color = UIColor(red: red, green: green, blue: blue, alpha: CGFloat(1.0))
        return color
    }()
    
    static let actionOrange : UIColor = {
        let red   = CGFloat(251 / 255.0)
        let green = CGFloat(158 / 255.0)
        let blue  = CGFloat(61 / 255.0)
        let color = UIColor(red: red, green: green, blue: blue, alpha: CGFloat(1.0))
        return color
    }()
    
    static let darkGrayText : UIColor = {
       return UIColor(white: 0.29, alpha: 1.0)
    }()
    
    static var random: UIColor {
        get {
            let randRed = Double.random(in: 0..<255)
            let randGrn = Double.random(in: 0..<255)
            let randBlu = Double.random(in: 0..<255)
            let red   = CGFloat(randRed / 255.0)
            let green = CGFloat(randGrn / 255.0)
            let blue  = CGFloat(randBlu / 255.0)
            return UIColor(red: red, green: green, blue: blue, alpha: CGFloat(1.0))
        }
    }
}

extension UIFont {
    
    static let primaryTextPrompt = {
        return UIFont.systemFont(ofSize: 40)
    }()
    
    static let title: UIFont = {
        return UIFont.systemFont(ofSize: 28)
    }()
    
    static let body: UIFont = {
        return UIFont.systemFont(ofSize: 17)
    }()
    
    static let tiny: UIFont = {
        return UIFont.systemFont(ofSize: 12)
    }()
    
    static let bodyBold: UIFont = {
       return UIFont.systemFont(ofSize: 17, weight: .bold)
    }()
}
