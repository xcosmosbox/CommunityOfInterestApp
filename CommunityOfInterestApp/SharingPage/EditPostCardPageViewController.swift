//
//  EditPostCardPageViewController.swift
//  CommunityOfInterestApp
//
//  Created by Yuxiang Feng on 8/5/2023.
//

import UIKit

class EditPostCardPageViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UITextViewDelegate {

    // Properties
    var imagesArray: [UIImage] = []
    var collectionView: UICollectionView!
    var titleTextField: UITextField!
    var contentTextView: UITextView!
    var tagButtons: [UIButton] = []
    
//    let tags = ["Food", "Pet", "Travel"] // tags
    let tags = ["Travel"] // tags
    
    weak var databaseController: DatabaseProtocol?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.databaseController
        
        imagesArray = databaseController!.currentImages
        
        setupCollectionView()
        setupTextFieldsAndTagButtons()
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        imagesArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCell", for: indexPath) as! ImageCell
        cell.imageView.image = imagesArray[indexPath.item]
        return cell
    }
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    
    
    
    //Setting the collection view
    func setupCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 10
        layout.minimumInteritemSpacing = 10
        layout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        layout.itemSize = CGSize(width: (UIScreen.main.bounds.width - 40) / 3, height: (UIScreen.main.bounds.width - 40) / 3)
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(ImageCell.self, forCellWithReuseIdentifier: "ImageCell")
        collectionView.backgroundColor = .white
        
        view.addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.heightAnchor.constraint(equalToConstant: UIScreen.main.bounds.width)
        ])
    }
    
    
    func setupTextFieldsAndTagButtons() {
        titleTextField = UITextField()
        titleTextField.placeholder = "Please type the title"
        
        contentTextView = UITextView()
        contentTextView.text = "Please type the content"
        contentTextView.textColor = .lightGray
        contentTextView.delegate = self
        
        // set the deafult height for content text view
        contentTextView.heightAnchor.constraint(equalToConstant: 150).isActive = true
        
        for tag in tags {
            let button = UIButton()
            button.setTitle(tag, for: .normal)
            button.setTitleColor(.black, for: .normal)
            button.layer.borderWidth = 1
            button.layer.borderColor = UIColor.black.cgColor
            button.addTarget(self, action: #selector(tagButtonTapped(_:)), for: .touchUpInside)
            tagButtons.append(button)
        }
        
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 10
        
        stackView.addArrangedSubview(titleTextField)
        stackView.addArrangedSubview(contentTextView)
        
        let tagsStackView = UIStackView()
        tagsStackView.axis = .horizontal
        tagsStackView.spacing = 10
        tagsStackView.distribution = .fillEqually
        
        for button in tagButtons {
            tagsStackView.addArrangedSubview(button)
        }
        
        // Add “Add Tag” button
        let addTagButton = UIButton()
        addTagButton.setTitle("+ Add Tag", for: .normal)
        addTagButton.setTitleColor(.blue, for: .normal)
        addTagButton.addTarget(self, action: #selector(addTagButtonTapped), for: .touchUpInside)
        tagsStackView.addArrangedSubview(addTagButton)
        
        stackView.addArrangedSubview(tagsStackView)
        
        view.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            stackView.topAnchor.constraint(equalTo: collectionView.bottomAnchor, constant: 20)
        ])
    }

    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == "Please type the content" {
            textView.text = ""
            textView.textColor = .black
        }
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Please type the content"
            textView.textColor = .lightGray
        }
    }

    
    @objc func tagButtonTapped(_ sender: UIButton) {
        if sender.backgroundColor == .lightGray {
            sender.backgroundColor = .white
            sender.setTitleColor(.black, for: .normal)
        } else {
            sender.backgroundColor = .lightGray
            sender.setTitleColor(.white, for: .normal)
        }
    }
    
    @objc func addTagButtonTapped() {
        let alertController = UIAlertController(title: "Add New Tag", message: "Please type new tag", preferredStyle: .alert)
        
        alertController.addTextField { (textField) in
            textField.placeholder = "New Tag"
        }
        
        let addAction = UIAlertAction(title: "Add", style: .default) { [weak self] _ in
            guard let self = self else { return }
            if let textField = alertController.textFields?.first, let newTag = textField.text, !newTag.isEmpty {
                self.addNewTag(tag: newTag)
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alertController.addAction(addAction)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true, completion: nil)
    }

    
//    func addNewTag(tag: String) {
//        let button = UIButton()
//        button.setTitle(tag, for: .normal)
//        button.setTitleColor(.white, for: .normal)
//        button.backgroundColor = .lightGray
//        button.layer.borderWidth = 1
//        button.layer.borderColor = UIColor.black.cgColor
//        button.addTarget(self, action: #selector(tagButtonTapped(_:)), for: .touchUpInside)
//        tagButtons.append(button)
//
//        if let tagsStackView = tagButtons.last?.superview as? UIStackView {
//            tagsStackView.insertArrangedSubview(button, at: tagButtons.count - 1)
//        }
//    }
    func addNewTag(tag: String) {
        let button = UIButton()
        button.setTitle(tag, for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .lightGray
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.black.cgColor
        button.addTarget(self, action: #selector(tagButtonTapped(_:)), for: .touchUpInside)
        tagButtons.append(button)
        
        if let tagsStackView = tagButtons.first?.superview as? UIStackView {
            tagsStackView.insertArrangedSubview(button, at: tagButtons.count - 2)
        }
    }




    
    
    
}
