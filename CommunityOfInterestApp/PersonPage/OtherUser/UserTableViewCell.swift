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
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    func setupWithUser(userDocRef: DocumentReference, showFollowButton: Bool) {
        self.userDocRef = userDocRef
        Task{
            do{
                await print(try userDocRef.getDocument().data() ?? "!!!!!!")
                let dataCol = try await userDocRef.getDocument().data()
                if let dataCol = dataCol{
                    DispatchQueue.main.async {
                        self.usernameLabel.text = dataCol["name"] as? String
                        let path = dataCol["profile_image"] as? String
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
                    }
                    self.followButton.isHidden = !showFollowButton

                    if showFollowButton {
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
                } catch{
                    print(error)
                }
            }
        } else{
            Task{
                do{
                    try await databaseController?.addUserIntoFollowing(otherUserDocRef: userDocRef!){ () in
                        self.followButton.setTitle("Following", for: .normal)
                        self.followButton.backgroundColor = .gray
                    }
                } catch {
                    print(error)
                }
            }
        }
            
        
    }
    
    
    
}
