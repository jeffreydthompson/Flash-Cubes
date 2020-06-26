//
//  DeckCreateTableCell.swift
//  Flash Cubes
//
//  Created by Jeffrey Thompson on 5/6/19.
//  Copyright © 2019 Jeffrey Thompson. All rights reserved.
//

import UIKit

class DeckCreateTableCell: UITableViewCell {
    
    enum ShowState {
        case immutable
        case noEditPromptType
        case fullNoButton
        case fullButton
        case partial
        case hidden
    }
    
    enum PromptOption {
        case text
        case audio
        case image
    }

    static let reuseidentifier = "DeckCreateTableCell"
    static let cellHeight = CGFloat(125 + 20)
    var indexPath: IndexPath!
    var delegate: CreateDeckCellDelegate!
    
    var underlayLeft: UIView = {
        let view = UIView(frame: .zero)
        view.backgroundColor = UIColor.underlay
        view.clipsToBounds = true
        view.layer.cornerRadius = 20
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner]
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    var underlayRight: UIView = {
        let view = UIView(frame: .zero)
        view.backgroundColor = UIColor.underlay
        view.clipsToBounds = true
        view.layer.cornerRadius = 20
        view.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMaxXMaxYCorner]
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    var cellTextfield: UITextField = {
       let tf = UITextField(frame: .zero)
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.backgroundColor = .white
        tf.textAlignment = .center
        tf.borderStyle = UITextField.BorderStyle.roundedRect
        tf.attributedPlaceholder = NSAttributedString(string: AppText.addTextHere)
        return tf
    }()
    
