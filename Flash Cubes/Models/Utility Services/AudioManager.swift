//
//  AudioManager.swift
//  Flash Cubes
//
//  Created by Jeffrey Thompson on 4/23/19.
//  Copyright © 2019 Jeffrey Thompson. All rights reserved.
//

import Foundation
import AVFoundation

enum AudioPlaybackSpeed {
    case fast
    case normal
    case slow
}

class AudioManager: NSObject {
    
    enum AVError: Error {
        case recordingError
        case playbackError
    }
    
    enum AudioManagerState {
        case neutral
        case recording
        case playing
    }
    
    static public let shared = AudioManager()
    
    private var avSession: AVAudioSession!
    private var avPlayer: AVAudioPlayer?
    private var avRecorder: AVAudioRecorder?
    
    private var managerState: AudioManagerState = .neutral
    public var pendingRecording: ((Data?, Error?) -> Void)?
    public var pendingPlaybackEnd: (() -> Void)?
    private var pendingRecordingURL: URL?
    
    private override init(){
        self.avSession = AVAudioSession.sharedInstance()
    }
    
    public func initRecorder(atURL: URL) {
        do {
            try avSession.setCategory(AVAudioSession.Category.record)
        } catch let error {
            print("\(#function) \(error)")
            return
        }
        
        let settings = [
            AVFormatIDKey : kAudioFormatAppleLossless,
            AVEncoderAudioQualityKey : AVAudioQuality.max.rawValue,
            AVNumberOfChannelsKey : 2,
            AVEncoderBitRateKey : 128000,
            AVSampleRateKey : 44100
            ] as [String : Any]
        
        do {
            try avRecorder = AVAudioRecorder(url: atURL, settings: settings)
            avRecorder?.delegate = self
            avRecorder?.prepareToRecord()
        } catch let error {
            print("\(#function) \(error)")
        }
    }
    
    private func initPlayer(fromData: Data, atSpeed: AudioPlaybackSpeed) {
        do {
            try avSession.setCategory(AVAudioSession.Category.playback)
        } catch let error {
            print("\(#function) \(error)")
            return
        }
        
        do {
            try avPlayer = AVAudioPlayer(data: fromData, fileTypeHint: AVFileType.m4a.rawValue)
            avPlayer?.delegate = self
            avPlayer?.enableRate = true
            
            switch atSpeed {
            case .fast:
                avPlayer?.rate = 1.5
            case .normal:
                avPlayer?.rate = 1.0
            case .slow:
                avPlayer?.rate = 0.5
            }
            
            avPlayer?.volume = 1.0
            avPlayer?.prepareToPlay()
            
        } catch let error {
            print("\(#function) \(error)")
        }
    }
    
    public func playAudio(fromData: Data, atSpeed: AudioPlaybackSpeed, completion: @escaping (Bool?, Error?) -> Void) {
        self.managerState = .playing
        
        initPlayer(fromData: fromData, atSpeed: atSpeed)
        
        if let playSuccess = avPlayer?.play() {
            completion(playSuccess, nil)
        } else {
            completion(nil, AVError.playbackError)
        }
    }
    
    public func stopPlay(){
        avPlayer?.stop()
    }
    
    public func stopRecord(){
        avRecorder?.stop()
    }
    
    public func recordAudio(completion: @escaping (Bool?, Error?) -> Void) {
        self.pendingRecordingURL = UniqueTempAudioURL.m4a.generate
        self.managerState = .recording
        
        initRecorder(atURL: pendingRecordingURL!)
        if let recordSuccess = avRecorder?.record() {
            completion(recordSuccess, nil)
        } else {
            completion(nil, AVError.recordingError)
        }
    }
    
    public func recordAudio(at url: URL) {
        self.managerState = .recording
        
        self.pendingRecordingURL = url
        initRecorder(atURL: self.pendingRecordingURL!)
        
        avRecorder?.record()
    }
}

extension AudioManager: AVAudioPlayerDelegate {
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        //print("\(#function)")
        
        self.pendingPlaybackEnd?()
        self.pendingPlaybackEnd = nil
        
        self.managerState = .neutral
    }
    
    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        //print("\(#function)")
        
        self.pendingPlaybackEnd?()
        self.pendingPlaybackEnd = nil
        
        self.managerState = .neutral
    }
}

extension AudioManager: AVAudioRecorderDelegate {
    
    func audioRecorderEncodeErrorDidOccur(_ recorder: AVAudioRecorder, error: Error?) {
        //print("\(#function)")
        self.managerState = .neutral
    }
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        //print("\(#function)")
        
        switch self.managerState {
        case .recording:
            if let path = pendingRecordingURL?.path {
                if let data = FileManager.default.contents(atPath: path) {
                    self.pendingRecording?(data, nil)
                } else {
                    self.pendingRecording?(nil, AVError.recordingError)
                }
            } else {
                self.pendingRecording?(nil, AVError.recordingError)
            }
        default:
            break
        }
        
        self.pendingRecordingURL = nil
        self.pendingRecording = nil
        
        self.managerState = .neutral
    }
    
}
