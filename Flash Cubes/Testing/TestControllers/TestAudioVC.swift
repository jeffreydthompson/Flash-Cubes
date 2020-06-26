//
//  TestAudioVC.swift
//  Flash Cubes
//
//  Created by Jeffrey Thompson on 4/23/19.
//  Copyright © 2019 Jeffrey Thompson. All rights reserved.
//

import UIKit

protocol PromptEditDelegate {
    
    func editPrompt(forKey: String, newPrompt: Any)
    
}

class TestAudioVC: UIViewController {

    var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupViews()
    }
    
    
    private func setupViews() {
        self.view.backgroundColor = UIColor.orange
        
        tableView = UITableView(frame: .zero)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.backgroundColor = UIColor.clear
        tableView.separatorStyle = .none
        
        self.view.addSubview(tableView)
        
        self.view.addConstraintsWithFormat(format: "H:|-8-[v0]-8-|", views: tableView)
        self.view.addConstraintsWithFormat(format: "V:[v0(400)]-8-|", views: tableView)
    }
    
    @objc func beginRecord(){
    
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension TestAudioVC: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 6
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 76.0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return AudioTestCell(row: indexPath.row)
        //return TestAudioCell(row: indexPath.row)
    }
    
}

extension TestAudioVC: UITableViewDelegate {
    
}


class TestAudioCell: UITableViewCell {
    
    enum AudioState {
        case neutral
        case recording
        case playing
    }
    
    var rowId: Int!
    var recordButton: UIButton?
    var playButton: UIButton?
    var audioData: Data? {
        didSet {
            DispatchQueue.main.async {
                self.updateViews()
            }
        }
    }
    var audioState: AudioState = .neutral
    
    public init(row: Int){
        super.init(style: .default, reuseIdentifier: nil)
        self.rowId = row
        setupViews()
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        rowId = 0
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews(){
        
        self.contentView.backgroundColor = UIColor.clear
        self.backgroundColor = UIColor.clear
        
        let underLayer = UIView(frame: .zero)
        underLayer.backgroundColor = UIColor(white: 1.0, alpha: 0.8)
        underLayer.layer.cornerRadius = 6.0
        underLayer.layer.masksToBounds = true
        
        self.addSubview(underLayer)
        addConstraintsWithFormat(format: "H:|-3-[v0]-3-|", views: underLayer)
        addConstraintsWithFormat(format: "V:|-3-[v0]-3-|", views: underLayer)
        
        recordButton = UIButton(type: .custom)
        recordButton?.setTitle("●", for: .normal)
        recordButton?.setTitleColor(UIColor.red, for: .normal)
        recordButton?.backgroundColor = UIColor(white: 1.0, alpha: 0.9)
        recordButton?.addTarget(self, action: #selector(recordButtonOnPress), for: .touchUpInside)
        
        playButton = UIButton(type: .custom)
        playButton?.setTitle("▶︎", for: .normal)
        playButton?.setTitleColor(UIColor.black, for: .normal)
        playButton?.backgroundColor = UIColor(white: 1.0, alpha: 0.9)
        playButton?.addTarget(self, action: #selector(playButtonOnPress), for: .touchUpInside)
        playButton?.isEnabled = (self.audioData != nil)
        
        self.addSubview(recordButton!)
        self.addSubview(playButton!)
        
        addConstraintsWithFormat(format: "H:|-20-[v0(60)]-140-[v1(60)]", views: recordButton!,playButton!)
        addConstraintsWithFormat(format: "V:|-8-[v0(60)]", views: recordButton!)
        addConstraintsWithFormat(format: "V:|-8-[v0(60)]", views: playButton!)
    }
    
    private func updateViews(){
        switch self.audioState {
        case .neutral:
            playButton?.setTitle("▶︎", for: .normal)
            playButton?.isEnabled = (self.audioData != nil)
            recordButton?.setTitle("●", for: .normal)
            playButton?.isEnabled = true
        case .playing:
            playButton?.setTitle("◼︎", for: .normal)
            playButton?.isEnabled = true
            recordButton?.setTitle("●", for: .normal)
            recordButton?.isEnabled = false
        case .recording:
            playButton?.setTitle("▶︎", for: .normal)
            playButton?.isEnabled = false
            recordButton?.setTitle("◼︎", for: .normal)
            recordButton?.isEnabled = true
        }
    }
    
    private func recordingCompletion(data: Data?, error: Error?){
        print("\(#function)")
        
        if let error = error {
            print("\(#function) \(error)")
            return
        }
        
        if let data = data {
            self.audioData = data
        }
    }
    
    private func playbackCompletion() {
        print("\(#function)")
        self.audioState = .neutral
        
        DispatchQueue.main.async {
            self.updateViews()
        }
    }
    
    @objc private func playButtonOnPress(){
        print("Pressed play button at row \(rowId ?? -999)")
        
        switch self.audioState {
        case .neutral:
            self.audioState = .playing
            
            DispatchQueue.main.async {
                self.updateViews()
            }
            
            AudioManager.shared.pendingPlaybackEnd = self.playbackCompletion
            
            if let data = audioData {
                AudioManager.shared.playAudio(fromData: data, atSpeed: .normal) { (success, error) in
                    if let error = error {
                        print("\(#function) \(error)")
                        return
                    }
                    
                    if let success = success {
                        print("\(#function) cell \(self.rowId ?? -999) playback success: \(success)")
                    } else {
                        print("\(#function) cell \(self.rowId ?? -999) playback unidentified error")
                    }
                }
            }
            
        case .playing:
            self.audioState = .neutral
            
            DispatchQueue.main.async {
                self.updateViews()
            }
            
            AudioManager.shared.stopPlay()
            
        default:
            break
        }
    }
    
    @objc private func recordButtonOnPress() {
        
        print("pressed record button at row \(rowId ?? -999)")
        
        switch self.audioState {
        case .neutral:
            
            self.audioState = .recording
            
            DispatchQueue.main.async {
                self.updateViews()
            }
            
            AudioManager.shared.pendingRecording = self.recordingCompletion
            
            AudioManager.shared.recordAudio { (success, error) in
                if let error = error {
                    print("\(#function) \(error)")
                    return
                }
                
                print("\(#function) cell \(self.rowId ?? -999) record success: \(String(describing: success))")
            }
            
        case .recording:
            self.audioState = .neutral
            
            DispatchQueue.main.async {
                self.updateViews()
            }
            
            AudioManager.shared.stopRecord()
            
        default:
            break
        }
    }
}
