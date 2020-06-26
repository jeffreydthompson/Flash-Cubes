//
//  ReviewVC.swift
//  Flash Cubes
//
//  Created by Jeffrey Thompson on 5/23/19.
//  Copyright © 2019 Jeffrey Thompson. All rights reserved.
//

import UIKit

protocol ReviewDialogDelegate {
    func reviewDialog(didQuit: Bool)
    func reviewDialog(userOpted quit: Bool)
}

protocol ReviewSettingsDelegate {
    func reviewSettings(didChange audioSpeed: AudioPlaybackSpeed)
}

protocol ReviewActionDelegate {
    func commit(forCube key: String, retention: Double)
}

protocol ReviewSessionDelegate {
    func reviewSession(overDueArrayFinished: Bool)
    func reviewSession(newArrayFinished: Bool)
    func reviewSession(learnedFiveNewComplete: Bool, completion: @escaping (Bool) -> Void)
}

class ReviewVC: UIViewController, ReviewSessionDelegate, ReviewActionDelegate, ReviewSettingsDelegate, ReviewDialogDelegate {
    
    enum ReviewActionState {
        case question
        case answer
        case feedback
    }
    
    var reviewSession: ReviewSession! {
        didSet {
            self.reviewSession.delegate = self
        }
    }
    
    var reviewActionState: ReviewActionState = .question {
        didSet {
            actionContainer.actionState = self.reviewActionState
            switch self.reviewActionState {
            case .question:
                self.titleContainer.stateIndicator.text = "?"
                self.titleContainer.primaryLabel.text = reviewSession.titles.question
                self.titleContainer.secondaryLabel.text = reviewSession.titles.questionSecondary
                self.titleContainer.guessForLabel.text = "\(AppText.guessFor) \(reviewSession.titles.answer)"
            case .answer:
                self.titleContainer.stateIndicator.text = "!"
                self.titleContainer.primaryLabel.text = reviewSession.titles.answer
                self.titleContainer.secondaryLabel.text = reviewSession.titles.answerSecondary
                self.titleContainer.guessForLabel.text = ""
            case .feedback:
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.7) {
                    self.actionContainer.swapNew {
                        self.reviewActionState = .question
                        self.layoutOnStateUpdate()
                    }
                }
            }
        }
    }
    
    var isPortrait: Bool {
        get {
            return self.view.frame.height > self.view.frame.width
        }
    }
    
    var audioPlaybackSpeed: AudioPlaybackSpeed = .normal {
        didSet {
            actionContainer.audioPlaybackSpeed = self.audioPlaybackSpeed
        }
    }
    
    var backgroundImgView: UIImageView = {
        var img = UIImage(named: "imgBackgroundNoLogo")
        let imgView = UIImageView(image: img)
        imgView.contentMode = .scaleAspectFill
        imgView.translatesAutoresizingMaskIntoConstraints = false
        return imgView
    }()
    
    var titleContainer: ReviewTitleContainer = {
        let view = ReviewTitleContainer(frame: .zero)
        return view
    }()
    
    var actionContainer: ReviewActionContainer = {
        let view = ReviewActionContainer(frame: .zero)
        return view
    }()
    
    var cubeContainer: UIView = {
        let view = UIView(frame: .zero)
        return view
    }()
    
    lazy var settingsBarButton: UIBarButtonItem = {
        let iconSettingsImg = UIImage(named: "iconSettings")
        let btnSettings = UIButton(type: .custom)
        btnSettings.setImage(iconSettingsImg, for: .normal)
        btnSettings.addTarget(self, action: #selector(settingsOnPress), for: .touchUpInside)
        return UIBarButtonItem(customView: btnSettings)
    }()
    
    lazy var showHintBarButton: UIBarButtonItem = {
        var iconHintImg = UIImage(named: "iconHintOutline")
        if self.hintsEnabled {
            iconHintImg = UIImage(named: "iconHintSolid")
        }
        let btnHint = UIButton(type: .custom)
        btnHint.setImage(iconHintImg, for: .normal)
        btnHint.addTarget(self, action: #selector(hintOnPress), for: .touchUpInside)
        return UIBarButtonItem(customView: btnHint)
    }()
    
    lazy var quitReviewBackButton: UIBarButtonItem = {
        let btn = UIButton(type: .custom)
        btn.setTitle(AppText.quit, for: .normal)
        btn.addTarget(self, action: #selector(quitOnPress), for: .touchUpInside)
        return UIBarButtonItem(customView: btn)
    }()
    
    var hintsEnabled = true {
        didSet {
            
            UserDefaults.standard.set(hintsEnabled, forKey: "hintsEnabled")
            
            DispatchQueue.main.async {
                if self.hintsEnabled {
                    let iconHintImg = UIImage(named: "iconHintSolid")
                    let btnHint = UIButton(type: .custom)
                    btnHint.setImage(iconHintImg, for: .normal)
                    btnHint.addTarget(self, action: #selector(self.hintOnPress), for: .touchUpInside)
                    let barButton = UIBarButtonItem(customView: btnHint)
                    let barBtnItems = [barButton,self.settingsBarButton]
                    self.navigationItem.rightBarButtonItems = barBtnItems
                } else {
                    let iconHintImg = UIImage(named: "iconHintOutline")
                    let btnHint = UIButton(type: .custom)
                    btnHint.setImage(iconHintImg, for: .normal)
                    btnHint.addTarget(self, action: #selector(self.hintOnPress), for: .touchUpInside)
                    let barButton = UIBarButtonItem(customView: btnHint)
                    let barBtnItems = [barButton,self.settingsBarButton]
                    self.navigationItem.rightBarButtonItems = barBtnItems
                }
                
                self.actionContainer.hintsEnabled = self.hintsEnabled
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        if let hints = UserDefaults.standard.object(forKey: "hintsEnabled") as? Bool {
            hintsEnabled = hints
        }
        
        setupNavBar()
        setupViews()
        
        /*if let prompts = reviewSession.getNext() {
         actionContainer.prompts = prompts
         } else {
         fatalError("Error: NO PROMPTS FOR YOU!")
         }*/
    }
    
    func setupNavBar(){
        
        self.navigationItem.leftBarButtonItems = [quitReviewBackButton]
        
        let barBtnItems = [showHintBarButton,settingsBarButton]
        
        self.navigationItem.rightBarButtonItems = barBtnItems
    }
    
    func setupViews(){
        view.addSubview(backgroundImgView)
        
        NSLayoutConstraint.activate([
            backgroundImgView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundImgView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            backgroundImgView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundImgView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
            ])
        
        view.addSubview(titleContainer)
        
        titleContainer.backgroundColor = .clear
        
        titleContainer.isPortrait = self.isPortrait
        titleContainer.primaryLabel.text = reviewSession.titles.question
        titleContainer.secondaryLabel.text = reviewSession.titles.questionSecondary
        titleContainer.guessForLabel.text = "\(AppText.guessFor) \(reviewSession.titles.answer)"
        
        NSLayoutConstraint.activate([
            titleContainer.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            titleContainer.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            titleContainer.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            titleContainer.heightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.heightAnchor, multiplier: 0.25)
            ])
        
        view.addSubview(actionContainer)
        
        actionContainer.backgroundColor = .clear
        actionContainer.delegate = self
        actionContainer.audioPlaybackSpeed = self.audioPlaybackSpeed
        
        actionContainer.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTap)))
        let rightSwipeGR = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipeRight))
        rightSwipeGR.direction = .right
        actionContainer.addGestureRecognizer(rightSwipeGR)
        let leftSwipeGR = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipeLeft))
        leftSwipeGR.direction = .left
        actionContainer.addGestureRecognizer(leftSwipeGR)
        
        //actionContainer.prompts = reviewSession.getNext()
        do {
            try actionContainer.prompts = reviewSession.getNext()
        } catch let error {
            handle(error: error)
        }
        
        actionContainer.actionState = self.reviewActionState
        actionContainer.hintsEnabled = self.hintsEnabled
        
        NSLayoutConstraint.activate([
            actionContainer.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            actionContainer.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            actionContainer.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            actionContainer.topAnchor.constraint(equalTo: titleContainer.bottomAnchor)
            ])
        
        actionContainer.setupBaseView()
        actionContainer.setQuestions()
    }
    
    func layoutOnStateUpdate(){
        actionContainer.setupBaseView()
        
        switch reviewActionState {
        case .question:
            do {
                try actionContainer.prompts = reviewSession.getNext()
                actionContainer.setQuestions()
            } catch let error {
                handle(error: error)
            }
            //            if let nextReviewPrompts = reviewSession.getNext() {
            //                actionContainer.prompts = nextReviewPrompts
            //                actionContainer.setQuestions()
            //            }
            break
        case .answer:
            break
        case .feedback:
            break
        }
    }
    
    @objc func quitOnPress(){
        let reviewDialogVC = ReviewDialogVC()
        reviewDialogVC.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
        reviewDialogVC.dialogType = .quitPressed
        reviewDialogVC.delegate = self
        self.navigationController?.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
        self.navigationController?.present(reviewDialogVC, animated: true, completion: nil)
    }
    
    @objc func settingsOnPress(){
        
        let reviewSettingsVC = ReviewSettingsVC()
        reviewSettingsVC.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
        reviewSettingsVC.delegate = self
        reviewSettingsVC.currentAudioSpeed = self.audioPlaybackSpeed
        self.navigationController?.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
        self.navigationController?.present(reviewSettingsVC, animated: false, completion: nil)
        
    }
    
    @objc func hintOnPress(){
        self.hintsEnabled = !self.hintsEnabled
    }
    
    @objc func handleSwipeRight(){
        guard reviewActionState == .answer else { return }
        
        actionContainer.handleSwipeRight {
            //self.reviewActionState = .feedback
        }
    }
    
    @objc func handleSwipeLeft(){
        guard reviewActionState == .answer else { return }
        
        actionContainer.handleSwipeLeft {
            //self.reviewActionState = .feedback
        }
    }
    
    @objc func handleTap(){
        
        guard reviewActionState == .question else { return }
        
        actionContainer.handleTap {
            self.reviewActionState = .answer
            // feed answer prompts
        }
    }
    
    func reviewDialog(userOpted quit: Bool) {
        if quit {
            // pop back to deckTableView
            self.navigationController?.viewControllers.forEach({
                if $0.isKind(of: DeckTblVC.self) {
                    self.navigationController?.popToViewController($0, animated: true)
                }
            })
        }
    }
    
    func reviewDialog(didQuit: Bool) {
        if didQuit {
            // pop back to deckTableView
            self.navigationController?.viewControllers.forEach({
                if $0.isKind(of: DeckTblVC.self) {
                    self.navigationController?.popToViewController($0, animated: true)
                }
            })
        } else {
            self.reviewActionState = .feedback
        }
    }
    
    func reviewSettings(didChange audioSpeed: AudioPlaybackSpeed) {
        self.audioPlaybackSpeed = audioSpeed
    }
    
    func reviewSession(overDueArrayFinished: Bool) {
        
        let reviewDialogVC = ReviewDialogVC()
        reviewDialogVC.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
        reviewDialogVC.dialogType = .overdueFinished
        reviewDialogVC.delegate = self
        self.navigationController?.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
        self.navigationController?.present(reviewDialogVC, animated: true, completion: nil)
        
    }
    
    func reviewSession(newArrayFinished: Bool) {
        
        let reviewDialogVC = ReviewDialogVC()
        reviewDialogVC.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
        reviewDialogVC.dialogType = .newFinished
        reviewDialogVC.delegate = self
        self.navigationController?.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
        self.navigationController?.present(reviewDialogVC, animated: true, completion: nil)
        
    }
    
    func reviewSession(learnedFiveNewComplete: Bool, completion: @escaping (Bool) -> Void){
        
        AlertService.sendUserDialogMessage(title: AppText.greatjob, message: AppText.learnedNew, to: self) {
            completion(true)
        }
        
    }
    
    func commit(forCube key: String, retention: Double) {
        do {
            try reviewSession.commit(for: key, retention: retention) { (overDueNotificationNeeded, newNotificationNeeded) in
                
                if overDueNotificationNeeded {
                    let reviewDialogVC = ReviewDialogVC()
                    reviewDialogVC.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
                    reviewDialogVC.dialogType = .overdueFinished
                    reviewDialogVC.delegate = self
                    self.navigationController?.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
                    self.navigationController?.present(reviewDialogVC, animated: true, completion: nil)
                }
                
                if newNotificationNeeded {
                    let reviewDialogVC = ReviewDialogVC()
                    reviewDialogVC.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
                    reviewDialogVC.dialogType = .newFinished
                    reviewDialogVC.delegate = self
                    self.navigationController?.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
                    self.navigationController?.present(reviewDialogVC, animated: true, completion: nil)
                }
                
                if !overDueNotificationNeeded && !newNotificationNeeded {
                    self.reviewActionState = .feedback
                }
            }
            
        } catch let error {
            handle(error: error)
        }
    }
    
    func handle(error: Error){
        
        self.dismiss(animated: false) {
            AlertService.sendUserAlertMessage(title: AppText.error, message: error.localizedDescription, to: self)
        }
    }
}

