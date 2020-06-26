//
//  DLCDataStructures.swift
//  FlashCube_Prototype
//
//  Created by Jeffrey Thompson on 11/24/18.
//  Copyright © 2018 Jeffrey Thompson. All rights reserved.
//

import Foundation
import FirebaseDatabase
import FirebaseStorage

enum DownloadError: Error {
    case customError
    case jsonParse
    case imageParse
    case audioParse
    case dataMissing
    case localSave
}

extension DownloadError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .customError:
            return NSLocalizedString("A user friendly desciption of the error.", comment: "Download Error has occured.")
        case .jsonParse:
            return NSLocalizedString("A user friendly desciption of the error.", comment: "Error parsing JSON from downloaded content.")
        case .imageParse:
            return NSLocalizedString("A user friendly desciption of the error.", comment: "Error parsing image from downloaded content.")
        case .audioParse:
            return NSLocalizedString("A user friendly desciption of the error.", comment: "Error parsing audio from downloaded content.")
        case .dataMissing:
            return NSLocalizedString("A user friendly desciption of the error.", comment: "Download has missing or corrupted data.")
        case .localSave:
            return NSLocalizedString("A user friendly desciption of the error.", comment: "Could not save data locally.")
        }
    }
}

struct FolderCollection: Decodable {
    let folders: [MainFolder]?
}

struct MainFolder: Decodable {
    let name: String
    let subFolders: [SubFolder]?
}

struct SubFolder: Decodable {
    let name: String
    let content: [Content]?
}

struct Content: Decodable {
    let name: String
    let price: Double
    let storagePath: String
    let IAPid: String?
}

struct StoredDeck: Decodable {
    let name: String
    let folderPath: String
    let protoPrompts: [String]
    let imageFileURLs: [String]? // large image files that get sliced up ex: "3:Words1to100.pdf" protopromptIndex: filename
    let audioFileURLs: [String]? // large audio files that get sliced up
    let cubes: [CubeData]?
}

struct CubeData: Decodable {
    let name: String
    let text: [String]?
    let audioURLPaths: [String]?
    let imageURLPaths: [String]?
    let imageThumbnailURLPaths: [String]?
    let audioCutoffTimes: [String]?
}

enum DLCPromptType {
    case text
    case audio
    case image
}

enum DLCPrompt {
    case text(String)
    //IFBREAKCHANGEBACK
    //case audio(UIImage?)
    case audio(URL?)
    case image(UIImage?)
    
    var value: Any? {
        switch self {
        case .text(let str):
            return str
        case .audio(let url):
            return url
        //IFBREAKCHANGEBACK
        //case .audio(let img):
            //return img
        case .image(let img):
            return img
        }
    }
}

struct MetaData {
    let description: String
    let type: DLCPromptType
}

struct DLCCube {
    let name: String
    var prompts: [Int : DLCPrompt]
}
