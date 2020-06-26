//
//  FirebaseDeckBuilder.swift
//  Flash Cubes
//
//  Created by Jeffrey Thompson on 6/10/19.
//  Copyright © 2019 Jeffrey Thompson. All rights reserved.
//
//gs://flash-cubes.appspot.com/Languages/Vi to X/French/Tiếng Pháp 101-200

import Foundation
import UIKit

struct FirebaseDeckBuilder {
    
    struct SupportedLanguages {
        
        struct Language: Hashable {
            var language: String
            var code: String
        }
        
        static var English = Language(language: "English", code: "en")//(language: "English", code: "en")
        static var Korean = Language(language: "Korean", code: "ko")
        static var Vietnamese = Language(language: "Vietnamese", code: "vi")
        static var Japanese = Language(language: "Japanese", code: "ja")
        static var French = Language(language: "French", code: "fr")
    }

    static func languageName(language: SupportedLanguages.Language, inLanguage: SupportedLanguages.Language) -> String {
        
        switch inLanguage {
            
        case SupportedLanguages.English:
            switch language {
            case SupportedLanguages.English:
                return "English"
            case SupportedLanguages.Vietnamese:
                return "Vietnamese"
            case SupportedLanguages.Korean:
                return "Korean"
            case SupportedLanguages.Japanese:
                return "Japanese"
            case SupportedLanguages.French:
                return "French"
            default:
                return ""
            }
            
        case SupportedLanguages.French:
            switch language {
            case SupportedLanguages.English:
                return "Anglais"
            case SupportedLanguages.Vietnamese:
                return "Vietnamien"
            case SupportedLanguages.Korean:
                return "Coréen"
            case SupportedLanguages.Japanese:
                return "Japonais"
            case SupportedLanguages.French:
                return "Français"
            default:
                return ""
            }
            
        case SupportedLanguages.Vietnamese:
            switch language {
            case SupportedLanguages.English:
                return "Tiếng Anh"
            case SupportedLanguages.Korean:
                return "Tiếng Hàn"
            case SupportedLanguages.Japanese:
                return "Tiếng Nhật"
            case SupportedLanguages.Vietnamese:
                return "Tiếng Việt"
            case SupportedLanguages.French:
                return "Tiếng Pháp"
            default:
                return ""
            }
            
        case SupportedLanguages.Korean:
            switch language {
            case SupportedLanguages.English:
                return "영어"
            case SupportedLanguages.Korean:
                return "한국어"
            case SupportedLanguages.Vietnamese:
                return "베트남어"
            case SupportedLanguages.Japanese:
                return "일본어"
            case SupportedLanguages.French:
                return "프랑스어"
            default:
                return ""
            }
        case SupportedLanguages.Japanese:
            switch language {
            case SupportedLanguages.English:
                return "英語"
            case SupportedLanguages.Vietnamese:
                return "ベトナム語"
            case SupportedLanguages.Korean:
                return "韓国語"
            case SupportedLanguages.Japanese:
                return "日本語"
            case SupportedLanguages.French:
                return "フランス語"
            default:
                return ""
            }
        default:
            return ""
        }
    }
    
    static func textPromptName(fromLanguage: SupportedLanguages.Language, toLanguage: SupportedLanguages.Language) -> String {
        
        switch fromLanguage {
        case SupportedLanguages.English:
            return "\(languageName(language: toLanguage, inLanguage: SupportedLanguages.English)) text"
        case SupportedLanguages.French:
            return "\(languageName(language: toLanguage, inLanguage: SupportedLanguages.French)) texte"
        case SupportedLanguages.Vietnamese:
            return "Từ \(languageName(language: toLanguage, inLanguage: SupportedLanguages.Vietnamese))"
        case SupportedLanguages.Korean:
            return "\(languageName(language: toLanguage, inLanguage: SupportedLanguages.Korean)) 텍스트"
        case SupportedLanguages.Japanese:
            return "\(languageName(language: toLanguage, inLanguage: SupportedLanguages.Japanese))のテキスト"
        default:
            break
        }
        
        return ""
    }
    
