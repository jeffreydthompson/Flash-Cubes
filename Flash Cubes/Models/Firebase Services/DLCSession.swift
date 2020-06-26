//
//  DLCSession.swift
//  Flash Cubes
//
//  Created by Jeffrey Thompson on 6/4/19.
//  Copyright © 2019 Jeffrey Thompson. All rights reserved.
//

import Foundation
import FirebaseStorage
import AVFoundation

struct DatabaseFolderCollection: Decodable {
    let folders: [DatabaseMainFolder]?
}

struct DatabaseMainFolder: Decodable {
    let name: String
    let subFolders: [DatabaseSubFolder]?
}

struct DatabaseSubFolder: Decodable {
    let name: String
    let content: [DatabaseContent]?
    let storageFolder: String
}

struct DatabaseContent: Decodable {
    let name: String
    let price: Double
    let IAPid: String?
    let filename: String?
}

struct AudioDataContainer: Codable {
    
    enum Key: CodingKey {
        case promptName
        case audioPrompts
    }
    
    var promptName: String
    var audioPrompts: [CubePrompt]
    
    init(promptName: String, audioPrompts: [CubePrompt]) {
        self.promptName = promptName
        self.audioPrompts = audioPrompts
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: Key.self)
        try container.encode(promptName, forKey: .promptName)
        try container.encode(audioPrompts, forKey: .audioPrompts)
    }
    
    init(from decoder: Decoder) throws {
        let container     = try decoder.container(keyedBy: Key.self)
        self.promptName   = try container.decode(String.self, forKey: .promptName)
        self.audioPrompts = try container.decode([CubePrompt].self, forKey: .audioPrompts)
    }
    
}

struct FirebaseDeck: Codable {
    
    enum Key: CodingKey {
        case name
        case cubeNames
        case protoPrompts
        case imageSheets
        case audioContainers
        case texts
    }
    
    var name: String
    var cubeNames: [String]
    var protoPrompts: [String : CubePrompt]
    var imageSheets: [String : Data]?
    var audioContainers: [String : AudioDataContainer]?
    var texts: [String : [String]]?
    
    init(name: String, cubeNames: [String], protoPrompts: [String : CubePrompt], imageSheets: [String : Data]?, audioContainers: [String : AudioDataContainer]?, texts: [String : [String]]?) {
        self.name = name
        self.cubeNames = cubeNames
        self.protoPrompts = protoPrompts
        self.imageSheets = imageSheets
        self.audioContainers = audioContainers
        self.texts = texts
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: Key.self)
        try container.encode(name, forKey: .name)
        try container.encode(cubeNames, forKey: .cubeNames)
        try container.encode(protoPrompts, forKey: .protoPrompts)
        try container.encodeIfPresent(imageSheets, forKey: .imageSheets)
        try container.encodeIfPresent(audioContainers, forKey: .audioContainers)
        try container.encodeIfPresent(texts, forKey: .texts)
    }
    
    init(from decoder: Decoder) throws {
        let container     = try decoder.container(keyedBy: Key.self)
        self.name         = try container.decode(String.self, forKey: .name)
        self.cubeNames    = try container.decode([String].self, forKey: .cubeNames)
        self.protoPrompts = try container.decode([String : CubePrompt].self, forKey: .protoPrompts)
        self.imageSheets  = try container.decodeIfPresent([String : Data].self, forKey: .imageSheets)
        self.audioContainers = try container.decodeIfPresent([String : AudioDataContainer].self, forKey: .audioContainers)
        self.texts           = try container.decodeIfPresent([String : [String]].self, forKey: .texts)
    }
    
}

class DLCSession {
    
    struct DownloadInfo: Decodable {
        let name: String
        let folderPath: String?
        let protoPrompts: [String]
        let imageFileURLs: [String]? // large image files that get sliced up ex: "3:Words1to100.pdf" protopromptIndex: filename
        let audioFileURLs: [String]? // large audio files that get sliced up
        let cubes: [CubeData]?
    }
    
