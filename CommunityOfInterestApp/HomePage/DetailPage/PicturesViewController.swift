//
//  PicturesViewController.swift
//  CommunityOfInterestApp
//
//  Created by Yuxiang Feng on 30/4/2023.
//

import UIKit
import FirebaseStorage

class PicturesViewController: MediaViewController {
    
    let imageView = UIImageView()
//    let image: UIImage
    let imagePath: String
    
    init(imagePath: String) {
        self.imagePath = imagePath
        super.init(mediaURL: imagePath)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
//        var image: UIImage
        
        // download image from firebase Storage
        let gsReference = Storage.storage().reference(forURL: imagePath)
        gsReference.getData(maxSize: 100 * 1024 * 1024){ data, error in
            if let error = error{
                print("error!: \(error)")
            } else{
                let postImage = UIImage(data: data!)
                // zoom in and out the image
//                let scaledImage = postImage?.scaledImage(toSize: CGSize(width: CardView.cardWidth, height: 200))
                // set the post image view's image
                self.imageView.image = postImage
                print("page load!!!! YEEEEEE")
                print(postImage)
            }
        }
        
        
//        imageView.image = image
        imageView.contentMode = .scaleAspectFill
        view.addSubview(imageView)
        
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
                    imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                    imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                    imageView.topAnchor.constraint(equalTo: view.topAnchor),
                    imageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
                ])
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