    static func phoneticTextPromptName(fromLanguage: SupportedLanguages.Language, toLanguage: SupportedLanguages.Language) -> String {
        
        switch fromLanguage {
        case SupportedLanguages.English:
            return "\(languageName(language: toLanguage, inLanguage: SupportedLanguages.English)) phonetic text"
        case SupportedLanguages.French:
            return "\(languageName(language: toLanguage, inLanguage: SupportedLanguages.French)) texte phonétique"
        case SupportedLanguages.Vietnamese:
            return "Từ \(languageName(language: toLanguage, inLanguage: SupportedLanguages.Vietnamese)) chữ Latinh"
        case SupportedLanguages.Korean:
            return "\(languageName(language: toLanguage, inLanguage: SupportedLanguages.Korean)) 라틴 문자"
        case SupportedLanguages.Japanese:
            return "\(languageName(language: toLanguage, inLanguage: SupportedLanguages.Japanese))のラテン文字"
        default:
            break
        }
        
        return ""
    }
    
    static func audioPromptName(fromLanguage: SupportedLanguages.Language, toLanguage: SupportedLanguages.Language) -> String {
        
        switch fromLanguage {
        case SupportedLanguages.English:
            return "\(languageName(language: toLanguage, inLanguage: SupportedLanguages.English)) audio"
        case SupportedLanguages.French:
            return "Audio \(languageName(language: toLanguage, inLanguage: SupportedLanguages.French))"
        case SupportedLanguages.Vietnamese:
            return "Âm thanh \(languageName(language: toLanguage, inLanguage: SupportedLanguages.Vietnamese))"
        case SupportedLanguages.Korean:
            return "\(languageName(language: toLanguage, inLanguage: SupportedLanguages.Korean)) 오디오"
        case SupportedLanguages.Japanese:
            return "\(languageName(language: toLanguage, inLanguage: SupportedLanguages.Japanese))の音声"
        default:
            break
        }
        
        return ""
    }
    
    static func imagePromptName(fromLanguage: SupportedLanguages.Language) -> String {
        
        switch fromLanguage {
        case SupportedLanguages.English:
            return "Images"
        case SupportedLanguages.English:
            return "Images"
        case SupportedLanguages.Vietnamese:
            return "Hình ảnh"
        case SupportedLanguages.Korean:
            return "이미지"
        case SupportedLanguages.Japanese:
            return "画像"
        default:
            break
        }
        
        return ""
    }
    
