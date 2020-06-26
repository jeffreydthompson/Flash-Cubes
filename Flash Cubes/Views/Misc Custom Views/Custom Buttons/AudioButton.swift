//
//  AudioButton.swift
//  Flash Cubes
//
//  Created by Jeffrey Thompson on 4/27/19.
//  Copyright © 2019 Jeffrey Thompson. All rights reserved.
//

import UIKit

class AudioButton: UIButton {
    
    var playbackSpeed: AudioPlaybackSpeed = .normal

    var audioData: Data? {
        didSet {
            if self.audioData == nil {
                setNilButton()
            }
        }
    }
    
    var replayImg: UIImage = {
        return UIImage(named: "imgAudioReplay")!
    }()
    
    var audioImg: UIImage = {
        return UIImage(named: "imgAudioLarge")!
    }()
    
    var audioImgNil: UIImage = {
        return UIImage(named: "imgAudioNilLarge")!
    }()
    
    convenience init(audio data: Data?) {
        self.init(frame: .zero)
        setupButton()
        self.audioData = data
        if self.audioData == nil {
            setNilButton()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupButton()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupButton(){
        self.setImage(audioImg, for: .normal)
        self.addTarget(self, action: #selector(onPress), for: .touchUpInside)
        self.translatesAutoresizingMaskIntoConstraints = false
        self.layer.cornerRadius = 6
        self.layer.masksToBounds = true
    }
    
    func setNilButton(){
        self.setImage(audioImgNil, for: .normal)
        self.layer.cornerRadius = 6
        self.layer.masksToBounds = true
    }
    
    func setAsReplay(){
        self.setImage(replayImg, for: .normal)
        self.layer.cornerRadius = 6
        self.layer.masksToBounds = true
    }
    
    @objc func onPress(){
        if let data = audioData {
            AudioManager.shared.playAudio(fromData: data, atSpeed: self.playbackSpeed) { (success, error) in
                if let error = error {
                    print("\(#function) \(error)")
                }
            }
        }
    }
}
