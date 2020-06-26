//
//  ReviewSession.swift
//  Flash Cubes
//
//  Created by Jeffrey Thompson on 5/22/19.
//  Copyright © 2019 Jeffrey Thompson. All rights reserved.
//

import Foundation

struct ReviewSession {
    
    enum ReviewError: Error {
        case promptsNil
        case cubeNotFound
    }
    
    struct SessionRecords {
        
        var startedWithOverdue: Bool? = nil
        var startedWithNew: Bool? = nil
        var overDueFinishNotificationSent = false
        
        var overDueFinished: Bool? = nil
        var newStackFinished: Bool? = nil
        var newFinishedNotificationSent = false
        
        var recordOfCubeKeysSent = [String]()
    }
    
    struct NewStack {
        
        var cubeKeys: [String] {
            didSet {
                cubeKeys.forEach({
                    learnedNew[$0] = false
                })
            }
        }
        
        var deck: FlashCubeDeck!
        var cubes: [String : FlashCube] {
            return deck.flashCubes?.filter({ self.cubeKeys.contains($0.key)}) ?? [String : FlashCube]()
        }
        
        var learnedNew: [String : Bool]
        
        init(deck: FlashCubeDeck, sessionKey: ReviewRecordKey, maxReviewAmount: Int) {
            self.cubeKeys = [String]()
            self.deck = deck
            
            if let newKeys = deck.flashCubes?.filter({ $0.value.getStateFor(reviewRecord: sessionKey) == .new }).keys {
                var newKeysLimit = [String]()
                var array = Array(newKeys)
                
                var forLoopMax = 0
                if array.count > 0 {
                    forLoopMax = array.count
                }
                
                if forLoopMax > maxReviewAmount {
                    forLoopMax = maxReviewAmount
                }
                
                for _ in 0..<forLoopMax {
                    newKeysLimit.append(array.removeFirst())
                }
                self.cubeKeys = newKeysLimit
            }
            
            learnedNew = [String: Bool]()
        }
        
        // called at commit / save function
        mutating func removeLearned(forReviewKey: ReviewRecordKey) -> Int {
            
            cubes.forEach { (cubeEntry) in
                
                if let state = cubeEntry.value.getStateFor(reviewRecord: forReviewKey) {
                    switch state {
                    case .new:
                        break
                    default:
                        self.learnedNew[cubeEntry.key] = true
                    }
                }
//
//                if let retention = cubeEntry.value.reviewRecordDatabase?.getRetention(forKey: forReviewKey) {
//                    if retention > 0.98 {
//                        //self.cubeKeys.removeAll(where: {$0 == cubeEntry.key})
//                        self.learnedNew[cubeEntry.key] = true
//                    }
//                }
            }
            
            let learned = learnedNew.filter({$0.value == true}).count
            
            if learned == cubeKeys.count {
                cubeKeys = [String]()
                return 0
            }
            
            return (cubeKeys.count - learned)
        }
        
        func testPrintNewCubes(){
            print("\(#function) ")
            for key in self.cubeKeys {
                if let cube = self.cubes[key] {
                    print("     \(cube.name ?? "")")
                }
            }
        }
        
        func testPrintValid(ary: [String]){
            print("\(#function) ")
            for key in ary {
                if let cube = self.cubes[key] {
                    print("     \(cube.name ?? "")")
                }
            }
        }
        
        func testPrintSorted(ary: [String], reviewKey: ReviewRecordKey){
            
            print("\(#function) ")
            for key in ary {
                if let cube = self.cubes[key] {
                    if let retention = cube.reviewRecordDatabase?.getRetention(forKey: reviewKey) {
                        print("     \(cube.name ?? "") \(retention)")
                    }
                }
            }
            
        }
    }
    
    var maxNewCubeAmount: Int
    
    var deck: FlashCubeDeck
    
    var delegate: ReviewSessionDelegate!
    
    var questionKey: String
    var questionKeySecondary: String?
    var answerKey: String
    var answerKeySecondary: String?
    
    var sessionReviewKey: ReviewRecordKey {
        get {
            return ReviewRecordKey(fromPrompt: questionKey, toPrompt: answerKey)
        }
    }
    
    var reviewSessionStartsWithOverdue: Bool?
    
    func testPrintOverdue(reviewKey: ReviewRecordKey){
        
        /*let overdue = deck.flashCubes?.filter({ (_, cube) in
            return (cube.reviewRecordDatabase?.getDueDate(forKey: reviewKey) ?? Date.distantFuture) < Date()
        })
        
        print("\(#function)")
        overdue?.forEach({ (_, cube) in
            print("     \(cube.name ?? "")")
        })*/
        
        print("\(#function)")
        self.overDue.forEach({ (_, cube) in
            print("     \(cube.name ?? "")")
        })
    }
    
