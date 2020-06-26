//
//  DeckCollection.swift
//  Flash Cubes
//
//  Created by Jeffrey Thompson on 4/24/19.
//  Copyright © 2019 Jeffrey Thompson. All rights reserved.
//

import Foundation

class DeckCollection: Codable {
    
    enum IOError: Error {
        case couldNotFileData
        case deckLoadFailure
        case deckDoesNotExistForKey
        case couldNotDeleteDeck
    }
    
    enum SortOrder {
        case ascending
        case descending
        
        //func simpleMax<T: Comparable>(_ x: T, _ y: T) -> T {
        
        //var TESTfunction = <T : Comparable>(_ x: T, _ y: T) -> Bool {}
        
        var functionDoubles: (Double, Double) -> Bool {
            switch self {
            case .ascending:
                return {$0<$1}
            case .descending:
                return {$0>$1}
            }
        }
        
        var function: (String, String) -> Bool {
            switch self {
            case .ascending:
                return {$0<$1}
            case .descending:
                return {$0>$1}
            }
        }
    }
    
    enum SortBy {
        case deckName
        case deckRetention
        case deckProficiency
        case nextReviewDate
        case dateCreated
    }
    
    var deckFileNames: [String]?
    var deckCollection: [String : FlashCubeDeck]?
    
    enum Key: CodingKey {
        case pathCollection
    }
    
    public init(){}
    
    public func sort(by: SortBy, order: SortOrder, completion: () -> Void) {
        
            let sortedAryDict = self.deckCollection?.sorted(by: {
                switch by {
                case .deckName:
                    return order.function($0.value.name!,$1.value.name!)
                case .dateCreated:
                    return order.function($0.value.dateCreated!.description,$1.value.dateCreated!.description)
                case .nextReviewDate:
                    if let dateOne = $0.value.nextReviewDate {
                        if let dateTwo = $1.value.nextReviewDate {
                            return order.function(dateOne.description,dateTwo.description)
                        }
                    }
                    fallthrough
                case .deckRetention:
                    return order.functionDoubles($0.value.retention,$1.value.retention)
                case .deckProficiency:
                    return order.functionDoubles($0.value.proficiency,$1.value.proficiency)
                }
            })
            
            var sortedKeys = [String]()
            sortedAryDict?.forEach({
                sortedKeys.append($0.key)
            })
        
            //print(deckFileNames as Any)
            //print(sortedKeys as Any)
        
            deckFileNames = sortedKeys
            completion()
    }
    
    public func updateDeckCollection(completion: @escaping () -> Void){
        // load only decks that are missing from the deck collection - loading everything is waaaaay too I/O intensive
        
        if deckFileNames == nil {
            deckFileNames = [String]()
        }
        
        var missingDeckNames = [String]()
        do {
            let deckNames = try FileManager.default.contentsOfDirectory(atPath: Directory.decks.path)
            deckNames.forEach({
                if !deckFileNames!.contains($0){
                    deckFileNames!.append($0)
                    missingDeckNames.append($0)
                }
            })
        } catch let error {
            print(error)
        }
        
        //then load the decks into dictionary
        if self.deckCollection == nil {
            self.deckCollection = [String : FlashCubeDeck]()
        }
        
        missingDeckNames.forEach({
            do {
                let path = Directory.decks.url.appendingPathComponent($0).path
                deckCollection![$0] = try loadDeck(fromPath: path)
            } catch let error {
                let name = $0
                deckFileNames?.removeAll(where: { (fileName) -> Bool in
                    name == fileName
                })
                print("\(#function) \(error)")
            }
        })
        
        completion()
    }
    
    public func searchAndLoadDecks(){
        //search through the directory and populate anything missing from the filepath collection
        
        if deckFileNames == nil {
            deckFileNames = [String]()
        }
        
        do {
            let deckNames = try FileManager.default.contentsOfDirectory(atPath: Directory.decks.path)
            deckNames.forEach({
                if !deckFileNames!.contains($0){
                    deckFileNames!.append($0)
                }
            })
        } catch let error {
            print(error)
        }
        
        //then load the decks into dictionary
        if self.deckCollection == nil {
            self.deckCollection = [String : FlashCubeDeck]()
        }
        
        deckFileNames!.forEach({
            do {
                let path = Directory.decks.url.appendingPathComponent($0).path
                deckCollection![$0] = try loadDeck(fromPath: path)
            } catch let error {
                let name = $0
                deckFileNames?.removeAll(where: { (fileName) -> Bool in
                    name == fileName
                })
                print("\(#function) \(error)")
            }
        })
    }
    
    private func loadDeck(fromPath: String) throws -> FlashCubeDeck {
        guard let fileData = FileManager.default.contents(atPath: fromPath) else {
            throw IOError.couldNotFileData
        }
        
        var loadDeck: FlashCubeDeck?
        
        do {
            loadDeck = try PropertyListDecoder().decode(FlashCubeDeck.self, from: fileData)
            if loadDeck != nil {
                return loadDeck!
            } else {
                throw IOError.deckLoadFailure
            }
        } catch let error {
            throw error
        }
    }
    
    public func submit(new deck: FlashCubeDeck) throws {
        
        do {
            let path = Directory.decks.url.appendingPathComponent(deck.deckSubFolder).path
            let directoryPath = Directory.decksData.url.appendingPathComponent(deck.deckSubFolder).path
            let data = try PropertyListEncoder().encode(deck)
            try FileManager.default.createDirectory(atPath: directoryPath, withIntermediateDirectories: false, attributes: nil)
            
            FileManager.default.createFile(atPath: path, contents: data, attributes: nil)
            
            self.deckFileNames?.append(deck.deckSubFolder)
            self.deckCollection?[deck.deckSubFolder] = deck
            
        } catch let error {
            throw error
        }
    }
    
    public func deleteDeck(forFileName: String) throws {
        
        do {
            let path = Directory.decks.url.appendingPathComponent(forFileName).path
            let cubesPath = Directory.decksData.url.appendingPathComponent(forFileName).path
            try FileManager.default.removeItem(atPath: path)
            try FileManager.default.removeItem(atPath: cubesPath)
            deckCollection?.removeValue(forKey: forFileName)
            deckFileNames?.removeAll(where: {$0 == forFileName})
        } catch let error {
            print("\(#function) \(error)")
            throw IOError.couldNotDeleteDeck
        }
    }
    
    public func saveDeck(forKey: String) throws {
        guard deckCollection?[forKey] != nil else {
            throw IOError.deckDoesNotExistForKey
        }
        
        do {
            let data = try PropertyListEncoder().encode(deckCollection![forKey]!)
            let path = Directory.decks.url.appendingPathComponent(forKey).path
            FileManager.default.createFile(atPath: path, contents: data, attributes: nil)
        } catch let error {
            print("\(#function) \(error)")
            throw error
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: Key.self)
        try container.encode(self.deckFileNames, forKey: .pathCollection)
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: Key.self)
        self.deckFileNames = try container.decodeIfPresent([String].self, forKey: .pathCollection)
        self.searchAndLoadDecks()
    }
}
