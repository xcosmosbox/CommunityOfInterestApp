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
    func parseUserCardViewList()
    func getCurrentUserUID() -> String
    func getCurrentUserFollowing(completion: @escaping ([DocumentReference]) -> Void) async
    func getCurrentUserFollower(completion: @escaping ([DocumentReference]) -> Void) async
    
    // person page data init
//    func getUserModel() -> User
    func getUserModel(completion: @escaping (User) -> Void)
    func getCardModel(cardRef: DocumentReference, completion: @escaping (Card) -> Void)
    func getUserModelByDocRef(userDocRef: DocumentReference, completion: @escaping (User) -> Void)
    func getUserPostsListByDocRefArray(postsRefArray:[DocumentReference], completion: @escaping ([Card]) -> Void)
    
    
    // image
    var currentImages:[UIImage] {get}
    var currentImagesCounter:Int {get}
    func saveCurrentImagesAsDraft(images:[UIImage])
    func clearCurrentImages()
    func uploadCurrentImagesForCard(title: String, content: String, selectedTags: [String], completion: @escaping (DocumentReference, Card) -> Void)
    func addPostIntoUser(postDocRef: DocumentReference)
    
    // likes & collections operations
    func addPostToUserLikesField(id: String, completion: @escaping () -> Void)
    func addPostToUserCollectionsField(id: String, completion: @escaping () -> Void)
    
    // update user info
    func updateUserProfileImage(image: UIImage, completion: @escaping () -> Void)
    func updateUserName(name: String, completion: @escaping () -> Void)
    func updateUserProfileContent(content: String, completion: @escaping () -> Void)
    
    // others user page
    func addUserIntoFollowing(otherUserDocRef: DocumentReference, completion: @escaping () -> Void) async
    func addMeIntoSomeoneFollower(otherUserDocRef: DocumentReference, completion: @escaping () -> Void) async
    
    // search page
    func fetchPostsForSearch(serachType:String, searchText:String, pageSize:Int, currentDocument: DocumentSnapshot?, completion: @escaping ([Card], DocumentSnapshot) -> Void)
    
    
    
}











