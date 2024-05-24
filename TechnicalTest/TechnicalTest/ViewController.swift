//
//  ViewController.swift
//  TechnicalTest
//
//  Created by Hugues Bousselet on 23/05/2024.
//

import UIKit

class ViewController: UIViewController, UITextFieldDelegate {
    var sizedCurrentText = "Dogs"
    var imageCalls = ImageAPI()
    //label
    var explanationLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 25, weight: .semibold)
        label.textAlignment = .center
        label.textColor = .black
        label.text = "Please enter a keyword to prompt a search for images in the Pixabay API"
        label.numberOfLines = 4
        return label
    }()
    
    //text field
    var searchBar: UITextField = {
        let search = UITextField()
        search.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        search.borderStyle = UITextField.BorderStyle.roundedRect
        search.keyboardType = UIKeyboardType.default
        search.autocorrectionType = UITextAutocorrectionType.no
        search.returnKeyType = UIReturnKeyType.done
        search.clearButtonMode = UITextField.ViewMode.whileEditing
        search.contentVerticalAlignment = UIControl.ContentVerticalAlignment.center
        search.text = "Dogs"
        
        return search
    }()
    
    //button validate research
    var validateButton: UIButton = {
       let button = UIButton()
        button.setTitle("Search", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.tintColor = UIColor.blue
        button.backgroundColor = UIColor.systemBlue
        return button
    }()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Search for images"
        view.backgroundColor = .white
        searchBar.delegate = self
        validateButton.addTarget(self, action: #selector(searchButtonPushed), for: .touchUpInside)
        
        view.addSubview(searchBar)
        view.addSubview(explanationLabel)
        view.addSubview(validateButton)
        
        setupConstraint()
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentText = textField.text ?? ""
        guard let stringRange = Range(range, in: currentText) else { return false }
        let updatedText = currentText.replacingCharacters(in: stringRange, with: string).lowercased()
        self.sizedCurrentText = updatedText.replacingOccurrences(of: " ", with: "+")
        return updatedText.count <= 100
    }
    
    @objc func searchButtonPushed() {
        //call for api searched ?
        let calls = ImageAPI()
        let VC = ImagesViewController()
        Task.detached {
            try await prepareCollectionView()
        }
        
        func prepareCollectionView() async throws {
            do {
                try await calls.searchImages(search: self.sizedCurrentText)
                if calls.imagesFound[0].hits.isEmpty {
                    let ac = UIAlertController(title: "No image found", message: "Please select another wording/sentence", preferredStyle: .alert)
                    ac.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
                    navigationController?.present(ac, animated: true, completion: nil)
                    return
            } else {
                VC.imagesSearch = calls.imagesFound
                navigationController?.pushViewController(VC, animated: true)
            }
            } catch {
                print(error)
            }
        }
    }
        
    func setupConstraint() {
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        explanationLabel.translatesAutoresizingMaskIntoConstraints = false
        validateButton.translatesAutoresizingMaskIntoConstraints = false
        
        let viewConstraints = [
            explanationLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            explanationLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            explanationLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            explanationLabel.heightAnchor.constraint(equalToConstant: 100),
            
            searchBar.topAnchor.constraint(equalTo: explanationLabel.topAnchor, constant: 120),
            searchBar.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            searchBar.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            searchBar.heightAnchor.constraint(equalToConstant: 50),
            
            validateButton.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 30),
            validateButton.leadingAnchor.constraint(equalTo: searchBar.leadingAnchor, constant: 30),
            validateButton.widthAnchor.constraint(equalToConstant: 200),
            
        ]
        NSLayoutConstraint.activate(viewConstraints)
    }


}

