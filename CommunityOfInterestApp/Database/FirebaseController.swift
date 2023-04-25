//
//  FirebaseController.swift
//  CommunityOfInterestApp
//
//  Created by Yuxiang Feng on 25/4/2023.
//

import UIKit
import Firebase
import FirebaseFirestoreSwift
import FirebaseStorage

class FirebaseController: NSObject, DatabaseProtocol {
    
    var defaultTags: [Tag] = []
    var currentCards: [Card] = []
    var listeners = MulticastDelegate<DatabaseListener>()
    
    // reference to firebase
    var authController: Auth
    var database: Firestore
    var deafultTagRef: CollectionReference?
    var postRef: CollectionReference?
    var userRef: CollectionReference?
    var currentUser: FirebaseAuth.User?
    
    override init() {
        FirebaseApp.configure()
        authController = Auth.auth()
        database = Firestore.firestore()
        
        super.init()
        
        // anonymous sign in
        Task{
            do {
                let authDataResult = try await authController.signInAnonymously()
                currentUser = authDataResult.user
            }
            catch {
                // sign in failed
                fatalError("Firebase Authentication Failed with Error \(String(describing: error))")
            }
            
            // sign in success
            self.setupDefaultTags()
        }
    }

    
    
    func cleanup() {
        // nothing to do
    }
    
    func addListener(listener: DatabaseListener) {
        listeners.addDelegate(listener)
        
        if listener.listenerType == .tag || listener.listenerType == .all{
            listener.onTagChange(change: .update, tags: self.defaultTags)
        }
        
        if listener.listenerType == .explore || listener.listenerType == .all{
            listener.onExploreChange(change: .update, cards: self.currentCards)
        }
        
        
    }
    
    func removeListener(listener: DatabaseListener) {
        <#code#>
    }
    
    
    
    func addTag(name: String) -> Tag {
        <#code#>
    }
    
    func deleteTag(tag: Tag) {
        <#code#>
    }
    
    
    
    func addCard(card: Card) -> Card {
        <#code#>
    }
    
    func deleteCard(card: Card) {
        <#code#>
    }
    
    
    
    func setupDefaultTags(){
        
        deafultTagRef = database.collection("default_tag")
        deafultTagRef?.addSnapshotListener(){
            (querySnapshot, error) in
            
            guard let querySnapshot = querySnapshot else{
                print("Failed to fetch documents with error: \(String(describing: error))")
                return
            }
            
            self.parseTagsSnapshot(snapshot: querySnapshot)
            
            if self.postRef == nil{
                self.setupCurrentCards()
            }
            
            
        }
        
    }
    
    
    func setupCurrentCards() {
        
        self.currentCards = [Card]()
        
        
        
        
    }
    
    
    func parseTagsSnapshot(snapshot: QuerySnapshot){
        snapshot.documentChanges.forEach{ (change) in
            
            var parsedTag: Tag?
            
            do {
                parsedTag = try change.document.data(as: Tag.self)
                print(parsedTag?.name)
            } catch {
                print("Unable to decode tag. Is the tag malformed?")
                return
            }
            
            guard let tag = parsedTag else{
                print("Document doesn't exist")
                return
            }
            
            if change.type == .added{
                print(defaultTags)
                defaultTags.insert(tag, at: Int(change.newIndex))
            } else if change.type == .modified{
                defaultTags[Int(change.oldIndex)] = tag
            } else if change.type == .removed {
                defaultTags.remove(at: Int(change.oldIndex))
            }
            
            listeners.invoke{ (listener) in
                if listener.listenerType == ListenerType.tag || listener.listenerType == ListenerType.all{
                    listener.onTagChange(change: .update, tags: self.defaultTags)
                }
                
            }
            
            
            
        }
    }
    
    
    
    
    
}
