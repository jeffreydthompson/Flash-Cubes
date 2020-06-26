//
//  CubeTableCellNew.swift
//  Flash Cubes
//
//  Created by Jeffrey Thompson on 6/14/19.
//  Copyright © 2019 Jeffrey Thompson. All rights reserved.
//

import UIKit

class CubeTableCellNew: UITableViewCell {
    
    enum State {
        case dlc
        case overview
    }
    
    static let reuseIdentifier = "CubeTableCellNew"
    
    var prompts: [String : CubePrompt]!
    var retention: Double!
    var proficiency: Double!
    var name: String!
    
    var isPastDue: Bool = false
    var isNew: Bool = false
    
    var state: State = .overview
    
    
    private var isiPad: Bool {
        get {
            return UIDevice.current.model == "iPad"
        }
    }
    
    var cellHeight: CGFloat {
        get {
            return audioImgContainerHeight + textContainerHeight + 32
        }
    }
    
    private var audioImgContainerHeight: CGFloat {
        get {
            let items = prompts.filter({$0.value.type != .text}).count
            if items == 0 {return 0}
            let rows = (items / 3) + 1
            let imgSize = self.isiPad ? 120 : 60
            
            let height = CGFloat(rows * imgSize)
            return height
        }
    }
    private var textContainerHeight: CGFloat {
        get {
            let items = prompts.filter({$0.value.type == .text}).count
            if items == 0 {return 0}
            let height = CGFloat(items * 30)
            return height
        }
    }
    
    private let cubeSpinAnimImgs: [UIImage] = {
        var imgs = [UIImage]()
        for index in 1...59 {
            if let img = UIImage(named: "imgCubeSpin\(index)"){
                imgs.append(img)
            }
        }
        return imgs
    }()
    
    private var underLayer: UIView = {
        let layer = UIView(frame: .zero)
        layer.translatesAutoresizingMaskIntoConstraints = false
        layer.backgroundColor = UIColor.underlay
        layer.layer.cornerRadius = 16.0
        layer.layer.masksToBounds = true
        return layer
    }()
    
    private var retentionBar: UIProgressView {
        get {
            let bar = UIProgressView(progressViewStyle: .default)
            bar.translatesAutoresizingMaskIntoConstraints = false
            bar.layer.cornerRadius = 1.5
            bar.layer.masksToBounds = true
            bar.tintColor = .graphRed
            bar.progress = Float(self.retention)
            return bar
        }
    }
    
    private var proficiencyBar: UIProgressView {
        get {
            let bar = UIProgressView(progressViewStyle: .default)
            bar.translatesAutoresizingMaskIntoConstraints = false
            bar.layer.cornerRadius = 1.5
            bar.layer.masksToBounds = true
            bar.tintColor = .appleBlue
            bar.progress = Float(self.proficiency)
            return bar
        }
    }
    
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
    
    private var leftContainer: UIView {
        get {
            let view = UIView(frame: .zero)
            view.translatesAutoresizingMaskIntoConstraints = false
            
            let imgView = UIImageView(frame: .zero)
            imgView.animationImages = self.cubeSpinAnimImgs
            imgView.highlightedAnimationImages = self.cubeSpinAnimImgs
            imgView.translatesAutoresizingMaskIntoConstraints = false
            imgView.animationDuration = TimeInterval(4)
            imgView.startAnimating()
            
            let label = UILabel(frame: .zero)
            label.translatesAutoresizingMaskIntoConstraints = false
            label.font = .body
            label.textColor = .white
            label.textAlignment = .center
            label.numberOfLines = 2
            label.text = self.name
            
            switch self.state {
            case .overview:
                
                let profBar = self.proficiencyBar
                
                view.addSubview(profBar)
                NSLayoutConstraint.activate([
                    profBar.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8),
                    profBar.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                    profBar.heightAnchor.constraint(equalToConstant: 3.0),
                    profBar.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -3.0)
                    ])
                
                let retBar = self.retentionBar
                
                view.addSubview(retBar)
                NSLayoutConstraint.activate([
                    retBar.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8),
                    retBar.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                    retBar.heightAnchor.constraint(equalToConstant: 3.0),
                    retBar.bottomAnchor.constraint(equalTo: profBar.topAnchor, constant: -3.0)
                    ])
                
                view.addSubview(imgView)
                