    static func buildDeck(fromLanguage: SupportedLanguages.Language, toLanguage: SupportedLanguages.Language, from: Int, to: Int ) {
        
        /*
         masterlists guide
         
         [0] audiofile name (still need to add language code suffix) & English secondary text
         [1] English primary text
         [2] Viet text
         [3] Korean text
         [4] Korean phonetic text
         [5] Japanese text
         [6] Japanese phonetic text
         
         */
        
        let primaryTextIndex: Int = {
            switch fromLanguage {
            case SupportedLanguages.English:
                return 1
            case SupportedLanguages.French:
                return 7
            case SupportedLanguages.Korean:
                return 3
            case SupportedLanguages.Japanese:
                return 5
            case SupportedLanguages.Vietnamese:
                return 2
            default:
                return -1
            }
        }()
        
        let targetTextIndex: Int = {
            switch toLanguage {
            case SupportedLanguages.English:
                return 1
            case SupportedLanguages.French:
                return 7
            case SupportedLanguages.Korean:
                return 3
            case SupportedLanguages.Japanese:
                return 5
            case SupportedLanguages.Vietnamese:
                return 2
            default:
                return -1
            }
        }()
        
        let cubeNameIndex: Int = {
            switch fromLanguage {
            case SupportedLanguages.English:
                return 0
            case SupportedLanguages.French:
                return 7
            case SupportedLanguages.Vietnamese:
                return 2
            case SupportedLanguages.Korean:
                return 3
            case SupportedLanguages.Japanese:
                return 5
            default:
                return -1
            }
        }()
        
        let phoneticIndex: Int? = {
            switch toLanguage {
            case SupportedLanguages.Korean:
                return 4
            case SupportedLanguages.Japanese:
                return 6
            default:
                return nil
            }
        }()
        
        
        let languageName = self.languageName(language: toLanguage, inLanguage: fromLanguage)
        
        let range = "\(from)-\(to)"
        
        let name = "\(languageName) \(range)"
        // "Từ tiếng \(languageName) chữ Latin" : CubePrompt.text(nil),
        
        let primaryTextPromptName = self.textPromptName(fromLanguage: fromLanguage, toLanguage: fromLanguage)
        let targetTextPromptName = self.textPromptName(fromLanguage: fromLanguage, toLanguage: toLanguage)
        let audioPromptName = self.audioPromptName(fromLanguage: fromLanguage, toLanguage: toLanguage)
        let imagePromptName = self.imagePromptName(fromLanguage: fromLanguage)
        
        var protoPrompts = [
            primaryTextPromptName : CubePrompt.text(nil),
            targetTextPromptName : CubePrompt.text(nil),
            audioPromptName : CubePrompt.audio(nil),
            imagePromptName : CubePrompt.image(nil)
        ]
        
        if let _ = phoneticIndex {
            let phoneticText = self.phoneticTextPromptName(fromLanguage: fromLanguage, toLanguage: toLanguage)
            protoPrompts[phoneticText] = CubePrompt.text(nil)
        }
        
        let textFileName = "\(range)text.master"
        print("\(#function) csv fileName: \(textFileName)")
        
        guard let textFile = Bundle.main.url(forResource: textFileName, withExtension: "csv") else { fatalError("textFile not found") }
        
        do {
            let text = try String(contentsOf: textFile, encoding: String.Encoding.utf8)
            let readLines = text.components(separatedBy: "\n")
            
            guard readLines.count > 1 else {fatalError("readlines didn't split correctly. need \r")}
            
            var cubeNames = [String]()
            var texts = [String : [String]]()
            texts[primaryTextPromptName] = [String]()
            texts[targetTextPromptName] = [String]()
            if let _ = phoneticIndex {
                let phoneticText = self.phoneticTextPromptName(fromLanguage: fromLanguage, toLanguage: toLanguage)
                texts[phoneticText] = [String]()
            }
            //texts["Từ tiếng \(languageName) chữ Latinh"] = [String]()
            
            var audioContainers = [String : AudioDataContainer]()
            var audioPrompts = [CubePrompt]()
            
            for line in readLines {
                print(line)
                
                let parsed = line.components(separatedBy: ",")
                
                cubeNames.append(parsed[cubeNameIndex].capitalized)
                
                texts[targetTextPromptName]!.append(parsed[targetTextIndex])
                texts[primaryTextPromptName]!.append(parsed[primaryTextIndex])
                
                if let phonetic = phoneticIndex {
                    let phoneticText = self.phoneticTextPromptName(fromLanguage: fromLanguage, toLanguage: toLanguage)
                    texts[phoneticText]!.append(parsed[phonetic])
                }
                
                //                let audioFileName = "\(parsed[0]).ko.m4a"
                //                guard let audioFile = Bundle.main.path(forResource: audioFileName, ofType: nil) else {
                //                    fatalError("Couldn't find audio file for \(audioFileName)")
                //                }
                
                let audioFileName = "\(parsed[0]).\(toLanguage.code).m4a"
                guard let audioFile = Bundle.main.path(forResource: audioFileName, ofType: nil, inDirectory: "\(range)Audio\(toLanguage.code.capitalized)") else {
                    fatalError("Couldn't find audio file for \(audioFileName)")
                }
                //guard let audioFile = Bundle.main.url(forResource: audioFileName, withExtension: nil) else {
                //fatalError("Couldn't find audio file for \(audioFileName)")
                //}
                
                guard let data = FileManager.default.contents(atPath: audioFile) else {
                    fatalError("Couldn't load audio file for \(audioFileName)")
                }
                
                audioPrompts.append(.audio(data))
                
            }
            
            audioContainers[audioPromptName] = AudioDataContainer(promptName: audioPromptName, audioPrompts: audioPrompts)
            
            guard let imageFile = Bundle.main.path(forResource: "\(range).pdf", ofType: nil) else {
                fatalError("couldn't find image file for \(range).pdf")
            }
            
            guard let imageData = FileManager.default.contents(atPath: imageFile) else {
                fatalError("couldn't load image file for \(range).pdf")
            }
            
            var imageSheets = [String : Data]()
            imageSheets[imagePromptName] = imageData
            
            let firebaseDeck = FirebaseDeck(name: name, cubeNames: cubeNames, protoPrompts: protoPrompts, imageSheets: imageSheets, audioContainers: audioContainers, texts: texts)
            
            let deckEncoded = try PropertyListEncoder().encode(firebaseDeck)
            let savePath = Directory.dlc.url.appendingPathComponent(name).path
            FileManager.default.createFile(atPath: savePath, contents: deckEncoded, attributes: nil)
            
        } catch let error {
            fatalError(error.localizedDescription)
        }
        
    }
    
