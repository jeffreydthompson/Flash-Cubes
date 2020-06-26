//
//  DLCPrepDeck.swift
//  Flash Cubes
//
//  Created by Jeffrey Thompson on 5/26/19.
//  Copyright © 2019 Jeffrey Thompson. All rights reserved.
//

import Foundation

class DLCPrepDeck: Codable {
    
    var name: String?
    var protoPrompts: [String : CubePrompt]?
    var flashCubes: [String : FlashCube]?
    
    enum Key: CodingKey {
        case name
        case protoPrompts
        case flashCubes
    }
}
