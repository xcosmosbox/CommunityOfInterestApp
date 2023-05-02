//
//  PersonPageViewController.swift
//  CommunityOfInterestApp
//
//  Created by Yuxiang Feng on 2/5/2023.
//

import UIKit
import FirebaseStorage

class PersonPageViewController: UIViewController, DatabaseListener {
    
    var listenerType: ListenerType = .person
    weak var databaseController: DatabaseProtocol?
    
    var currentUser: User?
    
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
        
        currentUser = databaseController?.getUserModel()
        
        
        userNameLabel.text = currentUser?.name
        userProfileLabel.text = currentUser?.profile
        let gsReference = Storage.storage().reference(forURL: (currentUser?.profile_image)!)
        gsReference.getData(maxSize: 10 * 1024 * 1024){ data, error in
            if let error = error{
                print("error!: \(error)")
            } else{
                let userProfileImage = UIImage(data: data!)
                self.userProfileImageView.image = userProfileImage
            }
        }
        userFollowingNumber.text = String(describing: currentUser?.following?.count)
        userFollowerLabel.text = String(describing: currentUser?.follower?.count)
        
        
        
        
        
        

    }
    
    
    func showPostsView(){
        
    }
    
    func showCollectionsView(){
        
    }
    
    func showLikesView(){
        
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
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        databaseController?.removeListener(listener: self)
        self.showCardViewComponent?.clearAll(initialScrollComponentContentSize: initialScrollComponentContentSize!, initialLeftCardStackFrame: initialLeftCardStackFrame!, initialRightCardStackFrame: initialRightCardStackFrame!)
    }
    
    
    
    func onExploreChange(change: DatabaseChange, cards: [Card]) {
        <#code#>
    }
    
    func onTagChange(change: DatabaseChange, tags: [Tag]) {
        <#code#>
    }
    
    func onAuthChange(change: DatabaseChange, userIsLoggedIn: Bool, error: String) {
        <#code#>
    }

}
