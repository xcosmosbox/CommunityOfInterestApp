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
                
                // create corresponding user document
                try await database.collection("user").document(currentUser!.uid).setData([
                    "name": "username",
                    
                ])
            }
            catch {
                // sign in failed
                fatalError("Firebase Authentication Failed with Error \(String(describing: error))")
            }
            
            // sign in success
            self.setupDefaultTags()
            
            // init user's tags list
//            do{
//                print("=====hahahahahahaha====")
//                try await database.collection("user").document(currentUser!.uid).updateData([
//                    "tags": FieldValue.arrayUnion(defaultTags)
//                ])
//                print("=====hahahahahahaha====")
//            }
            
        }
    }

    
    
    func cleanup() {
        // nothing to do
    }
    
    func addListener(listener: DatabaseListener) {
        listeners.addDelegate(listener)
        
        if listener.listenerType == .tag || listener.listenerType == .all || listener.listenerType == .tagAndExp{
            listener.onTagChange(change: .update, tags: self.defaultTags)
        }
        
        if listener.listenerType == .explore || listener.listenerType == .all || listener.listenerType == .tagAndExp{
            listener.onExploreChange(change: .update, cards: self.currentCards)
        }
        
        
    }
    
    func removeListener(listener: DatabaseListener) {
        listeners.removeDelegate(listener)
    }
    
    
    
    func addTag(name: String) -> Tag {
        let tag = Tag()
        tag.name = name
        
        // add one tag for firestore
        // only for dev level, will be modified in the future
        database.collection("user").document(currentUser!.uid).updateData([
            "tags": FieldValue.arrayUnion([tag.name!])
        ]) {
            error in
            
            if let error = error {
                print("add new tag error: \(error)")
            } else {
                print("add new tag successfully")
            }
        }
        
        // add one tag on local
        self.defaultTags.append(tag)
        
        return tag
        
    }
    
    
    func deleteTag(tag: Tag) {
        // delete one tag for firestore
        database.collection("user").document(currentUser!.uid).updateData([
            "tags": FieldValue.arrayRemove([tag.name])
        ]){ error in
            if let error = error{
                print("delete a tag error: \(error)")
            } else {
                print("delete a tag successfully")
            }
        }
        
        // delete one tag on local
        self.defaultTags.removeAll(where: {$0.name == tag.name})
        
    }
    
    
    
    func addCard(card: Card) -> Card {
        // milestone 2
        let card = Card()
        return card
    }
    
    func deleteCard(card: Card) {
        // milestone 2
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
        
        postRef = database.collection("post")
        postRef?.limit(to: 15).getDocuments{ (querySnapshot, error) in
            
            guard let querySnapshot = querySnapshot else{
                print("Failed to get documents with error: \(String(describing: error))")
                return
            }
            
            self.parseCardsSnapshot(snapshot: querySnapshot)
            
        }
        
        
        
        
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
            
            database.collection("user").document(currentUser!.uid).updateData([
                "tags": FieldValue.arrayUnion([tag.name!])
            ])
            
            listeners.invoke{ (listener) in
                if listener.listenerType == ListenerType.tag || listener.listenerType == ListenerType.all || listener.listenerType == .tagAndExp{
                    listener.onTagChange(change: .update, tags: self.defaultTags)
                }
                
            }
            
            
            
        }
    }
    
    
    func parseCardsSnapshot(snapshot: QuerySnapshot){
        
        snapshot.documentChanges.forEach{ (change) in
            
            var parsedCard: Card?
            
            do{
                parsedCard = try change.document.data(as: Card.self)
                print(parsedCard?.cover)
            } catch {
                print("Unable to decode card. Is the card malformed?")
                return
            }
            
            guard let card = parsedCard else{
                print("Document doesn't exits")
                return
            }
            
            if change.type == .added{
                print(currentCards)
                currentCards.insert(card, at: Int(change.newIndex))
            } else if change.type == .modified{
                currentCards[Int(change.oldIndex)] = card
            } else if change.type == .removed {
                currentCards.remove(at: Int(change.oldIndex))
            }
            
//            listeners.invoke{ (listener) in
//                if listener.listenerType == ListenerType.explore || listener.listenerType == ListenerType.all || listener.listenerType == .tagAndExp{
//                    listener.onExploreChange(change: .update, cards: self.currentCards)
//                }
//
//            }
            
            
        }
        
        listeners.invoke{ (listener) in
            if listener.listenerType == ListenerType.explore || listener.listenerType == ListenerType.all || listener.listenerType == .tagAndExp{
                listener.onExploreChange(change: .update, cards: self.currentCards)
            }
            
        }
        
    }
    
    
    
//    func downloadImage(path: String) -> Data {
//        let gsReference = Storage.storage().reference(forURL: path)
//
//        gsReference.getData(maxSize: 10 * 1024 * 1024){ data, error in
//
//            print(type(of: data))
//            if let error = error{
//                print("error!: \(error)")
//            } else {
////                image = UIImage(data: data!)
//            }
//
//        }
//
////        return image
//
//    }
    
    
    
    
    
    
}