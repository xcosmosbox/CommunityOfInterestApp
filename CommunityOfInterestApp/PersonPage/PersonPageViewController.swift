//
//  PersonPageViewController.swift
//  CommunityOfInterestApp
//
//  Created by Yuxiang Feng on 2/5/2023.
//

import UIKit
import FirebaseStorage

class PersonPageViewController: UIViewController, DatabaseListener, DetailChangeDelegate {

    
    
    var listenerType: ListenerType = .person
    weak var databaseController: DatabaseProtocol?
    
    var currentUser: User?
    
    var currentUserLikesList: [Card]?
    var currentUserCollectionsList: [Card]?
    var currentUserPostsList: [Card]?
    
    var showCardViewComponent:ExploreComponent?
    // At the beginning of the record, the size and frame of the three Views
    var initialScrollComponentContentSize: CGSize?
    var initialLeftCardStackFrame: CGRect?
    var initialRightCardStackFrame: CGRect?
    
    
    
    @IBOutlet weak var userProfileImageView: UIImageView!
    
    
    @IBOutlet weak var userNameLabel: UILabel!
    
    @IBOutlet weak var userProfileLabel: UILabel!
    
    @IBOutlet weak var userFollowingNumber: UILabel!
    
    @IBOutlet weak var userFollowerLabel: UILabel!
    
    
    @IBOutlet weak var showDifferCardSegmentedControl: UISegmentedControl!
    
    
    @IBOutlet weak var cardScrollView: UIScrollView!
    
    @IBOutlet weak var leftStackView: UIStackView!
    
