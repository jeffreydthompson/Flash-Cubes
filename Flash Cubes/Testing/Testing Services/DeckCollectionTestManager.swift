//
//  DeckCollectionTestManager.swift
//  Flash Cubes
//
//  Created by Jeffrey Thompson on 4/24/19.
//  Copyright © 2019 Jeffrey Thompson. All rights reserved.
//

import Foundation

class DeckCollectionTestManager {
    
    enum IOError: Error {
        case noFileAtPath
    }
    
    var deckCollection: DeckCollection?
    
    static public let shared = DeckCollectionTestManager()
    
    private init(){}
    
    public func loadDeckCollection() throws {
        
        guard let fileData = FileManager.default.contents(atPath: FilePath.deckCollection.path) else {
            print("retrieving data error")
            throw IOError.noFileAtPath
        }
        
        do {
            deckCollection =  try PropertyListDecoder().decode(DeckCollection.self, from: fileData)
            
            deckCollection?.deckCollection?.forEach({
                print($0.value.name as Any)
                //print($0.value.flashCubes as Any)
            })
            
        } catch let error {
            throw error
        }
    }
    
    public func deckCollectionInit(){
        deckCollection = DeckCollection()
        deckCollection?.searchAndLoadDecks()
        
        deckCollection?.deckCollection?.forEach({
            print($0.value.name as Any)
            //print($0.value.flashCubes as Any)
        })
        
        self.save(deckCollection: deckCollection!, atPath: FilePath.deckCollection.path)
    }
    
    public func testSort(){
        
        //deckCollection?.sort(by: .deckName, order: .descending)
        
        /*
        guard deckCollection != nil else {return}
        
        deckCollection?.deckFileNames?.forEach({
            print("\($0)")
        })
        deckCollection?.deckCollection?.forEach({
            print("\($0.key) : \($0.value.name!)")
        })
        
        let testFunc: (String, String) -> Bool = {$0 < $1}
        
        let sortedAryDict = deckCollection?.deckCollection?.sorted(by: {
            //$0.value.name! < $1.value.name!
            testFunc($0.value.name!,$1.value.name!)
        })
        
        var sortedKeys = [String]()
        sortedAryDict?.forEach({
            sortedKeys.append($0.key)
        })
        
        print(sortedKeys as Any)
        /*deckCollection?.deckCollection?.forEach({
            print("\($0.key) : \($0.value.name!)")
        })*/*/
    }
    
    public func save(deckCollection: DeckCollection, atPath: String) {
        do {
            let data = try PropertyListEncoder().encode(deckCollection)
            FileManager.default.createFile(atPath: atPath, contents: data, attributes: nil)
        } catch let error {
            print("\(#function) \(error)")
        }
    }
}
