//
//  DLCPrepFlashCube.swift
//  Flash Cubes
//
//  Created by Jeffrey Thompson on 5/27/19.
//  Copyright © 2019 Jeffrey Thompson. All rights reserved.
//

//
//  File.swift
//  Flash Cubes
//
//  Created by Jeffrey Thompson on 4/22/19.
//  Copyright © 2019 Jeffrey Thompson. All rights reserved.
//

import Foundation

struct DLCPrepFlashCube: Codable {
    
    var name: String?
    var prompts: [String : CubePrompt]?
    var defaultIndex: Int?
    
    enum Key: CodingKey {
        case name
        case prompts
        case index
    }
    
    public init() {
        self.prompts = [String : CubePrompt]()
    }
    
    public init(prompts: [String : CubePrompt]){
        self.prompts = prompts
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: Key.self)
        try container.encode(name, forKey: .name)
        try container.encode(prompts, forKey: .prompts)
        try container.encode(defaultIndex, forKey: .index)
    }
    
    init(from decoder: Decoder) throws {
        let container             = try decoder.container(keyedBy: Key.self)
        self.name                 = try container.decodeIfPresent(String.self, forKey: .name)
        self.prompts              = try container.decodeIfPresent([String : CubePrompt].self, forKey: .prompts)
        self.defaultIndex         = try container.decodeIfPresent(Int.self, forKey: .index)
    }
}


