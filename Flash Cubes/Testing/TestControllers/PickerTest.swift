//
//  PickerTest.swift
//  Flash Cubes
//
//  Created by Jeffrey Thompson on 5/7/19.
//  Copyright © 2019 Jeffrey Thompson. All rights reserved.
//

import UIKit

class PickerTest: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    let pickerImages: [UIImageView] = {
        var imgs = [UIImageView]()
        
        let audioImg = UIImage(named: "imgAudioNil")
        let audioView = UIImageView(image: audioImg)
        //audioView.transform = CGAffineTransform(rotationAngle: (.pi / 2)) // <- radians = 90 degrees.
        imgs.append(audioView)
        
        let textImg = UIImage(named: "imgTextThemeColor")
        let textView = UIImageView(image: textImg)
        //textView.transform = CGAffineTransform(rotationAngle: (.pi / 2))
        imgs.append(textView)
        
        let imgImg = UIImage(named: "imgImageThemeColor")
        let imgView = UIImageView(image: imgImg)
        //imgView.transform = CGAffineTransform(rotationAngle: (.pi / 2))
        imgs.append(imgView)
        
        return imgs
    }()
    
    var pickerViewHorizontal: UIPickerView = {
        var pickerView = UIPickerView(frame: .zero)
        pickerView.translatesAutoresizingMaskIntoConstraints = false
        pickerView.backgroundColor = .orange
        return pickerView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(pickerViewHorizontal)
        pickerViewHorizontal.delegate = self
        pickerViewHorizontal.dataSource = self
        
        NSLayoutConstraint.activate([
            pickerViewHorizontal.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            pickerViewHorizontal.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
            pickerViewHorizontal.widthAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor),
            pickerViewHorizontal.heightAnchor.constraint(equalToConstant: 200)
            ])
        // Do any additional setup after loading the view.
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 3
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 60
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        
        //let uiview = UIView(frame: CGRect(x: 0, y: 0, width: 60, height: 60))
        let img = UIImage(named: "imgAudioNil")
        return UIImageView(image: img)
        //imgView = UIImageView(image: img)
        //uiview.addSubview(imgView)
        
        //return pickerImages[row]
        //return uiview
    }

}
