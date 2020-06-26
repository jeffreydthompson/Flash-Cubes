//
//  CubeTableCell.swift
//  Flash Cubes
//
//  Created by Jeffrey Thompson on 4/27/19.
//  Copyright © 2019 Jeffrey Thompson. All rights reserved.
//

import UIKit

class CubeTableCell: UITableViewCell {
    
    static let reuseIdentifier = "CubeTableCell"
    
    var nameLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.font = .body
        label.textColor = .white
        label.textAlignment = .center
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var arrowLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .body
        label.textColor = .white
        label.textAlignment = .center
        label.text = "➤"
        return label
    }()
    
    var underLayer: UIView = {
        let layer = UIView(frame: .zero)
        layer.backgroundColor = UIColor(white: 1.0, alpha: 0.5)
        layer.layer.cornerRadius = 10.0
        layer.layer.masksToBounds = true
        return layer
    }()
    
    let cubeSpinAnimImgs: [UIImage] = {
        var imgs = [UIImage]()
        for index in 1...59 {
            if let img = UIImage(named: "imgCubeSpin\(index)"){
                imgs.append(img)
            }
        }
        return imgs
    }()
    
    var progressBar: UIProgressView = {
        var bar = UIProgressView(progressViewStyle: .default)
        bar.translatesAutoresizingMaskIntoConstraints = false
        bar.layer.cornerRadius = 1.5
        bar.layer.masksToBounds = true
        return bar
    }()
    
    var pastDueImgView: UIImageView = {
        var img = UIImage(named: "imgPastDue")
        var imgView = UIImageView(image: img)
        imgView.translatesAutoresizingMaskIntoConstraints = false
        return imgView
    }()
    
    var newImgView: UIImageView = {
        var img = UIImage(named: "imgNew")
        var imgView = UIImageView(image: img)
        imgView.translatesAutoresizingMaskIntoConstraints = false
        return imgView
    }()
    
