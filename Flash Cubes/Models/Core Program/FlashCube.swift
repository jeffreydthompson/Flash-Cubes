//
//  File.swift
//  Flash Cubes
//
//  Created by Jeffrey Thompson on 4/22/19.
//  Copyright © 2019 Jeffrey Thompson. All rights reserved.
//

import Foundation

struct FlashCube: Codable {
    
    var name: String?
    let fileName: String!
    var creationDate: Date?
    var defaultIndex: Int?
    
    // short term recall
    var retention: Double {
        get {
            if reviewRecordDatabase == nil {return 0.0}
            return reviewRecordDatabase?.averageRetention ?? 0
        }
    }
    // long term recall
    var proficiency: Double {
        get {
            if reviewRecordDatabase == nil {return 0.0}
            return reviewRecordDatabase?.averageProficiency ?? 0
        }
    }
    
    var reportAllReviewRecordKeys: [ReviewRecordKey]? {
        get {
            var keys = [ReviewRecordKey]()
            reviewRecordDatabase?.database.forEach({ (key, _) in
                keys.append(key)
            })
            
            keys.removeDuplicates()
            if keys.count > 0 {
                return keys
            }
            return nil
        }
    }
    
    var reviewState: ReviewState {
        get {
            if reviewRecordDatabase == nil {
                return .new
            } else {
                if reviewRecordDatabase?.database.count == 0 {
                    return .new
                }
            }
            
            if let date = nextReviewDate {
                if Date() < date {
                    return .neutral
                } else {
                    return .reviewIsDue
                }
            }
            
            return .neutral
        }
    }
    
    var nextReviewDate: Date? {
        get {
            return reviewRecordDatabase?.nearestDueDate ?? nil
            //return reviewRecordDatabase?.database.compactMap({getNextReviewDate(for: $0.key)}).min() ?? nil
            
            //            if self.reviewRecordDatabase == nil {return nil}
            //
            //            if let datesOptionals = self.reviewRecordDatabase?.database.map({ getNextReviewDate(for: $0.key) }) {
            //                let dates = datesOptionals.filter({ $0 != nil }) as! [Date]
            //                return dates.min()
            //            }
            //
            //            return nil
        }
    }
    
    // TODO: delete isOverDueFlags after bug fixed.
    var isOverDueFlags: [ReviewRecordKey : Bool]?
    var reviewStateForKeyFlags: [ReviewRecordKey : ReviewState]?
    
    var prompts: [String : CubePrompt]?
    var reviewRecordDatabase: ReviewDatabase? {
        didSet {
            if let database = self.reviewRecordDatabase {
                database.database.forEach({
                    if self.isOverDueFlags?[$0.key] != nil {
                        if database.getRetention(forKey: $0.key) >= 0.98 {
                            self.isOverDueFlags?[$0.key] = false
                        }
                    }
                })
            }
        }
    }
    
    enum Key: CodingKey {
        case name
        case fileName
        case creationDate
        case recordHistory
        case recordDatabase
        case prompts
        case defaultIndex
    }
    
    enum ReviewState {
        case new
        case neutral
        case reviewIsDue
    }
    
    public init(){
        self.creationDate = Date()
        self.fileName = UniqueString.timeStamp.generate
    }
    
    public init(prompts: [String : CubePrompt]){
        self.creationDate = Date()
        self.prompts = prompts
        self.fileName = UniqueString.timeStamp.generate
    }
    
    func getRetentionFor(reviewRecords: [ReviewRecordKey]) -> Double {
        
        var index = 0
        var retentionTotal = 0.0
        
        reviewRecords.forEach { recordKey in
            let retention = reviewRecordDatabase?.getRetention(forKey: recordKey) ?? 0.0
            retentionTotal += retention
            index += 1
        }
        
        if index == 0 {
            return 0
        } else {
            return retentionTotal / Double(index)
        }
        
    }
    
    func getProficiencyFor(reviewRecords: [ReviewRecordKey]) -> Double {
        
        var index = 0
        var proficiencyTotal = 0.0
        
        reviewRecords.forEach { recordKey in
            let proficiency = reviewRecordDatabase?.getProficiency(forKey: recordKey) ?? 0.0
            proficiencyTotal += proficiency
            index += 1
        }
        
        if index == 0 {
            return 0
        } else {
            return proficiencyTotal / Double(index)
        }
    }
    
    func getStateFor(reviewRecord: ReviewRecordKey) -> ReviewState? {
        if let state = self.reviewStateForKeyFlags?[reviewRecord] {
            return state
        }
        
        return nil
    }
    
