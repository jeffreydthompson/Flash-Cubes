//
//  DLCPrepManager.swift
//  Flash Cubes
//
//  Created by Jeffrey Thompson on 5/27/19.
//  Copyright © 2019 Jeffrey Thompson. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation



struct DLCPrepManager {
    
    // Firebase Storage structures
    struct DLCPrepDeckInfo: Decodable {
        let name: String
        let protoPrompts: [String]
        let imageFileURLs: [String]? // large image files that get sliced up ex: "3:Words1to100.pdf" protopromptIndex: filename
        let audioFileURLs: [String]? // large audio files that get sliced up
        let cubes: [CubeData]?
    }
    
    struct CubeData: Decodable {
        let name: String
        let text: [String]?
        let audioURLPaths: [String]?
        let imageURLPaths: [String]?
        let imageThumbnailURLPaths: [String]?
        let audioCutoffTimes: [String]?
    }
    
    func getPrepDeck(fromJSON fileName: String, completion: @escaping (DLCPrepDeck?) -> Void) {
        
        //"1-100Ja.json"
        guard let info = getDeckInfo(fromJSON: fileName) else {completion(nil);return}
        
        var keys = [String : String]()
        
        var protoPrompts = [String : CubePrompt]()
        info.protoPrompts.forEach({
            
            let promptInfo = $0.components(separatedBy: ":")
            var prompt: CubePrompt? = nil
            
            keys[promptInfo[0]] = promptInfo[1]
            
            if promptInfo[2] == "text" {
                prompt = .text(nil)
            } else if promptInfo[2] == "audio" {
                prompt = .audio(nil)
            } else {
                prompt = .image(nil)
            }
            
            protoPrompts [promptInfo[1]] = prompt
        })
        
        var deck = DLCPrepDeck(name: info.name, protoPrompts: protoPrompts)
        
        info.cubes?.forEach({
            var cube = DLCPrepFlashCube()
            cube.name = $0.name
            $0.text?.forEach({ (textString) in
                let parsed = textString.components(separatedBy: ":")
                let key = keys[parsed[0]]!
                let prompt = CubePrompt.text(parsed[1])
                
                cube.prompts![key] = prompt
            })
            
            deck.flashCubes?.append(cube)
        })
        
        var imgDict = [String : [UIImage]]()
        info.imageFileURLs?.forEach({
            let parsed = $0.components(separatedBy: ":")
            
            if let img = UIImage(named: parsed[1]) {
                let array = slice(image: img)
                imgDict[parsed[0]] = array
            }
        })
        
        for (_ , array) in imgDict.enumerated() {
            for (cubeIndex, img) in array.value.enumerated() {
                let imgPrompt = CubePrompt.image(img)
            
                let key = keys[array.key]!
                deck.flashCubes?[cubeIndex].prompts?[key] = imgPrompt
            }
        }
        
        if info.audioFileURLs == nil {
            completion(deck)
            return
        }
        
        var audioAsyncCounter = (info.audioFileURLs?.count ?? 0) * (info.cubes?.count ?? 0)
        var audioFileIndex = -1
        info.audioFileURLs?.forEach({
            audioFileIndex += 1
            
            let parsed = $0.components(separatedBy: ":")
            let fileName = parsed[1].components(separatedBy: ".")[0]
            let promptIndex = Int(parsed[0])!
            
            if let cubes = info.cubes {
                for (cubeIndex, cube) in cubes.enumerated() {
                    
                    let cutOffTimesParsed = cube.audioCutoffTimes?[audioFileIndex].components(separatedBy: ":")
                    
                    guard let startMilliSeconds = Int64(cutOffTimesParsed![1]) else {
                        completion(nil)
                        return
                    }
                    
                    guard let endMilliSeconds = Int64(cutOffTimesParsed![2]) else {
                        completion(nil)
                        return
                    }
                    
                    let startTime = CMTime(value: startMilliSeconds, timescale: 1000)
                    let endTime = CMTime(value: endMilliSeconds, timescale: 1000)
                    
                    splitAudio(fileName: fileName, start: startTime, end: endTime, cubeIndex: cubeIndex, promptIndex: promptIndex, completion: { (data, error, returnedCubeIndex, returnedPromptIndex) in
                        
                        guard let data = data else {completion(nil); return}
                        if let _ = error {completion(nil); return}
                        
                        audioAsyncCounter -= 1
                        print(audioAsyncCounter)
                        
                        let key = keys["\(returnedPromptIndex)"]!
                        let audioPrompt = CubePrompt.audio(data)
                        deck.flashCubes?[returnedCubeIndex].prompts?[key] = audioPrompt
                        
                        if audioAsyncCounter == 0 {
                            completion(deck)
                        }
                    })
                }
            }
        })
    }
    