//    var cubeSpinImage: UIImageView?
//    var cubeProgress: UIProgressView?
    var notificationsIcon: UIImageView?
    
    var prompts: [String : CubePrompt]?
    var containerHeight: Int?
    var progress: Double? {
        didSet {
            self.progressBar.progress = Float(progress!)
            let hue = CGFloat( (progress! * progress!) * 0.3)
            let progressColor =  UIColor(hue: hue, saturation: 0.75, brightness: 1.0, alpha: 1.0)
            self.progressBar.progressTintColor = progressColor
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.backgroundColor = .clear
        self.contentView.backgroundColor = .clear
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        self.prompts = nil
        self.subviews.forEach({
            $0.subviews.forEach({view in
                view.removeFromSuperview()
            })
            $0.removeFromSuperview()
        })
        setupViews()
    }
    
    /*func getImageAudioPromptContainer(for prompts: [String : CubePrompt]) -> UIView {
        
        func constrain(view: UIView, inside: UIView, row: Int, column: Int) {
        
            view.translatesAutoresizingMaskIntoConstraints = false
            
            //hacky... ohwells.  NSLayout is hacky.
            // right to left.  up to down.
            if row == 0 {
                if column == 0 {
                    NSLayoutConstraint.activate([
                        view.widthAnchor.constraint(equalTo: inside.widthAnchor, multiplier: 0.33),
                        view.heightAnchor.constraint(equalTo: inside.widthAnchor, multiplier: 0.33),
                        view.topAnchor.constraint(equalTo: inside.topAnchor),
                        view.trailingAnchor.constraint(equalTo: inside.trailingAnchor)
                        ])
                } else if column == 1 {
                    NSLayoutConstraint.activate([
                        view.widthAnchor.constraint(equalTo: inside.widthAnchor, multiplier: 0.33),
                        view.heightAnchor.constraint(equalTo: inside.widthAnchor, multiplier: 0.33),
                        view.topAnchor.constraint(equalTo: inside.topAnchor),
                        view.centerXAnchor.constraint(equalTo: inside.centerXAnchor)
                        ])
                } else if column == 2 {
                    NSLayoutConstraint.activate([
                        view.widthAnchor.constraint(equalTo: inside.widthAnchor, multiplier: 0.33),
                        view.heightAnchor.constraint(equalTo: inside.widthAnchor, multiplier: 0.33),
                        view.topAnchor.constraint(equalTo: inside.topAnchor),
                        view.leadingAnchor.constraint(equalTo: inside.leadingAnchor)
                        ])
                }
            } else {
                if column == 0 {
                    NSLayoutConstraint.activate([
                        view.widthAnchor.constraint(equalTo: inside.widthAnchor, multiplier: 0.33),
                        view.heightAnchor.constraint(equalTo: inside.widthAnchor, multiplier: 0.33),
                        view.bottomAnchor.constraint(equalTo: inside.bottomAnchor),
                        view.trailingAnchor.constraint(equalTo: inside.trailingAnchor)
                        ])
                } else if column == 1 {
                    NSLayoutConstraint.activate([
                        view.widthAnchor.constraint(equalTo: inside.widthAnchor, multiplier: 0.33),
                        view.heightAnchor.constraint(equalTo: inside.widthAnchor, multiplier: 0.33),
                        view.bottomAnchor.constraint(equalTo: inside.bottomAnchor),
                        view.centerXAnchor.constraint(equalTo: inside.centerXAnchor)
                        ])
                } else if column == 2 {
                    NSLayoutConstraint.activate([
                        view.widthAnchor.constraint(equalTo: inside.widthAnchor, multiplier: 0.33),
                        view.heightAnchor.constraint(equalTo: inside.widthAnchor, multiplier: 0.33),
                        view.bottomAnchor.constraint(equalTo: inside.bottomAnchor),
                        view.trailingAnchor.constraint(equalTo: inside.trailingAnchor)
                        ])
                }
            }
        }

        let container = UIView(frame: .zero)
        container.translatesAutoresizingMaskIntoConstraints = false

        let audioPrompts = prompts.values.filter({$0.type == .audio})
        let imagePrompts = prompts.values.filter({$0.type == .image})

        var index = 0

        audioPrompts.forEach({
            let row = index/3
            let column = index % 3

            let localContainer = UIView(frame: .zero)
            localContainer.translatesAutoresizingMaskIntoConstraints = false

            var audioData: Data? = nil
            switch $0 {
            case .audio(let data):
                audioData = data
            default:
                break
            }

            container.addSubview(localContainer)
            constrain(view: localContainer, inside: container, row: row, column: column)

            let audioBtn = AudioButton(audio: audioData)
            
            localContainer.addSubview(audioBtn)
            localContainer.constrain(withConstant: 6, view: audioBtn)
            
            index += 1
        })

        imagePrompts.forEach({
            let row = index/3
            let column = index % 3
            
            let localContainer = UIView(frame: .zero)
            localContainer.translatesAutoresizingMaskIntoConstraints = false
            
            var img: UIImage? = nil
            
            switch $0 {
            case .image(let image):
                img = image
            default:
                break
            }
            
            container.addSubview(localContainer)
            constrain(view: localContainer, inside: container, row: row, column: column)
            
            let imgView = UIImageView(image: img)
            localContainer.addSubview(imgView)
            
            localContainer.constrain(withConstant: 6, view: imgView)
            
            index += 1
        })

        return container
    }
    
    func setupViews(){
        
        self.contentView.addAndConstrain(view: underLayer, top: 3, bottom: 3, left: 3, right: 3)

        guard let prompts = prompts else {return}
        
        self.contentView.addSubview(arrowLabel)
        NSLayoutConstraint.activate([
            arrowLabel.topAnchor.constraint(equalTo: contentView.topAnchor),
            arrowLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            arrowLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            arrowLabel.widthAnchor.constraint(equalToConstant: 30)
            ])
        
        let promptsContainer = getImageAudioPromptContainer(for: prompts)
        
        contentView.addSubview(promptsContainer)
        NSLayoutConstraint.activate([
            promptsContainer.topAnchor.constraint(equalTo: contentView.topAnchor),
            promptsContainer.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            promptsContainer.trailingAnchor.constraint(equalTo: arrowLabel.leadingAnchor),
            promptsContainer.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.7)
            ])
        
    }*/
    
    
    func getPromptContainer(prompts: [String : CubePrompt]) -> UIView {
        
        var imgs = [UIImageView]()
        var audio = [AudioButton]()
        var texts = [UILabel]()
        
        prompts.forEach({
            switch $0.value {
            case .text(let str):
                let label = UILabel(frame: .zero)
                if let str = str {
                    label.text = str
                } else {
                    label.text = "..."
                }
                label.font = UIFont.body
                label.textColor = UIColor.white
                label.numberOfLines = 2
                label.textAlignment = .right
                texts.append(label)
            case .audio(let data):
                let audioBtn = AudioButton(frame: .zero)
                audioBtn.audioData = data
                audio.append(audioBtn)
            case .image(let img):
                var imgView: UIImageView?
                if let img = img {
                    imgView = UIImageView(image: img)
                } else {
                    let nilImage = UIImage(named: "imgImageNil")
                    imgView = UIImageView(image: nilImage)
                }
                imgView!.layer.cornerRadius = 6
                imgView!.layer.masksToBounds = true
                imgView!.contentMode = .scaleAspectFit
                imgs.append(imgView!)
            }
        })
        
        var imgViewsIndex = 0
        var textViewIndex = 0
        let container = UIView(frame: .zero)
        
        for (index, imgView) in imgs.enumerated() {
            container.addSubview(imgView)
            let rightOffset = 8 + ((index % 3) * 68)
            let topOffset = 8 + ((index / 3) * 68)
            container.addConstraintsWithFormat(format: "H:[v0(60)]-\(rightOffset)-|", views: imgView)
            container.addConstraintsWithFormat(format: "V:|-\(topOffset)-[v0(60)]", views: imgView)
            imgViewsIndex += 1
        }
        
        for (_ , audioBtn) in audio.enumerated() {
            container.addSubview(audioBtn)
            let rightOffset = 8 + ((imgViewsIndex % 3) * 68)
            let topOffset = 8 + ((imgViewsIndex / 3) * 68)
            container.addConstraintsWithFormat(format: "H:[v0(60)]-\(rightOffset)-|", views: audioBtn)
            container.addConstraintsWithFormat(format: "V:|-\(topOffset)-[v0(60)]", views: audioBtn)
            imgViewsIndex += 1
        }
        
        for (index, text) in texts.enumerated() {
            container.addSubview(text)
            let topOffset = 8 + (((imgViewsIndex + 2) / 3) * 68) + (index * 48)
            container.addConstraintsWithFormat(format: "H:|-8-[v0]-8-|", views: text)
            container.addConstraintsWithFormat(format: "V:|-\(topOffset)-[v0(40)]", views: text)
            
            textViewIndex += 1
        }
        
        containerHeight = 8 + (((imgViewsIndex + 2) / 3) * 68) + (textViewIndex * 48)
        
        if containerHeight! < 120 {
            containerHeight = 120
        }
        
        return container
    }
    
    func setupViews(){
        self.backgroundColor = UIColor.clear
        
        self.addAndConstrain(view: underLayer, top: 3, bottom: 3, left: 3, right: 3)
        
        guard let prompts = prompts else {return}
        
        let promptsContainer = getPromptContainer(prompts: prompts)
        self.addSubview(promptsContainer)
        
        let width = CGFloat(8 + (3*68))
//        NSLayoutConstraint.activate([
//            promptsContainer.widthAnchor.constraint(equalToConstant: width),
//            promptsContainer.topAnchor.constraint(equalTo: self.topAnchor),
//            promptsContainer.bottomAnchor.constraint(equalTo: self.bottomAnchor),
//            promptsContainer.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -20)
//            ])
        self.addConstraintsWithFormat(format: "H:[v0(\(width))]-20-|", views: promptsContainer)
        if let height = containerHeight {
            self.addConstraintsWithFormat(format: "V:|[v0(\(height))]", views: promptsContainer)
        }
        
        let container = UIView(frame: .zero)
        container.translatesAutoresizingMaskIntoConstraints = false
        
        self.addSubview(container)
        
        NSLayoutConstraint.activate([
            container.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 3.0),
            container.trailingAnchor.constraint(equalTo: promptsContainer.leadingAnchor, constant: -3.0),
            container.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            container.heightAnchor.constraint(equalToConstant: 123)
            ])
        
        let cubeSpinAnimView = UIImageView(frame: .zero)
        cubeSpinAnimView.animationImages = cubeSpinAnimImgs
        cubeSpinAnimView.highlightedAnimationImages = cubeSpinAnimImgs
        cubeSpinAnimView.translatesAutoresizingMaskIntoConstraints = false
        cubeSpinAnimView.animationDuration = TimeInterval(4)
        cubeSpinAnimView.startAnimating()
        
        container.addSubview(cubeSpinAnimView)
        
        NSLayoutConstraint.activate([
            cubeSpinAnimView.topAnchor.constraint(equalTo: container.topAnchor),
            cubeSpinAnimView.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            cubeSpinAnimView.widthAnchor.constraint(equalToConstant: 60.0),
            cubeSpinAnimView.heightAnchor.constraint(equalToConstant: 60.0)
            ])
        
        container.addSubview(nameLabel)

        NSLayoutConstraint.activate([
            //nameLabel.topAnchor.constraint(equalTo: cubeSpinAnimView.bottomAnchor),
            nameLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            nameLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            nameLabel.heightAnchor.constraint(equalToConstant: 60.0),
            nameLabel.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -3)
            ])
        
        container.addSubview(progressBar)
        
        NSLayoutConstraint.activate([
            progressBar.topAnchor.constraint(equalTo: nameLabel.bottomAnchor),
            progressBar.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 8.0),
            progressBar.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -8.0),
            progressBar.heightAnchor.constraint(equalToConstant: 3.0)
            ])
        
        self.addSubview(arrowLabel)
        
        NSLayoutConstraint.activate([
            arrowLabel.widthAnchor.constraint(equalToConstant: 22),
            arrowLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            arrowLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -6.0),
            arrowLabel.heightAnchor.constraint(equalToConstant: 20)
            ])
    }
    
    
    public func setPastDue() {
        self.addSubview(pastDueImgView)
        
        NSLayoutConstraint.activate([
            pastDueImgView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 6.0),
            pastDueImgView.topAnchor.constraint(equalTo: self.topAnchor, constant: 6.0),
            pastDueImgView.widthAnchor.constraint(equalToConstant: 30.0),
            pastDueImgView.heightAnchor.constraint(equalToConstant: 30.0)
            ])
    }
    
    public func setNew() {
        self.addSubview(newImgView)
        
        NSLayoutConstraint.activate([
            newImgView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 6.0),
            newImgView.topAnchor.constraint(equalTo: self.topAnchor, constant: 6.0),
            newImgView.widthAnchor.constraint(equalToConstant: 30.0),
            newImgView.heightAnchor.constraint(equalToConstant: 30.0)
            ])
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
