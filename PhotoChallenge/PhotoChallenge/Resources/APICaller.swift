//
//  APICaller.swift
//  PhotoChallenge
//
//  Created by Andres Liu on 9/13/21.
//

import UIKit

class APICaller {
    static let shared = APICaller()
    
    struct Constants {
        static let imagesUrl = URL(string: "https://eulerity-hackathon.appspot.com/image")
        static let uploadUrl = URL(string: "https://eulerity-hackathon.appspot.com/upload")
    }
    
    public func getImages(completion: @escaping (Result<[Image], Error>) -> Void) {
        
        guard let url = Constants.imagesUrl else { return }
        
        URLSession.shared.dataTask(with: url) { (data, _, error) in
            
            if let error = error {
                
                completion(.failure(error))
                
            } else if let data = data {
                do {
                    let result = try JSONDecoder().decode([Image].self, from: data)
                    completion(.success(result))
                    
                } catch {
                    completion(.failure(error))
                }
            }
        }.resume()
    }
    
    public func getUploadURL(completion: @escaping (Result<String, Error>) -> Void) {
        
        guard let url = Constants.uploadUrl else { return }
        
        URLSession.shared.dataTask(with: url) { (data, _, error) in
            
            if let error = error {
                
                completion(.failure(error))
                
            } else if let data = data {
                do {
                    let result = try JSONDecoder().decode(UploadResponse.self, from: data)
                    completion(.success(result.url))
                    
                } catch {
                    completion(.failure(error))
                }
            }
        }.resume()
    }
}


