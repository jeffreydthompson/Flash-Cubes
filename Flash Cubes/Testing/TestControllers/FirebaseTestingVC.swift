//
//  FirebaseTestingVC.swift
//  Flash Cubes
//
//  Created by Jeffrey Thompson on 6/7/19.
//  Copyright © 2019 Jeffrey Thompson. All rights reserved.
//

import UIKit
import AVFoundation

class FirebaseTestingVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.random

        // Do any additional setup after loading the view.
        //firebaseTesting()
        //audioSplicing(jsonFilename: "401to500VT.json", audioFileName: "401to500VT")
        ENaudioSplicing(csvFilename: "401-500EnTimeSplits", audioFileName: "401-500En")
    }
    
    func ENaudioSplicing(csvFilename: String, audioFileName: String){
        //"101to200VT.json"
        //"101-200Vi"
        do {
            let contents = try FileManager.default.contentsOfDirectory(at: Directory.dlc.url, includingPropertiesForKeys: nil, options: FileManager.DirectoryEnumerationOptions.skipsHiddenFiles)
            try contents.forEach({ url in
                try FileManager.default.removeItem(at: url)
            })
        } catch let error {
            print(error.localizedDescription)
        }
        
        guard let audioURL = Bundle.main.url(forResource: audioFileName, withExtension: "m4a") else {fatalError("no audio file")}
        //guard let audioData = FileManager.default.contents(atPath: audioPath) else {fatalError("couldn't load audio")}
        
        let audioAsset = AVAsset(url: audioURL)
        //JSONDecoder().decode(StoredDeck.self, from: data)
        
        guard let textFile = Bundle.main.url(forResource: csvFilename, withExtension: "csv") else { fatalError("textFile not found") }
        //let textFile = Bundle.main.path(forResource: "1-100text.ko.csv", ofType: nil)!
        do {
            let text = try String(contentsOf: textFile, encoding: String.Encoding.utf8)
            
            let readLines = text.components(separatedBy: "\r")
            guard readLines.count > 1 else {fatalError("readlines didn't split correctly. need \r")}
            
            for line in readLines {
                var spliced = line.components(separatedBy: ",")
                let name = spliced[1]
                guard let start = Int64(spliced[2]) else {fatalError("Splice error")}
                guard let end = Int64(spliced[3]) else {fatalError("Splice error")}
                
                let startTime = CMTime(value: start, timescale: 1000)
                let endTime = CMTime(value: end, timescale: 1000)
                
                if let exporter = AVAssetExportSession(asset: audioAsset, presetName: AVAssetExportPresetAppleM4A) {
                    
                    exporter.outputFileType = AVFileType.m4a
                    let fileName = "\(name.lowercased()).en.m4a"
                    exporter.outputURL = Directory.dlc.url.appendingPathComponent(fileName)
                    let duration = endTime - startTime
                    exporter.timeRange = CMTimeRangeMake(start: startTime, duration: duration)
                    
                    exporter.exportAsynchronously {
                        print("saved \(name.lowercased()).en.m4a")
                    }
                }
            }
        } catch let error {
            fatalError(error.localizedDescription)
        }
        
    }
    
    func audioSplicing(jsonFilename: String, audioFileName: String){
        //"101to200VT.json"
        //"101-200Vi"
        do {
            let contents = try FileManager.default.contentsOfDirectory(at: Directory.dlc.url, includingPropertiesForKeys: nil, options: FileManager.DirectoryEnumerationOptions.skipsHiddenFiles)
            try contents.forEach({ url in
                try FileManager.default.removeItem(at: url)
            })
        } catch let error {
            print(error.localizedDescription)
        }
        
        guard let jsonPath = Bundle.main.path(forResource: jsonFilename, ofType: nil) else {fatalError("no json file")}
        guard let jsonData = FileManager.default.contents(atPath: jsonPath) else {fatalError("couldn't load json data")}
        guard let audioURL = Bundle.main.url(forResource: audioFileName, withExtension: "m4a") else {fatalError("no audio file")}
        //guard let audioData = FileManager.default.contents(atPath: audioPath) else {fatalError("couldn't load audio")}
        
        let audioAsset = AVAsset(url: audioURL)
        //JSONDecoder().decode(StoredDeck.self, from: data)
        do {
            let storedDeck = try JSONDecoder().decode(StoredDeck.self, from: jsonData)
            
            storedDeck.cubes?.forEach({ cube in
                cube.audioCutoffTimes?.forEach({ cutOffs in
                    let spliced = cutOffs.components(separatedBy: ":")
                    guard let start = Int64(spliced[1]) else {fatalError("Splice error")}
                    guard let end = Int64(spliced[2]) else {fatalError("Splice error")}
                    
                    let startTime = CMTime(value: start, timescale: 1000)
                    let endTime = CMTime(value: end, timescale: 1000)
                    
                    if let exporter = AVAssetExportSession(asset: audioAsset, presetName: AVAssetExportPresetAppleM4A) {
                        
                        exporter.outputFileType = AVFileType.m4a
                        let fileName = "\(cube.name.lowercased()).vi.m4a"
                        exporter.outputURL = Directory.dlc.url.appendingPathComponent(fileName)
                        let duration = endTime - startTime
                        exporter.timeRange = CMTimeRangeMake(start: startTime, duration: duration)
                        
                        exporter.exportAsynchronously {
                            print("saved \(cube.name.lowercased()).vi.m4a")
                        }
                    }
                })
            })
            
        } catch let error {
            fatalError(error.localizedDescription)
        }
        
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    /*func firebaseTesting(){
        
        Auth.auth().signInAnonymously { (result, error) in
            
            if let error = error {
                print("\(#function) \(error.localizedDescription)")
                self.navigationController?.popViewController(animated: true)
            }
            
            if result != nil {
                downloadFirebaseDeck(completion: { (firebaseDeck, error) in
                    
                    if let error = error {
                        print("\(#function) \(error.localizedDescription)")
                    }
                    
                    guard let firebackDeck = firebaseDeck else {return}
                    
                    let prepDeck = DLCSession.prepDeck(from: firebackDeck)
                    
                    let contentVC = FirebaseContenVC()
                    contentVC.deck = prepDeck
                    self.navigationController?.pushViewController(contentVC, animated: true)
                    
                })
            }
        }
    }*/

}