    var addRemoveButton: UIButton = {
        let button = UIButton(type: .custom)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 80)
        button.setTitleColor(.themeColor, for: .normal)
        //button.backgroundColor = .purple
        return button
    }()
    
    var showState: ShowState = .hidden {
        didSet {
            DispatchQueue.main.async {
                self.contentView.subviews.forEach({$0.removeFromSuperview()})
                self.setupViews()
            }
        }
    }
    
    var pickerView: UIPickerView = {
        let frame = CGRect(x: 0, y: 0, width: 60, height: 200)
        var pickerView = UIPickerView(frame: frame)
        pickerView.showsSelectionIndicator = false
        return pickerView
    }()
    
    var pickerViewHorizontal: UIPickerView = {
        var pickerView = UIPickerView(frame: .zero)
        pickerView.translatesAutoresizingMaskIntoConstraints = false
        pickerView.backgroundColor = .orange
        pickerView.showsSelectionIndicator = true
        return pickerView
    }()
    
    var option: PromptOption = .text {
        didSet {
            var selectedRow = 1
            switch self.option {
            case .audio:
                selectedRow = 0
            case .text:
                selectedRow = 1
            case .image:
                selectedRow = 2
            }
            
            DispatchQueue.main.async {
                self.pickerView.selectRow(selectedRow, inComponent: 0, animated: false)
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        contentView.subviews.forEach({$0.removeFromSuperview()})
        setupViews()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setupViews() {
        
        self.backgroundColor = .clear
        contentView.backgroundColor = .clear
        
        if showState == .hidden { return }
        
        contentView.addSubview(underlayLeft)
        
        NSLayoutConstraint.activate([
            underlayLeft.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            underlayLeft.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 6),
            underlayLeft.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -6),
            underlayLeft.widthAnchor.constraint(equalToConstant: 92)
            ])
        
        if showState != .immutable && showState != .fullNoButton {
            contentView.addSubview(addRemoveButton)
            
            NSLayoutConstraint.activate([
                addRemoveButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
                addRemoveButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
                addRemoveButton.heightAnchor.constraint(equalToConstant: 92),
                addRemoveButton.widthAnchor.constraint(equalToConstant: 92)
                ])
            
            if showState == .partial {
                addRemoveButton.setTitle("＋", for: .normal)
                addRemoveButton.addTarget(self, action: #selector(buttonOnPress), for: .touchUpInside)
                return
            } else {
                addRemoveButton.setTitle("－", for: .normal)
                addRemoveButton.addTarget(self, action: #selector(buttonOnPress), for: .touchUpInside)
            }
        }
        
        contentView.addSubview(underlayRight)
        
        NSLayoutConstraint.activate([
            underlayRight.leadingAnchor.constraint(equalTo: underlayLeft.trailingAnchor, constant: 4),
            underlayRight.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            underlayRight.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 6),
            underlayRight.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -6)
            ])
        
        contentView.addSubview(cellTextfield)
        cellTextfield.delegate = self
        
        NSLayoutConstraint.activate([
            cellTextfield.topAnchor.constraint(equalTo: underlayRight.topAnchor, constant: 10),
            cellTextfield.leadingAnchor.constraint(equalTo: underlayRight.leadingAnchor, constant: 15),
            cellTextfield.trailingAnchor.constraint(equalTo: underlayRight.trailingAnchor, constant: -15),
            cellTextfield.heightAnchor.constraint(equalToConstant: 30)
            ])
        
        contentView.addSubview(pickerView)
        pickerView.delegate = self
        pickerView.dataSource = self
        pickerView.transform = CGAffineTransform(rotationAngle: CGFloat(-(Double.pi / 2)))
        if self.showState == .noEditPromptType {
            pickerView.isUserInteractionEnabled = false
        } else {
            pickerView.isUserInteractionEnabled = true
        }
        
        let xOffset = CGFloat(92+16+4+16)
        let pickerWidth = (contentView.safeAreaLayoutGuide.layoutFrame.width - xOffset) - CGFloat(32)
        pickerView.frame = CGRect(x: xOffset,y: 60,width: pickerWidth,height: 60)
        
        
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        cellTextfield.resignFirstResponder()
    }
    
    private func getPromptOption() -> PromptOption {
        let pickerSelection = pickerView.selectedRow(inComponent: 0)
        switch pickerSelection {
        case 0:
            return .audio
        case 1:
            return .text
        default:
            return .image
        }
    }
    
    @objc func buttonOnPress(){
        
        let newState: ShowState = {
            switch self.showState {
            case .immutable:
                return .immutable
            case .fullNoButton:
                return .fullNoButton
            case .fullButton, .noEditPromptType:
                return .partial
            case .partial:
                return .fullButton
            case .hidden:
                return .hidden
            }
        }()
        
        delegate.createDeckCell(cellDidUpdateShowState: newState, cellAt: indexPath)
    }
}

extension DeckCreateTableCell: UITextFieldDelegate {
    
    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextField.DidEndEditingReason) {
        
        delegate.createDeckCell(cellDidUpdateTextField: textField.text, cellAt: indexPath)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        return true
    }
    
}

extension DeckCreateTableCell: UIPickerViewDelegate {
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        //print("\(#function) selected row: \(row)")
        let promptOption: PromptOption = {
            switch row {
            case 0:
                return .audio
            case 1:
                return .text
            default:
                return .image
            }
        }()

        delegate.createDeckCell(cellDidUpdatePromptOption: promptOption, cellAt: indexPath)
    }
    
}

extension DeckCreateTableCell: UIPickerViewDataSource {
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 60
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {

        var img: UIImage? = nil
        
        switch row {
        case 0:
            img = UIImage(named: "imgAudioThemeColor")
        case 1:
            img = UIImage(named: "imgTextThemeColor")
        default:
            img = UIImage(named: "imgImageThemeColor")
        }
        
        let imageView = UIImageView(image: img)
        imageView.transform = CGAffineTransform(rotationAngle: (.pi / 2))
        
        if self.showState == .noEditPromptType {
            imageView.alpha = 0.3
        }
        
        return imageView//UIImageView(image: img)

    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 3
    }
}
