//
//  FlashCubeDeck.swift
//  Flash Cubes
//
//  Created by Jeffrey Thompson on 4/22/19.
//  Copyright © 2019 Jeffrey Thompson. All rights reserved.
//

import Foundation

class FlashCubeDeck: Codable {
    
    enum IOError: Error {
        case noSuchKey
        case keysDoNotMatch
        case promptsDoNotMatch
        case couldNotLoadCubeData
        case cubeDoesNotExist
    }
    
    var name: String?
    let deckSubFolder: String!
    var dateCreated: Date?
    var protoPrompts: [String : CubePrompt]?
    var protoCube: FlashCube? {
        get {
            guard let prompts = self.protoPrompts else {return nil}
            return FlashCube(prompts: prompts)
        }
    }
    
    lazy var allReviewRecordKeys: [ReviewRecordKey]? = {
        
        var recordKeys = [ReviewRecordKey]()
        
        self.flashCubes?.forEach({ (_, cube) in
            if let keys = cube.reportAllReviewRecordKeys {
                for key in keys {
                    recordKeys.append(key)
                }
                recordKeys.removeDuplicates()
            }
        })
        
        if recordKeys.count > 0 {
            print("\(#function) \(recordKeys)")
            return recordKeys
        }
        
        return nil
        
        
        // !! not optimized.
        //        get {
        //            var recordKeys = [ReviewRecordKey]()
        //
        //            deck.flashCubes?.forEach({ (_, cube) in
        //                if let keys = cube.reportAllReviewRecordKeys {
        //                    for key in keys {
        //                        recordKeys.append(key)
        //                    }
        //                    recordKeys.removeDuplicates()
        //                }
        //            })
        //
        //            if recordKeys.count > 0 {
        //                print("\(#function) \(recordKeys)")
        //                return recordKeys
        //            }
        //
        //            return nil
        //        }
        
    }()

    var retention: Double {
        get {
            if self.flashCubes == nil || self.flashCubes?.count == 0 {
                return 0.0
            }
            var sum: Double = 0.0
            //self.flashCubes?.forEach({ sum += $0.value.retention })
            self.flashCubes?.forEach({ sum += $0.value.getRetentionFor(reviewRecords: allReviewRecordKeys ?? [ReviewRecordKey]()) })
            return (sum / Double(self.flashCubes?.count ?? 1))
        }
    }
    var proficiency: Double {
        get {
            if self.flashCubes == nil || self.flashCubes?.count == 0  {
                return 0.0
            }
            var sum: Double = 0.0
            //self.flashCubes?.forEach({ sum += $0.value.proficiency })
            self.flashCubes?.forEach({ sum += $0.value.getProficiencyFor(reviewRecords: allReviewRecordKeys ?? [ReviewRecordKey]()) })
            return (sum / Double(self.flashCubes?.count ?? 1))
        }
    }
    var nextReviewDate: Date? {
        get {
            var nextDate: Date? = nil
            
            self.flashCubes?.forEach({
                if let date = $0.value.nextReviewDate {
                    if nextDate == nil {
                        nextDate = date
                    } else {
                        if nextDate! > date {
                            nextDate = date
                        }
                    }
                }
            })
            
            return nextDate
        }
    }
    var reviewState: ReviewState {
        get {
            var pastDue = false
            self.flashCubes?.forEach({
                switch $0.value.reviewState {
                case .reviewIsDue:
                    pastDue = true
                default:
                    break
                }
            })
            if pastDue {return .pastDue}
            
            if self.flashCubes?.filter({$0.value.reviewState == .new}).count == self.flashCubes?.count {
                return .new
            }

            return .neutral
        }
    }
    
    var cubeFileNames: [String]?
    var flashCubes: [String : FlashCube]?
    
    enum Key: CodingKey {
        case name
        case subfolder
        case dateCreated
        case protoPrompts
        case cubeFileNames
        //case flashCubes
    }
    
    enum ReviewState {
        case new
        case neutral
        case pastDue
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
        
        var functionInt: (Int, Int) -> Bool {
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
        case cubeDefaultIndex
        case cubeName
        case cubeRetention
        case cubeProficiency
        case nextReviewDate
    }
    
    public init(protoPrompts: [String : CubePrompt]){
        self.protoPrompts = protoPrompts
        self.dateCreated = Date()
        self.deckSubFolder = UniqueString.timeStamp.generate
    }
    
    public func sort(by: SortBy, order: SortOrder, completion: () -> Void) {
        
        let sortedAryDict = self.flashCubes?.sorted(by: {
            switch by {
            case .cubeDefaultIndex:
                let first = $0.value.defaultIndex != nil ? $0.value.defaultIndex! : 0
                let second = $1.value.defaultIndex != nil ? $1.value.defaultIndex! : 0
                return order.functionInt(first, second)
            case .cubeName:
                return order.function($0.value.name!,$1.value.name!)
            case .nextReviewDate:
                if let dateOne = $0.value.nextReviewDate {
                    if let dateTwo = $1.value.nextReviewDate {
                        return order.function(dateOne.description,dateTwo.description)
                    }
                }
                fallthrough
            case .cubeRetention:
                return order.functionDoubles($0.value.retention,$1.value.retention)
            case .cubeProficiency:
                return order.functionDoubles($0.value.proficiency,$1.value.proficiency)
            }
        })
        
        var sortedKeys = [String]()
        sortedAryDict?.forEach({
            sortedKeys.append($0.key)
        })
        
        //print(deckFileNames as Any)
        //print(sortedKeys as Any)
        
        cubeFileNames = sortedKeys
        completion()
    }
    
