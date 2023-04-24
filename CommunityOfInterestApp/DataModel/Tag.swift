//
//  Tag.swift
//  CommunityOfInterestApp
//
//  Created by Yuxiang Feng on 25/4/2023.
//

import UIKit
import FirebaseFirestoreSwift

class Tag: NSObject, Codable {
    
    @DocumentID var id: String?
    var name: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
    }
    
}
