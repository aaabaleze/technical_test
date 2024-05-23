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
        
        // get the current text, or use an empty string if that failed
        let currentText = textField.text ?? ""

            // attempt to read the range they are trying to change, or exit if we can't
        guard let stringRange = Range(range, in: currentText) else { return false }

            // add their new text to the existing text
        let updatedText = currentText.replacingCharacters(in: stringRange, with: string).lowercased()
        self.sizedCurrentText = updatedText.replacingOccurrences(of: " ", with: "+")
        print("current: \(self.sizedCurrentText)")

            // make sure the result is under 100 characters
            return updatedText.count <= 100
    }
    
    @objc func searchButtonPushed() {
        print("button is hitted with textfield input : \(self.sizedCurrentText)")
        //call for api searched ?
        let calls = ImageAPI()
        let VC = ImagesViewController()
        Task.detached {
            try await prepareCollectionView()
        }
        // pop up to collection view
        
        func prepareCollectionView() async throws {
            do {
                //search for the images
                try await calls.searchImages(search: self.sizedCurrentText)
                VC.imagesSearch = calls.imagesFound
                navigationController?.pushViewController(VC, animated: true)
                //download images
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

