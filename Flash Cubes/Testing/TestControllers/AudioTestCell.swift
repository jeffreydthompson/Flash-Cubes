//
//  AudioTestCell.swift
//  Flash Cubes
//
//  Created by Jeffrey Thompson on 4/23/19.
//  Copyright © 2019 Jeffrey Thompson. All rights reserved.
//

import UIKit
import AVFoundation

class AudioTestCell: UITableViewCell, AVAudioPlayerDelegate, AVAudioRecorderDelegate {
    
    enum AudioState {
        case neutral
        case play
        case record
    }

    private var rowId: Int!
    private var audioState: AudioState = .neutral {
        didSet {
            print("\(#function) audiostate changed to \(self.audioState)")
            self.updateViews()
        }
    }
    
    private var avSession: AVAudioSession?
    private var avPlayer: AVAudioPlayer?
    private var avRecorder: AVAudioRecorder?
    
    private var playButton: UIButton?
    private var recordButton: UIButton?
    
    private var newAudioData: Data?
    private var tmpURL: URL?
    
    private var previouslyExistingAudioData: Data? // incase editing old recording
    
    private let attrStringAttributes: [NSAttributedString.Key : Any] = [
        NSAttributedString.Key.font : UIFont.systemFont(ofSize: 30),
        NSAttributedString.Key.strokeColor : UIColor.red
    ]
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    private func setupViews(){
        
        self.contentView.backgroundColor = UIColor.clear
        self.backgroundColor = UIColor.clear
        
        let underLayer = UIView(frame: .zero)
        underLayer.backgroundColor = UIColor(white: 1.0, alpha: 0.6)
        underLayer.layer.cornerRadius = 10.0
        underLayer.layer.masksToBounds = true
        self.addSubview(underLayer)
        
        addConstraintsWithFormat(format: "H:|-3-[v0]-3-|", views: underLayer)
        addConstraintsWithFormat(format: "V:|-3-[v0]-3-|", views: underLayer)
        
        
        let recordTitle = NSAttributedString(string: "●", attributes: attrStringAttributes)
        recordButton = UIButton(type: .custom)
        //recordButton?.setTitle("●", for: .normal)
        recordButton?.setAttributedTitle(recordTitle, for: .normal)
        recordButton?.setTitleColor(UIColor.red, for: .normal)
        recordButton?.backgroundColor = UIColor(white: 1.0, alpha: 0.9)
        recordButton?.addTarget(self, action: #selector(recordButtonOnPress), for: .touchUpInside)
        
        let playTitle = NSAttributedString(string: "▶︎", attributes: attrStringAttributes)
        playButton = UIButton(type: .custom)
        playButton?.setAttributedTitle(playTitle, for: .normal)
        playButton?.backgroundColor = UIColor(white: 1.0, alpha: 0.9)
        playButton?.addTarget(self, action: #selector(playButtonOnPress), for: .touchUpInside)
        
        self.addSubview(recordButton!)
        self.addSubview(playButton!)
        
        addConstraintsWithFormat(format: "H:|-20-[v0(60)]-140-[v1(60)]", views: recordButton!,playButton!)
        addConstraintsWithFormat(format: "V:|-8-[v0(60)]", views: recordButton!)
        addConstraintsWithFormat(format: "V:|-8-[v0(60)]", views: playButton!)
    }
    
    private func updateViews(){
        print("\(#function) for state: \(self.audioState)")
        
        let stopTitle = NSAttributedString(string: "◼︎", attributes: attrStringAttributes)
        let playTitle = NSAttributedString(string: "▶︎", attributes: attrStringAttributes)
        let recordTitle = NSAttributedString(string: "●", attributes: attrStringAttributes)
        
        switch self.audioState {
        case .neutral:
            recordButton?.isEnabled = true
            recordButton?.setAttributedTitle(recordTitle, for: .normal)
            playButton?.isEnabled = (newAudioData != nil) || (previouslyExistingAudioData != nil)
            playButton?.setAttributedTitle(playTitle, for: .normal)
        case .play:
            playButton?.setAttributedTitle(stopTitle, for: .normal)
            recordButton?.isEnabled = false
        case .record:
            recordButton?.setAttributedTitle(stopTitle, for: .normal)
            playButton?.isEnabled = false
        }
    }
    
    public init(row: Int) {
        super.init(style: .default, reuseIdentifier: nil)
        self.rowId = row
        
        self.selectionStyle = .none
        
        avSession = AVAudioSession.sharedInstance()
        setupViews()
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.rowId = 0
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @objc func recordButtonOnPress(){
        
        switch self.audioState {
        case .neutral:
            
            do {
                try avSession?.setCategory(AVAudioSession.Category.record)
            } catch let error {
                print("\(#file) \(#function) \(error)")
            }
            
            let settings: [String : Any] = [
                AVFormatIDKey : kAudioFormatAppleLossless,
                AVEncoderAudioQualityKey : AVAudioQuality.high.rawValue,
                AVNumberOfChannelsKey : 2,
                AVEncoderBitRateKey : 128000,
                AVSampleRateKey : 44100
            ]
            
            if tmpURL == nil {
                tmpURL = UniqueTempAudioURL.m4a.generate
            }
            
            do {
                try avRecorder = AVAudioRecorder(url: tmpURL!, settings: settings)
                avRecorder?.delegate = self
                avRecorder?.prepareToRecord()
                avRecorder?.record()
            } catch let error {
                print("\(#file) \(#function) \(error)")
            }
            
            self.audioState = .record
            break
            
        case .record:
            
            avRecorder?.stop()
            break
            
        case .play:
            break
        }
        
        
    }
    
    @objc func playButtonOnPress(){
        
        switch self.audioState {
        case .neutral:
            var data: Data? = nil
            if previouslyExistingAudioData != nil {
                data = previouslyExistingAudioData
            }
            
            if newAudioData != nil {
                data = newAudioData
            }
            
            guard data != nil else {
                print("\(#file) \(#function) nil audio data")
                return
            }
            
            do {
                try avSession?.setCategory(AVAudioSession.Category.playback)
                try avPlayer = AVAudioPlayer(data: data!, fileTypeHint: AVFileType.m4a.rawValue)
                avPlayer?.delegate = self
                avPlayer?.volume = 1.0
                avPlayer?.prepareToPlay()
                avPlayer?.play()
            } catch let error {
                print("\(#file) \(#function) \(error)")
            }
            
            self.audioState = .play
            break
            
        case .play:
            
            avPlayer?.stop()
            self.audioState = .neutral
            break
            
        case .record:
            break
        }
        
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        print("\(#file) \(#function)")
        
        self.audioState = .neutral
    }
    
    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        print("\(#file) \(#function) playback error occured")
    }
    
    func audioRecorderEncodeErrorDidOccur(_ recorder: AVAudioRecorder, error: Error?) {
        print("\(#file) \(#function)")
    }
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        print("\(#file) \(#function) record error occured")
        
        if(flag) {
            if let path = tmpURL?.path {
                if let data = FileManager.default.contents(atPath: path) {
                    self.newAudioData = data
                }
            }
        }
        
        self.audioState = .neutral
    }
}