    lazy var titles: (question: String, questionSecondary: String?, answer: String, answerSecondary: String?) = {
        return (question: questionKey, questionSecondary: questionKeySecondary, answer: answerKey, answerSecondary: answerKeySecondary)
    }()
    
    var sessionRecords = SessionRecords()
    var trackLastKeysGiven = [String]()
    lazy var newStack = NewStack(deck: self.deck, sessionKey: sessionReviewKey, maxReviewAmount: self.maxNewCubeAmount)//NewStack(deck: self.deck, sessionKey: sessionReviewKey)//NewStack(cubes: [String : FlashCube]())
    
    var overDue: [String : FlashCube] {
        
        /*
         let overdue = deck.flashCubes?.filter({ (_, cube) in
         return (cube.reviewRecordDatabase?.getDueDate(forKey: reviewKey) ?? Date.distantFuture) < Date()
         })
         
         print("\(#function)")
         overdue?.forEach({ (_, cube) in
         print("     \(cube.name ?? "")")
         })*/
        
        get {
            let overDue = deck.validCubes(forKey: sessionReviewKey)?.filter({//deck.flashCubes?.filter({
                // load based on reviewStateFlags that are set in the flashcube struct on load.
                if let overdue = $0.value.reviewStateForKeyFlags?[sessionReviewKey] {
                    if overdue == .reviewIsDue {
                        return true
                    }
                }
                return false
            }) ?? [String : FlashCube]()
            return overDue
        }
    }
    
    var neutral: [String : FlashCube] {
        get {
            let neutral = deck.validCubes(forKey: sessionReviewKey)?.filter({
                if let neutral = $0.value.reviewStateForKeyFlags?[sessionReviewKey] {
                    if neutral == .neutral {return true}
                }
                return false
            }) ?? [String : FlashCube]()
            return neutral
        }
    }
    
    init(deck: FlashCubeDeck, questionKey: String, answerKey: String, maxNewCubeAmount: Int) {
        self.deck = deck
        self.questionKey = questionKey
        self.answerKey = answerKey
        self.maxNewCubeAmount = maxNewCubeAmount
        testPrintAll()
    }
    
    init(deck: FlashCubeDeck, questionKey: String, answerKey: String, questionKeySecondary: String?, answerKeySecondary: String?, maxNewCubeAmount: Int) {
        self.deck = deck
        self.questionKey = questionKey
        self.answerKey = answerKey
        self.questionKeySecondary = questionKeySecondary
        self.answerKeySecondary = answerKeySecondary
        self.maxNewCubeAmount = maxNewCubeAmount
        testPrintAll()
    }

    mutating func commit(for cubeKey: String, retention: Double, completion: @escaping (_ overDueNotificationNeeded: Bool, _ newNotificationNeeded: Bool) -> Void) throws {
        
        deck.flashCubes?[cubeKey]?.commitReviewRecord(fromPromptKey: self.questionKey, toPromptKey: self.answerKey, withProficiency: retention)
        
        
        do {
            try deck.saveCube(forKey: cubeKey, with: self.sessionReviewKey)
        } catch let error {
            throw error
        }
        
        if overDue.count == 0 {
            sessionRecords.overDueFinished = true
        }
        
        
        // check to see if overdue notification needs to be sent:
        if (sessionRecords.startedWithOverdue ?? false) && (sessionRecords.overDueFinished ?? false) {
            if !sessionRecords.overDueFinishNotificationSent {
                completion(true, false)
                sessionRecords.overDueFinishNotificationSent = true
                return
            }
        }
        
        // check to see if new notification needs to be sent:
        if (sessionRecords.startedWithNew ?? false) && !(sessionRecords.newStackFinished ?? false) {
            //if !sessionRecords.newFinishedNotificationSent {
                if newStack.removeLearned(forReviewKey: sessionReviewKey) == 0 {
                    sessionRecords.newFinishedNotificationSent = true
                    completion(false, true)
                    return
                }
            //}
        }
        
        completion(false, false)
    }
    
