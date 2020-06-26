//
//  DeckTestManager.swift
//  Flash Cubes
//
//  Created by Jeffrey Thompson on 4/23/19.
//  Copyright © 2019 Jeffrey Thompson. All rights reserved.
//

import Foundation
import UIKit

class DeckTestManager {
    
    static public let shared = DeckTestManager()
    
    private init(){}
    
    public func initJapaneseTenDeck() -> FlashCubeDeck {
        
        let info: [String : (en: String, ja: String, audio: String, img: String)] = [
            "no" : (en: "no", ja: "禁止", audio: "no.ja.mp4", img: "no.png"),
            "man" : (en: "man", ja: "男", audio: "man.ja.mp4", img: "man.png"),
            "time" : (en: "time", ja: "時間", audio: "time.ja.mp4", img: "time.png"),
            "up" : (en: "up", ja: "上へ", audio: "up.ja.mp4", img: "up.png"),
            "go" : (en: "go", ja: "行く", audio: "go.ja.mp4", img: "go.png"),
            "new" : (en: "new", ja: "新しい", audio: "new.ja.mp4", img: "new.png"),
            "see" : (en: "see", ja: "気づく", audio: "see.ja.mp4", img: "see.png"),
            "first" : (en: "first", ja: "第一", audio: "first.ja.mp4", img: "first.png"),
            "work" : (en: "work", ja: "仕事", audio: "work.ja.mp4", img: "work.png"),
            "think" : (en: "think", ja: "考える", audio: "think.ja.mp4", img: "think.png")
        ]
        
        var protoPrompts = [String : CubePrompt]()
        protoPrompts["English text"] = .text(nil)
        protoPrompts["Japanese text"] = .text(nil)
        protoPrompts["Japanese audio"] = .audio(nil)
        protoPrompts["Image"] = .image(nil)
        
        let newDeck = FlashCubeDeck(protoPrompts: protoPrompts)
        
        info.forEach({ (infoData) in
            var cube = newDeck.protoCube
            cube?.name = infoData.key
            
            cube?.prompts?["English text"] = .text(infoData.value.en)
            cube?.prompts?["Japanese text"] = .text(infoData.value.ja)
            
            let audioPath = "\(infoData.key).ja.m4a"
            
            if let filepath = Bundle.main.path(forResource: audioPath, ofType: nil) {
                let data = FileManager.default.contents(atPath: filepath)
                cube?.prompts?["Japanese audio"] = .audio(data)
            }
            
            if let img = UIImage(named: infoData.key) {
                cube?.prompts?["Image"] = .image(img)
            }
            
            do {
                try newDeck.submit(cube: cube!)
            } catch let error {
                print("\(#function) \(error)")
            }
        })
        
        newDeck.name = "Japanese 10 words test"
        
        return newDeck
    }
    
