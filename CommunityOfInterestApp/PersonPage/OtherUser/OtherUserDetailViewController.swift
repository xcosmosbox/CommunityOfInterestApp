//
//  OtherUserDetailViewController.swift
//  CommunityOfInterestApp
//
//  Created by Yuxiang Feng on 12/5/2023.
//

import UIKit
import Firebase
import FirebaseFirestoreSwift
import FirebaseStorage

// this class will show other user's detail
class OtherUserDetailViewController: UIViewController, DetailChangeDelegate {
    
    
    
    
    @IBOutlet weak var userImageView: UIImageView!
    
    @IBOutlet weak var userNameLabel: UILabel!
    
    @IBOutlet weak var userProfileLabel: UILabel!
    
    @IBOutlet weak var scrollViewControl: UIScrollView!
    
    
    @IBOutlet weak var leftStack: UIStackView!
    
    @IBOutlet weak var rightStack: UIStackView!
    
    
    weak var databaseController: DatabaseProtocol?
    var currentUserPostsList: [Card]?
    var showCardViewComponent:ExploreComponent?
    // At the beginning of the record, the size and frame of the three Views
    var initialScrollComponentContentSize: CGSize?
    var initialLeftCardStackFrame: CGRect?
    var initialRightCardStackFrame: CGRect?
    
    var currentUserDocRef: DocumentReference?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.databaseController
        
        initialScrollComponentContentSize = scrollViewControl.contentSize
        initialLeftCardStackFrame = leftStack.frame
        initialRightCardStackFrame = rightStack.frame
        
        // init ExploreComponent
        self.showCardViewComponent = ExploreComponent(scrollComponent: scrollViewControl, leftStack: leftStack, rightStack: rightStack)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.showCardViewComponent?.clearAll(initialScrollComponentContentSize: initialScrollComponentContentSize!, initialLeftCardStackFrame: initialLeftCardStackFrame!, initialRightCardStackFrame: initialRightCardStackFrame!)
        
        Task{
            do{
                databaseController?.getUserModelByDocRef(userDocRef: currentUserDocRef!){ (userModel) in
                    DispatchQueue.main.async {
                        self.userNameLabel.text = userModel.name
                        self.userProfileLabel.text = userModel.profile
                        let gsReference = Storage.storage().reference(forURL: userModel.profile_image!)
                        gsReference.getData(maxSize: 10 * 1024 * 1024){ data, error in
                            if let error = error{
                                print("error!: \(error)")
                            } else{
                                let userProfileImage = UIImage(data: data!)
                                self.userImageView.image = userProfileImage
                            }
                        }
                        self.databaseController?.getUserPostsListByDocRefArray(postsRefArray: userModel.posts!){ (cards) in
                            var cardViews:[CardView] = []
                            cards.forEach{ card in
                                let cardView = CardFactory().buildACardView(username: card.username!, title: card.title!, imagePath: card.cover!, homepageViewControl: self, card: card)
                                cardViews.append(cardView)
                                if cardViews.count == cards.count{
                                    self.showCardViewComponent?.fillNewCards(cards: cardViews)
                                }
                            }
                            
                        }
                    }
                    
                }
            }
        }
        
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
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
    
    
    
    
    
    
    

}