    private struct ProgressTracker {
        var progress: Double
        var total: Double
    }
    
    private var storage = Storage.storage().reference()
    
    var delegate: DLCSessionDelegate!
    
    var jsonStoragePath: String
    var storagePath: String
    
    var firebaseFolderPath: String
    var firebaseComponentName: String
    
    private var deck: DLCPrepDeck? {
        didSet {
            print("\(#function) built.  Time for a new VC.")
            //guard let deck = self.deck else {return}
            //delegate.dlcSession(didDownload: deck)
            self.firebaseDeck(from: self.deck!, andJSON: self.jsonStoragePath)
        }
    }
    private var downloadInfo: DownloadInfo?
    
    private var pendingDownloads: (image: Bool, audio: Bool) = (false, false) {
        didSet {
            if pendingDownloads.image && pendingDownloads.audio {
                print("\(#function) downloads complete")
                self.buildDeckFromDownloadedData { (deck, error) in
                    
                    if let error = error {
                        print("\(#function) \(error.localizedDescription)")
                    }
                    
                    if let deck = deck {
                        self.deck = deck
                    }
                }
            }
        }
    }
    
    private var imageSheets = [Int : Data?]() {
        didSet {
            if imageSheets.count == 0 {return}
            if imageSheets.compactMap({$0.value}) == imageSheets.map({$0.value}) {
                pendingDownloads.image = true
            }
        }
    }
    
    private var audioReels = [Int : Data?]() {
        didSet {
            if audioReels.count == 0 {return}
            if audioReels.compactMap({$0.value}) == audioReels.map({$0.value}) {
                
                pendingDownloads.audio = true
            }
        }
    }

    private var audioPromptCounter = [Int]()
    
    private var protoPrompts = [String : CubePrompt]()
    private var promptIndexDict = [Int : String]()
    
    private var progressTrack = [Int: ProgressTracker]() {
        didSet {
            var totalSum = 0.0
            var completedSum = 0.0
            progressTrack.forEach { (key, value) in
                totalSum += value.total
                completedSum += value.progress
            }
            let percentage = (completedSum / totalSum) * 100
            print("\(#function) \(percentage)%, completed: \(completedSum), total: \(totalSum)")
        }
    }
    
    private let promptDict = [
        "text" : CubePrompt.text(nil),
        "audio" : CubePrompt.audio(nil),
        "image" : CubePrompt.image(nil)
    ]
    
    init(folderPath: String, componentName: String) {
        self.firebaseFolderPath = folderPath
        self.firebaseComponentName = componentName
        self.jsonStoragePath = ""
        self.storagePath = ""
    }
    
    init(storagePath: String) {
        self.jsonStoragePath = storagePath
        self.firebaseFolderPath = ""
        self.firebaseComponentName = ""
        
        var components = storagePath.components(separatedBy: "/")
        let _ = components.popLast()
        var assembled = ""
        for index in 0 ..< components.count-1 {
            assembled += components[index]
            assembled += "/"
        }
        assembled += components.last ?? ""
        
        self.storagePath = assembled
    }

    func initDeckDownload(){
        
        fetchJSON(from: jsonStoragePath) { (downloadInfo, error) in
            
            if let error = error {
                print("\(#function) \(error.localizedDescription)")
                return
            }
            
            guard let downloadInfo = downloadInfo else {
                //completion(nil, DownloadError.dataMissing)
                return
            }
            
            self.downloadInfo = downloadInfo
            
            downloadInfo.protoPrompts.forEach({ (prompt) in
                let parsed = prompt.components(separatedBy: ":")
                
                let index = Int(parsed[0])!, name = parsed[1], type = self.promptDict[parsed[2]]!
                
                self.promptIndexDict[index] = name
                self.protoPrompts[name] = type
            })
            downloadInfo.imageFileURLs?.forEach({ (imageURL) in
                let parsed = imageURL.components(separatedBy: ":")
                let index = Int(parsed[0])!, storagePath = parsed[1]
                self.imageSheets[index] = nil
                self.imageDownload(forIndex: index, fromPath: storagePath)
                })
            downloadInfo.audioFileURLs?.forEach({ (audioURL) in
                let parsed = audioURL.components(separatedBy: ":")
                let index = Int(parsed[0])!, storagePath = parsed[1]
                self.audioReels[index] = nil
                self.audioDownload(forIndex: index, fromPath: storagePath)
            })
        }
    }
    