    private func getDeckInfo(fromJSON filePath: String) -> DLCPrepDeckInfo? {
        
        let filepath = Bundle.main.path(forResource: filePath, ofType: nil)!
        guard let data = FileManager.default.contents(atPath: filepath) else { return nil }
        
        do {
            let deck = try JSONDecoder().decode(DLCPrepDeckInfo.self, from: data)
            return deck
        } catch _ {
            return nil
        }
    }
    
    func saveAudioContainers(from deck: DLCPrepDeck) {
        
        if let containers = audioDataContainers(from: deck) {
            do {
                try audioContainersToFile(containers: containers)
            } catch let error {
                print("\(#function) \(error.localizedDescription)")
            }
        } else {
            print("\(#function) Error - no audio data in deck")
        }
        
    }
    
    private func audioContainersToFile(containers: [AudioDataContainer]) throws {
        for container in containers {
            let fileURL = Directory.testing.url.appendingPathComponent(container.promptName)
            
            do {
                let encodedData = try PropertyListEncoder().encode(container)
                FileManager.default.createFile(atPath: fileURL.path, contents: encodedData, attributes: nil)
            } catch let error {
                throw error
            }
        }
    }
    
    private func audioDataContainers(from prepDeck: DLCPrepDeck) -> [AudioDataContainer]? {
        
        let audioKeys = Array(prepDeck.protoPrompts!.filter({$0.value.type == .audio}).keys)
        
        var containers = [AudioDataContainer]()
        
        for key in audioKeys {
            
            var prompts = [CubePrompt]()
            
            for cube in prepDeck.flashCubes! {
                prompts.append(cube.prompts![key]!)
            }
            
            let container = AudioDataContainer(promptName: key, audioPrompts: prompts)
            containers.append(container)
        }
        
        if containers.count > 0 {
            return containers
        } else {
            return nil
        }
    }
    
    static func prepDeckToFile(prepDeck: DLCPrepDeck, completion: @escaping (Error?) -> Void) {
        
        guard let protoPrompts = prepDeck.protoPrompts else {return}
        
        let deck = FlashCubeDeck(protoPrompts: protoPrompts)
        deck.name = prepDeck.name != nil ? prepDeck.name! : "Temp Deck Name"
        
        
        prepDeck.flashCubes?.forEach({
            var cube = deck.protoCube
            cube?.name = $0.name
            cube?.prompts = $0.prompts
            
            do {
                try deck.submit(cube: cube!)
                
            } catch let error {
                completion(error)
                return
            }
        })
        
        //DeckTestManager.shared.save(deck: deck, withName: deck.deckSubFolder)
        let atPath = Directory.decks.url.appendingPathComponent(deck.deckSubFolder).path
        
        do {
            let data = try PropertyListEncoder().encode(deck)
            FileManager.default.createFile(atPath: atPath, contents: data, attributes: nil)
            completion(nil)
        } catch let error {
            completion(error)
            return
        }
    }
    
