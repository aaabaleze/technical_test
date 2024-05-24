//
//  ImagesViewController.swift
//  TechnicalTest
//
//  Created by Hugues Bousselet on 23/05/2024.
//

import UIKit

class ImagesViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    lazy var collectionView = UICollectionView()
    var imageLoader = GetImage()
    var imagesSearch: [ResponseSearchImages?] = []
    var imagesForDetailedView: [UIImage] = []
    let flowLayout: UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 5
        layout.minimumLineSpacing = 5
        layout.itemSize = CGSize(width: 150, height: 150)
        return layout
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        navigationItem.title = "Images"
        navigationItem.rightBarButtonItem =  UIBarButtonItem(title: "Detail", style: .done, target: self, action: #selector(goToDetailViewController))
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(customCell.self, forCellWithReuseIdentifier: "Cell")
        collectionView.allowsMultipleSelection = true
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(collectionView)
        collectionView.isScrollEnabled = true
        setupConstraint()
        
        for i in 0...(imagesSearch[0]?.hits.count)!-1 {
            if let imageURL = (imagesSearch[0]?.hits[i]?.webformatURL) {
                let image = imageURL
                if let url = URL(string: image) {
                    Task {
                        await updateImage(url: url, indexPath: i)
                        collectionView.reloadData()
                    }
                }
            }
        }
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if imagesSearch.count > 0 {
            return (imagesSearch[0]?.hits.count)! - 1
        } else {
            return 5
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath)
        cell?.layer.borderColor = UIColor.red.cgColor
        cell?.layer.borderWidth = 2.0
        if let imageURL = (imagesSearch[0]?.hits[indexPath.row]?.webformatURL) {
            if let imageFromCache = imageLoader.imageCache.object(forKey: imageURL as AnyObject) as? UIImage {
                self.imagesForDetailedView.append(imageFromCache)
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath)
        cell?.layer.borderColor = UIColor.white.cgColor
        cell?.layer.borderWidth = 2.0
        if let imageURL = imagesSearch[0]?.hits[indexPath.row]?.webformatURL {
            if let imageFromCache = imageLoader.imageCache.object(forKey: imageURL as AnyObject) as? UIImage {
                self.imagesForDetailedView.removeAll(where: {$0 == imageFromCache})
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! customCell
        if let imageURL = (imagesSearch[0]?.hits[indexPath.row]?.webformatURL) {
            let image = imageURL
                if let imageFromCache = imageLoader.imageCache.object(forKey: image as AnyObject) as? UIImage {
                    imageLoader.image = imageFromCache
                    cell.image.image = imageLoader.image
                    cell.image.contentMode = .center
                    cell.image.clipsToBounds = true
                } else {
                    let spinner = createRowLoader()
                    spinner.startAnimating()
                    cell.addSubview(spinner)
                }
        }
        return cell
    }
    
    @objc func goToDetailViewController() {
        if self.imagesForDetailedView.count >= 1 {
            let viewControllerGame = DetailViewController()
            viewControllerGame.images = self.imagesForDetailedView
            navigationController?.pushViewController(viewControllerGame, animated: true)
        } else {
            let ac = UIAlertController(title: "No image selected", message: "Please select at least one image", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
            navigationController?.present(ac, animated: true, completion: nil)
        }
    }
    
    func setupConstraint() {
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        let viewConstraints = [
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor)
        ]
        NSLayoutConstraint.activate(viewConstraints)
    }
    
    fileprivate func createRowLoader() -> UIActivityIndicatorView {
        let loader = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.medium)
        loader.translatesAutoresizingMaskIntoConstraints = false
        loader.color = UIColor.black
        loader.hidesWhenStopped = true
        return loader
    }
    func updateImage(url: URL, indexPath: Int) async {
        do {
            _ = try await imageLoader.loadImage(url: url, indexPath: indexPath)
        } catch {
            print("Oops!")
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = view.frame.width
        return CGSize(width: width, height: width)
    }
}

class customCell: UICollectionViewCell {
    var image: UIImageView = UIImageView(frame: CGRect.zero)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        image.frame.size = CGSize(width: self.frame.width, height: self.frame.height)
        image.contentMode  = .center
        image.clipsToBounds = true
        addSubview(image)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
