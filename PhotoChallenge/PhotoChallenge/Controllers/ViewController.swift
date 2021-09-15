//
//  ViewController.swift
//  PhotoChallenge
//
//  Created by Andres Liu on 9/13/21.
//

import UIKit

class GalleryViewController: UIViewController {

    let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 1
        layout.minimumInteritemSpacing = 1
        
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.register(PhotoCollectionViewCell.self, forCellWithReuseIdentifier: PhotoCollectionViewCell.identifier)
        cv.backgroundColor = .white
        return cv
    }()
    
    var models = [PhotoCollectionViewCellModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Gallery"
        
        view.addSubview(collectionView)
        collectionView.delegate = self
        collectionView.dataSource = self
        
        fetchImages()
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView.frame = view.bounds
    }
    
    private func fetchImages() {
        APICaller.shared.getImages { [weak self] result in
            switch result {
            case .success(let images):
                
                self?.models = images.compactMap({
                    PhotoCollectionViewCellModel(created: $0.created, updated: $0.updated, imageURL: URL(string: $0.url))
                })
                
                DispatchQueue.main.async {
                    self?.collectionView.reloadData()
                }
                
            case .failure(let error):
                print(error)
            }
        }
    }
    

}

extension GalleryViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return models.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PhotoCollectionViewCell.identifier, for: indexPath) as! PhotoCollectionViewCell
        
        cell.configure(model: models[indexPath.row])
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        var width: CGFloat = collectionView.frame.width / 3 - 1
        
        if UIDevice.current.orientation.isLandscape {
            width = collectionView.frame.width / 6 - 1
        }
        
        return CGSize(width: width, height: width)
    }
    
}
