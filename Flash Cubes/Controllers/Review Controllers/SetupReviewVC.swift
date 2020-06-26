//
//  SetupReviewVC.swift
//  Flash Cubes
//
//  Created by Jeffrey Thompson on 5/20/19.
//  Copyright © 2019 Jeffrey Thompson. All rights reserved.
//

import UIKit

protocol SetupReviewOptionsDelegate {
    func setupReviewOptions(choseReviewAmount: Int)
}

protocol SetupReviewPickerDelegate {
    func setupReviewPicker(picker: SetupReviewPickerCell, didSelectRowAt row: Int)
    func setupReviewPicker(picker: SetupReviewPickerCell, secondaryDidChangeState active: Bool)
}

class SetupReviewVC: UIViewController {
    
    struct SelectionTracker {
        
        var primaryQuestionSelection:   String? = nil
        var primaryAnswerSelection:     String? = nil
        var secondaryQuestionSelection: String? = nil
        var secondaryAnswerSelection:   String? = nil
        
        var secondaryQuestionIsActive: Bool = false
        var secondaryAnswerIsActive:   Bool = false
    }
    
    var maxReviewAmount = 7

    var deck: FlashCubeDeck!
    
    var backgroundImgView: UIImageView = {
        var img = UIImage(named: "imgBackgroundNoLogo")
        let imgView = UIImageView(image: img)
        imgView.contentMode = .scaleAspectFill
        imgView.translatesAutoresizingMaskIntoConstraints = false
        return imgView
    }()
    
