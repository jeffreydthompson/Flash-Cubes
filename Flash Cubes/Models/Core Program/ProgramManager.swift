//
//  ProgramManager.swift
//  Flash Cubes
//
//  Created by Jeffrey Thompson on 4/26/19.
//  Copyright © 2019 Jeffrey Thompson. All rights reserved.
//

import Foundation

class ProgramManager {
    
    enum IOError: Error {
        case noFileAtPath
    }
    
    var deckCollection: DeckCollection?
    
    public init(){}
    
    public func saveDeckCollection() {
        do {
            let data = try PropertyListEncoder().encode(deckCollection)
            FileManager.default.createFile(atPath: FilePath.deckCollection.path, contents: data, attributes: nil)
        } catch let error {
            print("\(#function) \(error)")
        }
    }
    
    public func initDeckCollection(completion: @escaping (() -> Void)) {
        
        do {
            try loadDeckCollection()
            completion()
            return
        } catch let error {
            print("\(#function) \(error)")
        }
        
        deckCollection = DeckCollection()
        deckCollection?.searchAndLoadDecks()
        
//        deckCollection?.deckCollection?.forEach({
//            print($0.value.name as Any)
//            //print($0.value.flashCubes as Any)
//        })
        
        saveDeckCollection()
        completion()
    }
    
    public func updateDeckCollection(completion: @escaping () -> Void) {
        guard self.deckCollection != nil else {return}
        
        self.deckCollection?.updateDeckCollection(completion: {
            completion()
        })
    }
    
    public func loadDeckCollection() throws {
        
        guard let fileData = FileManager.default.contents(atPath: FilePath.deckCollection.path) else {
            print("retrieving data error")
            throw IOError.noFileAtPath
        }
        
        do {
            deckCollection =  try PropertyListDecoder().decode(DeckCollection.self, from: fileData)
            deckCollection?.searchAndLoadDecks()
            
//            deckCollection?.deckCollection?.forEach({
//                print($0.value.name as Any)
//                //print($0.value.flashCubes as Any)
//            })
            
        } catch let error {
            throw error
        }
    }
}
