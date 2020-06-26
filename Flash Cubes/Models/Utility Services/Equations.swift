//
//  Equations.swift
//  Flash Cubes
//
//  Created by Jeffrey Thompson on 4/26/19.
//  Copyright © 2019 Jeffrey Thompson. All rights reserved.
//

import Foundation
import UIKit

struct Equations {
    
    static func halfLife(forInitial retention: Double, minutes: Int, forFibonacci index: Int) -> Double {
        let fibonacciIndex = fibonacci(for: index)
        
        let days = (Double(minutes) / 24.0) / 60.0
        let t2 = (Double(days) / Double(fibonacciIndex))
        
        return retention * (pow(0.8,t2))
    }
    
    static func halfLife(forInitial retention: Double, hours: Int, forFibonacci index: Int) -> Double {
        let fibonacciIndex = fibonacci(for: index)
        
        let days = Double(hours) / 24.0
        let t2 = (Double(days) / Double(fibonacciIndex))
        
        return retention * (pow(0.8,t2))
    }
    
    static func halfLife(forInitial retention: Double, overLengthOf time: Int, forFibonacci index: Int) -> Double {
        //=1*POWER(0.8,(daysFromBeginDecay / fibonacciIndex ))
        let fibonacciIndex = fibonacci(for: index)
        
        let t2 = (Double(time) / Double(fibonacciIndex))
        return retention * (pow(0.8,t2))
    }
    
    static public func fibonacci(for n: Int) -> Int {
        guard n >= 1 else {return 0}
        var a = 0
        var b = 1
        var c = -1
        for _ in 1..<n {
            c = a+b
            a = b
            b = c
        }
        return a+b
    }
    
    static public func uniqueInt() -> Int {
        return Int(Date.timeIntervalSinceReferenceDate)
    }
    
}

extension TimeInterval {
    
    init(days: Int) {
        self.init(24*60*60*days)
    }
    
    init(hours: Int) {
        self.init(60*60*hours)
    }
    
    init(minutes: Int) {
        self.init(60 * minutes)
    }
}

extension Dictionary {
    mutating func switchKey(fromKey: Key, toKey: Key) {
        if let entry = removeValue(forKey: fromKey) {
            self[toKey] = entry
        }
    }
}

extension Array where Element: Hashable {
    func removingDuplicates() -> [Element] {
        var addedDict = [Element: Bool]()
        
        return filter {
            addedDict.updateValue(true, forKey: $0) == nil
        }
    }
    
    mutating func removeDuplicates() {
        self = self.removingDuplicates()
    }
}


public var currentDeviceIsiPad: Bool {
    get {
        return UIDevice.current.model == "iPad"
    }
}

