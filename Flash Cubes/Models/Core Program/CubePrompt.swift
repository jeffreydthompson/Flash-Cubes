//
//  ModelDataStructures.swift
//  Flash Cubes
//
//  Created by Jeffrey Thompson on 4/22/19.
//  Copyright © 2019 Jeffrey Thompson. All rights reserved.
//

import Foundation
import UIKit

enum CubePrompt {
    case text(String?)
    case audio(Data?)
    case image(UIImage?)
    
    var value: Any? {
        switch self {
        case .text(let str):
            return str
        case .audio(let url):
            return url
        case .image(let img):
            return img
        }
    }
    
    enum NestedType {
        case text
        case audio
        case image
    }
    
    var typeId: Int {
        switch self {
        case .text( _):
            return 0
        case .audio( _):
            return 1
        case .image( _):
            return 2
        }
    }
    
    var type: NestedType {
        switch self {
        case .text( _):
            return .text
        case .audio( _):
            return .audio
        case .image( _):
            return .image
        }
    }
}

extension CubePrompt: Codable {
    
    enum Key: CodingKey {
        case rawValue
        case associatedValue
    }
    
    enum CodingError: Error {
        case unknownValue
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: Key.self)
        let rawValue = try container.decode(Int.self, forKey: .rawValue)
        switch rawValue {
        case 0:
            let text = try container.decodeIfPresent(String.self, forKey: .associatedValue)
            self = .text(text)
        case 1:
            let audioURL = try container.decodeIfPresent(Data.self, forKey: .associatedValue)
            self = .audio(audioURL)
        case 2:
            let imgData = try container.decodeIfPresent(Data.self, forKey: .associatedValue)
            if let imgDataUnwrapped = imgData {
                self = .image(UIImage(data: imgDataUnwrapped))
            } else {
                self = .image(nil)
            }
        default:
            throw CodingError.unknownValue
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: Key.self)
        switch self {
        case .text(let str):
            try container.encode(0, forKey: .rawValue)
            try container.encode(str, forKey: .associatedValue)
        case .audio(let url):
            try container.encode(1, forKey: .rawValue)
            try container.encode(url, forKey: .associatedValue)
        case .image(let img):
            if let img = img {
                if img.imageOrientation == .up {
                    let imgData = img.pngData()
                    try container.encode(2, forKey: .rawValue)
                    try container.encode(imgData, forKey: .associatedValue)
                    return
                }
                
                // to avoid the weird upsidedown image loading bug:
                UIGraphicsBeginImageContext(img.size)
                img.draw(in: CGRect(origin: CGPoint.zero, size: img.size))
                let imgAdjusted = UIGraphicsGetImageFromCurrentImageContext()
                UIGraphicsEndImageContext()
                
                let imgData = imgAdjusted?.pngData()
                try container.encode(2, forKey: .rawValue)
                try container.encode(imgData, forKey: .associatedValue)
            } else {
                let imgData = img?.pngData()
                try container.encode(2, forKey: .rawValue)
                try container.encode(imgData, forKey: .associatedValue)
            }
        }
    }
}