    static func buildDeck(language: SupportedLanguages.Language, from: Int, to: Int ) {
        
        let range = "\(from)-\(to)"
        
        let name = "Tiếng Anh \(range)"
        let protoPrompts = [
            "Từ tiếng Việt" : CubePrompt.text(nil),
            "Từ tiếng Anh" : CubePrompt.text(nil),
            "Âm thanh tiếng Anh" : CubePrompt.audio(nil),
            "Hình ảnh" : CubePrompt.image(nil)
        ]
        
        guard let textFile = Bundle.main.url(forResource: "\(range)text.vi.\(language.code)", withExtension: "csv") else { fatalError("textFile not found") }
        
        do {
            let text = try String(contentsOf: textFile, encoding: String.Encoding.utf8)
            let readLines = text.components(separatedBy: "\n")
            
            guard readLines.count > 1 else {fatalError("readlines didn't split correctly. need \r")}
            
            var cubeNames = [String]()
            var texts = [String : [String]]()
            texts["Từ tiếng Việt"] = [String]()
            texts["Từ tiếng Anh"] = [String]()
            
            var audioContainers = [String : AudioDataContainer]()
            var audioPrompts = [CubePrompt]()
            
            for line in readLines {
                print(line)
                
                let parsed = line.components(separatedBy: ",")
                
                //print("parsed: \(parsed[0]), \(parsed[1]), \(parsed[2]), \(parsed[3])")
                //print("parsed: \(parsed[0].count), \(parsed[1].count), \(parsed[2].count), \(parsed[3].count)")
                
                cubeNames.append(parsed[0].capitalized)
                
                texts["Từ tiếng Anh"]!.append(parsed[1])
                texts["Từ tiếng Việt"]!.append(parsed[0])
                
                //                let audioFileName = "\(parsed[0]).ko.m4a"
                //                guard let audioFile = Bundle.main.path(forResource: audioFileName, ofType: nil) else {
                //                    fatalError("Couldn't find audio file for \(audioFileName)")
                //                }
                
                let audioFileName = "\(parsed[1]).\(language.code).m4a"
                guard let audioFile = Bundle.main.path(forResource: audioFileName, ofType: nil, inDirectory: "\(range)Audio\(language.code.capitalized)") else {
                    fatalError("Couldn't find audio file for \(audioFileName)")
                }
                //guard let audioFile = Bundle.main.url(forResource: audioFileName, withExtension: nil) else {
                //fatalError("Couldn't find audio file for \(audioFileName)")
                //}
                
                guard let data = FileManager.default.contents(atPath: audioFile) else {
                    fatalError("Couldn't load audio file for \(audioFileName)")
                }
                
                audioPrompts.append(.audio(data))
                
            }
            
            audioContainers["Âm thanh tiếng Anh"] = AudioDataContainer(promptName: "Âm thanh tiếng Anh", audioPrompts: audioPrompts)
            
            guard let imageFile = Bundle.main.path(forResource: "\(range).pdf", ofType: nil) else {
                fatalError("couldn't find image file for \(range).pdf")
            }
            
            guard let imageData = FileManager.default.contents(atPath: imageFile) else {
                fatalError("couldn't load image file for \(range).pdf")
            }
            
            var imageSheets = [String : Data]()
            imageSheets["Hình ảnh"] = imageData
            
            let firebaseDeck = FirebaseDeck(name: name, cubeNames: cubeNames, protoPrompts: protoPrompts, imageSheets: imageSheets, audioContainers: audioContainers, texts: texts)
            
            let deckEncoded = try PropertyListEncoder().encode(firebaseDeck)
            let savePath = Directory.dlc.url.appendingPathComponent(name).path
            FileManager.default.createFile(atPath: savePath, contents: deckEncoded, attributes: nil)
            
        } catch let error {
            fatalError(error.localizedDescription)
        }
        
    }
    