                NSLayoutConstraint.activate([
                    imgView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.5),
                    imgView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                    imgView.heightAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.5),
                    imgView.topAnchor.constraint(equalTo: view.topAnchor, constant: 5)
                    ])
                
                view.addSubview(label)
                NSLayoutConstraint.activate([
                    label.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.5),
                    label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                    label.topAnchor.constraint(equalTo: imgView.bottomAnchor, constant: 5),
                    label.bottomAnchor.constraint(equalTo: retBar.topAnchor, constant: -5)
                    ])
                break
            case .dlc:
                
                view.addSubview(imgView)
                
                NSLayoutConstraint.activate([
                    imgView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.7),
                    imgView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                    imgView.heightAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.7),
                    imgView.topAnchor.constraint(equalTo: view.topAnchor, constant: 5)
                    ])
                
                view.addSubview(label)
                
                NSLayoutConstraint.activate([
                    label.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.5),
                    label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                    label.topAnchor.constraint(equalTo: imgView.bottomAnchor, constant: 5),
                    label.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -5)
                    ])
                break
            }
            return view
        }
    }
    
    private var audioImgContainer: UIView? {
        get {
            if self.prompts.filter({$0.value.type != .text}).count == 0 {
                return nil
            }
            let view = UIView(frame: .zero)
            view.translatesAutoresizingMaskIntoConstraints = false
            
            var subviews = [UIView]()
            self.prompts.filter({$0.value.type != .text}).sorted(by: {$0.key < $1.key}).forEach({
                
                switch $0.value {
                case .text(_):
                    break
                case .audio(let data):
                    let subView = UIView(frame: .zero)
                    subView.translatesAutoresizingMaskIntoConstraints = false
                    
                    let audioBtn = AudioButton(audio: data)
                    subView.addSubview(audioBtn)
                    NSLayoutConstraint.activate([
                        audioBtn.widthAnchor.constraint(equalTo: subView.widthAnchor, multiplier: 0.8),
                        audioBtn.heightAnchor.constraint(equalTo: subView.widthAnchor, multiplier: 0.8),
                        audioBtn.centerXAnchor.constraint(equalTo: subView.centerXAnchor),
                        audioBtn.centerYAnchor.constraint(equalTo: subView.centerYAnchor)
                        ])
                    
                    subviews.append(subView)
                    break
                case .image(let img):
                    let subView = UIView(frame: .zero)
                    subView.translatesAutoresizingMaskIntoConstraints = false
                    
                    let imgView = UIImageView(image: img)
                    imgView.translatesAutoresizingMaskIntoConstraints = false
                    imgView.layer.cornerRadius = 6
                    imgView.layer.masksToBounds = true
                    
                    subView.addSubview(imgView)
                    NSLayoutConstraint.activate([
                        imgView.widthAnchor.constraint(equalTo: subView.widthAnchor, multiplier: 0.8),
                        imgView.heightAnchor.constraint(equalTo: subView.widthAnchor, multiplier: 0.8),
                        imgView.centerXAnchor.constraint(equalTo: subView.centerXAnchor),
                        imgView.centerYAnchor.constraint(equalTo: subView.centerYAnchor)
                        ])
                    
                    subviews.append(subView)
                    break
                }
            })
            
            for (index, subview) in subviews.enumerated() {
                
                view.addSubview(subview)
                
                let imgSize: CGFloat = self.isiPad ? 120 : 60
                subview.widthAnchor.constraint(equalToConstant: imgSize).isActive = true
                subview.heightAnchor.constraint(equalToConstant: imgSize).isActive = true
                
                switch index {
                case 0:
                    subview.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
                    subview.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
                    break
                case 1:
                    subview.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
                    subview.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
                    break
                case 2:
                    subview.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
                    subview.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
                    break
                case 3:
                    subview.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
                    subview.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
                    break
                case 4:
                    subview.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
                    subview.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
                    break
                default:
                    subview.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
                    subview.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
                    break
                }
            }
            
            return view
        }
    }
    
    private var textContainer: UIView? {
        get {
            if self.prompts.filter({$0.value.type == .text}).count == 0 {
                return nil
            }
            
            let view = UIView(frame: .zero)
            view.translatesAutoresizingMaskIntoConstraints = false
            
            for (index, value) in self.prompts.filter({$0.value.type == .text}).sorted(by: {$0.key < $1.key}).enumerated() {
                let label = UILabel(frame: .zero)
                label.translatesAutoresizingMaskIntoConstraints = false
                label.font = .body
                label.textAlignment = .right
                label.textColor = .white
                //label.backgroundColor = .purple
                
                switch value.value {
                case .text(let str):
                    label.text = str
                    break
                default:
                    break
                }
                
                view.addSubview(label)
                
                NSLayoutConstraint.activate([
                    label.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                    label.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                    label.topAnchor.constraint(equalTo: view.topAnchor, constant: CGFloat(30 * index)),
                    label.heightAnchor.constraint(equalToConstant: 30)
                    ])
            }
            
            return view
        }
    }
    
    private var iconRightArrow: UIImageView = {
        let img = UIImage(named: "iconRightArrow")
        let imgView = UIImageView(image: img)
        imgView.translatesAutoresizingMaskIntoConstraints = false
        imgView.contentMode = ContentMode.scaleAspectFit
        
        return imgView
    }()
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.backgroundColor = .clear
        self.contentView.backgroundColor = .clear
        self.selectionStyle = .none
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func prepareForReuse() {
        
        //self.subviews.forEach({$0.removeFromSuperview()})
        
        self.contentView.subviews.forEach({ subview in
            subview.subviews.forEach({ subsubview in
                subsubview.subviews.forEach({ $0.removeFromSuperview() })
                subsubview.removeFromSuperview()
            })
            subview.removeFromSuperview()
        })
        
        self.isNew = false
        self.isPastDue = false
        self.prompts = nil
        self.name = nil
        self.retention = nil
        self.proficiency = nil
        
    }
    
    public func setupViews(){
        
        var rightOffset: CGFloat = -24
        if state == .overview {
            rightOffset = -48
        }
        
        contentView.addSubview(underLayer)

        NSLayoutConstraint.activate([
            underLayer.leadingAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            underLayer.trailingAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            underLayer.topAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.topAnchor, constant: 8),
            underLayer.bottomAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.bottomAnchor, constant: -8)
            ])
        
        let leftSideContainer = leftContainer
        contentView.addSubview(leftSideContainer)
        
        NSLayoutConstraint.activate([
            leftSideContainer.leadingAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.leadingAnchor, constant: 24),
            leftSideContainer.widthAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.heightAnchor, constant: -32),
            leftSideContainer.heightAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.heightAnchor, constant: -32),
            leftSideContainer.centerYAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.centerYAnchor)
            ])
        
        let containerWidth: CGFloat = self.isiPad ? 360 : 180
        if let audioImgContainer = self.audioImgContainer {
            contentView.addSubview(audioImgContainer)
            
            NSLayoutConstraint.activate([
                audioImgContainer.trailingAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.trailingAnchor, constant: rightOffset),
                audioImgContainer.topAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.topAnchor, constant: 16),
                audioImgContainer.heightAnchor.constraint(equalToConstant: self.audioImgContainerHeight),
                audioImgContainer.widthAnchor.constraint(equalToConstant: containerWidth)
                ])
        }
        
        if let textContainer = self.textContainer {
            contentView.addSubview(textContainer)
            
            NSLayoutConstraint.activate([
                textContainer.trailingAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.trailingAnchor, constant: rightOffset),
                textContainer.leadingAnchor.constraint(equalTo: leftSideContainer.trailingAnchor, constant: 30),
                textContainer.heightAnchor.constraint(equalToConstant: self.textContainerHeight),
                textContainer.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16 + self.audioImgContainerHeight)
                ])
        }
        
        if state == .overview {
            contentView.addSubview(iconRightArrow)
            
            NSLayoutConstraint.activate([
                iconRightArrow.trailingAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.trailingAnchor, constant: -24),
                iconRightArrow.centerYAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.centerYAnchor),
                iconRightArrow.widthAnchor.constraint(equalToConstant: 16),
                iconRightArrow.heightAnchor.constraint(equalToConstant: 16)
                ])
        }
        
        if isPastDue {setPastDue()}
        if isNew {setNew()}
        
    }
    
    private func setPastDue() {
        contentView.addSubview(pastDueImgView)
        
        let imgSize: CGFloat = self.isiPad ? 50 : 25
        NSLayoutConstraint.activate([
            pastDueImgView.leadingAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.leadingAnchor, constant: 20.0),
            pastDueImgView.topAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.topAnchor, constant: 12.0),
            pastDueImgView.widthAnchor.constraint(equalToConstant: imgSize),
            pastDueImgView.heightAnchor.constraint(equalToConstant: imgSize)
            ])
    }
    
    private func setNew() {
        contentView.addSubview(newImgView)
        
        let imgSize: CGFloat = self.isiPad ? 50 : 25
        NSLayoutConstraint.activate([
            newImgView.leadingAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.leadingAnchor, constant: 20.0),
            newImgView.topAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.topAnchor, constant: 12.0),
            newImgView.widthAnchor.constraint(equalToConstant: imgSize),
            newImgView.heightAnchor.constraint(equalToConstant: imgSize)
            ])
    }

}
