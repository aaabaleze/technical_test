//
//  model.swift
//  TechnicalTest
//
//  Created by Hugues Bousselet on 23/05/2024.
//

import Foundation
import UIKit

class ImageAPI {
    let searchUrl = "https://pixabay.com/api/"
    let imageToSearch = ""
    lazy var imagesFound: [ResponseSearchImages] = []
    
    func searchImages(search: String) async throws {
        let url = URL(string: self.searchUrl + "?key=" + String(Bundle.main.object(forInfoDictionaryKey: "API_KEY") as! String) + "&q=" + search + "&image_type=photo")
        
        let decoder = JSONDecoder()
        if let url = url {
            var request = URLRequest(url: url,timeoutInterval: Double.infinity)
            request.httpMethod = "GET"
            do {
                let (data, response) = try await URLSession.shared.data(for: request)
                print(response)
                let str = String(data: data, encoding: .utf8)
                let decodedAnswer = try decoder.decode(ResponseSearchImages.self, from: data)
                self.imagesFound.append(decodedAnswer)
                print(self.imagesFound)
                //print(response)
            } catch {
                print(error)
            }
        }
    }
}


struct ResponseSearchImages: Codable {
    var hits: [Hits?]
}

struct Hits: Codable {
    var id: Int?
    var imageHeight: Int?
    var imageSize: Int?
    var imageWidth: Int?
    var largeImageURL: String?
    var webformatURL: String?
    
}

class GetImage: UIImageView {
    //var viewController = ImagesViewController()
    //weak var collectionView = ImagesViewController.collectionView
    let imageCache = NSCache<AnyObject, AnyObject>()
    
    func loadImage(url: URL, indexPath: Int) async throws  {
        self.image = nil
        let spinner = createRowLoader()
        spinner.startAnimating()
        
        if let imageFromCache = imageCache.object(forKey: url.absoluteString as AnyObject) as? UIImage {
            print("image cache for indexpath: \(indexPath): \(url.absoluteString)")
            self.image = imageFromCache
            return
        }
        
        do {
            let request = URLRequest(url: url,timeoutInterval: Double.infinity)
            let (data, response) = try await URLSession.shared.data(for: request)
            print(response)
            guard let newImage = UIImage(data: data) else {
                print("error")
                return
            }
            self.imageCache.setObject(newImage, forKey: url.absoluteString as AnyObject)
            DispatchQueue.main.async {
                print("image for indexpath: \(indexPath): \(url.absoluteString)")
                self.image = newImage
                //self.viewController?.collectionView.reloadItems(at: [indexPath])
            }
            
        } catch {
            print(error)
        }
    }
    
    fileprivate func createRowLoader() -> UIActivityIndicatorView {
        let loader = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.medium)
        loader.translatesAutoresizingMaskIntoConstraints = false
        loader.color = UIColor.black
        loader.hidesWhenStopped = true
        return loader
    }
}