    static func buildDeck(from language: SupportedLanguages.Language, range from: Int, to: Int){
        
        let range = "\(from)-\(to)"
        
        let name = "\(language.language) \(range)"
        let protoPrompts = [
            "English text" : CubePrompt.text(nil),
            "\(language.language) text" : CubePrompt.text(nil),
            "\(language.language) phonetic" : CubePrompt.text(nil),
            "\(language.language) audio" : CubePrompt.audio(nil),
            "Images" : CubePrompt.image(nil)
        ]
        
        guard let textFile = Bundle.main.url(forResource: "\(range)text.\(language.code)", withExtension: "csv") else { fatalError("textFile not found") }
        //let textFile = Bundle.main.path(forResource: "1-100text.ko.csv", ofType: nil)!
        do {
            let text = try String(contentsOf: textFile, encoding: String.Encoding.utf8)
            let readLines = text.components(separatedBy: "\n")
            
            guard readLines.count > 1 else {fatalError("readlines didn't split correctly. need \r")}
            
            var cubeNames = [String]()
            var texts = [String : [String]]()
            texts["English text"] = [String]()
            texts["\(language.language) text"] = [String]()
            texts["\(language.language) phonetic"] = [String]()
            
            var audioContainers = [String : AudioDataContainer]()
            var audioPrompts = [CubePrompt]()
            
            for line in readLines {
                print(line)
                
                let parsed = line.components(separatedBy: ",")
                
                print("parsed: \(parsed[0]), \(parsed[1]), \(parsed[2]), \(parsed[3])")
                print("parsed: \(parsed[0].count), \(parsed[1].count), \(parsed[2].count), \(parsed[3].count)")
                
                cubeNames.append(parsed[0].capitalized)
                
                texts["English text"]!.append(parsed[1])
                texts["\(language.language) text"]!.append(parsed[2])
                texts["\(language.language) phonetic"]!.append(parsed[3])
                
                //                let audioFileName = "\(parsed[0]).ko.m4a"
                //                guard let audioFile = Bundle.main.path(forResource: audioFileName, ofType: nil) else {
                //                    fatalError("Couldn't find audio file for \(audioFileName)")
                //                }
                
                let audioFileName = "\(parsed[0]).\(language.code).m4a"
                guard let audioFile = Bundle.main.path(forResource: audioFileName, ofType: nil, inDirectory: "\(range)Audio\(language.code.capitalized)") else {
                    fatalError("Couldn't find audio file for \(audioFileName)")
                }
                //guard let audioFile = Bundle.main.url(forResource: audioFileName, withExtension: nil) else {
                //fatalError("Couldn't find audio file for \(audioFileName)")
                //}
                
                guard let data = FileManager.default.contents(atPath: audioFile) else {
                    fatalError("Couldn't load audio file for \(audioFileName)")
                }
                
                audioPrompts.append(.audio(data))
                
            }
            
            audioContainers["\(language.language) audio"] = AudioDataContainer(promptName: "\(language.language) audio", audioPrompts: audioPrompts)
            
            guard let imageFile = Bundle.main.path(forResource: "\(range).pdf", ofType: nil) else {
                fatalError("couldn't find image file for \(range).pdf")
            }
            
            guard let imageData = FileManager.default.contents(atPath: imageFile) else {
                fatalError("couldn't load image file for \(range).pdf")
            }
            
            var imageSheets = [String : Data]()
            imageSheets["Images"] = imageData
            
            let firebaseDeck = FirebaseDeck(name: name, cubeNames: cubeNames, protoPrompts: protoPrompts, imageSheets: imageSheets, audioContainers: audioContainers, texts: texts)
            
            let deckEncoded = try PropertyListEncoder().encode(firebaseDeck)
            let savePath = Directory.dlc.url.appendingPathComponent(name).path
            FileManager.default.createFile(atPath: savePath, contents: deckEncoded, attributes: nil)
            
        } catch let error {
            fatalError(error.localizedDescription)
        }
        
    }
    
