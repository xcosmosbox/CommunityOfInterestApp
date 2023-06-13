//
//  FirebaseController.swift
//  CommunityOfInterestApp
//
//  Created by Yuxiang Feng on 25/4/2023.
//
import Foundation
import UIKit
import Firebase
import FirebaseFirestoreSwift
import FirebaseStorage
import AVFoundation

class FirebaseController: NSObject, DatabaseProtocol {
    
    
   
    
    var defaultTags: [Tag] = []
    var currentCards: [Card] = []
    var listeners = MulticastDelegate<DatabaseListener>()
    
    // reference to firebase
    var authController: Auth
    var database: Firestore
    var fireStorage: Storage
    var deafultTagRef: CollectionReference?
    var postRef: CollectionReference?
    var userRef: CollectionReference?
    var currentUser: FirebaseAuth.User?
    
    // card cache pool
    var oneCardCache: Card? = nil
    
    // user login state
    var userLoginState: Bool
    var currentUserLikesList: [Card] = []
    var currentUserCollectionsList: [Card] = []
    var currentUserPostsList: [Card] = []
    
    // edit and push post
    var currentImages: [UIImage] = []
    var currentImagesCounter: Int = 0
    var currentVideos: [AVAsset] = []
    var currentVideosCounter: Int = 0
    
    
    override init() {
        FirebaseApp.configure()
        authController = Auth.auth()
        database = Firestore.firestore()
        fireStorage = Storage.storage()
        userLoginState = false
        super.init()
        clearCache()
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
        
        if listener.listenerType == .auth || listener.listenerType == .all{
            listener.onAuthChange(change: .update, userIsLoggedIn: userLoginState, error: "")
        }
        
        if listener.listenerType == .person || listener.listenerType == .all{
            listener.onPersonChange(change: .update, postsCards: self.currentUserPostsList, likesCards: self.currentUserLikesList, collectionsCards: self.currentUserCollectionsList)
        }
        
    }
    
    func removeListener(listener: DatabaseListener) {
        listeners.removeDelegate(listener)
    }
    
    
    // add tag into user's field
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
    
    // delete a tag from the user's field
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
        