    mutating func commitReviewRecord(fromPromptKey: String, toPromptKey: String, withProficiency: Double?){
        
        guard let retention = withProficiency else {return}
        let thisKey = ReviewRecordKey(fromPrompt: fromPromptKey, toPrompt: toPromptKey)
        
        // set the reviewState flags.  If flagged as due/new, needs to be 100% retention before being flagged as neutral again.
        
        if self.reviewStateForKeyFlags?[thisKey] == nil {
            self.reviewStateForKeyFlags?[thisKey] = .new
        }
        
        if let currentReviewState = self.reviewStateForKeyFlags?[thisKey] {
            if currentReviewState == .new || currentReviewState == .reviewIsDue {
                if retention > 0.98 {
                    self.reviewStateForKeyFlags?[thisKey] = .neutral
                }
            }
        }
        
        print("\(#function)")
        print("     cubeName: \(self.name ?? "")")
        print("     forKey: \(thisKey.fromPrompt) to \(thisKey.toPrompt)")
        print("     retention: \(withProficiency ?? -1)")
        let state = self.reviewStateForKeyFlags?[thisKey] != nil ? String(describing: self.reviewStateForKeyFlags![thisKey]!) : "nil"
        print("     state: \(state)")
        
        //TESTING: this deals with interrupted learning sessions. somewhat.. no advance if not learned.
        //DIDN'T WORK because it didn't record progress at all!!!! stupid.
        //if retention < 0.98 {return}
        
        // no previous records?  Make a database.
        if reviewRecordDatabase == nil {
            
            // keep as new if virgin cube and 0 proficiency.  otherwise will have a reviewflag down the road for a cube that was never learned
            if retention == 0 {return}
            
            var database = [ReviewRecordKey : [ReviewRecord]]()
            
            var validity = false
            if retention >= 0.98 {validity = true}
            
            let newRecord = ReviewRecord(date: Date(), proficiency: retention, validReviewTime: validity)
            database[thisKey] = [newRecord]
            reviewRecordDatabase = ReviewDatabase(database: database)
            
            return
        }
        
        // no preview records for Key?  Make new record array // unless proficiency is zero..
        if self.reviewRecordDatabase?.database[thisKey] == nil {
            
            // don't create record if key doesn't exist and 0 proficiency.  otherwise will have a reviewflag down the road for a cube that was never learned
            if retention == 0 {return}
            
            self.reviewRecordDatabase?.database[thisKey] = [ReviewRecord]()
            
            var validity = false
            if retention >= 0.98 {validity = true}
            
            let newRecord = ReviewRecord(date: Date(), proficiency: retention, validReviewTime: validity)
            self.reviewRecordDatabase?.database[thisKey]!.append(newRecord)
            return
        }
        
        // if it exists, check when was the last to see if valid review time.
        if let validDates = self.reviewRecordDatabase?.database[thisKey]?.filter({ reviewRecord in
            reviewRecord.validReviewTime == true
        }) {
            
            var validity = false
            
            // card is still new and hasn't reached 1.0 retention yet to set a valid value
            if validDates.count == 0 {
                if retention >= 0.98 { validity = true }
            }
            
            var lastDate = Date()
            if (validDates.last?.date) != nil {
                
                if let nextDate = getNextReviewDate(for: thisKey) {
                    if Date() > nextDate {
                        validity = true
                    }
                } else {
                    validity = true
                }
                
                if retention < 0.98 { validity = false }
                lastDate = validDates.last!.date!
            }
            
            // if within 24 hours then just overwrite.
            //print("\(#function) \(Calendar.current.dateComponents([.hour], from: lastDate, to: Date()).hour)")
            if let hours = Calendar.current.dateComponents([.hour], from: lastDate, to: Date()).hour {
                if hours < 24 {
                    //let validity = self.reviewRecordDatabase?.database[thisKey]!.last!.validReviewTime!
                    let _ = self.reviewRecordDatabase?.database[thisKey]!.popLast()
                    let newRecord = ReviewRecord(date: Date(), proficiency: retention, validReviewTime: validity)
                    self.reviewRecordDatabase?.database[thisKey]!.append(newRecord)
                    return
                }
            }
            
            let newRecord = ReviewRecord(date: Date(), proficiency: retention, validReviewTime: validity)
            self.reviewRecordDatabase?.database[thisKey]!.append(newRecord)
            
        }
        
        
    }
    
