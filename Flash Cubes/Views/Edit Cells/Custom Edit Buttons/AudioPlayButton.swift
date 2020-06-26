//
//  audioPlayButton.swift
//  Flash Cubes
//
//  Created by Jeffrey Thompson on 5/5/19.
//  Copyright © 2019 Jeffrey Thompson. All rights reserved.
//

import UIKit

class AudioPlayButton: UIButton {
    
    enum PlayState {
        case normal
        case disabled
        case playing
    }
    
    var delegate: AudioCellDelegate!
    
    var data: Data? {
        didSet {
            if self.data == nil {
                self.playState = .disabled
            } else {
                self.playState = .normal
            }
        }
    }
    
    let imgPlayActive: UIImage? = UIImage(named: "imgPlayActive")
    let imgPlayInactive: UIImage? = UIImage(named: "imgPlayInactive")
    let imgStopActive: UIImage? = UIImage(named: "imgStopActive")

    var playState: PlayState = .disabled {
        didSet {
            
            switch self.playState {
            case .playing:
                DispatchQueue.main.async {
                    self.setImage(self.imgStopActive, for: .normal)
                }
            case .normal:
                if let _ = data {
                    DispatchQueue.main.async {
                        self.setImage(self.imgPlayActive, for: .normal)
                    }
                } else {
                    self.playState = .disabled
                }
            case .disabled:
                DispatchQueue.main.async {
                    self.setImage(self.imgPlayInactive, for: .normal)
                }
            }
        }
    }
    
    public init(audioData: Data?) {
        super.init(frame: .zero)
        self.translatesAutoresizingMaskIntoConstraints = false
        
        data = audioData
        self.addTarget(self, action: #selector(onPress), for: .touchUpInside)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.translatesAutoresizingMaskIntoConstraints = false
        
        self.addTarget(self, action: #selector(onPress), for: .touchUpInside)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func playbackEnd() {
        self.playState = .normal
        self.delegate.playEnd()
    }
    
    @objc func onPress() {
        switch self.playState {
        case .playing:
            AudioManager.shared.stopPlay()
            playbackEnd()
            
        case .normal:
            if let audioData = data {
                
                AudioManager.shared.playAudio(fromData: audioData, atSpeed: .normal) { (_, _) in
                    self.playState = .playing
                    self.delegate.playStart()
                    AudioManager.shared.pendingPlaybackEnd = self.playbackEnd
                }
                
            } else {
                self.playState = .disabled
            }
        case .disabled:
            break
        }
    }
}
