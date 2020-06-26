//
//  RandomGenerators.swift
//  Flash Cubes
//
//  Created by Jeffrey Thompson on 4/25/19.
//  Copyright © 2019 Jeffrey Thompson. All rights reserved.
//

import Foundation
import UIKit

struct RandomGenerator {
    
    static public func getRandomText() -> String? {
        let randomString: [String?] = ["🐶","🐱","🐷","🐮","🐭","🐹","🐰","🦊","🐻","🐼","🐨","🐯","🦁","🐸","🐵",nil]
        return randomString.randomElement()!
    }
    
    static public func getRandomName(atLength: Int) -> String {
        var key = ""
        for _ in 0...atLength {
            if let character = "abcdefghijklmnopqrstuvwxyz".randomElement() {
                key += String(character)
            }
        }
        return key
    }
    
    static public func getRandomImage() -> UIImage? {
        let randomImages: [UIImage?] = [
            UIImage(named: "test1"),
            UIImage(named: "test2"),
            UIImage(named: "test3"),
            UIImage(named: "test4"),
            nil
        ]
        
        return randomImages.randomElement()!
    }
    
    static public func getRandomAudioData() -> Data? {
        
        var audioData: [Data?] = [nil]
        
        for index in 0..<4 {
            if let filepath = Bundle.main.path(forResource: "test\(index+1).m4a", ofType: nil) {
                let data = FileManager.default.contents(atPath: filepath)
                audioData.append(data)
            }
        }
        
        return audioData.randomElement()!
    }
    
    static public func getRandomReviewDatabase(forDeck: FlashCubeDeck) -> ReviewDatabase? {
        
        guard forDeck.protoPrompts!.count > 1 else {
            return nil
        }
        
        func getRandomKey(from deck: FlashCubeDeck) -> ReviewRecordKey {
            
            let keys = deck.protoPrompts?.keys
            let fromPromptKey = keys!.randomElement()!
            var toPromptKey = keys!.randomElement()!
            while toPromptKey == fromPromptKey {
                toPromptKey = keys!.randomElement()!
            }
            
            return ReviewRecordKey(fromPrompt: fromPromptKey, toPrompt: toPromptKey)
        }
        
        var database = [ ReviewRecordKey : [ReviewRecord]]()
        for _ in 0..<(forDeck.protoPrompts!.count * 2) {
            let randomKey = getRandomKey(from: forDeck)
            database[randomKey] = getRandomReviewRecords(forDeck: forDeck)
        }
        
        return ReviewDatabase(database: database)
    }
    
    static public func getRandomReviewRecords(forDeck: FlashCubeDeck) -> [ReviewRecord]? {
        
        func getNextReviewDate(recordHistory: [ReviewRecord]?) -> Date? {
            if let numberReviews = recordHistory?.count {
                if let lastDate = recordHistory?.last?.date {
                    let dayInterval = Equations.fibonacci(for: numberReviews)
                    let nextReview = lastDate.addingTimeInterval(TimeInterval(days: dayInterval))
                    return nextReview
                }
            }
            return nil
        }
        
        var reviewRecord = [ReviewRecord]()
        let randomArrayCount = Int.random(in: ClosedRange<Int>(uncheckedBounds: (1,6)))
        var furthestDaysInPast = Int.random(in: ClosedRange<Int>(uncheckedBounds: (randomArrayCount*5,randomArrayCount*8)))
        var nextDateInt = furthestDaysInPast
        for _ in 0..<randomArrayCount {
            let oldestDate = Date().addingTimeInterval(-1.0 * TimeInterval(days: nextDateInt))
            let proficiency = Double.random(in: 0.8..<1.0)
            
            var valid = false
            if reviewRecord.count == 0 {
                valid = true
            } else {
                if let date = getNextReviewDate(recordHistory: reviewRecord) {
                    if oldestDate > date {
                        valid = true
                    }
                }
            }
            
            reviewRecord.append(ReviewRecord(date: oldestDate, proficiency: proficiency, validReviewTime: valid))
            
            furthestDaysInPast = nextDateInt
            let least = Int(Double(furthestDaysInPast) * 0.8)
            nextDateInt = Int.random(in: least..<furthestDaysInPast)
        }
        
        return reviewRecord
    }
    
    static public func getRandomPrompt() -> CubePrompt {
        
        let randInt = Int.random(in: 0...2)
        let nilRand = Int.random(in: 0...3)
        
        switch randInt {
        case 0:
            if nilRand == 0 {
                return .text(nil)
            } else {
                return .text(getRandomText())
            }
        case 1:
            if nilRand == 0 {
                return .audio(nil)
            } else {
                return .audio(getRandomAudioData())
            }
        default:
            if nilRand == 0 {
                return .image(nil)
            } else {
                return .image(getRandomImage())
            }
        }
    }
    
}
