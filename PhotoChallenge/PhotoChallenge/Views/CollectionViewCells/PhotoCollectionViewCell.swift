//
//  PhotoCollectionViewCell.swift
//  PhotoChallenge
//
//  Created by Andres Liu on 9/13/21.
//

import UIKit

class PhotoCollectionViewCell: UICollectionViewCell {
    
    static let identifier = "PhotoCollectionViewCell"
    
    let photoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(photoImageView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        photoImageView.frame = contentView.bounds
    }
    
    public func configure(model: PhotoCollectionViewCellModel) {
        
        if let imageData = model.imageData {
            
            self.photoImageView.image = UIImage(data: imageData)
            
        } else {
            
            guard let url = model.imageURL else { return }
            
            URLSession.shared.dataTask(with: url) { (data, _, error) in
                
                guard let data = data, error == nil else { return }
                
                DispatchQueue.main.async {
                    self.photoImageView.image = UIImage(data: data)
                }
                
                model.imageData = data
                
            }.resume()
        }
    }
    
}