class ReviewTitleContainer: UIView {
    
    var isPortrait: Bool = true
    
    var stateIndicator: UILabel = {
        let label = UILabel(frame: .zero)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 60)
        label.textColor = .white
        label.textAlignment = .center
        label.numberOfLines = 1
        label.text = "?"
        return label
    }()
    
    var primaryLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .title
        label.textColor = .white
        label.textAlignment = .center
        label.numberOfLines = 3
        return label
    }()
    
    var secondaryLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .body
        label.textColor = .white
        label.textAlignment = .center
        label.numberOfLines = 3
        return label
    }()
    
    var guessForLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .body
        label.textColor = .white
        label.textAlignment = .center
        label.numberOfLines = 1
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.translatesAutoresizingMaskIntoConstraints = false
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupViews(){
        
        addSubview(stateIndicator)
        
        let largeMultiplier: CGFloat = (isPortrait && !currentDeviceIsiPad) ? 0.34 : 0.25
        let smallMultiplier: CGFloat = (isPortrait && !currentDeviceIsiPad) ? 0.19 : 0.25
        
        if (!isPortrait && !currentDeviceIsiPad) {
            stateIndicator.font = .body
            primaryLabel.font = .body
        } else {
            stateIndicator.font = UIFont.systemFont(ofSize: 60)
            primaryLabel.font = .title
        }
        
        NSLayoutConstraint.activate([
            stateIndicator.leadingAnchor.constraint(equalTo: self.safeAreaLayoutGuide.leadingAnchor),
            stateIndicator.trailingAnchor.constraint(equalTo: self.safeAreaLayoutGuide.trailingAnchor),
            stateIndicator.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor),
            stateIndicator.heightAnchor.constraint(equalTo: self.safeAreaLayoutGuide.heightAnchor, multiplier: largeMultiplier)
            ])
        
        addSubview(primaryLabel)
        
        NSLayoutConstraint.activate([
            primaryLabel.leadingAnchor.constraint(equalTo: self.safeAreaLayoutGuide.leadingAnchor),
            primaryLabel.trailingAnchor.constraint(equalTo: self.safeAreaLayoutGuide.trailingAnchor),
            primaryLabel.topAnchor.constraint(equalTo: stateIndicator.bottomAnchor),
            primaryLabel.heightAnchor.constraint(equalTo: self.safeAreaLayoutGuide.heightAnchor, multiplier: largeMultiplier)
            ])
        
        addSubview(secondaryLabel)
        
        NSLayoutConstraint.activate([
            secondaryLabel.leadingAnchor.constraint(equalTo: self.safeAreaLayoutGuide.leadingAnchor),
            secondaryLabel.trailingAnchor.constraint(equalTo: self.safeAreaLayoutGuide.trailingAnchor),
            secondaryLabel.topAnchor.constraint(equalTo: primaryLabel.bottomAnchor),
            secondaryLabel.heightAnchor.constraint(equalTo: self.safeAreaLayoutGuide.heightAnchor, multiplier: smallMultiplier)
            ])
        
        addSubview(guessForLabel)
        
        NSLayoutConstraint.activate([
            guessForLabel.leadingAnchor.constraint(equalTo: self.safeAreaLayoutGuide.leadingAnchor),
            guessForLabel.trailingAnchor.constraint(equalTo: self.safeAreaLayoutGuide.trailingAnchor),
            guessForLabel.topAnchor.constraint(equalTo: secondaryLabel.bottomAnchor),
            guessForLabel.bottomAnchor.constraint(equalTo: self.safeAreaLayoutGuide.bottomAnchor)
            ])
        

    }
}

