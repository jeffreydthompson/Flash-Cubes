//
//  MainNavigationController.swift
//  Flash Cubes
//
//  Created by Jeffrey Thompson on 4/23/19.
//  Copyright © 2019 Jeffrey Thompson. All rights reserved.
//

import UIKit

class MainNavigationController: UINavigationController {
    
    var programManager: ProgramManager?
    
    var backgroundImgView: UIImageView = {
        var img = UIImage(named: "imgBackground")
        let imgView = UIImageView(image: img)
        imgView.contentMode = .scaleAspectFill
        imgView.translatesAutoresizingMaskIntoConstraints = false
        return imgView
    }()
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        print("\(#function) \(currentDeviceIsiPad)")
        print("\(#function) \(UIDevice.current.model)")
        print(Directory.docs.path)
        
//        testing()
//
//        firebaseBuilding()

        setupNavBar()
        setupToolbar()
        transition()

    }
    
    func firebaseBuilding(){
        
//        FirebaseDeckBuilder.buildDeck(fromLanguage: FirebaseDeckBuilder.SupportedLanguages.English, toLanguage: FirebaseDeckBuilder.SupportedLanguages.Vietnamese, from: 101, to: 200)
//
        //FirebaseDeckBuilder.buildMusicDeck()
        
        //let fromLanguage = FirebaseDeckBuilder.SupportedLanguages.French
        
//        let fromLanguages = [
//            FirebaseDeckBuilder.SupportedLanguages.Japanese,
//            FirebaseDeckBuilder.SupportedLanguages.Korean
//        ]
//
//        let toLanguages = [
//            FirebaseDeckBuilder.SupportedLanguages.English,
//            FirebaseDeckBuilder.SupportedLanguages.Japanese,
//            FirebaseDeckBuilder.SupportedLanguages.Korean,
//            FirebaseDeckBuilder.SupportedLanguages.Vietnamese
//        ]
//
//        let toLanguage = FirebaseDeckBuilder.SupportedLanguages.French
//
//        for fromLanguage in fromLanguages {
//            FirebaseDeckBuilder.buildDeck(fromLanguage: fromLanguage, toLanguage: toLanguage, from: 1, to: 100)
//            FirebaseDeckBuilder.buildDeck(fromLanguage: fromLanguage, toLanguage: toLanguage, from: 101, to: 200)
//            FirebaseDeckBuilder.buildDeck(fromLanguage: fromLanguage, toLanguage: toLanguage, from: 201, to: 300)
//            FirebaseDeckBuilder.buildDeck(fromLanguage: fromLanguage, toLanguage: toLanguage, from: 301, to: 400)
//            FirebaseDeckBuilder.buildDeck(fromLanguage: fromLanguage, toLanguage: toLanguage, from: 401, to: 500)
//        }
//
//        for toLanguage in toLanguages {
//            FirebaseDeckBuilder.buildDeck(fromLanguage: fromLanguage, toLanguage: toLanguage, from: 1, to: 100)
//            FirebaseDeckBuilder.buildDeck(fromLanguage: fromLanguage, toLanguage: toLanguage, from: 101, to: 200)
//            FirebaseDeckBuilder.buildDeck(fromLanguage: fromLanguage, toLanguage: toLanguage, from: 201, to: 300)
//            FirebaseDeckBuilder.buildDeck(fromLanguage: fromLanguage, toLanguage: toLanguage, from: 301, to: 400)
//            FirebaseDeckBuilder.buildDeck(fromLanguage: fromLanguage, toLanguage: toLanguage, from: 401, to: 500)
//        }
        
    }
    
    func setupNavBar(){
        let attributes: [NSAttributedString.Key : Any] = [
            NSAttributedString.Key.font : UIFont.body,
            NSAttributedString.Key.foregroundColor : UIColor.white
        ]
        
        UINavigationBar.appearance().titleTextAttributes = attributes
        
        self.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationBar.shadowImage = UIImage()
        self.navigationBar.isTranslucent = true
        self.navigationBar.tintColor = .white
    }
    
    func setupToolbar(){
        self.toolbar.setBackgroundImage(UIImage(), forToolbarPosition: .any, barMetrics: .default)
        self.toolbar.setShadowImage(UIImage(), forToolbarPosition: .any)
        self.toolbar.isTranslucent = true
        self.toolbar.tintColor = .white
    }
    
    func transition(){
        self.programManager = ProgramManager()
        self.programManager?.initDeckCollection {
            let deckCollectionVC = DeckCollectionVC()
            deckCollectionVC.programManager = self.programManager!
            self.pushViewController(deckCollectionVC, animated: true)
        }
    }
    
    func testing() {
        
        let firebaseTesting = FirebaseTestingVC()
        self.pushViewController(firebaseTesting, animated: true)
        
        //        let audioVC = TestAudioVC()
        //        self.pushViewController(audioVC, animated: true)
        
        /*let manager = DLCPrepManager()
        if let deck = manager.firebaseDeck(fromJSON: "1-100Ja.json") {
            let name = deck.name
            let path = Directory.testing.url.appendingPathComponent(name).path
            
            do {
                let data = try PropertyListEncoder().encode(deck)
                FileManager.default.createFile(atPath: path, contents: data, attributes: nil)
            } catch let error {
                print("\(#function) \(error)")
            }
        } else {
            print("\(#function) deck load failure")
        }*/
        
        //        let testFirebaseVC = FirebaseTestingVC()
        //        self.pushViewController(testFirebaseVC, animated: true)
        
        //print("today minus past date \(today - pastDate)")
        //let testEditVC = CubeEditVC()
        //self.pushViewController(testEditVC, animated: true)
        //PersistenceManager.shared.cleanSweep()
        
        //let deck = DeckTestManager.shared.getRandomDeck(ofSize: nil)
        //DeckTestManager.shared.save(deck: deck, withName: deck.deckSubFolder)
        
        //let deck = DeckTestManager.shared.initJapaneseTwentyDeck()
        //DeckTestManager.shared.save(deck: deck, withName: deck.deckSubFolder)
        
        /*do {
         try DeckCollectionTestManager.shared.loadDeckCollection()
         } catch let error {
         print("\(error)")
         DeckCollectionTestManager.shared.deckCollectionInit()
         }
         
         DeckCollectionTestManager.shared.testSort()*/
        
        /*let manager = DLCPrepManager()
         manager.getPrepDeck(fromJSON: "1-100Ja.json") { (prepDeck) in
         
         guard let prepDeck = prepDeck else {return}
         
         manager.saveAudioContainers(from: prepDeck)
         
         //            let atPath = Directory.testing.url.appendingPathComponent("testing").path
         //
         //            do {
         //                let data = try PropertyListEncoder().encode(prepDeck)
         //                FileManager.default.createFile(atPath: atPath, contents: data, attributes: nil)
         //            } catch let error {
         //                print("\(#function) \(error)")
         //            }
         //            do {
         //                try manager.prepDeckToFile(prepDeck: prepDeck)
         //            } catch let error {
         //                print("\(#function) \(error.localizedDescription)")
         //            }
         }*/
        
        /*let fileName = "Japanese Audio"
         let filePath = Directory.testing.url.appendingPathComponent(fileName).path
         if let fileData = FileManager.default.contents(atPath: filePath){
         do {
         let container = try PropertyListDecoder().decode(AudioDataContainer.self, from: fileData)
         print(container as Any)
         } catch let error {
         print("\(#function) \(error.localizedDescription)")
         }
         } else {
         print("\(#function) couldn't load AudioContainerData")
         }*/
        
        //self.pushViewController(TESTINGCollVC(), animated: true)
    }
}