        // 'Explore' means  all post
        if tagNmae == " Explore "{
            postRef?.getDocuments{ (querySnapshot, error) in
                
                guard let querySnapshot = querySnapshot else{
                    print("Failed to get documents with error on getCommunityContentByTag: \(String(describing: error))")
                    return
                }
                // parse post
                self.parseCardsSnapshotFromNewTag(snapshot: querySnapshot)
            }
        } else {
            let name = tagNmae.trimmingCharacters(in: .whitespacesAndNewlines)
            // get new cards
            postRef?.whereField("tags", arrayContains: name).getDocuments{ (querySnapshot, error) in
                if let error = error{
                    print("error::::\(error)")
                } else {
                    
                    guard let querySnapshot = querySnapshot else{
                        print("Failed to get documents by tag name with error: \(String(describing: error))")
                        return
                    }
                    // parse post
                    self.parseCardsSnapshotFromNewTag(snapshot: querySnapshot)
                }
            }
        }
    }
    
    
    func setupCurrentCards() {
        // create the post reference
        postRef = database.collection("post")
        postRef?.getDocuments{ (querySnapshot, error) in
            
            guard let querySnapshot = querySnapshot else{
                print("Failed to get documents with error: \(String(describing: error))")
                return
            }
            self.parseCardsSnapshot(snapshot: querySnapshot)
        }
    }
    
    
    // parse tag method like lab
    func parseTagsSnapshot(snapshot: QuerySnapshot){
        snapshot.documentChanges.forEach{ (change) in
            var parsedTag: Tag?
            do {
                parsedTag = try change.document.data(as: Tag.self)
            } catch {
                print("Unable to decode tag. Is the tag malformed?")
                return
            }
            
            guard let tag = parsedTag else{
                print("Document doesn't exist")
                return
            }
            
            if change.type == .added{
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
            } catch {
                print("Unable to decode card. Is the card malformed?")
                return
            }
            
            guard let card = parsedCard else{
                print("Document doesn't exits")
                return
            }
            
            if change.type == .added{
                currentCards.insert(card, at: Int(change.newIndex))
            } else if change.type == .modified{
                currentCards[Int(change.oldIndex)] = card
            } else if change.type == .removed {
                currentCards.remove(at: Int(change.oldIndex))
            }
        }
        
        listeners.invoke{ (listener) in
            if listener.listenerType == ListenerType.explore || listener.listenerType == ListenerType.all || listener.listenerType == .tagAndExp{
                listener.onExploreChange(change: .update, cards: self.currentCards)
            }
            
        }
        
    }
    
    
    func parseCardsSnapshotFromNewTag(snapshot: QuerySnapshot){
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
    
    // set card cache
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
                
                // set the user default data
                let defaults = UserDefaults.standard
                defaults.set(true, forKey: "isLogin")
                defaults.set(email, forKey: "email")
                defaults.set(password, forKey: "password")
                
                // read the user document and set the user tags
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
                        
                        self.parseUserCardViewList()
                        
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
                
                // set the userDefaults data
                let defaults = UserDefaults.standard
                defaults.set(true, forKey: "isLogin")
                defaults.set(newEmail, forKey: "email")
                defaults.set(newPassword, forKey: "password")
                
                // set user login state
                userLoginState = true
            } catch {
                print("set user tags failed with error: \(error)")
            }
        }
    }
    
    // create new user document to firebase and set done the tags field
    func setupUserSelectedTags(tags: [String]) -> Bool {
        do{
            // create new user document to firebase and set done the tags field
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
            
            // set the userLoginState and set the defaultTags
            userLoginState = true
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
                
                if let userTagsFromDatabase = querySnapshot.data()!["tags"] as? [String]{
                    for userOneTag in userTagsFromDatabase{
                        let oneTag = Tag()
                        oneTag.name = userOneTag
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
    
    // parse current user
    func getUserModel(completion: @escaping (User) -> Void) {
        var userModel = User()
        let userDocRef = database.collection("user").document(currentUser!.uid).addSnapshotListener {
            (querySnapshot, error) in
            
            guard let querySnapshot = querySnapshot else {
                print("Failed to get documet for this user --> \(error!)")
                return
            }
            
            if querySnapshot.data() == nil{
                print("Failed to get documet for this user")
                return
            }
            
            if let id = querySnapshot.documentID as? String{
                userModel.id = id
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
            
            completion(userModel)
        }
    }
    
    // return UID of current user
    func getCurrentUserUID() -> String{
        return currentUser!.uid
    }
    
    // get following list by firebase
    func getCurrentUserFollowing(completion: @escaping ([DocumentReference]) -> Void) async{
        Task{
            do{
                try await database.document(currentUser!.uid).getDocument(){ (snapshot, error) in
                    completion((snapshot?.data()!["following"])! as! [DocumentReference])
                }
            }
        }
    }
    
    // get follower list by firebase
    func getCurrentUserFollower(completion: @escaping ([DocumentReference]) -> Void) async {
        Task{
            do{
                try await database.document(currentUser!.uid).getDocument(){ (snapshot, error) in
                    completion((snapshot?.data()!["follower"])! as! [DocumentReference])
                }
            }
        }
    }
    
    // parse card document to CARD model
    func getCardModel(cardRef: DocumentReference, completion: @escaping (Card) -> Void){
        var card = Card()
        let cardDocRef = database.collection("post").document(cardRef.documentID).addSnapshotListener {
            (querySnapshot, error) in
            
            guard let querySnapshot = querySnapshot else {
                print("Failed to get documet for this card --> \(error!)")
                return
            }
            
            if querySnapshot.data() == nil{
                print("Failed to get documet for this card")
                return
            }
            
            if let id = querySnapshot.documentID as? String{
                card.id = id
            }
            
            if let title = querySnapshot.data()!["title"] as? String{
                card.title = title
            }
            
            if let content = querySnapshot.data()!["content"] as? String{
                card.content = content
            }
            
            if let cover = querySnapshot.data()!["cover"] as? String{
                card.cover = cover
            }
            
            if let likes_number = querySnapshot.data()!["likes_number"] as? Int{
                card.likes_number = likes_number
            }
            
            if let picture = querySnapshot.data()!["picture"] as? [String]{
                card.picture = picture
            }
            
            if let username = querySnapshot.data()!["username"] as? String{
                card.username = username
            }
            
            completion(card)
            
        }
        
    }
    
    // using document reference to parse a user document
    func getUserModelByDocRef(userDocRef: DocumentReference, completion: @escaping (User) -> Void) {
        var userModel = User()
        userDocRef.addSnapshotListener {
            (querySnapshot, error) in
            
            guard let querySnapshot = querySnapshot else {
                print("Failed to get documet for this user getUserModelByDocRef--> \(error!)")
                return
            }
            
            if querySnapshot.data() == nil{
                print("Failed to get documet for this user getUserModelByDocRef")
                return
            }
            
            if let id = querySnapshot.documentID as? String{
                userModel.id = id
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
            
            completion(userModel)
        }
    }
    
    // get posts list
    func getUserPostsListByDocRefArray(postsRefArray:[DocumentReference], completion: @escaping ([Card]) -> Void){
        var resultPostList:[Card] = []
        do{
            postsRefArray.forEach{ referenceDoc in
                referenceDoc.getDocument{ (document, error) in
                    if let error = error{
                        print("error parsePostsList postsRefArray:\(error)")
                    } else if let document = document{
                        do{
                            let card = try document.data(as: Card.self)
                            if card == nil{
                                print("Failed to parse card")
                            }else{
                                resultPostList.append(card)
                                
                            }
                            if resultPostList.count == postsRefArray.count{
                                completion(resultPostList)
                            }
                            
                        }catch{
                            print("error parsePostsList catch:\(error)")
                        }
                    }
                    
                }
                
            }
        }
    }
    

    
    // using others function to parse the posts lise, likes list and collection list
    func parseUserCardViewList(){
        // init empty array
        self.currentUserPostsList = []
        self.currentUserLikesList = []
        self.currentUserCollectionsList = []
        
        self.listeners.invoke{ (listener) in
            if listener.listenerType == ListenerType.person || listener.listenerType == ListenerType.all{
                listener.onPersonChange(change: .update, postsCards: self.currentUserPostsList, likesCards: self.currentUserLikesList, collectionsCards: self.currentUserCollectionsList)
            }
            
        }
        
        Task{
            do{
                getUserModel{ userModel in
                    // parse
                    self.parsePostsList(referencesList: userModel.posts!)
                    self.parseLikesList(referencesList: userModel.likes!)
                    self.parseCollectionsList(referencesList: userModel.collections!)
                }
            }
        }
        
    }
    
    // using this method to check card is liked
    func checkIsLikeCard(card: Card, completion: @escaping (Bool) -> Void){
        Task {
            do {
                let arrayField = try await database.collection("user").document(currentUser!.uid).getDocument().data()?["likes"] as? [DocumentReference]
                let containsCard = arrayField?.contains(where: { $0.documentID == card.id }) ?? false
                completion(containsCard)
            } catch {
                completion(false)
            }
        }

    }
    
    // parse array of document reference
    func parsePostsList(referencesList: [DocumentReference]){
        do{
            referencesList.forEach{ referenceDoc in
                referenceDoc.getDocument{ (document, error) in
                    if let error = error{
                        print("error parsePostsList:\(error)")
                    } else if let document = document{
                        do{
                            let card = try document.data(as: Card.self)
                            if card == nil{
                                print("Failed to parse card")
                            }else{
                                self.currentUserPostsList.append(card)
                            }
                            
                            self.listeners.invoke{ (listener) in
                                if listener.listenerType == ListenerType.person || listener.listenerType == ListenerType.all{
                                    listener.onPersonChange(change: .update, postsCards: self.currentUserPostsList, likesCards: self.currentUserLikesList, collectionsCards: self.currentUserCollectionsList)
                                }
                                
                            }
                            
                        }catch{
                            print("error parsePostsList catch:\(error)")
                        }
                    }
                    
                }
                
            }
        }
    }
    func parseLikesList(referencesList: [DocumentReference]){
        do{
            referencesList.forEach{ referenceDoc in
                referenceDoc.getDocument{ (document, error) in
                    if let error = error{
                        print("error parsePostsList:\(error)")
                    } else if let document = document{
                        do{
                            let card = try document.data(as: Card.self)
                            if card == nil{
                                print("Failed to parse card")
                            }else{
                                self.currentUserLikesList.append(card)
                            }
                            
                            self.listeners.invoke{ (listener) in
                                if listener.listenerType == ListenerType.person || listener.listenerType == ListenerType.all{
                                    listener.onPersonChange(change: .update, postsCards: self.currentUserPostsList, likesCards: self.currentUserLikesList, collectionsCards: self.currentUserCollectionsList)
                                }
                            }
                        }catch{
                            print("error parsePostsList catch:\(error)")
                        }
                    }
                    
                }
                
            }
        }
    }
    func parseCollectionsList(referencesList: [DocumentReference]){
        do{
            referencesList.forEach{ referenceDoc in
                referenceDoc.getDocument{ (document, error) in
                    if let error = error{
                        print("error parsePostsList:\(error)")
                    } else if let document = document{
                        do{
                            let card = try document.data(as: Card.self)
                            if card == nil{
                                print("Failed to parse card")
                            }else{
                                self.currentUserCollectionsList.append(card)
                            }
                            
                            self.listeners.invoke{ (listener) in
                                if listener.listenerType == ListenerType.person || listener.listenerType == ListenerType.all{
                                    listener.onPersonChange(change: .update, postsCards: self.currentUserPostsList, likesCards: self.currentUserLikesList, collectionsCards: self.currentUserCollectionsList)
                                }
                            }
                        }catch{
                            print("error parsePostsList catch:\(error)")
                        }
                    }
                    
                }
                
            }
        }
    }
    
    
    
    // edit and push post
    func saveCurrentImagesAsDraft(images: [UIImage]) {
        for image in images{
            self.currentImages.append(image)
        }
    }
    
    // clear
    func clearCurrentImages() {
        self.currentImages.removeAll()
    }
    
    // save videos array draft
    func saveCurrentVideosAsDraft(videos: [AVAsset]){
        for video in videos {
            print("save video!11")
            self.currentVideos.append(video)
        }
    }
    // clear
    func clearCurrentVideos(){
        self.currentVideos.removeAll()
    }
    
    // push a post to firebase and upload corresponding image
    func uploadCurrentImagesForCard(title: String, content: String, selectedTags: [String], weatherInfo:(temp_c:Int, location:String, pushTime:String)?, completion: @escaping (DocumentReference, Card) -> Void) {
        self.currentImagesCounter = 0
        
        if weatherInfo != nil{
            Task{
                var newContent = ""
                // read the weather info
                if let loc = weatherInfo?.location, let p_time = weatherInfo?.pushTime, let temp_c = weatherInfo?.temp_c{
                    newContent = content + "\n\nCity: \(loc)  \nTime: \(p_time)  \nTemperature: \(temp_c)"
                }
                // build the folder path
                let folderPath = "images/\(self.currentUser?.uid ?? "hFeuyISsXUWxdOUV5LynsgIH4lC2")/"
                do{
                    // create the post document
                    self.createPostCardForFirebase(title: title, content: newContent, selectedTags: selectedTags){ (createdPostCardRef, createdCard) in
                        // upload each images
                        for image in self.currentImages{
                                self.uploadImageToStorage(folderPath: folderPath, image: image){ storageLocationStr in
                                        // store the image link
                                        // choose the first image as the cover page
                                        if self.currentImagesCounter == 0{
                                            createdPostCardRef.updateData([
                                                "cover":"gs://fit3178-final-ci-app.appspot.com/\(storageLocationStr)"
                                            ])
                                            createdCard.cover = "gs://fit3178-final-ci-app.appspot.com/\(storageLocationStr)"
                                        }
                                        // update the post document
                                        createdPostCardRef.updateData([
                                            "picture": FieldValue.arrayUnion(["gs://fit3178-final-ci-app.appspot.com/\(storageLocationStr)"])
                                        ]){_ in
                                            createdCard.picture?.append("gs://fit3178-final-ci-app.appspot.com/\(storageLocationStr)")
                                            self.currentImagesCounter += 1
                                            if self.currentImagesCounter == self.currentImages.count{
                                                completion(createdPostCardRef, createdCard)
                                            }
                                        }
                                }
                        }
                    }
                }
            }
        } else {
            Task{
                let folderPath = "images/\(self.currentUser?.uid ?? "hFeuyISsXUWxdOUV5LynsgIH4lC2")/"
                do{
                    // create the post document
                    self.createPostCardForFirebase(title: title, content: content, selectedTags: selectedTags){ (createdPostCardRef, createdCard) in
                        // upload each images
                        for image in self.currentImages{
                            DispatchQueue.main.async {
                                self.uploadImageToStorage(folderPath: folderPath, image: image){ storageLocationStr in
                                    DispatchQueue.main.async {
                                        // store the image link
                                        // choose the first image as the cover page
                                        if self.currentImagesCounter == 0{
                                            createdPostCardRef.updateData([
                                                "cover":"gs://fit3178-final-ci-app.appspot.com/\(storageLocationStr)"
                                            ])
                                            createdCard.cover = "gs://fit3178-final-ci-app.appspot.com/\(storageLocationStr)"
                                        }
                                        // update the post document
                                        createdPostCardRef.updateData([
                                            "picture": FieldValue.arrayUnion(["gs://fit3178-final-ci-app.appspot.com/\(storageLocationStr)"])
                                        ]){_ in
                                            createdCard.picture?.append("gs://fit3178-final-ci-app.appspot.com/\(storageLocationStr)")
                                            self.currentImagesCounter += 1
                                            if self.currentImagesCounter == self.currentImages.count{
                                                completion(createdPostCardRef, createdCard)
                                            }
                                        }
                                    }
                                }
                            }
                            
                        }
                    }
                }
            }
        }
    }
    
    func createPostCardForFirebase(title: String, content: String, selectedTags: [String], completion: @escaping (DocumentReference, Card) -> Void){
        
        Task{
            do{
                // create a new document to firebase
                database.collection("user").document(currentUser!.uid).getDocument{ (snapshot, error) in
                    if let error = error{
                        print("createPostCardForFirebase error: \(error)")
                        return
                    }
                    // init some info
                    if let user_name = snapshot?.data()!["name"] as? String{
                        var postedCard = Card()
                        postedCard.title = title
                        postedCard.content = content
                        postedCard.likes_number = 0
                        postedCard.username = user_name
                        
                        // create the document
                        let documentRef = self.database.collection("post").document()
                        documentRef.setData([
                            "audio":[],
                            "content":content,
                            "cover":"",
                            "likes_number":0,
                            "picture":[],
                            "publisher":self.database.collection("user").document(snapshot!.documentID),
                            "tags":selectedTags,
                            "title":title,
                            "username":user_name,
                            "video":[]
                        ])
                        postedCard.id = documentRef.documentID
                        
                        completion(documentRef, postedCard)
                    }
                }
            }catch{
                print("can not get the usermodel in firebase\(error)")
            }
        }
        
    }
    
    // upload image to Storage
    func uploadImageToStorage(folderPath: String, image:UIImage, completion: @escaping (String) -> Void){
        Task{
            // build the storage reference
            let path = folderPath + "imageName_\(Int(Date().timeIntervalSince1970))_\(UUID().uuidString).jpeg"
            let storageRef = self.fireStorage.reference(withPath: path)
            
            // build the imageData
            guard let imageData = image.jpegData(compressionQuality: 0.5) else {
                // image transfer to data faild
                return
            }
            
            // upload image
            do{
                // create a uploadTask by using await key word and putData function
                let uploadTask = try await storageRef.putData(imageData)
                
                try await uploadTask.observe(.progress){ storageTaskSnapshot in
                    
                    let progress = storageTaskSnapshot.progress
                    
                    let percentComplete = 100.0 * Double(progress!.completedUnitCount) / Double(progress!.totalUnitCount)
                    
                    if percentComplete == 100.0{
                        // check and get storage location
                        if storageTaskSnapshot.reference.fullPath != nil{
                            completion(storageTaskSnapshot.reference.fullPath)
                        }
                    }
                }
                
            } catch{
                print("error for upload task: error")
            }
            
        }
    }
    
    // add one post document reference to user's field
    func addPostIntoUser(postDocRef: DocumentReference) {
        database.collection("user").document(currentUser!.uid).updateData([
            "posts": FieldValue.arrayUnion([postDocRef])
        ])
    }
        
    // add one people into the following list
    func addUserToFollowingList(followingUser: DocumentReference, completion: @escaping () -> Void){
        let userDocRef = database.collection("user").document(currentUser!.uid)
        userDocRef.getDocument(){ (snapshot, error) in
            if let error = error{
                print("get user doc error: addUserToFollowingList \(error)")
                return
            }
            
            guard let snapshot = snapshot, let arrayField = snapshot.data()?["following"] as? [DocumentReference] else{
                print("get following array error: addUserToFollowingList")
                return
            }
            
            if arrayField.contains(followingUser){
                // do nothing
                completion()
            } else{
                userDocRef.updateData([
                    "following": FieldValue.arrayUnion([followingUser])
                ])
                followingUser.updateData([
                    "follower": FieldValue.arrayUnion([userDocRef])
                ]) { (updateError) in
                    if let updateError = updateError {
                        print("update error addUserToFollowingList: \(updateError)")
                    }
                    completion()
                }
            }
        }
        
    }
    
    // add one post into likes list
    func addPostToUserLikesField(id: String, completion: @escaping () -> Void) {
        let postCardDocRef = database.collection("post").document(id)
        let userDocRef = database.collection("user").document(currentUser!.uid)
        userDocRef.getDocument(){ (snapshot, error) in
            if let error = error{
                print("get user doc error: addPostToUserLikesField: \(error)")
                return
            }
            
            guard let snapshot = snapshot, let arrayField = snapshot.data()?["likes"] as? [DocumentReference] else{
                print("get likes fields error: addPostToUserLikesField")
                return
            }
            
            if arrayField.contains(postCardDocRef){
                
                userDocRef.updateData([
                    "likes": FieldValue.arrayRemove([postCardDocRef])
                ]){ (updateError) in
                    if let updateError = updateError {
                        print("remove card on likes error:addPostToUserLikesField: \(updateError)")
                    }
                    print("like contains, then remove it")
                    completion()
                    
                }
            } else{
                
                userDocRef.updateData([
                    "likes": FieldValue.arrayUnion([postCardDocRef])
                ]){ (updateError) in
                    if let updateError = updateError {
                        print("update card on likes error:addPostToUserLikesField: \(updateError)")
                    }
                    print("like uncontains, then add it")
                    completion()
                }
            }
            
        }
    }
    
    // add one post into collection list
    func addPostToUserCollectionsField(id: String, completion: @escaping () -> Void) {
        let postCardDocRef = database.collection("post").document(id)
        let userDocRef = database.collection("user").document(currentUser!.uid)
        userDocRef.getDocument(){ (snapshot, error) in
            if let error = error{
                print("get user doc error: addPostToUserCollectionsField: \(error)")
                return
            }
            
            guard let snapshot = snapshot, let arrayField = snapshot.data()?["collections"] as? [DocumentReference] else{
                print("get collections fields error: addPostToUserCollectionsField")
                return
            }
            
            if arrayField.contains(postCardDocRef){
               
                userDocRef.updateData([
                    "collections": FieldValue.arrayRemove([postCardDocRef])
                ]){ (updateError) in
                    if let updateError = updateError {
                        print("remove card on collect error:addPostToUserCollectionsField: \(updateError)")
                    }
                    print("collect contains, then remove it")
                    completion()
                    
                }
                
            } else{
                
                userDocRef.updateData([
                    "collections": FieldValue.arrayUnion([postCardDocRef])
                ]){ (updateError) in
                    if let updateError = updateError {
                        print("update card on collect error:addPostToUserCollectionsField: \(updateError)")
                    }
                    print("collect uncontains, then add it")
                    completion()
                    
                }
            }
            
        }
    }
    
    func clearCache(){
        let qery2 = database.collection("post").whereField("cover", isEqualTo: "")
        qery2.getDocuments(){ (snapshot, error) in
            if let error = error{
                print("error!")
                return
            }
            snapshot?.documents.forEach{ doc in
                doc.reference.delete(){ delError in
                    if let delError = delError{
                        print("delError\(delError)")
                        return
                    }
                    print("delete success")
                }
            }
        }
    }
        
   
       
    func updateUserProfileImage(image: UIImage, completion: @escaping () -> Void) {
        
        Task{
            // build the storage reference
            let path = "profileImageName_\(self.currentUser?.uid)_\(Int(Date().timeIntervalSince1970))_\(UUID().uuidString).jpeg"
            let storageRef = self.fireStorage.reference(withPath: path)
            
            // build the imageData
            guard let imageData = image.jpegData(compressionQuality: 0.8) else {
                // image transfer to data faild
                return
            }
            
            // upload image
            do{
                // create a uploadTask by using await key word and putData function
                let uploadTask = try await storageRef.putData(imageData)
                
                try await uploadTask.observe(.progress){ storageTaskSnapshot in
                    
                    let progress = storageTaskSnapshot.progress
                    
                    let percentComplete = 100.0 * Double(progress!.completedUnitCount) / Double(progress!.totalUnitCount)
                    
                    if percentComplete == 100.0{
                        // check and get storage location
                        if storageTaskSnapshot.reference.fullPath != nil{
                            self.database.collection("user").document(self.currentUser!.uid).updateData([
                                "profile_image":"gs://fit3178-final-ci-app.appspot.com/\(path)"
                            ]){ _ in 
                                completion()
                            }
                        }
                    }
                }
            } catch{
                print("error for upload task: error")
            }
            
        }
    }
    // update user name
    func updateUserName(name: String, completion: @escaping () -> Void) {
        Task{
            do{
                self.database.collection("user").document(self.currentUser!.uid).updateData([
                    "name":name
                ]){_ in 
                    completion()
                }
            }
        }
    }
    // update user profile content
    func updateUserProfileContent(content: String, completion: @escaping () -> Void) {
        Task{
            do{
                self.database.collection("user").document(self.currentUser!.uid).updateData([
                    "profile":content
                ]){_ in 
                    completion()
                }
            }
        }
    }
    
    
    // add user into following list
    func addUserIntoFollowing(otherUserDocRef: DocumentReference, completion: @escaping () -> Void) async {
        let userDocRef = database.collection("user").document(currentUser!.uid)
        try await userDocRef.getDocument(){ (snapshot, error) in
            if let error = error{
                print("get user doc error: addUserIntoFollowing: \(error)")
                return
            }
            
            guard let snapshot = snapshot, let arrayField = snapshot.data()?["following"] as? [DocumentReference] else{
                print("get following fields error: addUserIntoFollowing")
                return
            }
            
            if arrayField.contains(otherUserDocRef){
                userDocRef.updateData([
                    "following": FieldValue.arrayRemove([otherUserDocRef])
                ]){ (updateError) in
                    if let updateError = updateError {
                        print("remove user on following error:addUserIntoFollowing: \(updateError)")
                    }
                    print("following contains, then remove it")
                    completion()
                }
            } else{
                userDocRef.updateData([
                    "following": FieldValue.arrayUnion([otherUserDocRef])
                ]){ (updateError) in
                    if let updateError = updateError {
                        print("update following on user error:addUserIntoFollowing: \(updateError)")
                    }
                    print("following uncontains, then add it")
                    completion()
                }
            }
            
        }
    }
    // when user follow a people, then the people will increase a new follower
    func addMeIntoSomeoneFollower(otherUserDocRef: DocumentReference, completion: @escaping () -> Void) async {
        let userDocRef = database.collection("user").document(currentUser!.uid)
        try await otherUserDocRef.getDocument(){ (snapshot, error) in
            if let error = error{
                print("get user doc error: addMeIntoSomeoneFollower: \(error)")
                return
            }
            
            guard let snapshot = snapshot, let arrayField = snapshot.data()?["follower"] as? [DocumentReference] else{
                print("get follower fields error: addMeIntoSomeoneFollower")
                return
            }
            
            if arrayField.contains(userDocRef){
                otherUserDocRef.updateData([
                    "follower": FieldValue.arrayRemove([userDocRef])
                ]){ (updateError) in
                    if let updateError = updateError {
                        print("remove user on follower error:addMeIntoSomeoneFollower: \(updateError)")
                    }
                    print("follower contains, then remove it")
                    completion()
                }
            } else{
                otherUserDocRef.updateData([
                    "follower": FieldValue.arrayUnion([userDocRef])
                ]){ (updateError) in
                    if let updateError = updateError {
                        print("remove user on follower error:addMeIntoSomeoneFollower: \(updateError)")
                    }
                    print("follower uncontains, then add it")
                    completion()
                    
                }
            }
        }
    }
    
    
    
    // search posts
    func fetchPostsForSearch(serachType:String, searchText:String, completion: @escaping ([Card]) -> Void) {
        var cards: [Card] = []
            
        // get all documents from post collection
        database.collection("post").getDocuments { (querySnapshot, error) in
            if let error = error {
                print("fetchPostsForSearch error: \(error)")
                return
            }
            
            // fuzzy search
            querySnapshot?.documents.forEach { document in
                switch serachType {
                case "Tag":
                    // according tag
                    guard let tags = document.data()["tags"] as? [String] else { return }
                    if tags.contains(where: { $0.range(of: searchText, options: .caseInsensitive) != nil }) {
                        if let card = try? document.data(as: Card.self) {
                            cards.append(card)
                        }
                    }
                case "Title":
                    // according title
                    guard let title = document.data()["title"] as? String else { return }
                    if title.range(of: searchText, options: .caseInsensitive) != nil {
                        if let card = try? document.data(as: Card.self) {
                            cards.append(card)
                        }
                    }
                default:
                    print("unexpected search type")
                    return
                }
            }
            
            completion(cards)
        }
        
        
    }
    
    
    
    
    
    
}
