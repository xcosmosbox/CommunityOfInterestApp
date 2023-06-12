//
//  CardView.swift
//  CommunityOfInterestApp
//
//  Created by Yuxiang Feng on 11/4/2023.
//

import UIKit
import FirebaseStorage

// card view
class CardView: UIStackView {
    
    let usernameStack = UIStackView()
    let titleLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 180, height: 30))
    var like: UIImageView! = nil
    var postImageView: UIImageView! = nil
    var card: Card?
    
    static let cardHight = CGFloat(250)
    static let cardWidth = CGFloat(180)
    
    weak var databaseController: DatabaseProtocol?
    
    let appDelegate = UIApplication.shared.delegate as? AppDelegate
    weak var homePageController: UIViewController?
    
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    /**
     CardView is composed of many different parts.
     CardView as a whole is a VStack, in which there are three HStacks from top to bottom.
     The first HStack stores a UIImageView, and the UIImageView has a scaled image.
     There is a Label in the second HStack, which is used to stored the title.
     There are two Views in the third HStack from left to right. On the left is a Label and on the right is a UIImage.
     */
    func build(username:String, title: String, imagePath: String, homepageViewControl: UIViewController, card: Card) -> CardView {
        
        databaseController = appDelegate?.databaseController
        
        self.homePageController = homepageViewControl
        self.card = card
        // set itself
        self.axis = .vertical
        self.alignment = .leading
        self.spacing = 0
        self.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.widthAnchor.constraint(equalToConstant: CardView.cardWidth),
            self.heightAnchor.constraint(equalToConstant: CardView.cardHight)
        ])
        
        // set usernameStack
        usernameStack.axis = .horizontal
        usernameStack.axis = .horizontal
        usernameStack.alignment = .trailing
        usernameStack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            usernameStack.widthAnchor.constraint(equalToConstant: CardView.cardWidth),
            usernameStack.heightAnchor.constraint(equalToConstant: 20)
        ])
        
        // build username label
        let name = UILabel()
        name.text = username
        name.sizeToFit()
        
        // build title label
        titleLabel.text = title
        titleLabel.font = UIFont.boldSystemFont(ofSize: 16)
        titleLabel.numberOfLines = 0
        
        // build post image
        postImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: CardView.cardWidth, height: 200))
        postImageView?.contentMode = .scaleAspectFill
        postImageView?.clipsToBounds = true
        
        // create the image obj
        // download image from firebase Storage
        let gsReference = Storage.storage().reference(forURL: imagePath)
        gsReference.getData(maxSize: 10 * 1024 * 1024){ data, error in
            if let error = error{
                print("error!: \(error)")
            } else{
                let postImage = UIImage(data: data!)
                // zoom in and out the image
                let scaledImage = postImage?.scaledImage(toSize: CGSize(width: CardView.cardWidth, height: 200))
                // set the post image view's image
                self.postImageView?.image = scaledImage
            }
        }
        
        Task{
            do{
                // build like symbol
                databaseController!.checkIsLikeCard(card: self.card!) { isLiked in
                    DispatchQueue.main.async {
                        if isLiked {
                            let con = UIImage.SymbolConfiguration(hierarchicalColor: .red)
                            var img = UIImage(systemName: "heart.fill", withConfiguration: con)?.withTintColor(.red)
                            // build UIImageView
                            self.like = UIImageView(image: img)
                            // setting UIImageView's contentMode
                            self.like?.contentMode = .scaleAspectFit
                        } else {
                            // create SymbolConfiguration
                            let config = UIImage.SymbolConfiguration(pointSize: 20, weight: .regular, scale: .default)
                            // build UIImage
                            let image = UIImage(systemName: "heart", withConfiguration: config)
                            // build UIImageView
                            self.like = UIImageView(image: image)
                            // setting UIImageView's contentMode
                            self.like?.contentMode = .scaleAspectFit
                        }
                        
                        // build up it self
                        self.usernameStack.addArrangedSubview(name)
                        self.usernameStack.addArrangedSubview(self.like)
                        self.addArrangedSubview(self.postImageView)
                        self.addArrangedSubview(self.titleLabel)
                        self.addArrangedSubview(self.usernameStack)
                        
                        self.addTapGestureToStackView()
                    }
                }
            }
        }
        return self
    }
    
    
    // add a tap gesture to stack view
    // we allowed to click the card and jump to the detail page
    func addTapGestureToStackView(){
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(stackViewTapped))
        self.addGestureRecognizer(tapGestureRecognizer)
        self.isUserInteractionEnabled = true
    }
    
    // selector
    @objc func stackViewTapped() {
        guard let homeController = homePageController as? DetailChangeDelegate else{
            return
        }
        databaseController?.setOneCardCache(card: self.card!)
        homeController.loadCardDetail(self.card!)
    }
    
    
    

    
}


extension UIImage {
    // Use this function to ensure that the images in each card view are the same size
    func scaledImage(toSize newSize: CGSize) -> UIImage? {
        let aspectRatio = self.size.width / self.size.height
        let newHeight = newSize.width / aspectRatio
        let newSize = CGSize(width: newSize.width, height: newHeight)

        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)
        self.draw(in: CGRect(origin: CGPoint.zero, size: newSize))

        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return newImage
    }
}
