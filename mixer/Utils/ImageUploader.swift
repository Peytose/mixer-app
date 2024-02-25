//
//  ImageUploader.swift
//  mixer
//
//  Created by Peyton Lyons on 11/11/22.
//

import UIKit
import Firebase
import FirebaseStorage

enum UploadType {
    case profile
    case event
    case host
    
    var filePath: StorageReference {
        let filename = NSUUID().uuidString
        switch self {
            case .profile:
                return Storage.storage().reference(withPath: "/profile_images/\(filename)")
            case .event:
                return Storage.storage().reference(withPath: "/event_images/\(filename)")
            case .host:
                return Storage.storage().reference(withPath: "/host_images/\(filename)")
        }
    }
}

struct ImageUploader {
    static func uploadImage(image: UIImage, type: UploadType, completion: @escaping(String) -> Void) {
        guard let imageData = image.jpegData(compressionQuality: 0.5) else { return }
        let ref = type.filePath
        
        ref.putData(imageData) { _, error in
            if let error = error {
                print("DEBUG: Failed to upload image \(error.localizedDescription)")
                return
            }
            
            print("✅ Succesfully uploaded image ...")
            
            ref.downloadURL { url, _ in
                guard let imageUrl = url?.absoluteString else { return }
                completion(imageUrl)
            }
        }
    }
}
