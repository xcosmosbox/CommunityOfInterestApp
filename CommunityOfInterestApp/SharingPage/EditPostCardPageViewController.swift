//
//  EditPostCardPageViewController.swift
//  CommunityOfInterestApp
//
//  Created by Yuxiang Feng on 8/5/2023.
//

import UIKit
import CoreLocation

class EditPostCardPageViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UITextViewDelegate, UICollectionViewDelegateFlowLayout, UITextFieldDelegate, CLLocationManagerDelegate {

    // Properties
    var imagesArray: [UIImage] = []
    var collectionView: UICollectionView!
    var titleTextField: UITextField!
    var contentTextView: UITextView!
    var uploadButton = UIButton()
    var tagButtons: [UIButton] = []
    var APIUseStack: UIStackView = UIStackView()
    let weatherSwitch = UISwitch()
    var weatherInfo: Int?
    var weatherLocation: String?
    var pushTime: String?
    var pushInfo: (temp_c:Int, location:String, pushTime:String)? = nil
    var locationManager = CLLocationManager()
    
    private var activityIndicator: UIActivityIndicatorView!
    private var timer: Timer?
    
    // set the default tags
    let tags = ["Food", "Pet", "Travel", "Nature", "Game", "Sport", "Music"] // tags
    
    var selectedCard: Card?
    
    weak var databaseController: DatabaseProtocol?

    override func viewDidLoad() {
        super.viewDidLoad()

        // implements the CLLocationManagerDelegate
        locationManager.delegate = self
        let status = locationManager.authorizationStatus
        if status == .notDetermined{
            locationManager.requestWhenInUseAuthorization()
        }
        locationManager.startUpdatingLocation()
        
        // Do any additional setup after loading the view.
        
        // get the database controller instance
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.databaseController
        
        // set the images Array
        imagesArray = databaseController!.currentImages
        
        // setup
        setupCollectionView()
        setupWeatherButton()
        setupTextFieldsAndTagButtons()
        
        // set the indicator
        activityIndicator = UIActivityIndicatorView(style: .medium)
        activityIndicator.center = view.center
        view.addSubview(activityIndicator)
    }
    
    func setupWeatherButton() {
        
        // setup weather switch button
        var apiUseLabel = UILabel()
        apiUseLabel.text = "Add Weather Into Post"
        apiUseLabel.textColor = .systemGray2
        weatherSwitch.layer.cornerRadius = 5
        weatherSwitch.addTarget(self, action: #selector(weatherButtonTapped), for: .touchUpInside)
        
        // set the subview
        self.APIUseStack.addArrangedSubview(apiUseLabel)
        self.APIUseStack.addArrangedSubview(weatherSwitch)

        // adjust the constraints
        view.addSubview(self.APIUseStack)
        self.APIUseStack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.APIUseStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            self.APIUseStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            self.APIUseStack.topAnchor.constraint(equalTo: collectionView.bottomAnchor, constant: 10)
        ])
    }

    // selector
    @objc func weatherButtonTapped() {
        weatherSwitch.isSelected = !weatherSwitch.isSelected
        if weatherSwitch.isSelected {
            fetchWeatherInfo()
        } else {
            weatherInfo = nil
        }
    }

    func fetchWeatherInfo() {
        // nothing to do
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        // using the weather API to get the weather info and push time and push location
        if let location = locations.first {
            let appDelegate = UIApplication.shared.delegate as? AppDelegate
            var apiLink = appDelegate?.getAPIInfo()
            var api = apiLink! + "&q=\(location.coordinate.latitude),\(location.coordinate.longitude)&aqi=no"
            let url = URL(string: api)!
            let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
                if let data = data {
                    do {
                        // get the result json
                        let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as! [String: Any]
                        let current = json["current"] as! [String: Any]
                        self.weatherInfo = current["temp_c"] as? Int
                        let location = json["location"] as! [String : Any]
                        self.weatherLocation = location["tz_id"] as? String
                        self.pushTime = location["localtime"] as? String
                        if let weather_c = self.weatherInfo, let currtLocation = self.weatherLocation, let time = self.pushTime{
                            self.pushInfo = (temp_c:weather_c, location:currtLocation, pushTime:time)
                        }
                    } catch {
                        print(error)
                    }
                }
            }
            task.resume()
        }
        manager.stopUpdatingLocation()
    }

    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imagesArray.count
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
        collectionView.backgroundColor = .systemBackground
        
        view.addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.heightAnchor.constraint(equalToConstant: UIScreen.main.bounds.width-40)
        ])
    }
    
    // setup the text fields and tag buttons
    func setupTextFieldsAndTagButtons() {
        titleTextField = UITextField()
        titleTextField.placeholder = "Please type the title"
        titleTextField.delegate = self
        
        contentTextView = UITextView()
        contentTextView.text = "Please type the content"
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
            stackView.topAnchor.constraint(equalTo: self.APIUseStack.bottomAnchor, constant: 20)
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
    
    // the title, content and tag must have at least content to publish the post
    func updateUploadButtonState() {
        let isTitleFilled = !(titleTextField.text?.isEmpty ?? true)
        let isContentFilled = !contentTextView.text.isEmpty
        let isTagSelected = tagButtons.contains(where: { $0.isSelected })
        let hasImages = collectionView.numberOfItems(inSection: 0) > 0

        if isTitleFilled && isContentFilled && isTagSelected && hasImages {
            uploadButton.isEnabled = true
            uploadButton.backgroundColor = .red
        } else {
            uploadButton.isEnabled = false
            uploadButton.backgroundColor = .gray
        }
    }
    
    @objc func uploadButtonTapped() {
        activityIndicator.startAnimating()
        timer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: true){ _ in
            let selectedTags = self.tagButtons.filter { $0.isSelected }.map { $0.title(for: .normal)! }
            // upload the post
            self.databaseController?.uploadCurrentImagesForCard(title: self.titleTextField.text!, content: self.contentTextView.text, selectedTags: selectedTags, weatherInfo: self.pushInfo) { (documentReference, createdCard) in
                
                // refresh the local cache
                self.databaseController!.getCommunityContentByTag(tagNmae: " Explore ")
                
                // add post into user
                self.databaseController?.addPostIntoUser(postDocRef: documentReference)
                
                // creat the card and jump to the home page
                self.databaseController!.getCardModel(cardRef: documentReference){ card in
                    self.timer?.invalidate()
                    
                    self.selectedCard = card
                    
                    // Navigate to DetailViewController
                    self.navigateToDetailViewController()
                }
                
            }
        }
    }
    
    // jump to the home page
    func navigateToDetailViewController() {
        let storyboard = UIStoryboard(name: "HomePageMain", bundle: nil)
        if let pageNavController = storyboard.instantiateViewController(withIdentifier: "HomePageMainNavigationC") as? UINavigationController {
            if let sceneDelegate = self.view.window?.windowScene?.delegate as? SceneDelegate {
                sceneDelegate.window?.rootViewController = pageNavController
            }
        }
        
    }


    // should change characters in range
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        DispatchQueue.main.async {
            self.updateUploadButtonState()
        }
        return true
    }
    
    // update the upload button state
    func textViewDidChange(_ textView: UITextView) {
        updateUploadButtonState()
    }
    
    // begin editing
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == "Please type the content" {
            textView.text = ""
            textView.textColor = UIColor(named: "TextViewColor")
        }
    }

    // end editing
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Please type the content"
            textView.textColor = UIColor(named: "TextViewColor")
        }
    }

    // select the tag button
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


    // create the "Add New Tag" button
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

    // user can add new tag
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
