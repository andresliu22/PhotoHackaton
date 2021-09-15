//
//  PhotoCollectionViewCellModel.swift
//  PhotoChallenge
//
//  Created by Andres Liu on 9/13/21.
//

import UIKit

class PhotoCollectionViewCellModel {
    let created: String
    let updated: String
    let imageURL: URL?
    var imageData: Data? = nil
    
    init(created: String, updated: String, imageURL: URL?){
        self.created = created
        self.updated = updated
        self.imageURL = imageURL
    }
}
