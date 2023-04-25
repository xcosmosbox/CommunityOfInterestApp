//
//  User.swift
//  CommunityOfInterestApp
//
//  Created by Yuxiang Feng on 23/4/2023.
//

import UIKit
import FirebaseFirestoreSwift

// A NSobject for user document
class User: NSObject, Codable{
    
    // fields
    @DocumentID var id: String?
    var name: String?
    var profile: String?
    var profile_image: String?
    
    var tags: [TagBean] = []
    
    var posts: [Post] = []
    var likes: [Post] = []
    var collections: [Post] = []
    
    // encode and decode
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case profile
        case profile_image
    }
    

}
