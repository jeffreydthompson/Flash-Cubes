//
//  FirebaseStorageService.swift
//  FlashCube_Prototype
//
//  Created by Jeffrey Thompson on 11/2/18.
//  Copyright © 2018 Jeffrey Thompson. All rights reserved.
//

import Foundation
import FirebaseStorage

struct FirebaseStorageService {

    static private let storageRef = Storage.storage().reference()
    
    /*static func getFileSize(atFolder: String, atPath: String, completion: @escaping ((_ fileSizeBytes: Int64?, _ error: Error?) -> Void)){
        let itemRef = storageRef.child(atFolder).child(atPath)
        
        itemRef.getMetadata { (metaData, error) in
            if let error = error {
                completion(nil, error)
                return
            }
            
            if let size = metaData?.size {
                completion(size, nil)
            } else {
                completion(nil, DownloadError.dataMissing)
            }
        }
    }*/
    
    /*static func fetchAudio(atFolder: String, atPath: String, updateProgress: @escaping ((Int64) -> Void), completion: @escaping (URL?, Error?) -> Void) {
        
        let itemRef = storageRef.child(atFolder).child(atPath)
        let downloadTask = itemRef.getData(maxSize: 1024 * 1024 * 5) { (data, error) in
            
            if let error = error {
                print(error.localizedDescription)
                completion(nil, error)
                return
            }
            
            guard let data = data else {
                print("\(#function): \(String(describing: DownloadError.dataMissing.errorDescription))")
                completion(nil, DownloadError.dataMissing)
                return
            }
            
            do {
                let tempURL = UniqueTempAudioURL.m4a.generate//UniqueTempAudioURL.filePathForMP3.generate
                try data.write(to: tempURL)
                completion(tempURL, nil)
            } catch let error {
                print("TESTING audio data write error \(error.localizedDescription)")
                print("\(#function): \(String(describing: DownloadError.localSave.errorDescription))")
                completion(nil, DownloadError.localSave)
            }
        }
        
        downloadTask.observe(.progress) { (snapshot) in
            if let progress = snapshot.progress {
                
                //updateProgress(progress)
            }
        }
        
        downloadTask.resume()
    }*/
    
    static func fetchData(atFolder: String, atPath: String, completion: @escaping (Data?, Error?) -> Void) {
        let itemRef = storageRef.child(atFolder).child(atPath)
        
        itemRef.getData(maxSize: 1024 * 1024 * 10) { (data, error) in
            
            if let error = error {
                print(error.localizedDescription)
                completion(nil, error)
                return
            }
            
            guard let data = data else {
                print("\(#function): \(String(describing: DownloadError.dataMissing.errorDescription))")
                completion(nil, DownloadError.dataMissing)
                return
            }
            
            completion(data, nil)
        }
    }
    
    static func fetchAudio(atFolder: String, atPath: String, completion: @escaping (URL?, Error?) -> Void) {
        let itemRef = storageRef.child(atFolder).child(atPath)
        
        itemRef.getData(maxSize: 1024 * 1024 * 5) { (data, error) in
            
            if let error = error {
                print(error.localizedDescription)
                completion(nil, error)
                return
            }
            
            guard let data = data else {
                print("\(#function): \(String(describing: DownloadError.dataMissing.errorDescription))")
                completion(nil, DownloadError.dataMissing)
                return
            }
            
            do {
                let tempURL = UniqueTempAudioURL.m4a.generate//UniqueTempAudioURL.filePathForMP3.generate
                try data.write(to: tempURL)
                completion(tempURL, nil)
            } catch let error {
                print("TESTING audio data write error \(error.localizedDescription)")
                print("\(#function): \(String(describing: DownloadError.localSave.errorDescription))")
                completion(nil, DownloadError.localSave)
            }
        }
    }
    
    static func fetchJSON(atPath: String, completion: @escaping (StoredDeck?, Error?) -> Void) {
        let itemRef = storageRef.child(atPath)
        
        itemRef.getData(maxSize: 1024 * 64) { (data, error) in
            if let _ = error {
                completion(nil, error)
                return
            }
            
            guard let data = data else {
                print("\(#function): \(String(describing: DownloadError.dataMissing.errorDescription))")
                completion(nil, DownloadError.dataMissing)
                return
            }
            
            do {
                let storedDeck = try JSONDecoder().decode(StoredDeck.self, from: data)
                completion(storedDeck, nil)
            } catch let err {
                print("\(#function): \(String(describing: DownloadError.jsonParse.errorDescription))")
                completion(nil, DownloadError.jsonParse)
                print(err.localizedDescription)
            }
        }
    }
    
