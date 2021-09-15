//
//  Image.swift
//  PhotoChallenge
//
//  Created by Andres Liu on 9/13/21.
//

import UIKit

struct ImagesResponse: Codable {
    let images: [Image]
}

struct Image: Codable {
    let url: String
    let created: String
    let updated: String
}

struct UploadResponse: Codable {
    let url: String
}
