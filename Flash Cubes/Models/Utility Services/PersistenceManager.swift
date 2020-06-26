//
//  PersistenceManager.swift
//  Flash Cubes
//
//  Created by Jeffrey Thompson on 4/22/19.
//  Copyright © 2019 Jeffrey Thompson. All rights reserved.
//

import Foundation

enum Directory {
    case docs
    case tmp
    case deckCollection
    case decks
    case decksData
    case testing
    case dlc
    
    var url: URL {
        switch self {
        case .docs:
            return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        case .tmp:
            return URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
        case .deckCollection:
            let name = "deckCollection"
            let deckCollections = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent(name)
            if !deckCollections.hasDirectoryPath {
                PersistenceManager.shared.createSubDirectory(atDirectory: .docs, newDirectoryName: name)
            }
            return deckCollections
        case .decks:
            let name = "decks"
            let decks = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent(name)
            if !decks.hasDirectoryPath {
                PersistenceManager.shared.createSubDirectory(atDirectory: .docs, newDirectoryName: name)
            }
            return decks
        case .decksData:
            let name = "decksData"
            let decksData = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent(name)
            if !decksData.hasDirectoryPath {
                PersistenceManager.shared.createSubDirectory(atDirectory: .docs, newDirectoryName: name)
            }
            return decksData
        case .testing:
            let name = "testing"
            let testing = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent(name)
            if !testing.hasDirectoryPath {
                PersistenceManager.shared.createSubDirectory(atDirectory: .docs, newDirectoryName: name)
            }
            return testing
        case .dlc:
            let name = "downloadableContent"
            //let dlc = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent(name)
            let dlc = FileManager.default.urls(for: FileManager.SearchPathDirectory.libraryDirectory, in: FileManager.SearchPathDomainMask.userDomainMask).first!.appendingPathComponent("Caches").appendingPathComponent(name)
            if !dlc.hasDirectoryPath {
                //PersistenceManager.shared.createSubDirectory(atDirectory: .docs, newDirectoryName: name)
                let directory = FileManager.default.urls(for: FileManager.SearchPathDirectory.libraryDirectory, in: FileManager.SearchPathDomainMask.userDomainMask).first!.appendingPathComponent("Caches")
                PersistenceManager.shared.createSubDirectory(atDirectory: directory, newDirectoryName: name)
            }
            return dlc
        }
    }
    
    var path: String {
        switch self {
        case .tmp:
            return NSTemporaryDirectory()
        default:
            return self.url.path
        }
    }
}

extension Directory {
    static var array: [Directory] {
        var ary : [Directory] = []
        switch Directory.docs {
        case .docs:
            ary.append(.docs); fallthrough
        case .tmp:
            ary.append(.tmp); fallthrough
        case .deckCollection:
            ary.append(.deckCollection); fallthrough
        case .decks:
            ary.append(.decks); fallthrough
        case .decksData:
            ary.append(.decksData);fallthrough
        case .testing:
            ary.append(.testing);fallthrough
        case .dlc:
            ary.append(.dlc)
        }
        return ary
    }
}

enum FilePath {
    case deckCollection
    
    var path: String {
        return Directory.deckCollection.url.appendingPathComponent("deckCollection").path
    }
}

enum UniqueString {
    case timeStamp
    
    var generate: String {
        return String(describing: NSDate.timeIntervalSinceReferenceDate).replacingOccurrences(of: ".", with: "")
    }
}

enum UniqueTempAudioURL {
    case m4a
    case mp3
    
    var generate: URL {
        switch self {
        case .m4a:
            let fileName = UniqueString.timeStamp.generate.appending(".m4a")
            return Directory.tmp.url.appendingPathComponent(fileName)
        case .mp3:
            let fileName = UniqueString.timeStamp.generate.appending(".mp3")
            return Directory.tmp.url.appendingPathComponent(fileName)
        }
    }
    
    var path: String {
        switch self {
        default:
            return self.generate.path
        }
    }
}

class PersistenceManager {
    
    let fileMgr = FileManager.default
    
    static public let shared = PersistenceManager()
    
    private init() {}
    