class ReviewActionContainer: UIView {
    
    enum PromptOrder {
        case primary
        case secondary
    }
    
    var audioPlaybackSpeed: AudioPlaybackSpeed = .normal {
        didSet {
//            if self.audioPromptView != nil {
//                self.audioPromptView?.playbackSpeed = self.audioPlaybackSpeed
//            }
            self.subviews.forEach({ view in
                if let audioView = view as? AudioPromptView {
                    audioView.playbackSpeed = self.audioPlaybackSpeed
                }
            })
        }
    }
    
    private var isiPad: Bool {
        get {
            return UIDevice.current.model == "iPad"
        }
    }
    
    var actionState: ReviewVC.ReviewActionState = .question
    
    var cubeImageView = CubeImageView(frame: .zero)
    
    var delegate: ReviewActionDelegate!
    
    //var imagePromptView: UIImageView?
    //var audioPromptView: AudioPromptView?
    //var textPromptView: UILabel?
    
    var progressbarView: ProgressIndicator?
    
    //Constraints used for swapView animation
    var underScreenAnchor: NSLayoutConstraint?
    var overScreenAnchor: NSLayoutConstraint?
    var cubeCenterYAnchor: NSLayoutConstraint?
    var constrainingAnchor: NSLayoutDimension { get {return self.frame.width < self.frame.height ? self.widthAnchor : self.heightAnchor}}
    
