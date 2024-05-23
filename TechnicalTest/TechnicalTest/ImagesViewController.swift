//
//  ImagesViewController.swift
//  TechnicalTest
//
//  Created by Hugues Bousselet on 23/05/2024.
//

import UIKit

class ImagesViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    lazy var collectionView = UICollectionView()
    var imageLoader = GetImage()
    var imagesSearch: [ResponseSearchImages?] = []
    let flowLayout: UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 5
        layout.minimumLineSpacing = 5
        layout.itemSize = CGSize(width: 300, height: 300)
        layout.sectionInset = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
        return layout
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        navigationItem.title = "Images"
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(customCell.self, forCellWithReuseIdentifier: "Cell")
        collectionView.allowsMultipleSelection = true
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        //imageLoader.collectionView = collectionView
        view.addSubview(collectionView)
        collectionView.isScrollEnabled = true
        setupConstraint()
        print("count image: \((imagesSearch[0]?.hits.count)!)")
        
        for i in 0...(imagesSearch[0]?.hits.count)!-1 {
            //print(imagesSearch)
            if let imageURL = (imagesSearch[0]?.hits[i]?.webformatURL) {
                ("on va télécharger :\(imageURL)")
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
        print("selected")
        cell?.layer.borderColor = UIColor.red.cgColor
        cell?.layer.borderWidth = 2.0
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath)
        print("de-selected")
        cell?.layer.borderColor = UIColor.white.cgColor
        cell?.layer.borderWidth = 2.0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! customCell
        if let imageURL = (imagesSearch[0]?.hits[indexPath.row]?.webformatURL) {
            print("imageURL looks like : \(imageURL)")
            let image = imageURL
            if let url = URL(string: image) {
                if let imageFromCache = imageLoader.imageCache.object(forKey: image as AnyObject) as? UIImage {
                    print("je la trouve")
                    imageLoader.image = imageFromCache
                    print(imageLoader.image)
                    cell.image.image = imageLoader.image
                    cell.image.contentMode = .scaleAspectFill
                    cell.image.clipsToBounds = true
                } else {
                    print("je ne la trouve aps")
                }
            }
        }
        return cell
    }
    
    //return CGSize(width: (collectionView.bounds.width - 20) / 3, height: 50)
    
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
}

class customCell: UICollectionViewCell {
    var pageTitle = UILabel()
    var image = UIImageView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        image.contentMode  = .scaleAspectFill
        addSubview(image)
        setupConstraint()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupConstraint() {
        image.translatesAutoresizingMaskIntoConstraints = false
        let viewCellConstraints = [
            image.topAnchor.constraint(equalTo: contentView.topAnchor),
            image.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            image.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            image.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            ]
        NSLayoutConstraint.activate(viewCellConstraints)
    }
}
