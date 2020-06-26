//
//  ReviewHistoryTableHeader.swift
//  Flash Cubes
//
//  Created by Jeffrey Thompson on 5/27/19.
//  Copyright © 2019 Jeffrey Thompson. All rights reserved.
//

import UIKit

class ReviewHistoryTableHeader: UIView {
    
    var dateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateStyle = .medium
        df.timeStyle = .none
        return df
    }()
    
    var dueDate: Date? {
        didSet {
            setNeedsLayout()
        }
    }
    
    var overDueNotification: UIImageView = {
        let img = UIImage(named: "imgPastDue")
        let imgView = UIImageView(image: img)
        imgView.translatesAutoresizingMaskIntoConstraints = false
        return imgView
    }()

    var titleLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.textColor = .white
        return label
    }()
    
    var dueDateLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.textColor = .white
        label.text = ""
        //label.backgroundColor = .green
        return label
    }()
    
    lazy var detailStack: UIView = {
        let view = UIView(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(overDueNotification)
        
        NSLayoutConstraint.activate([
            overDueNotification.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            overDueNotification.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            overDueNotification.widthAnchor.constraint(equalToConstant: 30),
            overDueNotification.heightAnchor.constraint(equalToConstant: 30)
            ])
        
        view.addSubview(dueDateLabel)
        
        let labelWidth = dueDateLabel.intrinsicContentSize.width
        let labelHeight = dueDateLabel.intrinsicContentSize.height
        
        NSLayoutConstraint.activate([
            dueDateLabel.leadingAnchor.constraint(equalTo: overDueNotification.trailingAnchor, constant: 10),
            dueDateLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            dueDateLabel.widthAnchor.constraint(equalToConstant: labelWidth),
            dueDateLabel.heightAnchor.constraint(equalToConstant: labelHeight)
            ])
        
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupViews(){
        self.backgroundColor = .themeColor
        addSubview(titleLabel)
        
        if let date = dueDate {

            NSLayoutConstraint.activate([
                titleLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor),
                titleLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor),
                titleLabel.topAnchor.constraint(equalTo: self.topAnchor),
                titleLabel.heightAnchor.constraint(equalToConstant: 40)
                ])
            
            dueDateLabel.text = dateFormatter.string(from: date)
            
            let detailStackWidth = dueDateLabel.intrinsicContentSize.width + 40
            
            self.addSubview(detailStack)
            
            NSLayoutConstraint.activate([
                detailStack.centerXAnchor.constraint(equalTo: titleLabel.centerXAnchor),
                detailStack.topAnchor.constraint(equalTo: titleLabel.bottomAnchor),
                detailStack.widthAnchor.constraint(equalToConstant: detailStackWidth),
                detailStack.heightAnchor.constraint(equalToConstant: 40)
                ])
            
            /*
            let stackView = UIStackView(frame: .zero)
            stackView.translatesAutoresizingMaskIntoConstraints = false
            stackView.axis = .horizontal
            stackView.distribution = .fillEqually
            
            let overDueContainer = UIView(frame: .zero)
            //overDueContainer.translatesAutoresizingMaskIntoConstraints = false
            
            overDueContainer.addSubview(overDueNotification)
            
            NSLayoutConstraint.activate([
                overDueNotification.trailingAnchor.constraint(equalTo: overDueContainer.trailingAnchor, constant: -10),
                overDueNotification.centerYAnchor.constraint(equalTo: overDueContainer.centerYAnchor),
                overDueNotification.widthAnchor.constraint(equalToConstant: 30),
                overDueNotification.heightAnchor.constraint(equalToConstant: 30)
                ])
            
            stackView.addArrangedSubview(overDueContainer)
            
            
            let dateLabel = UILabel(frame: .zero)
            dateLabel.translatesAutoresizingMaskIntoConstraints = false
            dateLabel.textColor = .white
            dateLabel.text = dateFormatter.string(from: date)
            
            stackView.addArrangedSubview(dateLabel)
            
            self.addSubview(stackView)
            
            NSLayoutConstraint.activate([
                stackView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
                stackView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
                stackView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
                stackView.heightAnchor.constraint(equalToConstant: 40)
                ])*/
            
        } else {
            self.constrainToExtents(view: titleLabel)
        }
    }
    
    func setOverDue(){
        self.subviews.forEach({$0.removeFromSuperview()})
        setupViews()
//        addSubview(overDueNotification)
//
//        NSLayoutConstraint.activate([
//            overDueNotification.leadingAnchor.constraint(equalTo: self.safeAreaLayoutGuide.leadingAnchor),
//            overDueNotification.centerYAnchor.constraint(equalTo: self.safeAreaLayoutGuide.centerYAnchor),
//            overDueNotification.widthAnchor.constraint(equalToConstant: 30),
//            overDueNotification.heightAnchor.constraint(equalToConstant: 30)
//            ])
    }
}
