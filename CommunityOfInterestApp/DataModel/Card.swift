//
//  Card.swift
//  CommunityOfInterestApp
//
//  Created by Yuxiang Feng on 25/4/2023.
//

import UIKit
import FirebaseFirestoreSwift

class Card: NSObject, Codable {
    @DocumentID var id: String?
    var title: String?
    var cover: String?
    var likes_number: Int?
    var username: String?
    
    
    enum CodingKeys: String, CodingKey{
        case id
        case title
        case cover
        case likes_number
        case username
    }
    
}
