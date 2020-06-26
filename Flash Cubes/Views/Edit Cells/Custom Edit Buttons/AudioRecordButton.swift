//
//  AudioRecordButton.swift
//  Flash Cubes
//
//  Created by Jeffrey Thompson on 5/5/19.
//  Copyright © 2019 Jeffrey Thompson. All rights reserved.
//

import UIKit

class AudioRecordButton: UIButton {

    enum RecordState {
        case normal
        case recording
        case disabled
    }
    
    var delegate: AudioCellDelegate!
    
    let tmpDataURL: URL = UniqueTempAudioURL.m4a.generate
    
    let imgRecordActive: UIImage? = UIImage(named: "imgRecordActive")
    let imgRecordInactive: UIImage? = UIImage(named: "imgRecordInactive")
    let imgStopActive: UIImage? = UIImage(named: "imgStopActive")
    
    var recordState: RecordState = .normal {
        didSet {
            
            DispatchQueue.main.async {
                switch self.recordState {
                case .recording:
                    self.setImage(self.imgStopActive, for: .normal)
                case .normal:
                    self.setImage(self.imgRecordActive, for: .normal)
                case .disabled:
                    self.setImage(self.imgRecordInactive, for: .normal)
                }
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.translatesAutoresizingMaskIntoConstraints = false
        self.addTarget(self, action: #selector(onPress), for: .touchUpInside)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func recordEnd(data: Data?, error: Error?) {
        
        self.recordState = .normal
        self.delegate.recordEnd()
        
        if let error = error {
            print("\(#file) \(#function) \(error)")
        }
        
        if let data = data {
            self.delegate.receiveAudio(data: data)
        }
    }
    
    @objc func onPress(){
        
        switch self.recordState {
        case .recording:
            AudioManager.shared.stopRecord()
            
        case .normal:
            self.recordState = .recording
            delegate.recordStart()
            
            AudioManager.shared.pendingRecording = recordEnd(data:error:)
            AudioManager.shared.recordAudio(at: self.tmpDataURL)
            
        case .disabled:
            break
        }
    }
}
