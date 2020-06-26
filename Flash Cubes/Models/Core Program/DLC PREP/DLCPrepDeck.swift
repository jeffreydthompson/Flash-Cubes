//
//  DLCPrepDeck.swift
//  Flash Cubes
//
//  Created by Jeffrey Thompson on 5/26/19.
//  Copyright © 2019 Jeffrey Thompson. All rights reserved.
//

import Foundation

struct DLCPrepDeck: Codable {
    
    var price: Double?
    var IAPid: String?
    var name: String?
    var protoPrompts: [String : CubePrompt]?
    var flashCubes: [DLCPrepFlashCube]?
    
    enum Key: CodingKey {
        case name
        case protoPrompts
        case flashCubes
        case price
        case IAPid
    }
    
    init(name: String, protoPrompts: [String : CubePrompt]) {
        self.name = name
        self.protoPrompts = protoPrompts
        self.flashCubes = [DLCPrepFlashCube]()
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: Key.self)
        try container.encode(name, forKey: .name)
        try container.encode(protoPrompts, forKey: .protoPrompts)
        try container.encode(flashCubes, forKey: .flashCubes)
        try container.encode(price, forKey: .price)
        try container.encode(IAPid, forKey: .IAPid)
    }
    
    init(from decoder: Decoder) throws {
        let container     = try decoder.container(keyedBy: Key.self)
        self.name         = try container.decodeIfPresent(String.self, forKey: .name)
        self.protoPrompts = try container.decodeIfPresent([String : CubePrompt].self, forKey: .protoPrompts)
        self.flashCubes   = try container.decodeIfPresent([DLCPrepFlashCube].self, forKey: .flashCubes)
        self.IAPid        = try container.decodeIfPresent(String.self, forKey: .IAPid)
        self.price        = try container.decodeIfPresent(Double.self, forKey: .price)
    }
}