    public func initJapaneseTwentyDeck() -> FlashCubeDeck {
        
        /*
         
         find    発見する
         back    戻る
         long    長い
         down    下へ
         good    良い
         high    上昇
         world    世界
         hand    手
         old (not new)    旧
         know    知る
         
         */
        
        let info: [String : (en: String, ja: String, audio: String, img: String)] = [
            "no" : (en: "no", ja: "禁止", audio: "no.ja.mp4", img: "no.png"),
            "man" : (en: "man", ja: "男", audio: "man.ja.mp4", img: "man.png"),
            "time" : (en: "time", ja: "時間", audio: "time.ja.mp4", img: "time.png"),
            "up" : (en: "up", ja: "上へ", audio: "up.ja.mp4", img: "up.png"),
            "go" : (en: "go", ja: "行く", audio: "go.ja.mp4", img: "go.png"),
            "new" : (en: "new", ja: "新しい", audio: "new.ja.mp4", img: "new.png"),
            "see" : (en: "see", ja: "気づく", audio: "see.ja.mp4", img: "see.png"),
            "first" : (en: "first", ja: "第一", audio: "first.ja.mp4", img: "first.png"),
            "work" : (en: "work", ja: "仕事", audio: "work.ja.mp4", img: "work.png"),
            "think" : (en: "think", ja: "考える", audio: "think.ja.mp4", img: "think.png"),
            "find" : (en: "find", ja: "発見する", audio: "find.ja.mp4", img: "find.png"),
            "back" : (en: "back", ja: "戻る", audio: "back.ja.mp4", img: "back.png"),
            "long" : (en: "long", ja: "長い", audio: "long.ja.mp4", img: "long.png"),
            "down" : (en: "down", ja: "下へ", audio: "down.ja.mp4", img: "down.png"),
            "good" : (en: "good", ja: "良い", audio: "good.ja.mp4", img: "good.png"),
            "high" : (en: "high", ja: "上昇", audio: "high.ja.mp4", img: "high.png"),
            "world" : (en: "world", ja: "世界", audio: "world.ja.mp4", img: "world.png"),
            "hand" : (en: "hand", ja: "手", audio: "hand.ja.mp4", img: "hand.png"),
            "old" : (en: "old (not new)", ja: "旧", audio: "old.ja.mp4", img: "old.png"),
            "know" : (en: "know", ja: "知る", audio: "know.ja.mp4", img: "know.png")
        ]
        
        var protoPrompts = [String : CubePrompt]()
        protoPrompts["English text"] = .text(nil)
        protoPrompts["Japanese text"] = .text(nil)
        protoPrompts["Japanese audio"] = .audio(nil)
        protoPrompts["Image"] = .image(nil)
        
        let newDeck = FlashCubeDeck(protoPrompts: protoPrompts)
        
        info.forEach({ (infoData) in
            var cube = newDeck.protoCube
            cube?.name = infoData.key
            
            cube?.prompts?["English text"] = .text(infoData.value.en)
            cube?.prompts?["Japanese text"] = .text(infoData.value.ja)
            
            let audioPath = "\(infoData.key).ja.m4a"
            
            let filepath = Bundle.main.path(forResource: audioPath, ofType: nil)!
            let data = FileManager.default.contents(atPath: filepath)
            cube?.prompts?["Japanese audio"] = .audio(data)
            
            
            if let img = UIImage(named: infoData.key) {
                cube?.prompts?["Image"] = .image(img)
            }
            
            do {
                try newDeck.submit(cube: cube!)
            } catch let error {
                print("\(#function) \(error)")
            }
        })
        
        newDeck.name = "Japanese 20 words test"
        
        return newDeck
    }
    
    public func getRandomDeck(ofSize: Int?) -> FlashCubeDeck {
        
        let length = Int.random(in: ClosedRange<Int>(uncheckedBounds: (2,6))) // random amount of prompts
        
        var protoPrompts = [String : CubePrompt]()
        
        for _ in 0..<length {
            
            let key = RandomGenerator.getRandomName(atLength: 6)
            
            let randomPromptIndex = Int.random(in: ClosedRange<Int>(uncheckedBounds: (0,2)))
            switch randomPromptIndex {
            case 0:
                protoPrompts[key] = CubePrompt.text(nil)
                break
            case 1:
                protoPrompts[key] = CubePrompt.audio(nil)
                break
            case 2:
                protoPrompts[key] = CubePrompt.image(nil)
            default:
                break
            }
        }
        
        print(protoPrompts)
        let newDeck = FlashCubeDeck(protoPrompts: protoPrompts)
        
        for _ in 0..<(ofSize ?? 4) {
            var cube = newDeck.protoCube
            
            cube?.name = RandomGenerator.getRandomName(atLength: 8)
            cube?.prompts?.forEach({
                
                switch $0.value.typeId {
                case 0:
                    cube?.prompts?[$0.key] = CubePrompt.text(RandomGenerator.getRandomText())
                    break
                case 1:
                    cube?.prompts?[$0.key] = CubePrompt.audio(RandomGenerator.getRandomAudioData())
                    break
                case 2:
                    cube?.prompts?[$0.key] = CubePrompt.image(RandomGenerator.getRandomImage())
                    break
                default:
                    break
                }
            })
            
            //cube?.recordHistory = RandomGenerator.getRandomReviewRecords(forDeck: newDeck)
            cube?.reviewRecordDatabase = RandomGenerator.getRandomReviewDatabase(forDeck: newDeck)
            
            do {
                try newDeck.submit(cube: cube!)
            } catch let error {
                print("\(#function) \(error)")
            }
        }
        
        newDeck.name = RandomGenerator.getRandomName(atLength: 10)
        
        //self.probe(deck: newDeck)
        
        return newDeck
    }
    
    public func save(deck: FlashCubeDeck, withName: String) {
        //DeckTestManager.shared.save(deck: deck, withName: deck.deckSubFolder)
        let atPath = Directory.decks.url.appendingPathComponent(withName).path
        
        do {
            let data = try PropertyListEncoder().encode(deck)
            FileManager.default.createFile(atPath: atPath, contents: data, attributes: nil)
        } catch let error {
            print("\(#function) \(error)")
        }
    }
}