    /*static func fetchVectorImage(atFolder: String, atPath: String, updateProgress: @escaping ((Int64) -> Void), completion: @escaping ((UIImage?, Error?) -> Void)) {
        
        func resizeImage(image: UIImage, newWidth: CGFloat) -> UIImage? {
            
            let scale = newWidth / image.size.width
            let newHeight = image.size.height * scale
            UIGraphicsBeginImageContext(CGSize(width: newWidth, height: newHeight))
            image.draw(in: CGRect(x: 0, y: 0, width: newWidth, height: newHeight))
            let newImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            return newImage
        }
        
        let itemRef = storageRef.child(atFolder).child(atPath)
        
        let downloadTask = itemRef.getData(maxSize: 1024 * 1024 * 2) {(data, error) in
            
            if let error = error {
                print(error.localizedDescription)
                completion(nil, error)
                return
            }
            
            guard let data = data else {
                print("\(#function): \(String(describing: DownloadError.dataMissing.errorDescription))")
                completion(nil, DownloadError.dataMissing)
                return
            }
            
            if let ciimg = CIImage(data: data, options: nil){
                
                let img = UIImage(ciImage: ciimg)
                //HACK: 0.96 overcomes an automatic scaling bug issue.  Refuses to download at original size.
                if let sizedImage = resizeImage(image: img, newWidth: img.size.width * 0.96){
                    completion(sizedImage, nil)
                } else {
                    print("\(#function): \(String(describing: DownloadError.imageParse.errorDescription))")
                    completion(nil, DownloadError.imageParse)
                }
            } else {
                print("\(#function): \(String(describing: DownloadError.imageParse.errorDescription))")
                completion(nil, DownloadError.imageParse)
            }
            
            }
        
        downloadTask.observe(.progress) {(snapshot) in
                if let progress = snapshot.progress {
                    print("\(#function): completedUnitCount \(progress.completedUnitCount)")
                    print("\(#function): totalUnitCount \(progress.totalUnitCount)")
                }
        }
        
        downloadTask.resume()
    }*/
    
    static func fetchPDF(atFolder: String, atPath: String, completion: @escaping (UIImage?, Error?) -> Void ) {
        
        func resizeImage(image: UIImage, newWidth: CGFloat) -> UIImage? {
            
            let scale = newWidth / image.size.width
            let newHeight = image.size.height * scale
            UIGraphicsBeginImageContext(CGSize(width: newWidth, height: newHeight))
            image.draw(in: CGRect(x: 0, y: 0, width: newWidth, height: newHeight))
            let newImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            return newImage
        }
        
        let itemRef = storageRef.child(atFolder).child(atPath)
        //TimeKeeper.start()
        
        itemRef.getData(maxSize: 1024 * 1024 * 2) {(data, error) in
            
           // print("Fetch Elapsed time: \(TimeKeeper.elapsed())")
            
            if let error = error {
                print(error.localizedDescription)
                completion(nil, error)
                return
            }
            
            guard let data = data else {
                print("\(#function): \(String(describing: DownloadError.dataMissing.errorDescription))")
                completion(nil, DownloadError.dataMissing)
                return
            }
            
            if let ciimg = CIImage(data: data, options: nil){
                
                let img = UIImage(ciImage: ciimg)
                //HACK: 0.96 overcomes an automatic scaling bug issue.  Refuses to download at original size.
                if let sizedImage = resizeImage(image: img, newWidth: img.size.width * 0.96){
                    completion(sizedImage, nil)
                } else {
                    print("\(#function): \(String(describing: DownloadError.imageParse.errorDescription))")
                    completion(nil, DownloadError.imageParse)
                }
            } else {
                print("\(#function): \(String(describing: DownloadError.imageParse.errorDescription))")
                completion(nil, DownloadError.imageParse)
            }
        }
    }
}
