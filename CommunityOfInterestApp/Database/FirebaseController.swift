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
    
    // card cache pool
    var oneCardCache: Card? = nil
    
    // user login state
    var userLoginState: Bool
    
    
    override init() {
        FirebaseApp.configure()
        authController = Auth.auth()
        database = Firestore.firestore()
        userLoginState = false
        
        super.init()
        
        // anonymous sign in
//        Task{
//            do {
//                let authDataResult = try await authController.signInAnonymously()
//                currentUser = authDataResult.user
//
//                // create corresponding user document
//                try await database.collection("user").document(currentUser!.uid).setData([
//                    "name": "username",
//
//                ])
//            }
//            catch {
//                // sign in failed
//                fatalError("Firebase Authentication Failed with Error \(String(describing: error))")
//            }
//
//            // sign in success
//            self.setupDefaultTags()
//
//            // init user's tags list
////            do{
////                print("=====hahahahahahaha====")
////                try await database.collection("user").document(currentUser!.uid).updateData([
////                    "tags": FieldValue.arrayUnion(defaultTags)
////                ])
////                print("=====hahahahahahaha====")
////            }
//
//        }
    }

    
    
    func cleanup() {
        // nothing to do
    }
    
    func addListener(listener: DatabaseListener) {
        listeners.addDelegate(listener)
        
        if listener.listenerType == .tag || listener.listenerType == .all || listener.listenerType == .tagAndExp{
            print("appear HOME")
            print(defaultTags)
            listener.onTagChange(change: .update, tags: self.defaultTags)
        }
        
        if listener.listenerType == .explore || listener.listenerType == .all || listener.listenerType == .tagAndExp{
            listener.onExploreChange(change: .update, cards: self.currentCards)
        }
        
        if listener.listenerType == .auth || listener.listenerType == .all{
            listener.onAuthChange(change: .update, userIsLoggedIn: userLoginState, error: "")
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
    
    func getCommunityContentByTag(tagNmae: String) {
        
        // remove all cards
        currentCards = []
        
        if tagNmae == " Explore "{
            postRef?.limit(to: 15).getDocuments{ (querySnapshot, error) in
                
                guard let querySnapshot = querySnapshot else{
                    print("Failed to get documents with error on getCommunityContentByTag: \(String(describing: error))")
                    return
                }
                
                self.parseCardsSnapshotFromNewTag(snapshot: querySnapshot)
                
            }
            
        } else {
            let name = tagNmae.trimmingCharacters(in: .whitespacesAndNewlines)
            // get new cards
            postRef?.whereField("tags", arrayContains: name).limit(to: 10).getDocuments{ (querySnapshot, error) in
                if let error = error{
                    print("error::::\(error)")
                } else {
                    
                    guard let querySnapshot = querySnapshot else{
                        print("Failed to get documents by tag name with error: \(String(describing: error))")
                        return
                    }
                    self.parseCardsSnapshotFromNewTag(snapshot: querySnapshot)
                }
            }
        }
        
    }
    
    
    
//    func setupDefaultTags(){
//
//        deafultTagRef = database.collection("default_tag")
//        deafultTagRef?.addSnapshotListener(){
//            (querySnapshot, error) in
//
//            guard let querySnapshot = querySnapshot else{
//                print("Failed to fetch documents with error: \(String(describing: error))")
//                return
//            }
//
//            self.parseTagsSnapshot(snapshot: querySnapshot)
//
//            if self.postRef == nil{
//                self.setupCurrentCards()
//            }
//
//
//        }
//
//    }
    
    
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
    
    
    func parseCardsSnapshotFromNewTag(snapshot: QuerySnapshot){
        print("hduaishdi!!!!!!!!!1duaishdi!!!!!!")
        print(snapshot.documentChanges.count)
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
        }
            
            
        listeners.invoke{ (listener) in
            if listener.listenerType == ListenerType.explore || listener.listenerType == ListenerType.all || listener.listenerType == .tagAndExp{
                listener.onExploreChange(change: .reload, cards: self.currentCards)
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
    
    
    func setOneCardCache(card: Card) {
        self.oneCardCache = card
    }
    
    func getOneCardCache() -> Card {
        return self.oneCardCache!
    }

    
    
    func login(email: String, password: String) {
        Task{
            do{
                // using authController.signIn function to login firebase auth
                let authDataResult = try await authController.signIn(withEmail: email, password: password)
                // get user data
                currentUser = authDataResult.user
                userLoginState = true
                
                let userDocRef = database.collection("user").document(currentUser!.uid)
                userDocRef.getDocument{ (document, error) in
                    if let document = document, document.exists{
                        let data = document.data()
                        let userTags = data?["tags"] as? [String] ?? []
                        userTags.forEach{ tag in
                            let oneTag = Tag()
                            oneTag.name = tag
                            self.defaultTags.append(oneTag)
                        }
                        
                        self.listeners.invoke{ (listener) in
                            if listener.listenerType == ListenerType.tag || listener.listenerType == ListenerType.all || listener.listenerType == .tagAndExp{
                                listener.onTagChange(change: .update, tags: self.defaultTags)
                            }
                            
                        }
                        
                        if self.postRef == nil{
                            self.setupCurrentCards()
                        }
                        
                        self.listeners.invoke{ (listener) in
                            if listener.listenerType == ListenerType.auth || listener.listenerType == ListenerType.all{
                                listener.onAuthChange(change: .update, userIsLoggedIn: self.userLoginState, error: "")
                            }
                            
                        }
                        
                    } else{
                        print("Document does not exist: setupUserSelectedTags")
                    }
                    
                }

                
                
                
                
            } catch{
                // login failed
                print("Firebase Authentication Failed with Error \(String(describing: error))")
            }
        }
        
        
        
        
    }
    
    func signup(newEmail: String, newPassword: String) {
        Task{
            do{
                // using createUser function to signup account
                let authDataResult = try await authController.createUser(withEmail: newEmail, password: newPassword)
                
                // get user data
                currentUser = authDataResult.user
                
                // using user id to create the user document
                // we need to set the document ID == user id
                print("doahduoahsduoad")
                print("\(currentUser?.uid)")
//                try await database.collection("user").document(currentUser!.uid).setData([
//                    "name": "username",
//                    "profile":"everything you love is here",
//                    "profile_image":"gs://fit3178-final-ci-app.appspot.com/WechatIMG88.jpeg"
//                ])
//                let name = "usernmae"
//                try await database.collection("user").document(currentUser!.uid).setData([
//                    "name": name,
//                ])
                
                // init
                
                // set user login state
                userLoginState = true
                
                
            } catch {
                print("set user tags failed with error: \(error)")
            }
        }
    }
    
    func setupUserSelectedTags(tags: [String]) -> Bool {
        do{
            database.collection("user").document(currentUser!.uid).setData([
                "name": "username",
                "profile":"everything you love is here",
                "profile_image":"gs://fit3178-final-ci-app.appspot.com/WechatIMG88.jpeg",
                "collections":[],
                "follower":[],
                "following":[],
                "likes":[],
                "posts":[],
                "tags":tags
            ])
            
            userLoginState = true
            
            print("set user tag success")
            
            let userDocRef = database.collection("user").document(currentUser!.uid).addSnapshotListener{
                (querySnapshot, error) in
                print("dhoashdoasuhduaoshdouashdouashd")
                
                guard let querySnapshot = querySnapshot else {
                    print("Failed to get documet for this user --> \(error!)")
                    return
                }
                
                if querySnapshot.data() == nil{
                    print("Failed to get documet for this user")
                    return
                }
                
                if let userTagsFromDatabase = querySnapshot.data()!["tags"] as? [String]{
                    print("hihiiiiiiaisdiasidasidais")
                    for userOneTag in userTagsFromDatabase{
                        let oneTag = Tag()
                        oneTag.name = userOneTag
                        self.defaultTags.append(oneTag)
                        print(userOneTag)
                        print(oneTag)
                    }
                    
                    print("=========================================================================")
                    print(self.defaultTags)
                    print("=========================================================================")
                    self.listeners.invoke{ (listener) in
                        if listener.listenerType == ListenerType.tag || listener.listenerType == ListenerType.all || listener.listenerType == .tagAndExp{
                            print("test for tag change on signup")
                            listener.onTagChange(change: .update, tags: self.defaultTags)
                        }
                        
                    }
                    
                    
                    if self.postRef == nil{
                        self.setupCurrentCards()
                    }
                    
                    
                }else{
                    print("Document does not exist: setupUserSelectedTags")
                }
                
                
                
            }

            
            
            return true
            
        } catch {
            print("set user tags failed with error: \(error)")
            return false
        }
    }
    
    
    func getUserModel() -> User {
        var userModel = User()
        let userDocRef = database.collection("user").document(currentUser!.uid).addSnapshotListener{
            (querySnapshot, error) in
            
            guard let querySnapshot = querySnapshot else {
                print("Failed to get documet for this user --> \(error!)")
                return
            }
            
            if querySnapshot.data() == nil{
                print("Failed to get documet for this user")
                return
            }
            
            
            if let name = querySnapshot.data()!["name"] as? String {
                userModel.name = name
            }
            
            if let profile = querySnapshot.data()!["profile"] as? String {
                userModel.profile = profile
            }
            
            if let profile_image = querySnapshot.data()!["profile_image"] as? String {
                userModel.profile_image = profile_image
            }
            
            if let tags = querySnapshot.data()!["tags"] as? [String] {
                userModel.tags = tags
            }
            
            if let collections = querySnapshot.data()!["collections"] as? [DocumentReference] {
                userModel.collections = collections
            }
            
            if let follower = querySnapshot.data()!["follower"] as? [DocumentReference] {
                userModel.follower = follower
            }
            
            if let following = querySnapshot.data()!["following"] as? [DocumentReference] {
                userModel.following = following
            }
            
            if let likes = querySnapshot.data()!["likes"] as? [DocumentReference] {
                userModel.likes = likes
            }
            
            if let posts = querySnapshot.data()!["posts"] as? [DocumentReference] {
                userModel.posts = posts
            }
            
        }
        
        
        return userModel
        
    }
    
    
}