    mutating func getNext() throws -> (cubeKey: String, question: CubePrompt, questionSecondary: CubePrompt?, answer: CubePrompt, answerSecondary: CubePrompt?, progress: Double) {
        
        func pullCubeFromDeck(forKeys: [String]) throws -> (cubeKey: String, question: CubePrompt, questionSecondary: CubePrompt?, answer: CubePrompt, answerSecondary: CubePrompt?, progress: Double) {
            
            func randomCubeWeightedForLowRetention(from cubeKeys: [String]) -> String? {
                
                //validate
                for key in cubeKeys {
                    guard self.deck.flashCubes?[key]?.prompts?[questionKey] != nil else {return nil}
                    guard self.deck.flashCubes?[key]?.prompts?[answerKey] != nil else {return nil}
                }
                
                let keys = cubeKeys.sorted(by: {
                    let valOne = self.deck.flashCubes![$0]!.reviewRecordDatabase?.getRetention(forKey: self.sessionReviewKey) ?? 0.0
                    let valTwo = self.deck.flashCubes![$1]!.reviewRecordDatabase?.getRetention(forKey: self.sessionReviewKey) ?? 0.0
                    return valOne < valTwo
                })
                //let keys = cubeKeys.sorted(by: { self.deck.flashCubes![$0]!.retention < self.deck.flashCubes![$1]!.retention })
                
                newStack.testPrintSorted(ary: keys, reviewKey: self.sessionReviewKey)
                
                var cubesForTestInspection = [FlashCube]()
                
                for key in keys {
                    if let cube = deck.flashCubes?[key] {
                        cubesForTestInspection.append(cube)
                    }
                }
                
                // get some values < 1.0 to multiply together.. drawing probability closer to low..
                let first = Double.random(in: 0 ..< 1.0)
                let second = Double.random(in: 0 ..< 1.0)
                
                let weightedIndex = Int((first * second) * Double(keys.count))
                
                return keys[weightedIndex]
            }
            
            while sessionRecords.recordOfCubeKeysSent.count > 3 {
                sessionRecords.recordOfCubeKeysSent.removeFirst()
            }
            
            while (sessionRecords.recordOfCubeKeysSent.count >= forKeys.count) && (sessionRecords.recordOfCubeKeysSent.count > 0) {
                sessionRecords.recordOfCubeKeysSent.removeFirst()
            }
            
            let valid = forKeys.filter({ !sessionRecords.recordOfCubeKeysSent.contains($0) })
            
            newStack.testPrintValid(ary: valid)
            
            if let cubeKey = randomCubeWeightedForLowRetention(from: valid) {//valid.randomElement() {
                if let cube = deck.flashCubes?[cubeKey] {
                    guard let question = cube.prompts?[questionKey] else {throw ReviewError.promptsNil}
                    guard let answer = cube.prompts?[answerKey] else {throw ReviewError.promptsNil}
                    
                    let secondaryQuestion = cube.prompts?[questionKeySecondary ?? ""]
                    let secondaryAnswer = cube.prompts?[answerKeySecondary ?? ""]
                    
                    let retention = cube.reviewRecordDatabase?.getRetention(forKey: sessionReviewKey) ?? 0
                    
                    sessionRecords.recordOfCubeKeysSent.append(cubeKey)
                    
                    return (cubeKey: cubeKey, question: question, questionSecondary: secondaryQuestion, answer: answer, answerSecondary: secondaryAnswer, progress: retention)
                }
            }
            
            throw ReviewError.cubeNotFound
        }
        
        testPrintOverdue(reviewKey: sessionReviewKey)
        // get OverDue cubes
        // check to see if we need to go into the overdue on this turn.
        if (sessionRecords.startedWithOverdue ?? true) && !(sessionRecords.overDueFinished ?? false) {
            // okay see if there's anything here.

            if overDue.count > 0 {
                // if just starting out and value is nil.. set as true
                if sessionRecords.startedWithOverdue == nil {
                    sessionRecords.startedWithOverdue = true
                    sessionRecords.overDueFinished = false
                }
                
                let keys = Array(overDue.keys)
                
                do {
                    
                    // if less than 3 not particularly useful to keep reviewing one card repeatedly
                    // add in the neutrals as needed to shake things up.
                    if overDue.count < 3 {
                        if neutral.count > 0 {
                            let dice = Double.random(in: 0.0 ..< 1.0)
                            if dice < (Double(overDue.count) * 0.33) {
                                return try pullCubeFromDeck(forKeys: Array(neutral.keys))
                            } else {
                                return try pullCubeFromDeck(forKeys: keys)
                            }
                        }
                    }
                    
                    return try pullCubeFromDeck(forKeys: keys)
                }catch let error {
                    throw error
                }
                
            } else {
                // if startedWithOverdue is established fact.. and also true...
                // then overdue cubes have all been finished.
                if (sessionRecords.startedWithOverdue ?? false) {
                    sessionRecords.overDueFinished = true
                }
                
                // if just starting out and value is nil.. set as false
                if sessionRecords.startedWithOverdue == nil {
                    sessionRecords.startedWithOverdue = false
                }
            }
        }
        
        // check to see if we need to go into the newStack on this turn.
        if (sessionRecords.startedWithNew ?? true) && !(sessionRecords.newStackFinished ?? false){
            
            // establish if there are new cubes for the recordKey.  Either true or false, set the reviewsession record appropriately.
            if self.sessionRecords.startedWithNew == nil {
                //autoSet startWithNew to false - change if find new.
                self.sessionRecords.startedWithNew = false
                
                //init unreviewed nil values as new
                
                if let valid = self.deck.validCubes(forKey: self.sessionReviewKey) {

                    for (key, cube) in valid {

                        if cube.reviewStateForKeyFlags == nil {
                            self.deck.flashCubes?[key]?.reviewStateForKeyFlags = [ReviewRecordKey : FlashCube.ReviewState]()
                        }
                
                        if cube.reviewStateForKeyFlags?[self.sessionReviewKey] == nil {
                            self.deck.flashCubes?[key]?.reviewStateForKeyFlags?[self.sessionReviewKey] = .new
                            self.sessionRecords.startedWithNew = true
                        }
                        
                        if cube.reviewStateForKeyFlags?[self.sessionReviewKey] == .new {
                            self.sessionRecords.startedWithNew = true
                        }
                    }
                }
                
                // bug with closures.. trying the above instead.
                /*self.deck.validCubes(forKey: self.sessionReviewKey)?.forEach({
                    
                    if self.deck.flashCubes?[$0.key]?.reviewStateForKeyFlags == nil {
                        self.deck.flashCubes?[$0.key]?.reviewStateForKeyFlags = [ReviewRecordKey : FlashCube.ReviewState]()
                    }
                    
                    if $0.value.reviewStateForKeyFlags?[self.sessionReviewKey] == nil {
                        self.deck.flashCubes?[$0.key]?.reviewStateForKeyFlags?[self.sessionReviewKey] = .new
                        self.sessionRecords.startedWithNew = true
                    }
                })*/
            }
            
            //if newcubes exist && if newStack is not loaded, keep up to X (user specified) in the stack.
            if (sessionRecords.startedWithNew ?? false) && (newStack.cubeKeys.count < maxNewCubeAmount) {
                // sort them into order
                
                if newStack.cubeKeys.count < maxNewCubeAmount {
                    
                    let new = (deck.validCubes(forKey: sessionReviewKey)?.filter({
                        if let new = $0.value.reviewStateForKeyFlags?[self.sessionReviewKey] {
                            if new == .new {
                                return true
                            }
                        }
                        return false
                    }) ?? [String : FlashCube]() ).sorted(by: {
                        //($0.value.name ?? "a") < ($1.value.name ?? "b")
                        ($0.key) < ($1.key)
                    })
                    
                    //load up to max amount into newStack
                    var index = newStack.cubeKeys.count
                    new.forEach({
                        // check to not double load keys into new stack.
                        if !self.newStack.cubeKeys.contains($0.key){
                            if index < self.maxNewCubeAmount {
                                self.newStack.cubeKeys.append($0.key)
                            }
                            index += 1
                        }
                    })
                }
            }
            
            if newStack.cubeKeys.count > 0 {
                
                //newStack.testPrintNewCubes()
                
                do {
                    // repeating the same card over and over again.. not cool. doesn't help learn.
                    // only if there's other cubes to go to though....
                    if newStack.cubeKeys.count < 3 {
                        if neutral.count > 0 {
                            // percentage that will give new cube is (newStack.count * 0.2) 2 * 0.33 = 66%, 1 - 33%
                            let dice = Double.random(in: 0.0 ..< 1.0)
                            if dice < (Double(newStack.cubeKeys.count) * 0.33) {
                                return try pullCubeFromDeck(forKeys: Array(neutral.keys))
                            } else {
                                return try pullCubeFromDeck(forKeys: newStack.cubeKeys)
                            }
                        }
                    }
                    
                    return try pullCubeFromDeck(forKeys: newStack.cubeKeys)
                } catch let error {
                    throw error
                }
            } else {
                sessionRecords.newStackFinished = true
            }
        }
        
        // go to the neutral..

        if neutral.count > 0 {
            do {
                return try pullCubeFromDeck(forKeys: Array(neutral.keys))
            } catch let error {
                throw error
            }
        }
        
        throw ReviewError.cubeNotFound
    }
    
    func testPrintAll(){
        
        print("\(#function)")
        
        deck.flashCubes?.forEach({ cube in
            
            print("     cubeName: \(cube.value.name ?? "")")
            
            cube.value.reviewRecordDatabase?.database.forEach({ (key, value) in
                
                print("         record: \(key.fromPrompt) to \(key.toPrompt)")
                print("         status: \(String(describing: cube.value.getStateFor(reviewRecord: self.sessionReviewKey)))")
                
                value.forEach({ record in
                    print("             date: \(record.date ?? Date.distantPast)")
                    print("             retention: \(record.proficiency ?? -1)")
                    print("             valid: \(record.validReviewTime ?? false)")
                })
            })
        })
    }
}