    var safetyBox: UIView = {
        let view = UIView(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    var hintsEnabled = false {
        didSet {
            if !hintsEnabled {
                hintTapImgView.removeFromSuperview()
                hintSwipeLeftImgView.removeFromSuperview()
                hintSwipeRightImgView.removeFromSuperview()
            } else {
                switch actionState {
                case .question:
                    DispatchQueue.main.async {
                        self.setTapHint()
                    }
                case .answer:
                    DispatchQueue.main.async {
                        self.setSwipeHints()
                    }
                default:
                    break
                }
            }
        }
    }
    
    var hintTapImgView: UIImageView = {
        let img = UIImage(named: "imgTap")
        let imgView = UIImageView(image: img)
        imgView.translatesAutoresizingMaskIntoConstraints = false
        return imgView
    }()
    
    var hintSwipeRightImgView: UIImageView = {
        let img = UIImage(named: "imgSwipeRight")
        let imgView = UIImageView(image: img)
        imgView.translatesAutoresizingMaskIntoConstraints = false
        return imgView
    }()
    
    var hintSwipeLeftImgView: UIImageView = {
        let img = UIImage(named: "imgSwipeLeft")
        let imgView = UIImageView(image: img)
        imgView.translatesAutoresizingMaskIntoConstraints = false
        return imgView
    }()
    
    var prompts: (cubeKey: String, question: CubePrompt, questionSecondary: CubePrompt?, answer: CubePrompt, answerSecondary: CubePrompt?, progress: Double)? {
        didSet {
            
            if let progress = self.prompts?.progress {
                self.progress = progress
            }
            
        }
    }
    
    var progress: Double = 0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        translatesAutoresizingMaskIntoConstraints = false
        clipsToBounds = true
        //setupBaseView()
    }
    
    override func didMoveToSuperview() {
        // added due to layout bug.  cubeImageView image was too big on initial layout.
        setupBaseView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func swapNew(completion: @escaping () -> Void){
        
        progressbarView?.removeFromSuperview()
        
        UIView.animate(withDuration: 0.3, animations: {
            
            self.cubeCenterYAnchor?.isActive = false
            self.overScreenAnchor?.isActive = true
            self.layoutIfNeeded()
            
        }) { ( _) in
            
            self.overScreenAnchor?.isActive = false
            self.underScreenAnchor?.isActive = true
            
            self.layoutIfNeeded()
            
            UIView.animate(withDuration: 0.3, animations: {
                self.cubeImageView.image = self.cubeImageView.neutralImg
                self.underScreenAnchor?.isActive = false
                self.cubeCenterYAnchor?.isActive = true
                
                self.layoutIfNeeded()
            }, completion: { (_) in
                completion()
            })
        }
    }
    
    func handleTap(completion: @escaping () -> Void){
        setupBaseView()
        cubeImageView.animateTap {
            completion()
            self.setAnswers()
        }
    }
    
    func handleSwipeRight(completion: @escaping () -> Void){
        
        setupBaseView()
        
        self.progress += 0.12
        if self.progress > 1.0 {
            self.progress = 1
        }
        
        if let prompts = self.prompts {
            delegate.commit(forCube: prompts.cubeKey, retention: self.progress)
        }
        
        self.setProgressBar()
        
        cubeImageView.animateSwipeRight {
            completion()
        }
    }
    
    func handleSwipeLeft(completion: @escaping () -> Void){
        
        setupBaseView()
        
        self.progress -= 0.5
        if self.progress < 0 {
            self.progress = 0
        }
        
        if let prompts = self.prompts {
            delegate.commit(forCube: prompts.cubeKey, retention: self.progress)
        }
        
        self.setProgressBar()
        
        cubeImageView.animateSwipeLeft {
            completion()
        }
    }
    
    func setupBaseView(){
        subviews.forEach({ $0.removeFromSuperview() })
        
        addSubview(safetyBox)
        
        NSLayoutConstraint.activate([
            safetyBox.centerXAnchor.constraint(equalTo: centerXAnchor),
            safetyBox.centerYAnchor.constraint(equalTo: centerYAnchor),
            safetyBox.widthAnchor.constraint(equalTo: constrainingAnchor, multiplier: 0.69),
            safetyBox.heightAnchor.constraint(equalTo: constrainingAnchor, multiplier: 0.69)
            ])
        
        addSubview(cubeImageView)
        
        NSLayoutConstraint.activate([
            cubeImageView.widthAnchor.constraint(equalTo: constrainingAnchor),
            cubeImageView.heightAnchor.constraint(equalTo: constrainingAnchor),
            cubeImageView.centerXAnchor.constraint(equalTo: self.centerXAnchor)
            ])
        
        underScreenAnchor = cubeImageView.topAnchor.constraint(equalTo: self.bottomAnchor, constant: 50)
        overScreenAnchor = cubeImageView.bottomAnchor.constraint(equalTo: self.topAnchor, constant: -50)
        
        cubeCenterYAnchor = cubeImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor)
        cubeCenterYAnchor?.isActive = true
        
        self.layoutIfNeeded()
    }
    
    func setQuestions() {
        guard let prompts = self.prompts else {return}
        
        let hasSecondary = prompts.questionSecondary != nil
//        if let type = prompts.questionSecondary?.type {
//            if type == .audio {hasSecondary = false}
//        }
        
        switch prompts.question {
        case .text(let str):
            self.setText(text: str!, order: .primary, hasSecondary: hasSecondary)
        case .audio(let data):
            self.setAudio(data: data!, order: .primary, hasSecondary: hasSecondary)
        case .image(let img):
            self.setImage(img: img!, order: .primary, hasSecondary: hasSecondary)
        }
        
        if let secondary = prompts.questionSecondary {
            switch secondary {
            case .text(let str):
                self.setText(text: str!, order: .secondary, hasSecondary: hasSecondary)
            case .audio(let data):
                self.setAudio(data: data!, order: .secondary, hasSecondary: hasSecondary)
            case .image(let img):
                self.setImage(img: img!, order: .secondary, hasSecondary: hasSecondary)
            }
        }
        
        if hintsEnabled {
            setTapHint()
        }
    }
    
    func setAnswers(){
        guard let prompts = self.prompts else {return}
        
        let hasSecondary = prompts.answerSecondary != nil
        
        switch prompts.answer {
        case .text(let str):
            self.setText(text: str!, order: .primary, hasSecondary: hasSecondary)
        case .audio(let data):
            self.setAudio(data: data!, order: .primary, hasSecondary: hasSecondary)
        case .image(let img):
            self.setImage(img: img!, order: .primary, hasSecondary: hasSecondary)
        }
        
        if let secondary = prompts.answerSecondary {
            switch secondary {
            case .text(let str):
                self.setText(text: str!, order: .secondary, hasSecondary: hasSecondary)
            case .audio(let data):
                self.setAudio(data: data!, order: .secondary, hasSecondary: hasSecondary)
            case .image(let img):
                self.setImage(img: img!, order: .secondary, hasSecondary: hasSecondary)
            }
        }
        
        if hintsEnabled {
            setSwipeHints()
        }
        
        setProgressBar()
    }
    
    func setProgressBar() {
        progressbarView = ProgressIndicator(frame: .zero)
        
        self.addSubview(progressbarView!)
        progressbarView?.progress = Float(self.progress)
        
        NSLayoutConstraint.activate([
            progressbarView!.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 15),
            progressbarView!.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -15),
            progressbarView!.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -5),
            progressbarView!.heightAnchor.constraint(equalToConstant: 3)
            ])
    }
    
    func setTapHint() {
        addSubview(hintTapImgView)
        
        let offset: CGFloat = isiPad ? 0 : 25
        
        NSLayoutConstraint.activate([
            hintTapImgView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -offset),
            hintTapImgView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            hintTapImgView.widthAnchor.constraint(equalToConstant: 60),
            hintTapImgView.heightAnchor.constraint(equalToConstant: 60)
            ])
    }
    
    private func setSwipeHints() {
        addSubview(hintSwipeLeftImgView)
        
        NSLayoutConstraint.activate([
            hintSwipeLeftImgView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -25),
            hintSwipeLeftImgView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 25),
            hintSwipeLeftImgView.widthAnchor.constraint(equalToConstant: 60),
            hintSwipeLeftImgView.heightAnchor.constraint(equalToConstant: 60)
            ])
        
        addSubview(hintSwipeRightImgView)
        
        NSLayoutConstraint.activate([
            hintSwipeRightImgView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -25),
            hintSwipeRightImgView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -25),
            hintSwipeRightImgView.widthAnchor.constraint(equalToConstant: 60),
            hintSwipeRightImgView.heightAnchor.constraint(equalToConstant: 60)
            ])
    }
    
    private func setText(text: String, order: PromptOrder, hasSecondary: Bool) {
        
        let label = UILabel(frame: .zero)
        label.translatesAutoresizingMaskIntoConstraints = false
        //label.backgroundColor = .green
        
        switch order {
        case .primary:
            label.font = .primaryTextPrompt
            label.textColor = .themeColor
        case .secondary:
            label.font = .title
            label.textColor = .gray
        }
        
        label.numberOfLines = 3
        label.text = text
        label.textAlignment = .center
        
        addSubview(label)
        
        switch order {
        case .primary:
            if hasSecondary {
                NSLayoutConstraint.activate([
                    label.leadingAnchor.constraint(equalTo: safetyBox.leadingAnchor, constant: 15),
                    label.trailingAnchor.constraint(equalTo: safetyBox.trailingAnchor, constant: -15),
                    label.topAnchor.constraint(equalTo: safetyBox.topAnchor),
                    label.heightAnchor.constraint(equalTo: safetyBox.heightAnchor, multiplier: 0.45)
                    ])
            } else {
                NSLayoutConstraint.activate([
                    label.widthAnchor.constraint(equalTo: constrainingAnchor, multiplier: 0.7),
                    label.heightAnchor.constraint(equalTo: constrainingAnchor, multiplier: 0.7),
                    label.centerXAnchor.constraint(equalTo: self.centerXAnchor),
                    label.centerYAnchor.constraint(equalTo: self.centerYAnchor)
                    ])
            }
        case .secondary:
            NSLayoutConstraint.activate([
                label.leadingAnchor.constraint(equalTo: safetyBox.leadingAnchor, constant: 15),
                label.trailingAnchor.constraint(equalTo: safetyBox.trailingAnchor, constant: -15),
                label.bottomAnchor.constraint(equalTo: safetyBox.bottomAnchor),
                label.heightAnchor.constraint(equalTo: safetyBox.heightAnchor, multiplier: 0.45)
                ])
        }
        
    }
    
    func setAudio(data: Data, order: PromptOrder, hasSecondary: Bool) {
        
        let audioPromptView = AudioPromptView(frame: .zero)
        audioPromptView.playbackSpeed = self.audioPlaybackSpeed
        
        //audioPromptView?.backgroundColor = .purple
        
        self.addSubview(audioPromptView)
        
        let offset: CGFloat = isiPad ? 30 : 15
        
        switch order {
        case .primary:
            audioPromptView.audioData = data
            if hasSecondary {
                NSLayoutConstraint.activate([
                    audioPromptView.centerXAnchor.constraint(equalTo: safetyBox.centerXAnchor),
                    audioPromptView.topAnchor.constraint(equalTo: safetyBox.topAnchor, constant: offset),
                    audioPromptView.heightAnchor.constraint(equalTo: safetyBox.widthAnchor, multiplier: 0.40),
                    audioPromptView.widthAnchor.constraint(equalTo: safetyBox.widthAnchor, multiplier: 0.40)
                    ])
            } else {
                NSLayoutConstraint.activate([
                    audioPromptView.widthAnchor.constraint(equalTo: constrainingAnchor, multiplier: 0.5),
                    audioPromptView.heightAnchor.constraint(equalTo: constrainingAnchor, multiplier: 0.5),
                    audioPromptView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
                    audioPromptView.centerYAnchor.constraint(equalTo: self.centerYAnchor)
                    ])
            }
        case .secondary:
            audioPromptView.isSecondary = true
            audioPromptView.audioData = data
            
            NSLayoutConstraint.activate([
                audioPromptView.centerXAnchor.constraint(equalTo: safetyBox.centerXAnchor),
                audioPromptView.bottomAnchor.constraint(equalTo: safetyBox.bottomAnchor, constant: -offset),
                audioPromptView.heightAnchor.constraint(equalTo: safetyBox.widthAnchor, multiplier: 0.35),
                audioPromptView.widthAnchor.constraint(equalTo: safetyBox.widthAnchor, multiplier: 0.35)
                ])
        }
    }
    
    func setImage(img: UIImage, order: PromptOrder, hasSecondary: Bool) {
        
        let imgView = UIImageView(image: img)
        imgView.translatesAutoresizingMaskIntoConstraints = false
        imgView.contentMode = .scaleAspectFit
        //imgView.backgroundColor = .orange
        
        addSubview(imgView)
        
        let offset: CGFloat = isiPad ? 30 : 15
        
        switch order {
        case .primary:
            if hasSecondary {
                NSLayoutConstraint.activate([
                    imgView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
                    imgView.topAnchor.constraint(equalTo: safetyBox.topAnchor, constant: offset),
                    imgView.heightAnchor.constraint(equalTo: safetyBox.heightAnchor, multiplier: 0.4),
                    imgView.widthAnchor.constraint(equalTo: safetyBox.heightAnchor, multiplier: 0.4)
                    ])
            } else {
//                NSLayoutConstraint.activate([
//                    imgView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 16),
//                    imgView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -16),
//                    imgView.topAnchor.constraint(equalTo: self.bottomAnchor, constant: -16),
//                    imgView.heightAnchor.constraint(equalTo: self.heightAnchor, multiplier: 0.45)
//                    ])
                NSLayoutConstraint.activate([
                    imgView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
                    imgView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
                    imgView.widthAnchor.constraint(equalTo: constrainingAnchor, multiplier: 0.5),
                    imgView.heightAnchor.constraint(equalTo: constrainingAnchor, multiplier: 0.5)
                    ])
            }
        case .secondary:
            NSLayoutConstraint.activate([
                imgView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
                imgView.bottomAnchor.constraint(equalTo: safetyBox.bottomAnchor, constant: -offset),
                imgView.widthAnchor.constraint(equalTo: safetyBox.heightAnchor, multiplier: 0.35),
                imgView.heightAnchor.constraint(equalTo: safetyBox.heightAnchor, multiplier: 0.35)
                ])
        }
    }
}

