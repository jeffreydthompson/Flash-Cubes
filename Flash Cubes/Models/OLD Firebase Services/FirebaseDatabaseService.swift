//
//  FirebaseDatabaseService.swift
//  FlashCube_Prototype
//
//  Created by Jeffrey Thompson on 11/2/18.
//  Copyright © 2018 Jeffrey Thompson. All rights reserved.
//

/*
import Foundation
import FirebaseDatabase

struct FirebaseDatabaseService {
    
    static private let databaseRef = Database.database().reference()
    
    //NEW
    static func fetchFolderCollection(atPath: String, completion: @escaping (FolderCollection?) -> Void) {
        
        databaseRef.child(atPath).observe(.value) { (snapshot) in
            
            guard let unwrappedValue = snapshot.value as? NSObject else {
                completion(nil)
                return
            }
            
            guard let array = unwrappedValue as? [String:AnyObject] else {
                completion(nil)
                return
            }
            
            do {
                let json = try JSONSerialization.data(withJSONObject: array, options: [])
                let folderCollection = try JSONDecoder().decode(FolderCollection.self, from: json)
                completion(folderCollection)
            } catch let error {
                print(error.localizedDescription)
                completion(nil)
            }
        }
        
    }
    
    
    //OLD
    static func fetchData(atPath: String) -> NSArray? {
        var fetchedData: NSArray? = nil
        
        Database.database().reference().child(atPath).observeSingleEvent(of: .value) { (snapshot) in
            guard let unwrappedvalue = snapshot.value as? NSArray else { return }
            fetchedData = unwrappedvalue
        }
        return fetchedData
    }
    
    static func fetchSampleDeckArray(completion: @escaping (_ sampleDeck: [DownloadedSampleDeck]?) -> Void){
        var sampleDeckArray = [DownloadedSampleDeck]()
        
        let folder = "sampleDecks"
        
        Database.database().reference().child(folder).observeSingleEvent(of: .value) { (snapshot) in
            guard let snapshotValue = (snapshot.value as! NSArray) as? [[String:AnyObject]] else{
                print("no casting to snapshotValue")
                completion(nil)
                return
            }
            
            for value in snapshotValue {
                do {
                    let jsonData = try JSONSerialization.data(withJSONObject: value, options: [])
                    let sampleDeck = try JSONDecoder().decode(DownloadedSampleDeck.self, from: jsonData)
                    
                    sampleDeckArray.append(sampleDeck)
                } catch let error {
                    completion(nil)
                    print(error.localizedDescription)
                }
            }
            
            completion(sampleDeckArray)
        }
    }
    
    static func fetchSampleDeck(atIndex: Int, completion: @escaping (_ deck: DownloadedDeckData?) -> Void ){
        let folder = "decks"
        let index = String(atIndex)
        
        Database.database().reference().child(folder).child(index).observeSingleEvent(of: .value) { (snapshot) in
            guard let value = (snapshot.value as! NSArray) as? [[String:AnyObject]] else {
                print("sample deck download denied")
                completion(nil)
                return
            }
            
            print("DATABASE download: \(value)")
            
            do {
                let jsonData = try JSONSerialization.data(withJSONObject: value[0], options: [])
                let deck = try JSONDecoder().decode(DownloadedDeckData.self, from: jsonData)
                
                completion(deck)
            } catch let error {
                completion(nil)
                print("DATABASE error \(error.localizedDescription)")
            }
        }
    }
    
}
 */