    //write in crap as i go.
    static func buildDeck(){
        
        let range = "401-500"
        
        let name = "Korean \(range)"
        let protoPrompts = [
            "English text" : CubePrompt.text(nil),
            "Korean text" : CubePrompt.text(nil),
            "Korean phonetic" : CubePrompt.text(nil),
            "Korean audio" : CubePrompt.audio(nil),
            "Images" : CubePrompt.image(nil)
        ]
        
        guard let textFile = Bundle.main.url(forResource: "\(range)text.ko", withExtension: "csv") else { fatalError("textFile not found") }
        //let textFile = Bundle.main.path(forResource: "1-100text.ko.csv", ofType: nil)!
        do {
            let text = try String(contentsOf: textFile, encoding: String.Encoding.utf8)
            let readLines = text.components(separatedBy: "\n")
            
            guard readLines.count > 1 else {fatalError("readlines didn't split correctly. need \r")}
            
            var cubeNames = [String]()
            var texts = [String : [String]]()
            texts["English text"] = [String]()
            texts["Korean text"] = [String]()
            texts["Korean phonetic"] = [String]()
            
            var audioContainers = [String : AudioDataContainer]()
            var audioPrompts = [CubePrompt]()
            
            for line in readLines {
                print(line)
                
                let parsed = line.components(separatedBy: ",")
                
                print("parsed: \(parsed[0]), \(parsed[1]), \(parsed[2]), \(parsed[3])")
                print("parsed: \(parsed[0].count), \(parsed[1].count), \(parsed[2].count), \(parsed[3].count)")
                
                cubeNames.append(parsed[0].capitalized)
                
                texts["English text"]!.append(parsed[1])
                texts["Korean text"]!.append(parsed[2])
                texts["Korean phonetic"]!.append(parsed[3])
                
//                let audioFileName = "\(parsed[0]).ko.m4a"
//                guard let audioFile = Bundle.main.path(forResource: audioFileName, ofType: nil) else {
//                    fatalError("Couldn't find audio file for \(audioFileName)")
//                }
                
                let audioFileName = "\(parsed[0]).ko.m4a"
                guard let audioFile = Bundle.main.path(forResource: audioFileName, ofType: nil, inDirectory: "\(range)AudioKo") else {
                    fatalError("Couldn't find audio file for \(audioFileName)")
                }
                //guard let audioFile = Bundle.main.url(forResource: audioFileName, withExtension: nil) else {
                    //fatalError("Couldn't find audio file for \(audioFileName)")
                //}
                
                guard let data = FileManager.default.contents(atPath: audioFile) else {
                    fatalError("Couldn't load audio file for \(audioFileName)")
                }
                
                audioPrompts.append(.audio(data))
                
            }
            
            audioContainers["Korean audio"] = AudioDataContainer(promptName: "Korean audio", audioPrompts: audioPrompts)
            
            guard let imageFile = Bundle.main.path(forResource: "\(range).pdf", ofType: nil) else {
                fatalError("couldn't find image file for \(range).pdf")
            }
            
            guard let imageData = FileManager.default.contents(atPath: imageFile) else {
                fatalError("couldn't load image file for \(range).pdf")
            }
            
            var imageSheets = [String : Data]()
            imageSheets["Images"] = imageData
            
            let firebaseDeck = FirebaseDeck(name: name, cubeNames: cubeNames, protoPrompts: protoPrompts, imageSheets: imageSheets, audioContainers: audioContainers, texts: texts)
            
            let deckEncoded = try PropertyListEncoder().encode(firebaseDeck)
            let savePath = Directory.dlc.url.appendingPathComponent(name).path
            FileManager.default.createFile(atPath: savePath, contents: deckEncoded, attributes: nil)

        } catch let error {
            fatalError(error.localizedDescription)
        }
  
    }
    