class AudioPromptView: UIView {
    
    var isSecondary = false {
        didSet {
            if self.isSecondary {
                //audioImg.image = nil
                self.alpha = 0.5
            }
        }
    }
    
    var playbackSpeed: AudioPlaybackSpeed = .normal {
        didSet {
            replayBtn.playbackSpeed = self.playbackSpeed
        }
    }
    
    var audioData: Data? = nil {
        didSet {
            replayBtn.audioData = self.audioData
            if isSecondary {return}
            if let data = self.audioData {
                AudioManager.shared.playAudio(fromData: data, atSpeed: self.playbackSpeed, completion: {( _, error) in
                    if let error = error {
                        print("\(#function) \(error)")
                    }
                })
            }
        }
    }
    
    var audioImg: UIImageView = {
        let img = UIImage(named: "imgAudioLarge")
        let imgView = UIImageView(image: img)
        imgView.translatesAutoresizingMaskIntoConstraints = false
        return imgView
    }()
    
    var replayBtn: AudioButton = {
        let btn = AudioButton(audio: nil)
        btn.setAsReplay()
        return btn
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.translatesAutoresizingMaskIntoConstraints = false
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupViews(){
        
        backgroundColor = .clear
        addSubview(audioImg)
        constrainToExtents(view: audioImg)
        
        addSubview(replayBtn)
        NSLayoutConstraint.activate([
            replayBtn.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 0.25),
            replayBtn.heightAnchor.constraint(equalTo: self.heightAnchor, multiplier: 0.25),
            replayBtn.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            replayBtn.bottomAnchor.constraint(equalTo: self.bottomAnchor)
            ])
    }
}

