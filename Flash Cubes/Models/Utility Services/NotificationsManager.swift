//
//  NotificationsManager.swift
//  Flash Cubes
//
//  Created by Jeffrey Thompson on 5/6/19.
//  Copyright © 2019 Jeffrey Thompson. All rights reserved.
//

import Foundation
import UserNotifications

struct NotificationsManager {
    
    static private let center: UNUserNotificationCenter = {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert], completionHandler: { (_, error) in
            if let error = error {
                print(error.localizedDescription)
            }
        })
        return center
    }()
    
    var oneDayInterval: Double {
        get {
            return 24 * 60 * 60
        }
    }
    
    var eighteenHourInterval: Double {
        get {
            return 18 * 60 * 60
        }
    }
    
    public static func addNewRequest(forDeck: String, onDate: Date){
        
        if onDate < Date() {
            fatalError("\(#function) crap date given")
        }
        
        var duplicateDateTrigger = false
        let identifier = getDateString(date: onDate)
        let title = AppText.reviewAlert
        let interval = onDate.timeIntervalSince(Date())
        //let interval = onDate.timeIntervalSince(Date())
        
        //combine all requests that fall on the same day
        center.getPendingNotificationRequests(completionHandler: { (list) in
            for request in list {
                //debugPrint(request.debugDescription)
                if request.identifier == identifier {
                    duplicateDateTrigger = true
                    
                    var body = ""
                    
                    var userInfo = [AnyHashable : [String]]()
                    if let decks = request.content.userInfo["decks"] as? [String] {
                        if !decks.contains(forDeck) {
                            var decksArray = decks
                            decksArray.append(forDeck)
                            userInfo["decks"] = decksArray
                            
                            decksArray.forEach({ string in
                                body += string
                                body += ", "
                            })
                            
                            body.removeLast()
                            body.removeLast()
                        }
                    } else {
                        userInfo["decks"] = [forDeck]
                        body = forDeck
                    }
                    
                    self.center.removePendingNotificationRequests(withIdentifiers: [identifier])
                    self.setupNotificationRequest(identifier: identifier, title: title, body: body, interval: interval, userInfo: userInfo)
                }
            }
        })
        
        
        let userInfo: [AnyHashable : [String]] = ["decks" : [forDeck]]
        if duplicateDateTrigger == false {
            setupNotificationRequest(identifier: identifier, title: title, body: forDeck, interval: interval, userInfo: userInfo)
        }
    }
    
    private static func setupNotificationRequest(identifier: String, title: String, body: String, interval: Double, userInfo: [AnyHashable : Any]){
        /*let formatter = DateFormatter()
         formatter.dateStyle = .medium
         let identifier = formatter.string(from: Date().addingTimeInterval(interval))*/
        
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.userInfo = userInfo
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: interval, repeats: false)
        
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        center.add(request, withCompletionHandler: nil)
    }
    
    public static func printAllRequests(){
        print("Notifications:")
        _ = center.getPendingNotificationRequests(completionHandler: { (list) in
            for request in list {
                debugPrint("Notifications request: \(request.identifier),\(request.content.title), \(request.content.body)")
            }
        })
    }
    
    private static func areDatesSameDay(dateOne: Date, dateTwo: Date) -> Bool {
        return getDateString(date: dateOne) == getDateString(date: dateTwo)
    }
    
    private static func getDateString(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        
        return formatter.string(from: date)
    }
    
    public static func clearAllNotificationRequests(){
        center.removeAllPendingNotificationRequests()
    }
    
}

