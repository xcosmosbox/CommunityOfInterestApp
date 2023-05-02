//
//  DatabaseProtocol.swift
//  CommunityOfInterestApp
//
//  Created by Yuxiang Feng on 25/4/2023.
//

import Foundation
import UIKit
import Firebase

enum DatabaseChange {
    case add
    case remove
    case update
    case reload
}


enum ListenerType{
    case auth
    case explore
    case tag
    case tagAndExp
    case person
    case all
}

protocol DatabaseListener: AnyObject{
    var listenerType: ListenerType{get set}
    func onExploreChange(change: DatabaseChange, cards: [Card])
    func onTagChange(change: DatabaseChange, tags: [Tag])
    func onAuthChange(change: DatabaseChange, userIsLoggedIn: Bool, error: String)
    func onPersonChange(change: DatabaseChange, postsCards:[Card], likesCards:[Card], collectionsCards:[Card])
}

protocol DatabaseProtocol: AnyObject{
    //
    func cleanup()
    func addListener(listener: DatabaseListener)
    func removeListener(listener: DatabaseListener)
    
    // tags
    var defaultTags: [Tag] {get}
    func addTag(name: String) -> Tag
    func deleteTag(tag: Tag)
    
    // explore
    var currentCards: [Card] {get}
    func addCard(card: Card) -> Card
    func deleteCard(card: Card)
    func getCommunityContentByTag(tagNmae: String)
    
    
    // download
//    func downloadImage(path: String) -> Data
    
    // Card Detail Cache Pool
    func setOneCardCache(card: Card)
    func getOneCardCache() -> Card
    
    
    // app login and sign up
    func login(email:String, password:String)
    func signup(newEmail:String, newPassword:String)
    func setupUserSelectedTags(tags: [String]) -> Bool
    
    // person page data init
//    func getUserModel() -> User
    func getUserModel(completion: @escaping (User) -> Void)
    
    
    
}











