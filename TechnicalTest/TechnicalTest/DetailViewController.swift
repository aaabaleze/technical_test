//
//  DetailViewController.swift
//  TechnicalTest
//
//  Created by Hugues Bousselet on 23/05/2024.
//

import UIKit

class DetailViewController: UIViewController {
    var images: [UIImage] = []
    var imageView: UIImageView = UIImageView(frame: CGRect.zero)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.frame.size = CGSize(width: view.frame.width, height: view.frame.height)
        view.backgroundColor = .white
        imageView.contentMode  = .center
        imageView.clipsToBounds = true
        view.addSubview(imageView)
        animateImages()
    }
    
    func animateImages() {
        let animation = UIImage.animatedImage(with: self.images, duration: 2)
        self.imageView.image = animation
    }

}
