//
//  DatabaseProtocol.swift
//  CommunityOfInterestApp
//
//  Created by Yuxiang Feng on 25/4/2023.
//

import Foundation
import UIKit

enum DatabaseChange {
    case add
    case remove
    case update
    case reload
}


enum ListenerType{
    case explore
    case tag
    case tagAndExp
    case postPage
    case all
}

protocol DatabaseListener: AnyObject{
    var listenerType: ListenerType{get set}
    func onExploreChange(change: DatabaseChange, cards: [Card])
    func onTagChange(change: DatabaseChange, tags: [Tag])
    func onImagePageChange(change: DatabaseChange, pageNumber:Int)
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
    
    
    // Image page change
    func updateCurrentImagePageNumber(pageNumber: Int)
    func getCurrentImagePageNumber() -> Int
    
    
}











