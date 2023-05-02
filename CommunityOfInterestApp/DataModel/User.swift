//
//  User.swift
//  CommunityOfInterestApp
//
//  Created by Yuxiang Feng on 2/5/2023.
//

import UIKit
import FirebaseFirestoreSwift
import Firebase

class User: NSObject {
    @DocumentID var id:String?
    var name: String?
    var profile: String?
    var profile_image: String?
    var tags: [String]?
    var collections: [DocumentReference]?
    var follower: [DocumentReference]?
    var following: [DocumentReference]?
    var likes: [DocumentReference]?
    var posts: [DocumentReference]?
    
}
