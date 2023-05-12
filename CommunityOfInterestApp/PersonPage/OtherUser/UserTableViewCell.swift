//
//  UserTableViewCell.swift
//  CommunityOfInterestApp
//
//  Created by Yuxiang Feng on 12/5/2023.
//

import UIKit
import FirebaseStorage
import Firebase
import FirebaseFirestoreSwift

class UserTableViewCell: UITableViewCell {
    
    @IBOutlet weak var profileImageView: UIImageView!
    
    @IBOutlet weak var usernameLabel: UILabel!
    
    
    @IBOutlet weak var followButton: UIButton!
    

    var userDocRef: DocumentReference?
    
    weak var databaseController: DatabaseProtocol? = (UIApplication.shared.delegate as? AppDelegate)?.databaseController
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    func setupWithUser(userDocRef: DocumentReference, showFollowButton: Bool) {
        
        self.userDocRef = userDocRef
        
        Task{
            do{
                try await userDocRef.getDocument(){ (snapshot, error) in
                    self.usernameLabel.text = snapshot?.data()!["name"] as? String
                    
                    let path = snapshot?.data()!["profile_image"] as? String
                    
                    // set profile iamge
                    let gsReference = Storage.storage().reference(forURL: path!)
                    gsReference.getData(maxSize: 10 * 1024 * 1024){ data, error in
                        if let error = error{
                            print("error!: \(error)")
                        } else{
                            let userProfileImage = UIImage(data: data!)
                            // set the post image view's image
                            self.profileImageView.image = userProfileImage
                        }
                    }
                    
                    self.followButton.isHidden = !showFollowButton
                    
                    if showFollowButton {
            //            followButton.setTitle(isFollowing ? "Following" : "Follow", for: .normal)
            //            followButton.backgroundColor = isFollowing ? .gray : .red
                        self.followButton.setTitle("Following", for: .normal)
                        self.followButton.backgroundColor = .gray
                    }
                }
            }
        }
        
        
        
    }
    
    
    
    
    
    @IBAction func followButtonTapped(_ sender: Any) {
        if followButton.titleLabel?.text == "Following"{
            Task{
                do{
                    try await databaseController?.addUserIntoFollowing(otherUserDocRef: userDocRef!){ () in
                        self.followButton.setTitle("Follow", for: .normal)
                        self.followButton.backgroundColor = .red
                    }
                }
            }
        } else{
            Task{
                do{
                    try await databaseController?.addUserIntoFollowing(otherUserDocRef: userDocRef!){ () in
                        self.followButton.setTitle("Following", for: .normal)
                        self.followButton.backgroundColor = .gray
                    }
                }
            }
        }
            
        
    }
    
    
    
}
