//
//  CardFactory.swift
//  CommunityOfInterestApp
//
//  Created by Yuxiang Feng on 11/4/2023.
//

import Foundation
import UIKit


class CardFactory{
    
    func buildACardView(username:String, title: String, imagePath: String) -> CardView{
        return CardView().build(username: username, title: title, imagePath: imagePath)
    }
    
    
    func ONLY_TEST_BUILD_CARD() -> [CardView] {
        var list:[CardView] = []
        
        for i in 1...20{
            list.append(CardView().build(username:"UsernameU" , title: "Title\(i) Title This is a Large Title Large Title Lalllllll", imagePath: "food_0.pic"))
        }
        
        return list
    }
}
