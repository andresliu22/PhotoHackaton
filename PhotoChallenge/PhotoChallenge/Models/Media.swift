//
//  Media.swift
//  PhotoChallenge
//
//  Created by Andres Liu on 9/15/21.
//

import UIKit

struct Media {
    let key: String
    let filename: String
    let data: Data
    let mimeType: String
    
    init?(withImage image: UIImage, forKey key: String) {
        self.key = key
        self.mimeType = "image/jpeg"
        self.filename = "andresliu22_test.jpg"
        
        guard let data = image.jpegData(compressionQuality: 0.7) else { return nil }
        self.data = data
    }
    
}