    public func getNextReviewDate(for recordKey: ReviewRecordKey?) -> Date? {
        if let key = recordKey {
            return self.reviewRecordDatabase?.getDueDate(forKey: key) ?? nil
        } else {
            return nextReviewDate
        }
    }
    
    mutating func editPromptKeys(with keys: Dictionary<String, String>){
        self.reviewRecordDatabase?.database.forEach({ (databaseKey, _) in
            keys.forEach({(oldKey, newKey) in
                var fromPrompt = databaseKey.fromPrompt
                var toPrompt = databaseKey.toPrompt
                var change = false
                
                if databaseKey.fromPrompt == oldKey {
                    fromPrompt = newKey
                    change = true
                }
                
                if databaseKey.toPrompt == oldKey {
                    toPrompt = newKey
                    change = true
                }
                
                if change {
                    let newReviewKey = ReviewRecordKey(fromPrompt: fromPrompt, toPrompt: toPrompt)
                    self.reviewRecordDatabase?.database.switchKey(fromKey: databaseKey, toKey: newReviewKey)
                }
            })
        })
    }
    
    private mutating func setStatePerReviewKeyFlags() {
        if let database = self.reviewRecordDatabase {
            database.database.forEach({
                
                // instantiate class' variable if not done already.
                if self.reviewStateForKeyFlags == nil {
                    self.reviewStateForKeyFlags = [ReviewRecordKey : ReviewState]()
                }
                
                // if record exists for this key.. it might be new.  it might be due. check below.
                self.reviewStateForKeyFlags?[$0.key] = .neutral
                
                // so find out if new.  New means it has never gotten to 100% retention
                var noCompletions = true
                database.database[$0.key]?.forEach({ record in
                    if record.validReviewTime == true {noCompletions = false}
                })
                if noCompletions == true {
                    self.reviewStateForKeyFlags?[$0.key] = .new
                }
                
                // so find out if due.
                if let dueDate = database.getDueDate(forKey: $0.key) {
                    if dueDate < Date() {
                        self.reviewStateForKeyFlags?[$0.key] = .reviewIsDue
                    }
                }
                
                // if the key isn't in record... the nil in the flags variable.  Nil assumed to be new in reviewSession.
                // when reviewSession accesses a nil, it sets the flag as new for the key being used by the session.
            })
        }
    }
    
    private mutating func setOverDueFlags(){
        if let database = self.reviewRecordDatabase {
            database.database.forEach({
                if let dueDate = database.getDueDate(forKey: $0.key) {
                    if dueDate < Date() {
                        if self.isOverDueFlags == nil {
                            self.isOverDueFlags = [ReviewRecordKey : Bool]()
                        }
                        self.isOverDueFlags?[$0.key] = true
                    }
                }
            })
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: Key.self)
        try container.encode(name, forKey: .name)
        try container.encode(fileName, forKey: .fileName)
        try container.encode(creationDate, forKey: .creationDate)
        try container.encode(prompts, forKey: .prompts)
        //try container.encode(recordHistory, forKey: .recordHistory)
        try container.encode(reviewRecordDatabase, forKey: .recordDatabase)
        try container.encode(defaultIndex, forKey: .defaultIndex)
    }
    
    init(from decoder: Decoder) throws {
        let container             = try decoder.container(keyedBy: Key.self)
        self.fileName             = try container.decode(String.self, forKey: .fileName)
        self.name                 = try container.decodeIfPresent(String.self, forKey: .name)
        self.creationDate         = try container.decodeIfPresent(Date.self, forKey: .creationDate)
        self.prompts              = try container.decodeIfPresent([String : CubePrompt].self, forKey: .prompts)
        //self.recordHistory        = try container.decodeIfPresent([ReviewRecord].self, forKey: .recordHistory)
        self.reviewRecordDatabase = try container.decodeIfPresent(ReviewDatabase.self, forKey: .recordDatabase)
        self.defaultIndex         = try container.decodeIfPresent(Int.self, forKey: .defaultIndex)
        
        setOverDueFlags()
        setStatePerReviewKeyFlags()
    }
}

struct ReviewRecord: Codable {
    var date: Date?
    var proficiency: Double? // wrong use of word... but it's grandfathered in now... changing == big errors on load
    var validReviewTime: Bool?
}

struct ReviewRecordKey: Codable, Hashable {
    var fromPrompt: String
    var toPrompt: String
}

struct ReviewDatabase: Codable {
    
    private let proficiencies: [Double] = [0.1, 0.4, 0.6, 0.75, 0.85, 0.91, 0.96, 1.0]
    
