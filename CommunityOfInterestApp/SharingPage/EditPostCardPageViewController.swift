//
//  EditPostCardPageViewController.swift
//  CommunityOfInterestApp
//
//  Created by Yuxiang Feng on 8/5/2023.
//

import UIKit

class EditPostCardPageViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UITextViewDelegate, UICollectionViewDelegateFlowLayout, UITextFieldDelegate {

    // Properties
    var imagesArray: [UIImage] = []
    var collectionView: UICollectionView!
    var titleTextField: UITextField!
    var contentTextView: UITextView!
    var uploadButton = UIButton()
    var tagButtons: [UIButton] = []
    
    let tags = ["Food", "Pet", "Travel", "Nature", "Game", "Sport", "Music"] // tags
    
    var selectedCard: Card?
    
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
        titleTextField.delegate = self
        
        contentTextView = UITextView()
        contentTextView.text = "Please type the content"
        contentTextView.textColor = .lightGray
        contentTextView.delegate = self
        
        // set the deafult height for content text view
        contentTextView.heightAnchor.constraint(equalToConstant: 150).isActive = true
        
        for tag in tags {
            let button = UIButton()
            button.backgroundColor = .gray
            button.setTitle(tag, for: .normal)
            button.setTitleColor(.white, for: .normal)
            button.layer.borderWidth = 1
            button.layer.borderColor = UIColor.black.cgColor
            button.addTarget(self, action: #selector(tagButtonTapped(_:)), for: .touchUpInside)
            button.isSelected = false
            tagButtons.append(button)
        }
        
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 3
        
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
        addTagButton.widthAnchor.constraint(equalToConstant: 100).isActive = true
        tagsStackView.addArrangedSubview(addTagButton)
        
        let tagsScrollView = UIScrollView()
        tagsScrollView.showsHorizontalScrollIndicator = false
        tagsScrollView.addSubview(tagsStackView)
        

        stackView.addArrangedSubview(tagsScrollView)
        

        uploadButton.setTitle("POST", for: .normal)
        uploadButton.setTitleColor(.white, for: .normal)
        uploadButton.backgroundColor = .gray
        uploadButton.layer.cornerRadius = 5
        uploadButton.isEnabled = false
        uploadButton.addTarget(self, action: #selector(uploadButtonTapped), for: .touchUpInside)
        stackView.addArrangedSubview(uploadButton)

        
        view.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            stackView.topAnchor.constraint(equalTo: collectionView.bottomAnchor, constant: 20)
        ])
        
        tagsStackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tagsStackView.leadingAnchor.constraint(equalTo: tagsScrollView.leadingAnchor),
            tagsStackView.trailingAnchor.constraint(equalTo: tagsScrollView.trailingAnchor),
            tagsStackView.topAnchor.constraint(equalTo: tagsScrollView.topAnchor),
            tagsStackView.bottomAnchor.constraint(equalTo: tagsScrollView.bottomAnchor),
            tagsStackView.heightAnchor.constraint(equalTo: tagsScrollView.heightAnchor)
        ])
        
    }
    
    func updateUploadButtonState() {
        let isTitleFilled = !(titleTextField.text?.isEmpty ?? true)
        let isContentFilled = !contentTextView.text.isEmpty
        let isTagSelected = tagButtons.contains(where: { $0.isSelected })
        let hasImages = collectionView.numberOfItems(inSection: 0) > 0
        
//        print("=========")
//        print("isTitleFilled: \(isTitleFilled)")
//        print("isContentFilled: \(isContentFilled)")
//        print("isTagSelected: \(isTagSelected)")
//        print("hasImages: \(hasImages)")
//        print("=========")

        if isTitleFilled && isContentFilled && isTagSelected && hasImages {
            uploadButton.isEnabled = true
            uploadButton.backgroundColor = .red
        } else {
            uploadButton.isEnabled = false
            uploadButton.backgroundColor = .gray
        }
    }
    
    @objc func uploadButtonTapped() {
        let selectedTags = tagButtons.filter { $0.isSelected }.map { $0.title(for: .normal)! }

        databaseController?.uploadCurrentImagesForCard(title: titleTextField.text!, content: contentTextView.text, selectedTags: selectedTags) { (documentReference, createdCard) in
            
            print(createdCard.id)
            print(createdCard.picture)
            print(createdCard.cover)
            print(createdCard.username)
            print(createdCard.title)
            print(createdCard.content)
            
            // process the upload success content, such as go to the detail page
            print("upload success")
            // Save the created card object
            self.selectedCard = createdCard
            // Navigate to DetailViewController
            self.navigateToDetailViewController()
            
        }
    }
    
    
    func navigateToDetailViewController() {
        if let detailViewController = UIStoryboard(name: "HomePageMain", bundle: nil).instantiateViewController(withIdentifier: "DetailViewController") as? DetailViewController {
            
            // Call setOneCardCache(card: Card) from FirebaseController
            databaseController?.setOneCardCache(card: self.selectedCard!)
            
            detailViewController.card = self.selectedCard

            
            // Find the tabBarController and navigate to the first tab
            if let tabBarController = self.navigationController?.tabBarController {
                tabBarController.selectedIndex = 0

                // Get the HomePageViewController and its navigationController
                if let homePageNavigationController = tabBarController.viewControllers?.first as? UINavigationController,
                    let homePageViewController = homePageNavigationController.topViewController as? HomePageViewController {
                    self.navigationController?.popToRootViewController(animated: false)

                    // Push the DetailViewController onto HomePageViewController's navigationController
                    homePageNavigationController.pushViewController(detailViewController, animated: true)
                }
            }
        }
    }

    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        DispatchQueue.main.async {
            self.updateUploadButtonState()
        }
        return true
    }
    
    func textViewDidChange(_ textView: UITextView) {
        updateUploadButtonState()
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
        if sender.backgroundColor == .gray {
            sender.backgroundColor = .systemBlue
            sender.setTitleColor(.white, for: .normal)
            sender.isSelected = true
        } else {
            sender.backgroundColor = .gray
            sender.setTitleColor(.white, for: .normal)
            sender.isSelected = false
        }
        updateUploadButtonState()
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
        
        updateUploadButtonState()
    }

 
    func addNewTag(tag: String) {
        
        let button = UIButton()
        button.backgroundColor = .systemBlue
        button.setTitle(tag, for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.black.cgColor
        button.addTarget(self, action: #selector(tagButtonTapped(_:)), for: .touchUpInside)
        button.isSelected = true
        
        tagButtons.append(button)
        
        if let tagsStackView = tagButtons.first?.superview as? UIStackView {
            tagsStackView.insertArrangedSubview(button, at: tagButtons.count - 2)
        }
        
        updateUploadButtonState()
    }




    
    
    
}