    func validCubes(forKey: ReviewRecordKey) -> [String : FlashCube]? {
        let question = forKey.fromPrompt
        let answer = forKey.toPrompt
        
        let validCubes = self.flashCubes?.filter({
            $0.value.prompts?[question] != nil && $0.value.prompts?[answer] != nil
        })
        
        return validCubes
    }
    
    public func submit(cube: FlashCube) throws {
        
        // some defensive gatekeeping
        guard cube.prompts?.keys == self.protoPrompts?.keys else {
            throw IOError.keysDoNotMatch
        }
        
        try cube.prompts?.forEach({
            guard $0.value.typeId == self.protoPrompts![$0.key]?.typeId else {
                throw IOError.promptsDoNotMatch
            }
        })
        
        //okay, let them through
        if self.flashCubes == nil {
            self.flashCubes = [String : FlashCube]()
        }
        
        if self.cubeFileNames == nil {
            self.cubeFileNames = [String]()
        }
        
        self.cubeFileNames?.append(cube.fileName)
        self.flashCubes?[cube.fileName] = cube
        save(cube: cube)
    }
    
    public func searchAndLoadCubes(){
        //search through the directory and populate anything missing from the filepath collection
        
        if cubeFileNames == nil {
            cubeFileNames = [String]()
        }
        
        do {
            let subfolderPath = Directory.decksData.url.appendingPathComponent(self.deckSubFolder).path
            let cubeNames = try FileManager.default.contentsOfDirectory(atPath: subfolderPath)
            cubeNames.forEach({
                if !cubeFileNames!.contains($0){
                    cubeFileNames!.append($0)
                }
            })
        } catch let error {
            print("\(#function) \(error)")
        }
        
        //then load the cubes into dictionary
        if self.flashCubes == nil {
            self.flashCubes = [String : FlashCube]()
        }
        
        for (index, fileName) in cubeFileNames!.enumerated() {
            do {
                let loadPath = Directory.decksData.url.appendingPathComponent(self.deckSubFolder).appendingPathComponent(fileName).path
                var loadedCube = try loadCube(atPath: loadPath)
                if loadedCube.defaultIndex == nil {
                    loadedCube.defaultIndex = index
                }
                flashCubes![fileName] = loadedCube
                
            } catch let error {
                flashCubes![fileName] = nil
                let cubeFileName = fileName
                cubeFileNames?.removeAll(where: { (fileName) -> Bool in
                    cubeFileName == fileName
                })
                print("\(#function) \(error)")
            }
        }
        
    }
    
    private func loadCube(atPath: String) throws -> FlashCube {
        guard let fileData = FileManager.default.contents(atPath: atPath) else {
            throw IOError.couldNotLoadCubeData
        }
        
        var loadCube: FlashCube?
        
        do {
            loadCube = try PropertyListDecoder().decode(FlashCube.self, from: fileData)
            if loadCube != nil {
                return loadCube!
            } else {
                throw IOError.couldNotLoadCubeData
            }
        } catch let error {
            throw error
        }
    }
    
    public func delete(cube: FlashCube) throws {
        
        do {
            let path = Directory.decksData.url.appendingPathComponent(self.deckSubFolder).appendingPathComponent(cube.fileName).path
            try FileManager.default.removeItem(atPath: path)
            cubeFileNames?.removeAll(where: {$0 == cube.fileName})
            flashCubes?.removeValue(forKey: cube.fileName)
        } catch let error {
            throw error
        }
    }
    
    public func saveAll(){
        self.flashCubes?.forEach({
            save(cube: $0.value)
        })
    }
    
    public func saveCube(forKey: String, with reviewRecordKey: ReviewRecordKey?) throws {
        guard self.flashCubes?[forKey] != nil else {
            throw IOError.cubeDoesNotExist
        }
        
        save(cube: self.flashCubes![forKey]!)
        
        if let recordKey = reviewRecordKey {
            if let date = self.flashCubes?[forKey]?.getNextReviewDate(for: recordKey) {
                if date > Date() {
                    NotificationsManager.addNewRequest(forDeck: name ?? "Deck", onDate: date)
                }
            }
        }
    }
    
    private func save(cube: FlashCube){
        // ensure deck subdirectory exists
        if !Directory.decksData.url.appendingPathComponent(self.deckSubFolder).hasDirectoryPath {
            PersistenceManager.shared.createSubDirectory(atDirectory: Directory.decksData.url, newDirectoryName: self.deckSubFolder)
        }
        
        do {
            let savePath = Directory.decksData.url.appendingPathComponent(self.deckSubFolder).appendingPathComponent(cube.fileName).path
            let data = try PropertyListEncoder().encode(cube)
            FileManager.default.createFile(atPath: savePath, contents: data, attributes: nil)
        } catch let error {
            print("\(#function) \(error)")
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: Key.self)
        try container.encode(self.name, forKey: .name)
        try container.encode(self.cubeFileNames, forKey: .cubeFileNames)
        try container.encode(self.deckSubFolder, forKey: .subfolder)
        try container.encode(self.dateCreated, forKey: .dateCreated)
        try container.encode(self.protoPrompts, forKey: .protoPrompts)
        //try container.encode(self.flashCubes, forKey: .flashCubes)
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: Key.self)
        self.name = try container.decodeIfPresent(String.self, forKey: .name)
        self.cubeFileNames = try container.decodeIfPresent([String].self, forKey: .cubeFileNames)
        self.dateCreated = try container.decodeIfPresent(Date.self, forKey: .dateCreated)
        self.protoPrompts = try container.decodeIfPresent([String : CubePrompt].self, forKey: .protoPrompts)
        //self.flashCubes = try container.decodeIfPresent([FlashCube].self, forKey: .flashCubes)
        self.deckSubFolder = try container.decode(String.self, forKey: .subfolder)
        self.searchAndLoadCubes()
    }
}