    static func buildDeckViKo(){
        
        let name = "Tiếng Hàn 1-100"
        let protoPrompts = [
            "Từ Việt" : CubePrompt.text(nil),
            "Từ Hàn" : CubePrompt.text(nil),
            "Cách phát âm từ Hàn" : CubePrompt.text(nil),
            "Âm thanh Hàn" : CubePrompt.audio(nil),
            "Hình Ảnh" : CubePrompt.image(nil)
        ]
        
        guard let textFile = Bundle.main.url(forResource: "1-100textvi.ko", withExtension: "csv") else { fatalError("textFile not found") }
        //let textFile = Bundle.main.path(forResource: "1-100text.ko.csv", ofType: nil)!
        do {
            let text = try String(contentsOf: textFile, encoding: String.Encoding.utf8)
            let readLines = text.components(separatedBy: "\n")
            
            guard readLines.count > 1 else {fatalError("readlines didn't split correctly. need \r")}
            
            var cubeNames = [String]()
            var texts = [String : [String]]()
            texts["Từ Việt"] = [String]()
            texts["Từ Hàn"] = [String]()
            texts["Cách phát âm từ Hàn"] = [String]()
            
            var audioContainers = [String : AudioDataContainer]()
            var audioPrompts = [CubePrompt]()
            
            for line in readLines {
                print(line)
                
                let parsed = line.components(separatedBy: ",")
                
                print("parsed: \(parsed[0]), \(parsed[1]), \(parsed[2]), \(parsed[3])")
                print("parsed: \(parsed[0].count), \(parsed[1].count), \(parsed[2].count), \(parsed[3].count)")
                
                cubeNames.append(parsed[0].capitalized)
                
                texts["Từ Việt"]!.append(parsed[1])
                texts["Từ Hàn"]!.append(parsed[2])
                texts["Cách phát âm từ Hàn"]!.append(parsed[3])
                
                //                let audioFileName = "\(parsed[0]).ko.m4a"
                //                guard let audioFile = Bundle.main.path(forResource: audioFileName, ofType: nil) else {
                //                    fatalError("Couldn't find audio file for \(audioFileName)")
                //                }
                
                let audioFileName = "\(parsed[0]).ko.m4a"
                guard let audioFile = Bundle.main.path(forResource: audioFileName, ofType: nil, inDirectory: "1-100AudioKo") else {
                    fatalError("Couldn't find audio file for \(audioFileName)")
                }
                //guard let audioFile = Bundle.main.url(forResource: audioFileName, withExtension: nil) else {
                //fatalError("Couldn't find audio file for \(audioFileName)")
                //}
                
                guard let data = FileManager.default.contents(atPath: audioFile) else {
                    fatalError("Couldn't load audio file for \(audioFileName)")
                }
                
                audioPrompts.append(.audio(data))
                
            }
            
            audioContainers["Âm thanh Hàn"] = AudioDataContainer(promptName: "Âm thanh Hàn", audioPrompts: audioPrompts)
            
            guard let imageFile = Bundle.main.path(forResource: "1-100.pdf", ofType: nil) else {
                fatalError("couldn't find image file for 1-100.pdf")
            }
            
            guard let imageData = FileManager.default.contents(atPath: imageFile) else {
                fatalError("couldn't load image file for 1-100.pdf")
            }
            
            var imageSheets = [String : Data]()
            imageSheets["Hình Ảnh"] = imageData
            
            let firebaseDeck = FirebaseDeck(name: name, cubeNames: cubeNames, protoPrompts: protoPrompts, imageSheets: imageSheets, audioContainers: audioContainers, texts: texts)
            
            let deckEncoded = try PropertyListEncoder().encode(firebaseDeck)
            let savePath = Directory.dlc.url.appendingPathComponent(name).path
            FileManager.default.createFile(atPath: savePath, contents: deckEncoded, attributes: nil)
            
        } catch let error {
            fatalError(error.localizedDescription)
        }
        
    }
    