    func buildDeckFromDownloadedData(completion: @escaping (DLCPrepDeck?, Error?) -> Void){
        
        guard let info = self.downloadInfo else {return}
        
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
            if let parsedIndex = Int(parsed[0]) {
                if let dataOptional = self.imageSheets[parsedIndex] {
                    if let data = dataOptional {
                        if let ciimg = CIImage(data: data, options: nil){
                            let context = CIContext(options: nil)
                            if let ref = context.createCGImage(ciimg, from: ciimg.extent){
                                let img = UIImage(cgImage: ref)
                                if let key = promptIndexDict[parsedIndex]{
                                    let array = slice(image: img)
                                    imgDict[key] = array
                                }
                            }
                            /*
                             CIImage *ciImage = image.CIImage;
                             CIContext *context = [CIContext contextWithOptions:nil];
                             CGImageRef ref = [context createCGImage:ciImage fromRect:ciImage.extent];
                             UIImage *newImage = [UIImage imageWithCGImage:ref];
                             */
                        }
                    }
                }
            }
//            if let img = UIImage(named: parsed[1]) {
//                let array = slice(image: img)
//                imgDict[parsed[0]] = array
//            }
        })
        
        for (_ , array) in imgDict.enumerated() {
            for (cubeIndex, img) in array.value.enumerated() {
                let imgPrompt = CubePrompt.image(img)
                
                deck.flashCubes?[cubeIndex].prompts?[array.key] = imgPrompt
            }
        }
        
        if info.audioFileURLs == nil {
            completion(deck, nil)
            return
        }
        
        let audioAsyncCounter = (info.audioFileURLs?.count ?? 0) * (info.cubes?.count ?? 0)
        var audioFileIndex = -1
        
        info.audioFileURLs?.forEach({
            audioFileIndex += 1
            
            let parsed = $0.components(separatedBy: ":")
            let promptIndex = Int(parsed[0])!
            let audioURL = UniqueTempAudioURL.m4a.generate//parsed[1].components(separatedBy: ".")[0]
            guard let dataOptional = self.audioReels[promptIndex] else {
                completion(deck, DownloadError.audioParse)
                return}
            guard let data = dataOptional else {
                completion(deck, DownloadError.audioParse)
                return}
            
            FileManager.default.createFile(atPath: audioURL.path, contents: data, attributes: nil)
            
            if let cubes = info.cubes {
                for (cubeIndex, cube) in cubes.enumerated() {
                    
                    let cutOffTimesParsed = cube.audioCutoffTimes?[audioFileIndex].components(separatedBy: ":")
                    
                    guard let startMilliSeconds = Int64(cutOffTimesParsed![1]) else {
                        completion(nil, DownloadError.audioParse)
                        return
                    }
                    
                    guard let endMilliSeconds = Int64(cutOffTimesParsed![2]) else {
                        completion(nil, DownloadError.audioParse)
                        return
                    }
                    
                    let startTime = CMTime(value: startMilliSeconds, timescale: 1000)
                    let endTime = CMTime(value: endMilliSeconds, timescale: 1000)
                    
                    splitAudio(url: audioURL, start: startTime, end: endTime, cubeIndex: cubeIndex, promptIndex: promptIndex, completion: { (data, error, returnedCubeIndex, returnedPromptIndex) in

                        if let error = error {
                            print("\(#function) \(error.localizedDescription)")
                            completion(nil, error)
                            return
                        }
                        
                        guard let data = data else {
                            completion(nil, error)
                            return
                        }
                        
                        let key = keys["\(returnedPromptIndex)"]!
                        let audioPrompt = CubePrompt.audio(data)
                        deck.flashCubes?[returnedCubeIndex].prompts?[key] = audioPrompt
                        
                        self.audioPromptCounter.append(0)
                        print("\(#function) \(self.audioPromptCounter.count) / \(audioAsyncCounter)")
                        
                        if audioAsyncCounter == self.audioPromptCounter.count {
                            completion(deck, nil)
                        }
                    })
                }
            }
        })
    }
    
    func imageDownload(forIndex: Int, fromPath: String) {
        
        FirebaseStorageService.fetchData(atFolder: storagePath, atPath: fromPath) { (data, error) in
            if let data = data {
                print("\(#function) download success")
                //self.pendingDownloads.image = true
                self.imageSheets[forIndex] = data
            }
        }
        
    }
    
    func audioDownload(forIndex: Int, fromPath: String) {
        
        FirebaseStorageService.fetchData(atFolder: storagePath, atPath: fromPath) { (data, error) in
            if let _ = data {
                print("\(#function) download success")
                self.audioReels[forIndex] = data
            }
        }
    }
    
    func fetchJSON(from filePath: String, completion: @escaping (DownloadInfo?, Error?) -> Void) {
        
        let itemRef = storage.child(filePath)
        
        itemRef.getData(maxSize: 1024 * 64) { (data, error) in
            if let _ = error {
                completion(nil, error)
                return
            }
            
            guard let data = data else {
                completion(nil, DownloadError.dataMissing)
                return
            }
            
            do {
                let deck = try JSONDecoder().decode(DownloadInfo.self, from: data)
                completion(deck, nil)
                return
            } catch let error {
                completion(nil, error)
                return
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
    
    static private func slice(image: UIImage) -> [UIImage]? {
        
        guard let cgImg = image.cgImage else {return nil}

        let columns = 10
        let rows = 10

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
    
    private func splitAudio(url: URL, start: CMTime, end: CMTime, cubeIndex: Int, promptIndex: Int, completion: @escaping (Data?, Error?, _ cubeIndex: Int, _ promptIndex: Int) -> Void){
        
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
                    completion(nil, DownloadError.customError, cubeIndex, promptIndex)
                    break
                }
            }
        } else {
            completion(nil, DownloadError.customError, cubeIndex, promptIndex)
        }
    }
    
    
    
    static func testPullAudioContainerFromFirebase(){
        let folder = "Languages/En to X/Japanese/1-100EnJa"
        let path = "Japanese Audio"
        
        FirebaseStorageService.fetchData(atFolder: folder, atPath: path) { (data, error) in
            
            if let error = error {
                print("\(#function) \(error.localizedDescription)")
                return
            }
            
            if let data = data {
                
                do {
                    let container = try PropertyListDecoder().decode(AudioDataContainer.self, from: data)
                    print(container as Any)
                } catch let error {
                    print("\(#function) \(error.localizedDescription)")
                }
                
            } else {
                print("\(#function) Error - no data")
                return
            }
        }
    }
    
    func downloadFirebaseDeck(completion: @escaping (FirebaseDeck?, Error?) -> Void) {
        let folder = self.firebaseFolderPath//"Languages/En to X/Japanese"//"Languages/En to X/Vietnamese"
        let path = self.firebaseComponentName//"Japanese 1-100"//"Vietnamese 401-500"//
        
        FirebaseStorageService.fetchData(atFolder: folder, atPath: path) { (data, error) in
            
            if let error = error {
                print("\(#function) \(error.localizedDescription)")
                completion(nil, error)
                return
            }
            
            if let data = data {
                
                do {
                    let deck = try PropertyListDecoder().decode(FirebaseDeck.self, from: data)
                    print(deck as Any)
                    completion(deck, nil)
                } catch let error {
                    print("\(#function) \(error.localizedDescription)")
                    completion(nil, error)
                }
                
            } else {
                print("\(#function) Error - no data")
                completion(nil, DownloadError.customError)
                return
            }
        }
    }
    
    func prepDeck(from firebaseDeck: FirebaseDeck) -> DLCPrepDeck {
        
        var deck = DLCPrepDeck(name: firebaseDeck.name, protoPrompts: firebaseDeck.protoPrompts)
        
        deck.flashCubes = [DLCPrepFlashCube]()
        
        firebaseDeck.cubeNames.forEach({ cubeName in
            var flashCube = DLCPrepFlashCube()
            flashCube.name = cubeName
            flashCube.prompts = [String : CubePrompt]()
            deck.flashCubes?.append(flashCube)
        })
        
        firebaseDeck.imageSheets?.forEach({ (promptKey, data) in
            if let ciimg = CIImage(data: data, options: nil){
                let context = CIContext(options: nil)
                if let ref = context.createCGImage(ciimg, from: ciimg.extent){
                    let img = UIImage(cgImage: ref)
                    if let array = slice(image: img) {
                        for (index, image) in array.enumerated() {
                            let prompt = CubePrompt.image(image)
                            deck.flashCubes![index].prompts![promptKey] = prompt
                        }
                    }
                }
            }
        })
        
        firebaseDeck.audioContainers?.forEach({ (promptKey, audioContainer) in
            
            for (index, prompt) in audioContainer.audioPrompts.enumerated() {
                deck.flashCubes![index].prompts![promptKey] = prompt
            }
            
        })
        
        firebaseDeck.texts?.forEach({ (promptKey, stringArray) in
            for (index, text) in stringArray.enumerated() {
                let prompt = CubePrompt.text(text)
                deck.flashCubes![index].prompts![promptKey] = prompt
            }
        })
        
        return deck
    }
    
    func firebaseDeck(from deck: DLCPrepDeck, andJSON atPath: String) {
        
        guard let info = self.downloadInfo else {return}
        
        var promptsDict = [Int : String]()
        for protoString in info.protoPrompts {
            let parsed = protoString.components(separatedBy: ":")
            promptsDict[Int(parsed[0])!] = parsed[1]
        }
        
        var imageSheetsDict = [String : Data]()
        self.imageSheets.forEach({ (intKey, data) in
            let key = promptsDict[intKey]!
            imageSheetsDict[key] = data
        })
        
        let name = deck.name ?? ""
        let protoPrompts = deck.protoPrompts!
        let cubeNames = deck.flashCubes!.map({$0.name!})
        
        let audioPromptKeys = Array(protoPrompts.filter({$0.value.type == .audio}).keys)
        var audioContainers = [String : AudioDataContainer]()
        audioPromptKeys.forEach({ key in
            
            var audioPrompts = [CubePrompt]()
            deck.flashCubes?.forEach({ cube in
                if let prompt = cube.prompts?[key] {
                    audioPrompts.append(prompt)
                }
            })
            
            let audioContainer = AudioDataContainer(promptName: key, audioPrompts: audioPrompts)
            audioContainers[key] = audioContainer
        })
        
        let textPromptKeys = Array(protoPrompts.filter({$0.value.type == .text}).keys)
        var textContainers = [String : [String]]()
        textPromptKeys.forEach({ key in
            textContainers[key] = [String]()
            
            deck.flashCubes?.forEach({ cube in
                if let prompt = cube.prompts?[key] {
                    switch prompt {
                    case .text(let str):
                        if let text = str {
                            textContainers[key]?.append(text)
                        }
                    default:
                        break
                    }
                }
            })
        })
        
        let firebaseDeck = FirebaseDeck.init(name: name, cubeNames: cubeNames, protoPrompts: protoPrompts, imageSheets: imageSheetsDict, audioContainers: audioContainers, texts: textContainers)
        
        print("\(#function) \(firebaseDeck as Any)")
        
        let filePath = Directory.testing.url.appendingPathComponent(name).path
        
        do {
            let data = try PropertyListEncoder().encode(firebaseDeck)
            FileManager.default.createFile(atPath: filePath, contents: data, attributes: nil)
        } catch let error {
            print("\(#function) \(error.localizedDescription)")
        }
    }
    
}
