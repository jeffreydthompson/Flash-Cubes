//
//  RetentionDecayGraph.swift
//  Flash Cubes
//
//  Created by Jeffrey Thompson on 5/18/19.
//  Copyright © 2019 Jeffrey Thompson. All rights reserved.
//

import Foundation
import UIKit

class RetentionDecayGraph: UIView {
    
    let xAxis = [0.2, 0.5, 0.8]
    let graphResolution = 10
    
    var retentionData: [(retention: Double, onDate: Date, validReviewTime: Bool)]? {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    var proficiencyData: [(proficiency: Double, onDate: Date, validReviewTime: Bool)]? {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    var dueDate: Date? {
        didSet{
            self.setNeedsDisplay()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func resetViews(){
        self.subviews.forEach({$0.removeFromSuperview()})
    }
    
    func setupViews(){
        
        for axis in xAxis {
            let label = UILabel(frame: .zero)
            label.translatesAutoresizingMaskIntoConstraints = false
            label.font = UIFont.systemFont(ofSize: 9)
            label.textColor = .darkGray
            label.textAlignment = .right
            
            let percentage = Int(axis * 100)
            let text = "\(percentage)%"
            label.text = text
            
            self.addSubview(label)
            
            let y = self.frame.height * CGFloat(axis)
            
            NSLayoutConstraint.activate([
                label.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -5),
                label.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -y),
                label.widthAnchor.constraint(equalToConstant: 30),
                label.heightAnchor.constraint(equalToConstant: 10)
                ])
        }
    }
    
    override func draw(_ rect: CGRect) {
        
        resetViews()
        setupViews()
        
        for path in gridPaths(forPercentages: xAxis) {
            UIColor.darkGray.setStroke()
            path.stroke()
        }

        if let proficiencyData = proficiencyData {
            UIColor.appleBlue.setStroke()
            path(forProficiency: proficiencyData)?.stroke()
        }
        
        if let retentionData = retentionData {
            UIColor.graphRed.setStroke()
            path(forRetention: retentionData)?.stroke()
        }
        
        if let date = dueDate, let proficiencyData = proficiencyData {
            
            if date < Date() {
                
                UIColor.white.setStroke()
                duePath(forDate: date, proficiencyPoints: proficiencyData)?.stroke()
                
                if let startDate = proficiencyData.first?.onDate {
                    
                    let xOffset = getXmultipler(forStartDate: startDate, dueDate: date)
                    
                    let img = UIImage(named: "imgPastDue")
                    let imgView = UIImageView(image: img)
                    imgView.translatesAutoresizingMaskIntoConstraints = false
                    
                    self.addSubview(imgView)
                    
                    NSLayoutConstraint.activate([
                        imgView.topAnchor.constraint(equalTo: self.topAnchor),
                        imgView.heightAnchor.constraint(equalToConstant: 30),
                        imgView.widthAnchor.constraint(equalToConstant: 30),
                        imgView.centerXAnchor.constraint(equalTo: self.leadingAnchor, constant: xOffset)
                        ])
                }
            }
        }
        
        self.backgroundColor = .clear
        self.isOpaque = false
  
    }
    
    private func hourGetXmultipler(forStartDate: Date, dueDate: Date) -> CGFloat {
        
        let hourSpan = Calendar.current.dateComponents([.hour], from: forStartDate, to: Date()).hour!
        if hourSpan <= 0 {
            return 0
        }
        let dueDateSpan = Calendar.current.dateComponents([.hour], from: forStartDate, to: dueDate).hour!
        let xStep: CGFloat = self.frame.width / CGFloat(hourSpan)
        
        return (CGFloat(dueDateSpan) * xStep)
    }
    
    private func getXmultipler(forStartDate: Date, dueDate: Date) -> CGFloat {
        
        let daySpan = Calendar.current.dateComponents([.day], from: forStartDate, to: Date()).day!
        if daySpan <= graphResolution {
            return hourGetXmultipler(forStartDate: forStartDate, dueDate: dueDate)
        }
        let dueDateSpan = Calendar.current.dateComponents([.day], from: forStartDate, to: dueDate).day!
        let xStep: CGFloat = self.frame.width / CGFloat(daySpan)
        
        return CGFloat(dueDateSpan) * xStep
    }
    
    public func hoursDuePath(forDate: Date, proficiencyPoints: [(proficiency: Double, onDate: Date, validReviewTime: Bool)]) -> UIBezierPath? {
        
        if Date() < forDate {return nil}
        
        guard proficiencyPoints.count > 0 else {return nil}
        
        func hours(between: Date, and: Date) -> Int {
            return Calendar.current.dateComponents([.hour], from: between, to: and).hour!
        }
        
        var daySpan = 0
        var dueDateSpan = 0
        
        if let date0 = proficiencyPoints.first?.onDate {
            daySpan = hours(between: date0, and: Date())
            dueDateSpan = hours(between: date0, and: forDate)
        }
        
        if daySpan <= 0 {return nil} // then figure out hours?? ??
        let xStep: CGFloat = self.frame.width / CGFloat(daySpan)
        
        let x = CGFloat(dueDateSpan) * xStep
        
        let path = UIBezierPath()
        let yHi = self.frame.height
        let startPoint = CGPoint(x: x, y: 30)
        path.move(to: startPoint)
        let endPoint = CGPoint(x: x, y: yHi)
        path.addLine(to: endPoint)
        
        let pattern: [CGFloat] = [5.0, 5.0]
        path.setLineDash(pattern, count: 2, phase: 0.0)
        path.lineWidth = 0.5
        
        return path
    }
    
    public func duePath(forDate: Date, proficiencyPoints: [(proficiency: Double, onDate: Date, validReviewTime: Bool)]) -> UIBezierPath? {
        
        if Date() < forDate {return nil}
        
        guard proficiencyPoints.count > 0 else {return nil}
        
        func days(between: Date, and: Date) -> Int {
            return Calendar.current.dateComponents([.day], from: between, to: and).day!
        }
        
        var daySpan = 0
        var dueDateSpan = 0
        
        if let date0 = proficiencyPoints.first?.onDate {
            daySpan = days(between: date0, and: Date())
            dueDateSpan = days(between: date0, and: forDate)
        }
        
        if daySpan <= 10 {return hoursDuePath(forDate: forDate, proficiencyPoints: proficiencyPoints)} // then figure out hours?? ??
        let xStep: CGFloat = self.frame.width / CGFloat(daySpan)
        
        let x = CGFloat(dueDateSpan) * xStep
        
        let path = UIBezierPath()
        let yHi = self.frame.height
        let startPoint = CGPoint(x: x, y: 30)
        path.move(to: startPoint)
        let endPoint = CGPoint(x: x, y: yHi)
        path.addLine(to: endPoint)
        
        let pattern: [CGFloat] = [5.0, 5.0]
        path.setLineDash(pattern, count: 2, phase: 0.0)
        path.lineWidth = 0.5
        
        return path
    }
    
    public func gridPaths(forPercentages: [Double]) -> [UIBezierPath] {
        var paths = [UIBezierPath]()
        
        for percentage in forPercentages {
            let path = UIBezierPath()
            let y = self.frame.height - (self.frame.height * CGFloat(percentage))
            let startPoint = CGPoint(x: 0, y: y)
            path.move(to: startPoint)
            let endPoint = CGPoint(x: self.frame.width, y: y)
            path.addLine(to: endPoint)
            
            let pattern: [CGFloat] = [5.0, 5.0]
            path.setLineDash(pattern, count: 2, phase: 0.0)
            path.lineWidth = 0.5
            
            paths.append(path)
        }

        return paths
    }
    
    public func minutesPath(forProficiency points: [(proficiency: Double, onDate: Date, validReviewTime: Bool)]) -> UIBezierPath? {
        
        // roughly follow pattern of retention data.
        // only decay on last entry
        guard points.count > 0 else {return nil}
        
        func minutes(between: Date, and: Date) -> Int {
            return Calendar.current.dateComponents([.minute], from: between, to: and).minute!
        }
        
        var hourSpan = 0
        if let date0 = points.first?.onDate {
            hourSpan = minutes(between: date0, and: Date())
        }
        
        if hourSpan <= 0 {return nil} // then figure out hours?? ??
        
        let xStep: CGFloat = self.frame.width / CGFloat(hourSpan)
        let path = UIBezierPath()
        
        let startY = self.frame.height - (self.frame.height * CGFloat(points[0].proficiency))
        path.move(to: CGPoint(x: 0, y: startY))
        
        var trackCurrentX: CGFloat = 0.0
        
        if points.count == 1 {
            let hoursFromLast = minutes(between: points.last!.onDate, and: Date())
            for hour in 0..<hoursFromLast {
                let thisHourDecayValue = Equations.halfLife(forInitial: points[0].proficiency, minutes: hour, forFibonacci: 1)
                let thisHourDecayY = self.frame.height - (self.frame.height * CGFloat(thisHourDecayValue))
                let thisHourX = trackCurrentX + ( CGFloat(hour) * xStep )
                let thisHourPoint = CGPoint(x: thisHourX, y: thisHourDecayY)
                path.addLine(to: thisHourPoint)
            }
            let lastDecay = Equations.halfLife(forInitial: points.last!.proficiency, minutes: hoursFromLast, forFibonacci: 1)
            let yLast = self.frame.height - (self.frame.height * CGFloat(lastDecay))
            path.addLine(to: CGPoint(x: self.frame.width, y: yLast))
        }
        
        for index in 1..<points.count {
            let hoursPassed = minutes(between: points[index-1].onDate, and: points[index].onDate)
            
            let xLocal = trackCurrentX + CGFloat(hoursPassed) * xStep
            trackCurrentX = xLocal
            let yLocal = self.frame.height - (self.frame.height * CGFloat(points[index].proficiency))
            let pointLocal = CGPoint(x: xLocal, y: yLocal)
            path.addLine(to: pointLocal)
            
            // last iteration wrap up
            if index == points.count - 1 {
                //let daysFromLast = Calendar.current.compare(points.last!.onDate, to: Date(), toGranularity: .day).rawValue
                let hoursFromLast = minutes(between: points.last!.onDate, and: Date())
                for hour in 0..<hoursFromLast {
                    let thisHourDecayValue = Equations.halfLife(forInitial: points[index].proficiency, minutes: hour, forFibonacci: index)
                    let thisHourDecayY = self.frame.height - (self.frame.height * CGFloat(thisHourDecayValue))
                    let thisHourX = trackCurrentX + ( CGFloat(hour) * xStep )
                    let thisHourPoint = CGPoint(x: thisHourX, y: thisHourDecayY)
                    path.addLine(to: thisHourPoint)
                }
                let lastDecay = Equations.halfLife(forInitial: points.last!.proficiency, minutes: hoursFromLast, forFibonacci: index)
                let yLast = self.frame.height - (self.frame.height * CGFloat(lastDecay))
                path.addLine(to: CGPoint(x: self.frame.width, y: yLast))
            }
        }
        
        path.lineWidth = 3.5
        return path
    }
    
    public func hoursPath(forProficiency points: [(proficiency: Double, onDate: Date, validReviewTime: Bool)]) -> UIBezierPath? {
        
        // roughly follow pattern of retention data.
        // only decay on last entry
        guard points.count > 0 else {return nil}
        
        func hours(between: Date, and: Date) -> Int {
            return Calendar.current.dateComponents([.hour], from: between, to: and).hour!
        }
        
        var hourSpan = 0
        if let date0 = points.first?.onDate {
            hourSpan = hours(between: date0, and: Date())
        }
        
        if hourSpan <= graphResolution {return minutesPath(forProficiency: points)} // then figure out hours?? ??
        
        let xStep: CGFloat = self.frame.width / CGFloat(hourSpan)
        let path = UIBezierPath()
        
        let startY = self.frame.height - (self.frame.height * CGFloat(points[0].proficiency))
        path.move(to: CGPoint(x: 0, y: startY))
        
        var trackCurrentX: CGFloat = 0.0
        
        if points.count == 1 {
            let hoursFromLast = hours(between: points.last!.onDate, and: Date())
            for hour in 0..<hoursFromLast {
                let thisHourDecayValue = Equations.halfLife(forInitial: points[0].proficiency, hours: hour, forFibonacci: 1)
                let thisHourDecayY = self.frame.height - (self.frame.height * CGFloat(thisHourDecayValue))
                let thisHourX = trackCurrentX + ( CGFloat(hour) * xStep )
                let thisHourPoint = CGPoint(x: thisHourX, y: thisHourDecayY)
                path.addLine(to: thisHourPoint)
            }
            let lastDecay = Equations.halfLife(forInitial: points.last!.proficiency, hours: hoursFromLast, forFibonacci: 1)
            let yLast = self.frame.height - (self.frame.height * CGFloat(lastDecay))
            path.addLine(to: CGPoint(x: self.frame.width, y: yLast))
        }
        
        for index in 1..<points.count {
            let hoursPassed = hours(between: points[index-1].onDate, and: points[index].onDate)
            
            let xLocal = trackCurrentX + CGFloat(hoursPassed) * xStep
            trackCurrentX = xLocal
            let yLocal = self.frame.height - (self.frame.height * CGFloat(points[index].proficiency))
            let pointLocal = CGPoint(x: xLocal, y: yLocal)
            path.addLine(to: pointLocal)
            
            // last iteration wrap up
            if index == points.count - 1 {
                //let daysFromLast = Calendar.current.compare(points.last!.onDate, to: Date(), toGranularity: .day).rawValue
                let hoursFromLast = hours(between: points.last!.onDate, and: Date())
                for hour in 0..<hoursFromLast {
                    let thisHourDecayValue = Equations.halfLife(forInitial: points[index].proficiency, hours: hour, forFibonacci: index)
                    let thisHourDecayY = self.frame.height - (self.frame.height * CGFloat(thisHourDecayValue))
                    let thisHourX = trackCurrentX + ( CGFloat(hour) * xStep )
                    let thisHourPoint = CGPoint(x: thisHourX, y: thisHourDecayY)
                    path.addLine(to: thisHourPoint)
                }
                let lastDecay = Equations.halfLife(forInitial: points.last!.proficiency, hours: hoursFromLast, forFibonacci: index)
                let yLast = self.frame.height - (self.frame.height * CGFloat(lastDecay))
                path.addLine(to: CGPoint(x: self.frame.width, y: yLast))
            }
        }
        
        path.lineWidth = 3.5
        return path
    }
    
    public func path(forProficiency points: [(proficiency: Double, onDate: Date, validReviewTime: Bool)]) -> UIBezierPath? {
        
        // roughly follow pattern of retention data.
        // only decay on last entry
        guard points.count > 0 else {return nil}
        
        func days(between: Date, and: Date) -> Int {
            return Calendar.current.dateComponents([.day], from: between, to: and).day!
        }
        
        var daySpan = 0
        if let date0 = points.first?.onDate {
            daySpan = days(between: date0, and: Date())
        }
        
        if daySpan <= graphResolution {return hoursPath(forProficiency: points)} // then figure out hours?? ??
        
        let xStep: CGFloat = self.frame.width / CGFloat(daySpan)
        let path = UIBezierPath()
        
        let startY = self.frame.height - (self.frame.height * CGFloat(points[0].proficiency))
        path.move(to: CGPoint(x: 0, y: startY))
        
        var trackCurrentX: CGFloat = 0.0
        
        if points.count == 1 {
            let daysFromLast = days(between: points.last!.onDate, and: Date())
            for day in 0..<daysFromLast {
                let thisDayDecayValue = Equations.halfLife(forInitial: points[0].proficiency, overLengthOf: day, forFibonacci: 1)
                let thisDayDecayY = self.frame.height - (self.frame.height * CGFloat(thisDayDecayValue))
                let thisDayX = trackCurrentX + ( CGFloat(day) * xStep )
                let thisDayPoint = CGPoint(x: thisDayX, y: thisDayDecayY)
                path.addLine(to: thisDayPoint)
            }
            let lastDecay = Equations.halfLife(forInitial: points.last!.proficiency, overLengthOf: daysFromLast, forFibonacci: 1)
            let yLast = self.frame.height - (self.frame.height * CGFloat(lastDecay))
            path.addLine(to: CGPoint(x: self.frame.width, y: yLast))
        }
        
        for index in 1..<points.count {
            let daysPassed = days(between: points[index-1].onDate, and: points[index].onDate)
            
            let xLocal = trackCurrentX + CGFloat(daysPassed) * xStep
            trackCurrentX = xLocal
            let yLocal = self.frame.height - (self.frame.height * CGFloat(points[index].proficiency))
            let pointLocal = CGPoint(x: xLocal, y: yLocal)
            path.addLine(to: pointLocal)
            
            // last iteration wrap up
            if index == points.count - 1 {
                //let daysFromLast = Calendar.current.compare(points.last!.onDate, to: Date(), toGranularity: .day).rawValue
                let daysFromLast = days(between: points.last!.onDate, and: Date())
                for day in 0..<daysFromLast {
                    let thisDayDecayValue = Equations.halfLife(forInitial: points[index].proficiency, overLengthOf: day, forFibonacci: index)
                    let thisDayDecayY = self.frame.height - (self.frame.height * CGFloat(thisDayDecayValue))
                    let thisDayX = trackCurrentX + ( CGFloat(day) * xStep )
                    let thisDayPoint = CGPoint(x: thisDayX, y: thisDayDecayY)
                    path.addLine(to: thisDayPoint)
                }
                let lastDecay = Equations.halfLife(forInitial: points.last!.proficiency, overLengthOf: daysFromLast, forFibonacci: index)
                let yLast = self.frame.height - (self.frame.height * CGFloat(lastDecay))
                path.addLine(to: CGPoint(x: self.frame.width, y: yLast))
            }
        }
        
        path.lineWidth = 3.5
        return path
    }
    
    public func minutesPath(forRetention points: [(retention: Double, onDate: Date, validReviewTime: Bool)]) -> UIBezierPath? {
        
        guard points.count > 0 else {return nil}
        
        //x calc from Date
        //y calc from Double
        // handle offset in the NSLayouts..
        // y0 bottom of graph
        // y100 top of graph
        // x0 first date
        // xn last date
        // determine n as daten - date0.
        
        func minutes(between: Date, and: Date) -> Int {
            return Calendar.current.dateComponents([.minute], from: between, to: and).minute!
        }
        
        var daySpan = 0
        if let date0 = points.first?.onDate {
            daySpan = minutes(between: date0, and: Date())
        }
        
        if daySpan <= 0 {return nil} // then figure out hours?? ??
        
        //let yStep: CGFloat = self.frame.height / 100.0
        let xStep: CGFloat = self.frame.width / CGFloat(daySpan)
        let path = UIBezierPath()
        
        let startY = self.frame.height - (self.frame.height * CGFloat(points[0].retention))
        path.move(to: CGPoint(x: 0, y: startY))
        
        var trackCurrentX: CGFloat = 0.0
        
        if points.count == 1 {
            let daysFromLast = minutes(between: points.last!.onDate, and: Date())
            for day in 0..<daysFromLast {
                let thisDayDecayValue = Equations.halfLife(forInitial: points[0].retention, minutes: day, forFibonacci: 1)
                let thisDayDecayY = self.frame.height - (self.frame.height * CGFloat(thisDayDecayValue))
                let thisDayX = trackCurrentX + ( CGFloat(day) * xStep )
                let thisDayPoint = CGPoint(x: thisDayX, y: thisDayDecayY)
                path.addLine(to: thisDayPoint)
            }
            let lastDecay = Equations.halfLife(forInitial: points.last!.retention, minutes: daysFromLast, forFibonacci: 1)
            let yLast = self.frame.height - (self.frame.height * CGFloat(lastDecay))
            path.addLine(to: CGPoint(x: self.frame.width, y: yLast))
        }
        
        for index in 1..<points.count {
            //let daysPassed = Calendar.current.compare(points[index-1].onDate, to: points[index].onDate, toGranularity: .day).rawValue
            let daysPassed = minutes(between: points[index-1].onDate, and: points[index].onDate)
            
            let daysBetweenPoints = minutes(between: points[index-1].onDate, and: points[index].onDate)
            for day in 0..<daysBetweenPoints {
                let thisDayDecayValue = Equations.halfLife(forInitial: points[index-1].retention, minutes: day, forFibonacci: index)
                let thisDayDecayY = self.frame.height - (self.frame.height * CGFloat(thisDayDecayValue))
                let thisDayX = trackCurrentX + ( CGFloat(day) * xStep )
                let thisDayPoint = CGPoint(x: thisDayX, y: thisDayDecayY)
                path.addLine(to: thisDayPoint)
            }
            
            let xLocal = trackCurrentX + CGFloat(daysPassed) * xStep
            trackCurrentX = xLocal
            let decayValue = Equations.halfLife(forInitial: points[index-1].retention, minutes: daysPassed, forFibonacci: index)
            let decayY = self.frame.height - (self.frame.height * CGFloat(decayValue))
            
            path.addLine(to: CGPoint(x: xLocal, y: CGFloat(decayY)))
            
            let yLocal = self.frame.height - (self.frame.height * CGFloat(points[index].retention))
            path.addLine(to: CGPoint(x: xLocal, y: yLocal))
            
            // last iteration wrap up
            if index == points.count - 1 {
                //let daysFromLast = Calendar.current.compare(points.last!.onDate, to: Date(), toGranularity: .day).rawValue
                let daysFromLast = minutes(between: points.last!.onDate, and: Date())
                for day in 0..<daysFromLast {
                    let thisDayDecayValue = Equations.halfLife(forInitial: points[index].retention, minutes: day, forFibonacci: index)
                    let thisDayDecayY = self.frame.height - (self.frame.height * CGFloat(thisDayDecayValue))
                    let thisDayX = trackCurrentX + ( CGFloat(day) * xStep )
                    let thisDayPoint = CGPoint(x: thisDayX, y: thisDayDecayY)
                    path.addLine(to: thisDayPoint)
                }
                let lastDecay = Equations.halfLife(forInitial: points.last!.retention, minutes: daysFromLast, forFibonacci: index)
                let yLast = self.frame.height - (self.frame.height * CGFloat(lastDecay))
                path.addLine(to: CGPoint(x: self.frame.width, y: yLast))
            }
        }
        
        path.lineWidth = 3.5
        
        return path
    }
    
    public func hoursPath(forRetention points: [(retention: Double, onDate: Date, validReviewTime: Bool)]) -> UIBezierPath? {
        
        guard points.count > 0 else {return nil}
        
        //x calc from Date
        //y calc from Double
        // handle offset in the NSLayouts..
        // y0 bottom of graph
        // y100 top of graph
        // x0 first date
        // xn last date
        // determine n as daten - date0.
        
        func hours(between: Date, and: Date) -> Int {
            return Calendar.current.dateComponents([.hour], from: between, to: and).hour!
        }
        
        var daySpan = 0
        if let date0 = points.first?.onDate {
            daySpan = hours(between: date0, and: Date())
        }
        
        if daySpan <= graphResolution {return minutesPath(forRetention: points)} // then figure out hours?? ??
        
        //let yStep: CGFloat = self.frame.height / 100.0
        let xStep: CGFloat = self.frame.width / CGFloat(daySpan)
        let path = UIBezierPath()
        
        let startY = self.frame.height - (self.frame.height * CGFloat(points[0].retention))
        path.move(to: CGPoint(x: 0, y: startY))
        
        var trackCurrentX: CGFloat = 0.0
        
        if points.count == 1 {
            let daysFromLast = hours(between: points.last!.onDate, and: Date())
            for day in 0..<daysFromLast {
                let thisDayDecayValue = Equations.halfLife(forInitial: points[0].retention, hours: day, forFibonacci: 1)
                let thisDayDecayY = self.frame.height - (self.frame.height * CGFloat(thisDayDecayValue))
                let thisDayX = trackCurrentX + ( CGFloat(day) * xStep )
                let thisDayPoint = CGPoint(x: thisDayX, y: thisDayDecayY)
                path.addLine(to: thisDayPoint)
            }
            let lastDecay = Equations.halfLife(forInitial: points.last!.retention, hours: daysFromLast, forFibonacci: 1)
            let yLast = self.frame.height - (self.frame.height * CGFloat(lastDecay))
            path.addLine(to: CGPoint(x: self.frame.width, y: yLast))
        }
        
        for index in 1..<points.count {
            //let daysPassed = Calendar.current.compare(points[index-1].onDate, to: points[index].onDate, toGranularity: .day).rawValue
            let daysPassed = hours(between: points[index-1].onDate, and: points[index].onDate)
            
            let daysBetweenPoints = hours(between: points[index-1].onDate, and: points[index].onDate)
            for day in 0..<daysBetweenPoints {
                let thisDayDecayValue = Equations.halfLife(forInitial: points[index-1].retention, hours: day, forFibonacci: index)
                let thisDayDecayY = self.frame.height - (self.frame.height * CGFloat(thisDayDecayValue))
                let thisDayX = trackCurrentX + ( CGFloat(day) * xStep )
                let thisDayPoint = CGPoint(x: thisDayX, y: thisDayDecayY)
                path.addLine(to: thisDayPoint)
            }
            
            let xLocal = trackCurrentX + CGFloat(daysPassed) * xStep
            trackCurrentX = xLocal
            let decayValue = Equations.halfLife(forInitial: points[index-1].retention, hours: daysPassed, forFibonacci: index)
            let decayY = self.frame.height - (self.frame.height * CGFloat(decayValue))
            
            path.addLine(to: CGPoint(x: xLocal, y: CGFloat(decayY)))
            
            let yLocal = self.frame.height - (self.frame.height * CGFloat(points[index].retention))
            path.addLine(to: CGPoint(x: xLocal, y: yLocal))
            
            // last iteration wrap up
            if index == points.count - 1 {
                //let daysFromLast = Calendar.current.compare(points.last!.onDate, to: Date(), toGranularity: .day).rawValue
                let daysFromLast = hours(between: points.last!.onDate, and: Date())
                for day in 0..<daysFromLast {
                    let thisDayDecayValue = Equations.halfLife(forInitial: points[index].retention, hours: day, forFibonacci: index)
                    let thisDayDecayY = self.frame.height - (self.frame.height * CGFloat(thisDayDecayValue))
                    let thisDayX = trackCurrentX + ( CGFloat(day) * xStep )
                    let thisDayPoint = CGPoint(x: thisDayX, y: thisDayDecayY)
                    path.addLine(to: thisDayPoint)
                }
                let lastDecay = Equations.halfLife(forInitial: points.last!.retention, hours: daysFromLast, forFibonacci: index)
                let yLast = self.frame.height - (self.frame.height * CGFloat(lastDecay))
                path.addLine(to: CGPoint(x: self.frame.width, y: yLast))
            }
        }
        
        path.lineWidth = 3.5
        
        return path
    }
    
    public func path(forRetention points: [(retention: Double, onDate: Date, validReviewTime: Bool)]) -> UIBezierPath? {
        
        guard points.count > 0 else {return nil}
        let filteredPoints = points.filter({$0.validReviewTime})
        guard filteredPoints.count > 0 else {return nil}
        //x calc from Date
        //y calc from Double
        // handle offset in the NSLayouts..
        // y0 bottom of graph
        // y100 top of graph
        // x0 first date
        // xn last date
        // determine n as daten - date0.
        
        func days(between: Date, and: Date) -> Int {
            return Calendar.current.dateComponents([.day], from: between, to: and).day!
        }
        
        var daySpan = 0
        if let date0 = filteredPoints.first?.onDate {
            daySpan = days(between: date0, and: Date())
        }
        
        if daySpan <= graphResolution {return hoursPath(forRetention: filteredPoints)} // then figure out hours?? ??
        
        //let yStep: CGFloat = self.frame.height / 100.0
        let xStep: CGFloat = self.frame.width / CGFloat(daySpan)
        let path = UIBezierPath()
        
        let startY = self.frame.height - (self.frame.height * CGFloat(filteredPoints[0].retention))
        path.move(to: CGPoint(x: 0, y: startY))
        
        var trackCurrentX: CGFloat = 0.0
        
        if filteredPoints.count == 1 {
            let daysFromLast = days(between: filteredPoints.last!.onDate, and: Date())
            for day in 0..<daysFromLast {
                let thisDayDecayValue = Equations.halfLife(forInitial: filteredPoints[0].retention, overLengthOf: day, forFibonacci: 1)
                let thisDayDecayY = self.frame.height - (self.frame.height * CGFloat(thisDayDecayValue))
                let thisDayX = trackCurrentX + ( CGFloat(day) * xStep )
                let thisDayPoint = CGPoint(x: thisDayX, y: thisDayDecayY)
                path.addLine(to: thisDayPoint)
            }
            let lastDecay = Equations.halfLife(forInitial: filteredPoints.last!.retention, overLengthOf: daysFromLast, forFibonacci: 1)
            let yLast = self.frame.height - (self.frame.height * CGFloat(lastDecay))
            path.addLine(to: CGPoint(x: self.frame.width, y: yLast))
        }
        
        for index in 1..<filteredPoints.count {
            //let daysPassed = Calendar.current.compare(points[index-1].onDate, to: points[index].onDate, toGranularity: .day).rawValue
            let daysPassed = days(between: filteredPoints[index-1].onDate, and: filteredPoints[index].onDate)
            
            let daysBetweenPoints = days(between: filteredPoints[index-1].onDate, and: filteredPoints[index].onDate)
            for day in 0..<daysBetweenPoints {
                let thisDayDecayValue = Equations.halfLife(forInitial: filteredPoints[index-1].retention, overLengthOf: day, forFibonacci: index)
                let thisDayDecayY = self.frame.height - (self.frame.height * CGFloat(thisDayDecayValue))
                let thisDayX = trackCurrentX + ( CGFloat(day) * xStep )
                let thisDayPoint = CGPoint(x: thisDayX, y: thisDayDecayY)
                path.addLine(to: thisDayPoint)
            }
            
            let xLocal = trackCurrentX + CGFloat(daysPassed) * xStep
            trackCurrentX = xLocal
            let decayValue = Equations.halfLife(forInitial: filteredPoints[index-1].retention, overLengthOf: daysPassed, forFibonacci: index)
            let decayY = self.frame.height - (self.frame.height * CGFloat(decayValue))
            
            path.addLine(to: CGPoint(x: xLocal, y: CGFloat(decayY)))
            
            let yLocal = self.frame.height - (self.frame.height * CGFloat(filteredPoints[index].retention))
            path.addLine(to: CGPoint(x: xLocal, y: yLocal))
            
            // last iteration wrap up
            if index == filteredPoints.count - 1 {
                //let daysFromLast = Calendar.current.compare(points.last!.onDate, to: Date(), toGranularity: .day).rawValue
                let daysFromLast = days(between: filteredPoints.last!.onDate, and: Date())
                for day in 0..<daysFromLast {
                    let thisDayDecayValue = Equations.halfLife(forInitial: filteredPoints[index].retention, overLengthOf: day, forFibonacci: index)
                    let thisDayDecayY = self.frame.height - (self.frame.height * CGFloat(thisDayDecayValue))
                    let thisDayX = trackCurrentX + ( CGFloat(day) * xStep )
                    let thisDayPoint = CGPoint(x: thisDayX, y: thisDayDecayY)
                    path.addLine(to: thisDayPoint)
                }
                let lastDecay = Equations.halfLife(forInitial: filteredPoints.last!.retention, overLengthOf: daysFromLast, forFibonacci: index)
                let yLast = self.frame.height - (self.frame.height * CGFloat(lastDecay))
                path.addLine(to: CGPoint(x: self.frame.width, y: yLast))
            }
        }
        
        path.lineWidth = 3.5
        
        return path
    }
}
