//
//  TestManager.swift
//  Flash Cubes
//
//  Created by Jeffrey Thompson on 4/22/19.
//  Copyright © 2019 Jeffrey Thompson. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation

class CubeTestManager {
    
    let testPath = Directory.docs.url.appendingPathComponent("testFile").path
    
    static public let shared = CubeTestManager()
    
    private init() {}
    
    public func retrieveSavedTestCube() {
        
        guard let data = FileManager.default.contents(atPath: testPath) else {
            print("retrieving data error")
            return
        }
        
        do {
            let loadedCube = try PropertyListDecoder().decode(FlashCube.self, from: data)
            print("test loadedCube: creation Date: \(String(describing: loadedCube.creationDate))")
            if let prompts = loadedCube.prompts {
                for prompt in prompts {
                    print(prompt.key)
                    switch prompt.value {
                    case .text(let str):
                        print("prompt string: \(str ?? "nil value")")
                    case .audio(let data):
                        print("prompt audioData: \(String(describing: data))")
                    case .image(let img):
                        print("prompt image: \(String(describing: img?.size))")
                    }
                }
            }
        } catch let error {
            print(error)
        }
        
    }
    
    public func loadCube(fromPath: String) -> FlashCube? {
        
        guard let data = FileManager.default.contents(atPath: testPath) else {
            print("retrieving data error")
            return nil
        }
        
        do {
            let loadedCube = try PropertyListDecoder().decode(FlashCube.self, from: data)
            return loadedCube
        } catch let error {
            print(error)
            return nil
        }
    }
    
    public func save(cube: FlashCube, atPath: String) {
        do {
            let data = try PropertyListEncoder().encode(cube)
            FileManager.default.createFile(atPath: atPath, contents: data, attributes: nil)
        } catch let error {
            print(error)
        }
    }
    
    public func makeAndSaveTestCube() {
        print(Directory.docs.url)
        let newCube = testCube()
        
        do {
            let data = try PropertyListEncoder().encode(newCube)
            //let nsArchiveData = try NSKeyedArchiver.archivedData(withRootObject: data, requiringSecureCoding: false)
            FileManager.default.createFile(atPath: testPath, contents: data, attributes: nil)
        } catch let error {
            print(error)
        }
    }
    
    public func testCube() -> FlashCube {
        
        let text = "hello"
        var audioURL: URL? = nil
        let audioPath = Bundle.main.path(forResource: "test1.m4a", ofType: nil)
        if let path = audioPath {
            audioURL = URL(fileURLWithPath: path)
        }
        
        let image = UIImage(named: "test1")
        
        let textPrompt = CubePrompt.text(text)
        
        var audioPrompt: CubePrompt?
        if let url = audioURL {
            let audioData = FileManager.default.contents(atPath: url.path)
            audioPrompt = CubePrompt.audio(audioData)
        } else {
            audioPrompt = CubePrompt.audio(nil)
        }
        
        let imagePrompt = CubePrompt.image(image)
        
        let dict = [
            "text" : textPrompt,
            "audio" : audioPrompt!,
            "image" : imagePrompt
        ]
        
        let newCube = FlashCube(prompts: dict)
        return newCube
    }
}