    public func getSubDirectories() -> [Directory: [URL]] {
        var dictionary = [Directory : [URL]]()
        
        for directory in Directory.array {
            dictionary[directory] = [URL]()
            do {
                let contents = try fileMgr.contentsOfDirectory(at: directory.url, includingPropertiesForKeys: nil, options: FileManager.DirectoryEnumerationOptions.skipsHiddenFiles)
                for content in contents {
                    dictionary[directory]?.append(content)
                }
            } catch let error{
                print("Error: \(error.localizedDescription)")
            }
        }
        return dictionary
    }
    
    public func createFile(atPath: String, contents: Data?, attributes: [FileAttributeKey : Any]?){
        fileMgr.createFile(atPath: atPath, contents: contents, attributes: attributes)
    }
    
    public func deleteSubDirectory(atIndex: Int){
        //debugPrint("TESTING pre clearSubDirectory: \(subDirectories)~~~~~ END")
        
        if let docsSubdirectories = getSubDirectories()[.docs] {//subDirectories[.docs]{
            let subDirectory = docsSubdirectories[atIndex]
            
            if let enumerator = fileMgr.enumerator(at: subDirectory, includingPropertiesForKeys: nil){
                for (_, file) in enumerator.enumerated() {
                    if let path = file as? String {
                        do {
                            try fileMgr.removeItem(atPath: path)
                        } catch let error {
                            print("TESTING Error: \(error.localizedDescription)")
                        }
                    }
                }
            }
            
            do {
                try fileMgr.removeItem(at: subDirectory)
            } catch let error {
                print("TESTING Error: \(error.localizedDescription)")
            }
        }
        
        //debugPrint("TESTING post clearSubDirectory: \(subDirectories)~~~~~ END")
    }
    
    public func deleteSubDirectory(atDirectory: String){
        debugPrint("PersistenceMgr.deleteSubDirectory(atDirectory): \(atDirectory)")
        
        do {
            try fileMgr.removeItem(atPath: atDirectory)
        } catch let error {
            debugPrint("PersistenceMgr.deleteSubDirectory(atDirectory): Error: \(error.localizedDescription)")
        }
    }
    
    public func createSubDirectory(atDirectory: Directory, newDirectoryName: String){
        
        let newDirectory = atDirectory.url.appendingPathComponent(newDirectoryName)
        
        if newDirectory.hasDirectoryPath {
            print("\(#function) \(newDirectory.path) already exists")
            return
        }
        
        do {
            try fileMgr.createDirectory(at: newDirectory, withIntermediateDirectories: true, attributes: nil)
        } catch let error {
            print("Error: \(error.localizedDescription)")
        }
    }
    
    public func createSubDirectory(atDirectory: URL, newDirectoryName: String){
        
        let newDirectory = atDirectory.appendingPathComponent(newDirectoryName)
        
        do {
            try fileMgr.createDirectory(at: newDirectory, withIntermediateDirectories: true, attributes: nil)
        } catch let error {
            print("Error: \(error.localizedDescription)")
        }
    }
    
    
    func moveItem(from: URL, to: URL){
        
        do {
            try fileMgr.moveItem(at: from, to: to)
            try fileMgr.removeItem(at: from)
        } catch let error {
            print("Error: \(error.localizedDescription)")
        }
    }
    
    public var uniqueTempAudioFileURL: URL {
        
        let fileName = UniqueString.timeStamp.generate.appending(".m4a")
        
        return Directory.tmp.url.appendingPathComponent(fileName)
        
    }
    
    func cleanSweep(){
        
        //print("pre cleanSweep: \(subDirectories)~~~~~ END")
        
        if let docsSubdirectories = getSubDirectories()[.docs] {//subDirectories[.docs]{
            for docSubdirectory in docsSubdirectories{
                do {
                    try fileMgr.removeItem(at: docSubdirectory)
                } catch let error {
                    print("Error: \(error.localizedDescription)")
                }
            }
        }
        
        clearTempDirectory()
        
        //print("post cleanSweep: \(subDirectories)~~~~~ END")
    }
    
    func clearTempDirectory(){
        if let tempSubDirectories = getSubDirectories()[.tmp] {//subDirectories[.tmp]{
            for tempSubDirectory in tempSubDirectories{
                do {
                    try fileMgr.removeItem(at: tempSubDirectory)
                } catch let error{
                    print("Error: \(error.localizedDescription)")
                }
            }
        }
    }
}
