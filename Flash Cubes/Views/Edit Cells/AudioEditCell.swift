//
//  AudioEditCell.swift
//  Flash Cubes
//
//  Created by Jeffrey Thompson on 5/4/19.
//  Copyright © 2019 Jeffrey Thompson. All rights reserved.
//

import UIKit

protocol AudioCellDelegate {
    func receiveAudio(data: Data?)
    func recordStart()
    func recordEnd()
    func playStart()
    func playEnd()
}

class AudioEditCell: UITableViewCell, AudioCellDelegate {
    
    enum AudioCellState {
        case neutral
        case recording
        case playing
        case disabled
    }
    
    static let cellHeight: CGFloat = (16 * 3) + (40 + 60)
    static let reuseIdentifier = "audioEditCell"
    
    var delegate: EditCellDelegate!
    var indexPath: IndexPath!
    
    var titleLabel: UILabel!
    
    var audioData: Data? {
        didSet {
            
            playButton?.data = self.audioData
            
            DispatchQueue.main.async {
                
                self.trashButton.removeFromSuperview()
                if self.audioData != nil {
                    self.addTrashCan()
                }
            }
        }
    }
    
    var playButton: AudioPlayButton!
    var recordButton: AudioRecordButton!
    var trashButton: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setImage(UIImage(named: "iconTrashCan"), for: .normal)
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()
    
    var audioCellState: AudioCellState = .neutral {
        didSet {
            switch self.audioCellState {
            case .neutral:
                recordButton.recordState = .normal
                playButton.playState = .normal
            case .playing:
                recordButton.recordState = .disabled
            case .recording:
                playButton.playState = .disabled
            case .disabled:
                playButton.playState = .disabled
                recordButton.recordState = .disabled
            }
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.selectionStyle = .none
        
        setupViews()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        contentView.subviews.forEach({$0.removeFromSuperview()})
        setupViews()
    }
    
    func setupViews(){
        self.backgroundColor = .clear
        contentView.backgroundColor = .clear
        
        let underlayer = UIView(frame: .zero)
        underlayer.translatesAutoresizingMaskIntoConstraints = false
        underlayer.backgroundColor = .underlay
        underlayer.layer.cornerRadius = 8
        underlayer.layer.masksToBounds = true
        
        contentView.addSubview(underlayer)
        
        NSLayoutConstraint.activate([
            underlayer.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            underlayer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            underlayer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            underlayer.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8)
            ])
        
        titleLabel = UILabel(frame: .zero)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = .title
        titleLabel.textAlignment = .left
        titleLabel.textColor = .white
        
        contentView.addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            titleLabel.widthAnchor.constraint(equalToConstant: self.frame.width * 0.8),
            titleLabel.heightAnchor.constraint(equalToConstant: 40)
            ])
        
        recordButton = AudioRecordButton(frame: .zero)
        recordButton.delegate = self
        recordButton.recordState = .normal
        
        contentView.addSubview(recordButton)
        
        NSLayoutConstraint.activate([
            recordButton.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 72.0),
            //recordButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: oneThird-16),
            recordButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor, constant: -90),
            recordButton.widthAnchor.constraint(equalToConstant: 60),
            recordButton.heightAnchor.constraint(equalToConstant: 60)
            ])
        
        playButton = AudioPlayButton(frame: .zero)
        playButton.delegate = self
        
        contentView.addSubview(playButton)
        
        NSLayoutConstraint.activate([
            playButton.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 72.0),
            //playButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: (-1.0 * oneThird) + 16),
            playButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor, constant: 90),
            playButton.widthAnchor.constraint(equalToConstant: 60),
            playButton.heightAnchor.constraint(equalToConstant: 60)
            ])
    }
    
    func addTrashCan() {
        
        contentView.addSubview(trashButton)
        trashButton.addTarget(self, action: #selector(onTrashPress), for: .touchUpInside)
        
        NSLayoutConstraint.activate([
            trashButton.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            trashButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            trashButton.widthAnchor.constraint(equalToConstant: 40),
            trashButton.heightAnchor.constraint(equalToConstant: 40)
            ])
    }
    
    @objc func onTrashPress(){
        delegate.editCell(didDeletePromptFor: indexPath)
    }

    func receiveAudio(data: Data?) {
        //delegate.editCell(didSendNew prompt: .audio(data), for indexPath: indexPath)
        delegate.editCell(didSendNew: .audio(data), for: indexPath)
        //playButton.data = data
        self.audioData = data
    }
    
    func recordStart() {
        delegate.editCell(didTakeAudioFocusForPath: indexPath)
        self.audioCellState = .recording
    }
    
    func recordEnd() {
        delegate.editCellDidEndAudioFocus()
        self.audioCellState = .neutral
    }
    
    func playStart() {
        delegate.editCell(didTakeAudioFocusForPath: indexPath)
        self.audioCellState = .playing
    }
    
    func playEnd() {
        delegate.editCellDidEndAudioFocus()
        self.audioCellState = .neutral
    }
}