    static func buildMapDeck(){
        
        let countryName = "Country name"
        let capital = "Capital"
        let map = "Map"
        
        let name = "European geography"
        let protoPrompts = [
           countryName  : CubePrompt.text(nil),
           capital : CubePrompt.text(nil),
           map : CubePrompt.image(nil)
        ]
        
        let deck = FlashCubeDeck(protoPrompts: protoPrompts)
        deck.name = name
        
        guard let textFile = Bundle.main.url(forResource: "EuroSheet", withExtension: "csv") else { fatalError("textFile not found") }
        
        do {
            let text = try String(contentsOf: textFile, encoding: String.Encoding.utf8)
            let readLines = text.components(separatedBy: "\n")
            guard readLines.count > 1 else {fatalError("readlines didn't split correctly. need \r")}
            
            
//            var cubeNames = [String]()
//            var texts = [String : [String]]()
//            texts[countryName] = [String]()
//            texts[capital] = [String]()
//            var imgs = [UIImage]()
            
            for line in readLines {
                print(line)
                
                var cube = deck.protoCube
                
                let parsed = line.components(separatedBy: ",")
//                cubeNames.append(parsed[0])
//                texts[countryName]?.append(parsed[0])
//                texts[capital]?.append(parsed[1])
                
                guard let imageFile = Bundle.main.path(forResource: parsed[0], ofType: ".png") else {fatalError("couldn't find image file \(parsed[0])")}
                
                guard let data = FileManager.default.contents(atPath: imageFile) else {fatalError("couldn't load image file \(parsed[0])")}
                
                guard let img = UIImage(data: data) else {fatalError("couldn't cast image file from data \(parsed[0])")}
                
                cube?.name = parsed[0]
                cube?.prompts?[countryName] = CubePrompt.text(parsed[0])
                cube?.prompts?[capital] = CubePrompt.text(parsed[1])
                cube?.prompts?[map] = CubePrompt.image(img)
                
                do {
                    try deck.submit(cube: cube!)
                } catch let error {
                    fatalError(error.localizedDescription)
                }
            }
            
            let atPath = Directory.decks.url.appendingPathComponent(deck.deckSubFolder).path
            
            let data = try PropertyListEncoder().encode(deck)
            FileManager.default.createFile(atPath: atPath, contents: data, attributes: nil)

        } catch let error {
            print("\(#function) \(error.localizedDescription)")
        }
        
    }
    
    static func buildMusicDeck(){
        
        let notePicture = "Note on scale"
        let noteAudio = "Note played"
        
        let name = "Music note identification"
        let protoPrompts = [
            notePicture : CubePrompt.image(nil),
            noteAudio : CubePrompt.audio(nil)
        ]
        
        let deck = FlashCubeDeck(protoPrompts: protoPrompts)
        deck.name = name
        
        guard let textFile = Bundle.main.url(forResource: "MusicNotes", withExtension: "csv") else { fatalError("textFile not found") }
        
        do {
            let text = try String(contentsOf: textFile, encoding: String.Encoding.utf8)
            let readLines = text.components(separatedBy: "\n")
            guard readLines.count > 1 else {fatalError("readlines didn't split correctly. need \r")}
            
            for line in readLines {
                print(line)
                
                var cube = deck.protoCube
                
                let parsed = line.components(separatedBy: ",")
                
                guard let imageFile = Bundle.main.path(forResource: parsed[0], ofType: ".png") else {fatalError("couldn't find image file \(parsed[0])")}
                
                guard let data = FileManager.default.contents(atPath: imageFile) else {fatalError("couldn't load image file \(parsed[0])")}
                
                guard let img = UIImage(data: data) else {fatalError("couldn't cast image file from data \(parsed[0])")}
                
                guard let audioFile = Bundle.main.path(forResource: parsed[0], ofType: ".m4a") else {fatalError("couldn't find audio file \(parsed[0])")}
                
                guard let audioData = FileManager.default.contents(atPath: audioFile) else {fatalError("couldn't load image file \(parsed[0])")}
                
                
                cube?.name = parsed[0]
                cube?.prompts?[notePicture] = CubePrompt.image(img)
                cube?.prompts?[noteAudio] = CubePrompt.audio(audioData)
                
                do {
                    try deck.submit(cube: cube!)
                } catch let error {
                    fatalError(error.localizedDescription)
                }
            }
            
            let atPath = Directory.decks.url.appendingPathComponent(deck.deckSubFolder).path
            
            let data = try PropertyListEncoder().encode(deck)
            FileManager.default.createFile(atPath: atPath, contents: data, attributes: nil)
            
        } catch let error {
            print("\(#function) \(error.localizedDescription)")
        }
        
    }
}