class CubeImageView: UIImageView {
    
    var neutralImg: UIImage = {
        return UIImage(named: "imgCubeRotateDown1")!
    }()
    
    var onTapAnimationImages: [UIImage] = {
        var imgs = [UIImage]()
        for index in 1...30 {
            imgs.append(UIImage(named: "imgCubeRotateDown\(index)")!)
        }
        return imgs
    }()
    
    var swipeRightAnimationImages: [UIImage] = {
        var imgs = [UIImage]()
        for index in 1...30 {
            imgs.append(UIImage(named: "imgCubeRotateCheck\(index)")!)//"cubeSpinRight_\(index)")!)//
        }
        return imgs
    }()
    
    var swipeLeftAnimationImages: [UIImage] = {
        var imgs = [UIImage]()
        for index in 1...30 {
            imgs.append(UIImage(named: "imgCubeRotateX\(index)")!)//"rotateLeft\(index)-1")!)
        }
        return imgs
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.image = neutralImg
        self.translatesAutoresizingMaskIntoConstraints = false
        self.contentMode = .scaleAspectFit
        //self.backgroundColor = .orange
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func animateTap(completion: @escaping () -> Void){
        self.animationImages = onTapAnimationImages
        self.animationDuration = 0.3
        self.animationRepeatCount = 1
        self.startAnimating()
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.3) {
            completion()
        }
    }
    
    func animateSwipeRight(completion: @escaping () -> Void){
        self.image = UIImage(named: "imgCubeRotateCheck\(30)")
        self.animationImages = swipeRightAnimationImages
        self.animationDuration = 0.3
        self.animationRepeatCount = 1
        self.startAnimating()
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.3) {
            completion()
        }
    }
    
    func animateSwipeLeft(completion: @escaping () -> Void){
        self.image = UIImage(named: "imgCubeRotateX\(30)")
        self.animationImages = swipeLeftAnimationImages
        self.animationDuration = 0.3
        self.animationRepeatCount = 1
        self.startAnimating()
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.3) {
            completion()
        }
    }
}