    private func splitAudio(fileName: String, start: CMTime, end: CMTime, cubeIndex: Int, promptIndex: Int, completion: @escaping (Data?, Error?, _ cubeIndex: Int, _ promptIndex: Int) -> Void){
        
        guard let url = Bundle.main.url(forResource: fileName, withExtension: "m4a") else {
            completion(nil, DownloadError.dataMissing, cubeIndex, promptIndex)
            return
        }
        
        let asset = AVAsset(url: url)
        if let exporter = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetAppleM4A) {
            let exportURL = UniqueTempAudioURL.m4a.generate
            exporter.outputFileType = AVFileType.m4a
            exporter.outputURL = exportURL
            let duration = end-start
            exporter.timeRange = CMTimeRangeMake(start: start, duration: duration)
            
            exporter.exportAsynchronously {
                
                switch exporter.status {
                case AVAssetExportSession.Status.completed:
                    //completion(exportURL, nil)
                    if let data = FileManager.default.contents(atPath: exportURL.path) {
                        completion(data, nil, cubeIndex, promptIndex)
                    } else {
                        completion(nil, DownloadError.dataMissing, cubeIndex, promptIndex)
                    }
                    break
                case AVAssetExportSession.Status.failed:
                    completion(nil, DownloadError.audioParse, cubeIndex, promptIndex)
                    break
                case AVAssetExportSession.Status.cancelled:
                    completion(nil, exporter.error, cubeIndex, promptIndex)
                    break
                default:
                    break
                }
            }
        }
    }
    
    private func slice(image: UIImage) -> [UIImage]? {
        
        guard let cgImg = image.cgImage else {return nil}
        
        //print("\(#function) \(cgImg.width)")
        //print("\(#function) \(cgImg.height)")
        
        //let columnsDiv = Double(cgImg.width) / 900.0
        //let rowsDiv = Double(cgImg.height) / 900.0
        let columns = 10//Int(columnsDiv.rounded())
        let rows = 10//Int(rowsDiv.rounded())
        
        //print("\(#function) \(columns)")
        //print("\(#function) \(rows)")
        
        let width = cgImg.width / columns
        let height = cgImg.height / rows
        var imageArray = [UIImage]()
        
        for row in 0..<rows {
            for column in 0..<columns {
                let x = width * column
                let y = height * row
                let cropRect = CGRect(x: x, y: y, width: width, height: height)
                let img = cgImg.cropping(to: cropRect)
                if let croppedImg = img {
                    let uiImg = UIImage(cgImage: croppedImg)
                    imageArray.append(uiImg)
                }
            }
        }
        
        if imageArray.count > 0 {
            return imageArray
        } else {
            return nil
        }
    }
    
    func firebaseDeck(fromJSON fileName: String) -> FirebaseDeck? {
        
        // from old JSON:  new coming soon.
        let typeDict = [
            "text"  : CubePrompt.text(nil),
            "audio" : CubePrompt.audio(nil),
            "image" : CubePrompt.image(nil)
        ]
        
        var promptsDict = [Int : String]()
        
        guard let info = getDeckInfo(fromJSON: fileName) else {return nil}
        
        guard let cubeNames = info.cubes?.map({$0.name}) else {return nil}
        
        var protoPrompts = [String : CubePrompt]()
        for protoString in info.protoPrompts {
            let parsed = protoString.components(separatedBy: ":")
            promptsDict[Int(parsed[0])!] = parsed[1]
            let promptType = typeDict[parsed[2]]!
            protoPrompts[parsed[1]] = promptType
        }
        
        var imageSheets = [String : Data]()
        info.imageFileURLs?.forEach({ (imgString) in
            
            let parsed = imgString.components(separatedBy: ":")
            
            let filepath = Bundle.main.path(forResource: "\(parsed[1]).pdf", ofType: nil)!
            guard let data = FileManager.default.contents(atPath: filepath) else { return }
            
            let key = promptsDict[Int(parsed[0])!]!
            imageSheets[key] = data
        })
        
        //need to build the audioContainers first...
        var audioContainers = [String : AudioDataContainer]()
        let audioPromptsKeys = Array(protoPrompts.filter({$0.value.type == .audio}).keys)
        for key in audioPromptsKeys {
            let audioPath = Directory.testing.url.appendingPathComponent(key).path
            if let data = FileManager.default.contents(atPath: audioPath) {
                do {
                    let container = try PropertyListDecoder().decode(AudioDataContainer.self, from: data)
                    audioContainers[key] = container
                } catch let error {
                    print("\(#function) \(error.localizedDescription)")
                }
            }
        }
        
        var texts = [String : [String]]()
        let textPromptsKeys = Array(protoPrompts.filter({$0.value.type == .text}).keys)
        for key in textPromptsKeys {
            texts[key] = [String]()
            
            info.cubes?.forEach({
                if let textArray = $0.text {
                    for str in textArray {
                        let parsed = str.components(separatedBy: ":")
                        if promptsDict[Int(parsed[0])!]! == key {
                            texts[key]?.append(parsed[1])
                        }
                    }
                }
            })
        }
        
        return FirebaseDeck(name: info.name, cubeNames: cubeNames, protoPrompts: protoPrompts, imageSheets: imageSheets, audioContainers: audioContainers, texts: texts)
        
    }
    
}


