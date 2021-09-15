//
//  ImageViewController.swift
//  PhotoChallenge
//
//  Created by Andres Liu on 9/13/21.
//

import UIKit
import CoreImage

typealias Parameters = [String: String]

class ImageViewController: UIViewController, UIScrollViewDelegate {
    
    var selectedIndex: Int = 0
    var imageArr: [PhotoCollectionViewCellModel] = []
    
    let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.contentMode = .scaleAspectFit
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.backgroundColor = .black
        scrollView.minimumZoomScale = 1
        scrollView.maximumZoomScale = 6
        return scrollView
    }()
    
    let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.isUserInteractionEnabled = true
        return imageView
    }()
    
    private var originalImage: UIImage?
    private var originalImageURL: URL?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .black
        scrollView.delegate = self
        view.addSubview(scrollView)
        scrollView.addSubview(imageView)
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Edit", style: .done, target: self, action: #selector(editImage))
        
        loadImage()
        setupGesture()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        scrollView.frame = view.bounds
        imageView.frame = scrollView.bounds
        
    }
    
    // Load the image selected
    private func loadImage() {
        guard let imageData = imageArr[selectedIndex].imageData else { return }
        imageView.image = UIImage(data: imageData)
        originalImage = imageView.image
        originalImageURL = imageArr[selectedIndex].imageURL
    }
    
    // Setup gestures to recognize left and right swipe to switch between images
    // And double taps for zooming images
    private func setupGesture() {
        
        let doubleTapGesture = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTapGesture(recognizer:)))
        doubleTapGesture.numberOfTapsRequired = 2
        scrollView.addGestureRecognizer(doubleTapGesture)
        
        let leftSwipe: UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(recognizer:)))
        let rightSwipe: UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(recognizer:)))
        
        leftSwipe.direction = .left
        rightSwipe.direction = .right
        
        scrollView.addGestureRecognizer(leftSwipe)
        scrollView.addGestureRecognizer(rightSwipe)
    }
    
    // Double tap function for zooming
    @objc func handleDoubleTapGesture(recognizer: UITapGestureRecognizer) {
        if scrollView.zoomScale == 1 {
            scrollView.zoom(to: zoomRectForScale(scale: scrollView.maximumZoomScale, center: recognizer.location(in: recognizer.view)), animated: true)
        } else {
            scrollView.setZoomScale(1, animated: true)
        }
    }
    
    func zoomRectForScale(scale: CGFloat, center: CGPoint) -> CGRect {
        var zoomRect = CGRect.zero
        zoomRect.size.width = imageView.width / scale
        zoomRect.size.height = imageView.height / scale
        
        let newCenter = imageView.convert(center, from: scrollView)
        zoomRect.origin.x = newCenter.x - (zoomRect.size.width / 2.0)
        zoomRect.origin.y = newCenter.y - (zoomRect.size.height / 2.0)
        
        return zoomRect
        
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        if scrollView.zoomScale > 1 {
            if let image = imageView.image {
                let ratioW = imageView.width / image.size.width
                let ratioH = imageView.height / image.size.height
                
                let ratio = ratioW < ratioH ? ratioW : ratioH
                let newWidth = image.size.width * ratio
                let newHeight = image.size.height * ratio
                
                let left = 0.5 * (newWidth * scrollView.zoomScale > imageView.width ? (newWidth - imageView.frame.width) : (scrollView.width - scrollView.contentSize.width))
                
                let top = 0.5 * (newHeight * scrollView.zoomScale > imageView.height ? (newHeight - imageView.frame.height) : (scrollView.height - scrollView.contentSize.height))
                
                scrollView.contentInset = UIEdgeInsets(top: top, left: left, bottom: top, right: left)
            }
        } else {
            scrollView.contentInset = UIEdgeInsets.zero
        }
    }
    
    // Swipe function to switch between images
    @objc func handleSwipe(recognizer: UISwipeGestureRecognizer) {
        
        let direction: UISwipeGestureRecognizer.Direction = recognizer.direction
        
        switch direction {
        case UISwipeGestureRecognizer.Direction.left:
            self.selectedIndex += 1
            
        case UISwipeGestureRecognizer.Direction.right:
            self.selectedIndex -= 1
            
        default:
            break
        }
        
        self.selectedIndex = (self.selectedIndex < 0) ? (self.imageArr.count - 1) : self.selectedIndex % self.imageArr.count
        
        loadImage()
        
    }
    
    // Filter function to add some filters to the image using CoreImage
    // 1. Sepia Effect
    // 2. Photo Effect
    // 3. Blur Effect
    // 4. Noir Effect
    // 5. Add texts
    // 6. Clear filters
    private func applyFilterTo(image: UIImage, filterEffect: Filter) -> UIImage? {
        
        guard let cgImage = image.cgImage,
              let openGLContext = EAGLContext(api: .openGLES3) else {
            return nil
        }
        
        let context = CIContext(eaglContext: openGLContext)
        
        let ciImage = CIImage(cgImage: cgImage)
        let filter = CIFilter(name: filterEffect.filterName)
        
        filter?.setValue(ciImage, forKey: kCIInputImageKey)
        
        if let filterEffectValue = filterEffect.filterEffectValue,
           let filterEffectValueName = filterEffect.filterEffectValueName {
            filter?.setValue(filterEffectValue, forKey: filterEffectValueName)
        }
        
        var filteredImage: UIImage?
        
        if let output = filter?.value(forKey: kCIOutputImageKey) as? CIImage,
           let cgiImageResult = context.createCGImage(output, from: output.extent) {
            filteredImage = UIImage(cgImage: cgiImageResult)
        }
        
        return filteredImage
        
    }
    
    @objc private func editImage() {
        
        // Cancel action
        let alertController = UIAlertController(title: "Add Filter", message: nil, preferredStyle: .actionSheet)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alertController.addAction(cancelAction)
        
        // 1. Sepia Effect
        let sepiaFilter = UIAlertAction(title: "Sepia Effect", style: .default, handler: { [weak self] _ in
            self?.applySepia()
        })
        alertController.addAction(sepiaFilter)
        
        // 2. Photo Effect
        let photoEffectFilter = UIAlertAction(title: "Photo Effect", style: .default, handler: { [weak self] _ in
            self?.applyPhotoTransferEffect()
        })
        alertController.addAction(photoEffectFilter)
        
        // 3. Blur Effect
        let blurFilter = UIAlertAction(title: "Blur Effect", style: .default, handler: { [weak self] _ in
            self?.applyBlur()
        })
        alertController.addAction(blurFilter)
        
        // 4. Noir Effect
        let noirFilter = UIAlertAction(title: "Noir Effect", style: .default, handler: { [weak self] _ in
            self?.applyNoir()
        })
        alertController.addAction(noirFilter)
        
        // 5. Add text
        let addText = UIAlertAction(title: "Add text", style: .default, handler: { [weak self] _ in
            
            let vc = TextViewController()
            vc.completion = { [weak self] (text, color) in
                
                self?.textToImage(drawText: text, colorSelected: color, atPoint: CGPoint(x: 20, y: 20))
                
            }
            self?.navigationController?.pushViewController(vc, animated: true)
            
        })
        alertController.addAction(addText)
        
        // 6. Clear filters
        let clearFilter = UIAlertAction(title: "Clear filters", style: .default, handler: { [weak self] _ in
            self?.clearFilters()
        })
        alertController.addAction(clearFilter)

        let saveImage = UIAlertAction(title: "Save image", style: .destructive, handler: { [weak self] _ in
            
            self?.uploadImage()
        })
        alertController.addAction(saveImage)
        
        //Present Alert Controller
        self.present(alertController, animated:true, completion: nil)
        
    }
    
    // Applying Sephia Effect
    private func applySepia() {
        guard let image = imageView.image else { return }
        imageView.image = applyFilterTo(image: image, filterEffect: Filter(filterName: "CISepiaTone", filterEffectValue: 0.95, filterEffectValueName: kCIInputIntensityKey))
    }
    
    // Applying Photo Effect
    private func applyPhotoTransferEffect() {
        guard let image = imageView.image else { return }
        imageView.image = applyFilterTo(image: image, filterEffect: Filter(filterName: "CIPhotoEffectProcess", filterEffectValue: nil, filterEffectValueName: nil))
    }
    
    // Applying Blur Effect
    private func applyBlur() {
        guard let image = imageView.image else { return }
        imageView.image = applyFilterTo(image: image, filterEffect: Filter(filterName: "CIGaussianBlur", filterEffectValue: 8.0, filterEffectValueName: kCIInputRadiusKey))
    }
    
    // Applying Noir Effect
    private func applyNoir() {
        guard let image = imageView.image else { return }
        imageView.image = applyFilterTo(image: image, filterEffect: Filter(filterName: "CIPhotoEffectNoir", filterEffectValue: nil, filterEffectValueName: nil))
    }
    
    // Clear filters
    private func clearFilters() {
        imageView.image = originalImage
    }
    
    // Adding text to image
    private func textToImage(drawText text: String, colorSelected color: UIColor, atPoint point: CGPoint){
        guard let image = imageView.image else { return }
        
        let textColor = color
        let textFont = UIFont.systemFont(ofSize: 120, weight: .semibold)

        let scale = UIScreen.main.scale
        UIGraphicsBeginImageContextWithOptions(image.size, false, scale)

        let textFontAttributes = [
            NSAttributedString.Key.font: textFont,
            NSAttributedString.Key.foregroundColor: textColor,
            ] as [NSAttributedString.Key : Any]
        image.draw(in: CGRect(origin: CGPoint.zero, size: image.size))

        let rect = CGRect(origin: point, size: image.size)
        text.draw(in: rect, withAttributes: textFontAttributes)

        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        guard let imageWithText = newImage else { return }
        
        imageView.image = imageWithText
    }
    
    // POST Request to upload image
    private func uploadImage() {
        
        guard let originalURL = originalImageURL else { return }
        
        let parameters = ["appid": "andresliu22",
                          "original": originalURL.absoluteString]
        
        guard let image = imageView.image else { return }
        
        guard let mediaImage = Media(withImage: image, forKey: "image") else { return }
        
        guard let url = URL(string: UserDefaults.standard.value(forKey: "uploadURL") as! String) else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        let boundary = generateBoundary()
        
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        request.addValue("Client-ID f65203f7020dddc", forHTTPHeaderField: "Authorization")
        
        let dataBody = createDataBody(withParameters: parameters, media: [mediaImage], boundary: boundary)
        request.httpBody = dataBody
        
        let session = URLSession.shared
        session.dataTask(with: request) { (data, response, error) in
            if let response = response {
                print(response)
            }
            
            if let data = data {
                do {
                    let json = try JSONSerialization.jsonObject(with: data, options: [])
                    print(json)
                } catch {
                    print(error)
                }
            }
        }.resume()
        
    }
    
    // Setup multipart/form-data
    func generateBoundary() -> String {
        return "Boundary-\(NSUUID().uuidString)"
    }
    
    func createDataBody(withParameters params: Parameters?, media: [Media]?, boundary: String) -> Data {
        
        let lineBreak = "\r\n"
        var body = Data()
        
        if let parameters = params {
            for (key, value) in parameters {
                body.append("--\(boundary + lineBreak)")
                body.append("Content-Disposition: form-data; name=\"\(key)\"\(lineBreak + lineBreak)")
                body.append("\(value + lineBreak)")
            }
        }
        
        if let media = media {
            for photo in media {
                body.append("--\(boundary + lineBreak)")
                body.append("Content-Disposition: form-data; name=\"\(photo.key)\"; filename=\"\(photo.filename)\"\(lineBreak)")
                body.append("Content-Type: \(photo.mimeType + lineBreak + lineBreak)")
                body.append(photo.data)
                body.append(lineBreak)
            }
        }
        
        body.append("--\(boundary)--\(lineBreak)")
        
        return body
    }
}