    var labelQuestion: UILabel = {
        let label = UILabel(frame: .zero)
        label.font = UIFont.systemFont(ofSize: 50)
        label.textColor = .white
        label.textAlignment = .center
        label.text = "?"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var labelAnswer: UILabel = {
        let label = UILabel(frame: .zero)
        label.font = UIFont.systemFont(ofSize: 50)
        label.textColor = .white
        label.textAlignment = .center
        label.text = "!"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var settingsBarButton: UIBarButtonItem = {
        let iconSettingsImg = UIImage(named: "iconSettings")
        let btnSettings = UIButton(type: .custom)
        btnSettings.setImage(iconSettingsImg, for: .normal)
        btnSettings.addTarget(self, action: #selector(settingsOnPress), for: .touchUpInside)
        return UIBarButtonItem(customView: btnSettings)
    }()
    
    lazy var promptNames: [String] = {
        return deck.protoPrompts?.keys.sorted() ?? [String]()
    }()
    
    var selectionTracker = SelectionTracker()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        if let hints = UserDefaults.standard.object(forKey: "maxNewReview") as? Int {
            maxReviewAmount = hints
        }
        print("\(#function) Max review Amounts = \(maxReviewAmount)")
        
        setupNavBar()
        setupToolbar()
        setupViews()
    }
    
    func setupNavBar(){
        self.navigationItem.rightBarButtonItems = [settingsBarButton]
    }
    
    func setupToolbar(){
        var items = [UIBarButtonItem]()
        let reviewBtn = UIBarButtonItem(title: AppText.begin, style: .plain, target: self, action: #selector(onReviewPress))
        
        let attributes: [NSAttributedString.Key : Any] = [
            NSAttributedString.Key.font : UIFont.title,
            NSAttributedString.Key.foregroundColor : UIColor.white
        ]
        reviewBtn.setTitleTextAttributes(attributes, for: .normal)
        
        let separator = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        
        items.append(separator)
        items.append(reviewBtn)
        items.append(separator)
        
        self.navigationController?.isToolbarHidden = false
        self.toolbarItems = items
    }
    
    func setupViews(){
        
        view.addSubview(backgroundImgView)
        
        NSLayoutConstraint.activate([
            backgroundImgView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundImgView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            backgroundImgView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundImgView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
            ])
        
        let topContainer = UIView(frame: .zero)
        topContainer.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(topContainer)
        
        NSLayoutConstraint.activate([
            topContainer.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            topContainer.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            topContainer.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            topContainer.heightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.heightAnchor, multiplier: 0.5)
            ])
        
        let bottomContainer = UIView(frame: .zero)
        bottomContainer.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(bottomContainer)
        
        NSLayoutConstraint.activate([
            bottomContainer.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            bottomContainer.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            bottomContainer.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            bottomContainer.topAnchor.constraint(equalTo: topContainer.bottomAnchor)
            ])
        
        addChildViews(to: topContainer, presentationType: .question)
        addChildViews(to: bottomContainer, presentationType: .answer)
        
        selectionTracker.primaryQuestionSelection = self.promptNames[0]
        selectionTracker.primaryAnswerSelection = self.promptNames[1]
    }
    
    func addChildViews(to container: UIView, presentationType: SetupReviewPickerCell.PresentationType) {
        
        switch presentationType {
        case .question:
            container.addSubview(labelQuestion)
            
            NSLayoutConstraint.activate([
                labelQuestion.leadingAnchor.constraint(equalTo: container.leadingAnchor),
                labelQuestion.trailingAnchor.constraint(equalTo: container.trailingAnchor),
                labelQuestion.topAnchor.constraint(equalTo: container.topAnchor),
                labelQuestion.heightAnchor.constraint(equalTo: container.heightAnchor, multiplier: 0.2)
                ])
        case .answer:
            container.addSubview(labelAnswer)
            
            NSLayoutConstraint.activate([
                labelAnswer.leadingAnchor.constraint(equalTo: container.leadingAnchor),
                labelAnswer.trailingAnchor.constraint(equalTo: container.trailingAnchor),
                labelAnswer.topAnchor.constraint(equalTo: container.topAnchor),
                labelAnswer.heightAnchor.constraint(equalTo: container.heightAnchor, multiplier: 0.2)
                ])
        }
        
        let secondary = SetupReviewPickerCell(promptNames: self.promptNames, presentationType: presentationType, order: .secondary)
        secondary.delegate = self
        
        container.addSubview(secondary)
        
        NSLayoutConstraint.activate([
            secondary.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            secondary.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            secondary.heightAnchor.constraint(equalTo: container.heightAnchor, multiplier: 0.4),
            secondary.bottomAnchor.constraint(equalTo: container.bottomAnchor)
            ])
        
        let primary = SetupReviewPickerCell(promptNames: self.promptNames, presentationType: presentationType, order: .primary)
        primary.delegate = self
        
        container.addSubview(primary)
        
        NSLayoutConstraint.activate([
            primary.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            primary.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            primary.bottomAnchor.constraint(equalTo: secondary.topAnchor),
            primary.heightAnchor.constraint(equalTo: container.heightAnchor, multiplier: 0.4)
            ])
    }
    
    @objc func settingsOnPress(){
        let setupReviewSettingsVC = SetupReviewSettingsVC()
        setupReviewSettingsVC.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
        setupReviewSettingsVC.delegate = self
        setupReviewSettingsVC.currentReviewAmount = maxReviewAmount
        
        self.navigationController?.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
        self.navigationController?.present(setupReviewSettingsVC, animated: false, completion: nil)
    }
    
    @objc func onReviewPress(){
        
        if let question = selectionTracker.primaryQuestionSelection, let answer = selectionTracker.primaryAnswerSelection {
            if question == answer {
                AlertService.sendUserAlertMessage(title: AppText.notice, message: AppText.promptsCantBeSame, to: self)
                return
            }
        }

        if selectionTracker.secondaryQuestionIsActive {
            if let question = selectionTracker.secondaryQuestionSelection, let answer = selectionTracker.primaryAnswerSelection {
                if question == answer {
                    AlertService.sendUserAlertMessage(title: AppText.notice, message: AppText.promptsCantBeSame, to: self)
                    return
                }
            }
        }
        
        guard let questionKey = selectionTracker.primaryQuestionSelection else {return}
        guard let answerKey   = selectionTracker.primaryAnswerSelection   else {return}
        
        let reviewKey = ReviewRecordKey(fromPrompt: questionKey, toPrompt: answerKey)
        guard (deck.validCubes(forKey: reviewKey)?.count ?? 0) > 0 else {
            AlertService.sendUserAlertMessage(title: AppText.notice, message: AppText.noValidCubes, to: self)
            return
        }
        
        print("\(#function) setup should be okay with... ")
        print("\tprimary question:   \(selectionTracker.primaryQuestionSelection  ?? "no selection")")
        print("\tsecondary question: \(selectionTracker.secondaryQuestionSelection  ?? "no selection")")
        print("\tprimary answer:     \(selectionTracker.primaryAnswerSelection  ?? "no selection")")
        print("\tsecondary answer:   \(selectionTracker.secondaryAnswerSelection  ?? "no selection")")

        let secondaryQuestion = selectionTracker.secondaryQuestionIsActive ? selectionTracker.secondaryQuestionSelection : nil
        let secondaryAnswer = selectionTracker.secondaryAnswerIsActive ? selectionTracker.secondaryAnswerSelection : nil
        
        let reviewSession = ReviewSession(deck: deck, questionKey: questionKey, answerKey: answerKey, questionKeySecondary: secondaryQuestion, answerKeySecondary: secondaryAnswer, maxNewCubeAmount: maxReviewAmount)
        
        let reviewVC = ReviewVC()
        reviewVC.reviewSession = reviewSession
        self.navigationController?.pushViewController(reviewVC, animated: true)
    }
}

extension SetupReviewVC: SetupReviewOptionsDelegate {
    func setupReviewOptions(choseReviewAmount: Int) {
        self.maxReviewAmount = choseReviewAmount
        UserDefaults.standard.set(choseReviewAmount, forKey: "maxNewReview")
    }
}

extension SetupReviewVC: SetupReviewPickerDelegate {
    
    func setupReviewPicker(picker: SetupReviewPickerCell, didSelectRowAt row: Int) {
        //print("\(#function) \(String(describing: picker.presentationType)) \(String(describing: picker.order)) selectedRow: \(row) for \(self.promptNames[row])")
        
        //hacky as well.. too lazy to makes enums hashable for dictionary.
        switch (picker.presentationType, picker.order) {
        case (.question, .primary):
            selectionTracker.primaryQuestionSelection = self.promptNames[row]
        case (.question, .secondary):
            selectionTracker.secondaryQuestionSelection = self.promptNames[row]
        case (.answer, .primary):
            selectionTracker.primaryAnswerSelection = self.promptNames[row]
        case (.answer, .secondary):
            selectionTracker.secondaryAnswerSelection = self.promptNames[row]
        }
    }
    
    func setupReviewPicker(picker: SetupReviewPickerCell, secondaryDidChangeState active: Bool) {
        //print("\(#function) \(String(describing: picker.presentationType)) \(String(describing: picker.order)) changed isActive state to: \(active)")
        
        switch picker.presentationType {
        case .question:
            selectionTracker.secondaryQuestionIsActive = active
            
            if let selection = picker.secondaryRowSelection {
                selectionTracker.secondaryQuestionSelection = self.promptNames[selection]
            } else {
                selectionTracker.secondaryQuestionSelection = self.promptNames[0]
            }
            
        case .answer:
            selectionTracker.secondaryAnswerIsActive = active
            
            if let selection = picker.secondaryRowSelection {
                selectionTracker.secondaryAnswerSelection = self.promptNames[selection]
            } else {
                selectionTracker.secondaryAnswerSelection = self.promptNames[0]
            }
        }
    }
}