    @IBOutlet weak var rightStackView: UIStackView!
    

    
    @IBAction func showDifferCardAction(_ sender: Any) {
        
        var name = showDifferCardSegmentedControl.titleForSegment(at: showDifferCardSegmentedControl.selectedSegmentIndex) ?? ""
        
        
        // show the different card
        if name == "Posts"{
            showPostsView()
        } else if name == "Collections"{
            showCollectionsView()
        } else if name == "Likes"{
            showLikesView()
        }
        
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initialScrollComponentContentSize = cardScrollView.contentSize
        initialLeftCardStackFrame = leftStackView.frame
        initialRightCardStackFrame = rightStackView.frame
        
        // init ExploreComponent
        self.showCardViewComponent = ExploreComponent(scrollComponent: cardScrollView, leftStack: leftStackView, rightStack: rightStackView)
          

        // Do any additional setup after loading the view.
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.databaseController
        
        setupUserInteractionAndGesture()
    }
    
    
    // the three different to show the differ card view component view
    func showPostsView(){
        self.showCardViewComponent?.clearAll(initialScrollComponentContentSize: initialScrollComponentContentSize!, initialLeftCardStackFrame: initialLeftCardStackFrame!, initialRightCardStackFrame: initialRightCardStackFrame!)
        var cards:[CardView] = []
        self.currentUserPostsList?.forEach{ card in
            let cardView = CardFactory().buildACardView(username: card.username!, title: card.title!, imagePath: card.cover!, homepageViewControl: self, card: card)
            cards.append(cardView)
        }
        showCardViewComponent?.fillNewCards(cards: cards)
    }
    func showCollectionsView(){
        self.showCardViewComponent?.clearAll(initialScrollComponentContentSize: initialScrollComponentContentSize!, initialLeftCardStackFrame: initialLeftCardStackFrame!, initialRightCardStackFrame: initialRightCardStackFrame!)
        var cards:[CardView] = []
        self.currentUserCollectionsList?.forEach{ card in
            let cardView = CardFactory().buildACardView(username: card.username!, title: card.title!, imagePath: card.cover!, homepageViewControl: self, card: card)
            cards.append(cardView)
        }
        showCardViewComponent?.fillNewCards(cards: cards)
    }
    func showLikesView(){
        
        self.showCardViewComponent?.clearAll(initialScrollComponentContentSize: initialScrollComponentContentSize!, initialLeftCardStackFrame: initialLeftCardStackFrame!, initialRightCardStackFrame: initialRightCardStackFrame!)
        var cards:[CardView] = []
        self.currentUserLikesList?.forEach{ card in
            let cardView = CardFactory().buildACardView(username: card.username!, title: card.title!, imagePath: card.cover!, homepageViewControl: self, card: card)
            cards.append(cardView)
        }
        showCardViewComponent?.fillNewCards(cards: cards)
    }
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        databaseController?.addListener(listener: self)
        Task{
            do{
                databaseController?.getUserModel{ userModel in
                    self.currentUser = userModel
                    DispatchQueue.main.async {
                        self.userNameLabel.text = self.currentUser?.name
                        self.userProfileLabel.text = self.currentUser?.profile
                        let gsReference = Storage.storage().reference(forURL: (self.currentUser?.profile_image)!)
                        gsReference.getData(maxSize: 10 * 1024 * 1024){ data, error in
                            if let error = error{
                                print("error!: \(error)")
                            } else{
                                let userProfileImage = UIImage(data: data!)
                                self.userProfileImageView.image = userProfileImage
                            }
                        }
                        self.userFollowingNumber.text = "\(Int((self.currentUser?.following!.count)!))"
                        self.userFollowerLabel.text = "\(Int((self.currentUser?.follower!.count)!))"
                        
                        self.showDifferCardSegmentedControl.selectedSegmentIndex = 0
                        self.showPostsView()
                    }
                }
            }catch{
                print("error in PersonPageViewController\(error)")
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        databaseController?.removeListener(listener: self)
        
        self.currentUserPostsList = []
        self.currentUserLikesList = []
        self.currentUserCollectionsList = []
        
        self.showCardViewComponent?.clearAll(initialScrollComponentContentSize: initialScrollComponentContentSize!, initialLeftCardStackFrame: initialLeftCardStackFrame!, initialRightCardStackFrame: initialRightCardStackFrame!)
    }
    
    
    
    func onExploreChange(change: DatabaseChange, cards: [Card]) {
        // nothing to do
    }
    
    func onTagChange(change: DatabaseChange, tags: [Tag]) {
        // nothing to do
    }
    
    func onAuthChange(change: DatabaseChange, userIsLoggedIn: Bool, error: String) {
        // nothing to do
    }
    
    func onPersonChange(change: DatabaseChange, postsCards: [Card], likesCards: [Card], collectionsCards: [Card]) {
        
        self.currentUserPostsList = postsCards
        self.currentUserLikesList = likesCards
        self.currentUserCollectionsList = collectionsCards
        
        var temp_post:[Card] = []
        var temp_like:[Card] = []
        var temp_coll:[Card] = []
        
        for card in self.currentUserPostsList!{
            if !temp_post.contains(where: {$0.id == card.id}){
                temp_post.append(card)
            }
        }
        
        for card in self.currentUserLikesList!{
            if !temp_like.contains(where: {$0.id == card.id}){
                temp_like.append(card)
            }
        }
        
        for card in self.currentUserCollectionsList!{
            if !temp_coll.contains(where: {$0.id == card.id}){
                temp_coll.append(card)
            }
        }
        
        self.currentUserPostsList = temp_post
        self.currentUserLikesList = temp_like
        self.currentUserCollectionsList = temp_coll
        
      
    }
    
    func loadCardDetail(_ card: Card) {
        if let detailViewController = UIStoryboard(name: "HomePageMain", bundle: nil).instantiateViewController(withIdentifier: "DetailViewController") as? DetailViewController {
            
            // Call setOneCardCache(card: Card) from FirebaseController
            databaseController?.setOneCardCache(card: card)
            
            detailViewController.card = card

            
            // Find the tabBarController and navigate to the first tab
            if let tabBarController = self.navigationController?.tabBarController {
                tabBarController.selectedIndex = 0

                // Get the HomePageViewController and its navigationController
                if let homePageNavigationController = tabBarController.viewControllers?.first as? UINavigationController,
                    let homePageViewController = homePageNavigationController.topViewController as? HomePageViewController {
                    self.navigationController?.popToRootViewController(animated: false)

                    // Push the DetailViewController onto HomePageViewController's navigationController
                    homePageNavigationController.pushViewController(detailViewController, animated: true)
                }
            }
        }
    }
    
    
    
    func setupUserInteractionAndGesture(){
        self.userProfileImageView.isUserInteractionEnabled = true
        let uiimageViewGesture = UITapGestureRecognizer(target: self, action: #selector(toEditProfileImage))
        self.userProfileImageView.addGestureRecognizer(uiimageViewGesture)
        
        self.userNameLabel.isUserInteractionEnabled = true
        let userNameLabelGesture = UITapGestureRecognizer(target: self, action: #selector(toEditUsername))
        self.userNameLabel.addGestureRecognizer(userNameLabelGesture)
        
        self.userProfileLabel.isUserInteractionEnabled = true
        let userProfileLabelGesture = UITapGestureRecognizer(target: self, action: #selector(toEditUserProfileContent))
        self.userProfileLabel.addGestureRecognizer(userProfileLabelGesture)
        
        self.userFollowingNumber.isUserInteractionEnabled = true
        let userFollowingNumberGesture = UITapGestureRecognizer(target: self, action: #selector(toShowFollowingAndFollower))
        self.userFollowingNumber.addGestureRecognizer(userFollowingNumberGesture)
        
        self.userFollowerLabel.isUserInteractionEnabled = true
        let userFollowerLabelGesture = UITapGestureRecognizer(target: self, action: #selector(toShowFollowingAndFollower))
        self.userFollowerLabel.addGestureRecognizer(userFollowerLabelGesture)
        
        
        
    }
    
    @objc func toEditProfileImage(){
        performSegue(withIdentifier: "goToEditUserImage", sender: self.userProfileImageView.image)
        
    }
    
    @objc func toEditUsername(){
        performSegue(withIdentifier: "goToEditUsernamePage", sender: self.userNameLabel.text)
        
    }
    
    @objc func toEditUserProfileContent(){
        performSegue(withIdentifier: "goToEditProfileContentPage", sender: self.userProfileLabel.text)
        
    }
    
    @objc func toShowFollowingAndFollower(){
        performSegue(withIdentifier: "goToShowFollowingAndFollowerPage", sender: self)
        
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToEditUserImage"{
            let destination = segue.destination as? ProfileImageEditViewController
            
            destination?.profileImage = sender as? UIImage
        }
        
        if segue.identifier == "goToEditUsernamePage"{
            let destination = segue.destination as? UsernameEditViewController
            destination?.username = sender as? String
            
        }
        
        if segue.identifier == "goToShowFollowingAndFollowerPage"{
            let destination = segue.destination as? FollowingFollowerViewController
            destination?.followingUsers = self.currentUser!.following!
            destination?.followerUsers = self.currentUser!.follower!
        }
        
        
    }

}