    // this needs to exist to avoid limbo between records/ advancing prematurely due to interrupted sessions.
    // can't interfere with adding records, because those track the progress during review
    // but proficiency level and notifications cannot be driven simply by the existence of a review record at any given date.
    //var levelForKeyRecord: [ReviewRecordKey : Int]?
    
    var averageRetention: Double {
        get {
            var sum = 0.0
            database.forEach({
                sum += getRetention(forKey: $0.key)
            })
            return (sum / Double(database.count) )
        }
    }
    var averageProficiency: Double {
        get {
            var sum = 0.0
            database.forEach({
                sum += getProficiency(forKey: $0.key)
            })
            return (sum / Double(database.count) )
        }
    }
    
    var nearestDueDate: Date? {
        get {
            return database.compactMap({getDueDate(forKey: $0.key)}).min() ?? nil
        }
    }
    
    var database: [ReviewRecordKey : [ReviewRecord] ]
    
    func getRetention(forKey: ReviewRecordKey) -> Double {
        
        func halfLife(lastRecord: ReviewRecord, lengthOfTime: Int) -> Double {
            //=1*POWER(0.8,(A3/one))
            guard let lastRetention = lastRecord.proficiency else {return 0}
            guard let lastDate = lastRecord.date else {return 0}
            if Calendar.current.isDate(lastDate, inSameDayAs: Date()) {return lastRecord.proficiency ?? 0.0}
            
            let d1 = Calendar.current.startOfDay(for: lastDate)
            let d2 = Calendar.current.startOfDay(for: Date())
            let components = Calendar.current.dateComponents([.day], from: d1, to: d2)
            guard let interval = components.day else {return 0}
            
            let t2 = (Double(interval) / Double(lengthOfTime))
            return lastRetention * (pow(0.8,t2))
        }
        
        if let lastRecord = database[forKey]?.last {
            
            let validSum = database[forKey]!.filter({ $0.validReviewTime == true}).count
            let halfLifeLength = Equations.fibonacci(for: validSum)
            if halfLifeLength == 0 {return lastRecord.proficiency ?? 0.0}
            
            let halfLifeValue = halfLife(lastRecord: lastRecord, lengthOfTime: halfLifeLength)
            
            return halfLifeValue
        }
        
        return 0.0
    }
    
    func getProficiency(forKey: ReviewRecordKey) -> Double {
        
        // calculate the multiplier, index for "proficiencies" as defined above.
        if let validReviewSum = database[forKey]?.filter({$0.validReviewTime == true}).count {
            var index = validReviewSum - 1
            if index < 0 {index = 0}
            if index >= proficiencies.count {index = proficiencies.count - 1}
            return getRetention(forKey: forKey) * proficiencies[index]
        }
        return 0.0
    }
    
    func getProficiencyHistory(forKey: ReviewRecordKey) -> [(proficiency: Double, onDate: Date, validReviewTime: Bool)]? {
        
        if let retentions = getRetentionHistory(forKey: forKey) {
            
            var proficiencyHistory = [(Double, Date, Bool)]()
            for (index, entry) in retentions.enumerated() {
                var profIndex = index
                if profIndex >= proficiencies.count {profIndex = proficiencies.count - 1}
                let proficiency = entry.retention * proficiencies[profIndex]
                proficiencyHistory.append((proficiency,entry.onDate,entry.validReviewTime))
            }
            return proficiencyHistory
        }
        
        return nil
    }
    
    func getRetentionHistory(forKey: ReviewRecordKey) -> [(retention: Double, onDate: Date, validReviewTime: Bool)]? {
        
        if let records = database[forKey] {
            var history = [(Double, Date, Bool)]()
            
            for (_, record) in records.enumerated() {
                let newEntry = (record.proficiency ?? 0, record.date ?? Date.distantPast, record.validReviewTime ?? true)
                if record.validReviewTime == true {
                    history.append(newEntry)
                }
            }
            
            return history
        }
        return nil
    }
    
    func getDueDate(forKey: ReviewRecordKey) -> Date? {
        
        if let reviewRecordArry = database[forKey]?.filter({ $0.validReviewTime == true }) {
            if let lastDate = reviewRecordArry.last?.date {
                let dayInterval = Equations.fibonacci(for: reviewRecordArry.count)
                let nextReview = lastDate.addingTimeInterval(TimeInterval(days: dayInterval))
                return nextReview
            }
        }
        
        return nil
    }
}
