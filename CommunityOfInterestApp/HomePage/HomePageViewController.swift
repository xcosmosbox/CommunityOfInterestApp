//
//  HomePageViewController.swift
//  CommunityOfInterestApp
//
//  Created by Yuxiang Feng on 10/4/2023.
//

import UIKit

class HomePageViewController: UIViewController, DatabaseListener, DetailChangeDelegate{

    

    

    // init listener type
    var listenerType: ListenerType = .tagAndExp
    

    
    // Variables for two important components
    var HorizontalMenuBarComponent:HorizontalMenuComponent?
    var ExploreViewComponent:ExploreComponent?
    
    // connection for database
    weak var databaseController: DatabaseProtocol?
    
    
    
    
    @IBOutlet weak var HorizontalMenu: UIStackView!
    
    @IBOutlet weak var HorizontalMenuBar: UIScrollView!
    
    
    
    @IBOutlet weak var scrollComponent: UIScrollView!
    
    
    
    @IBOutlet weak var leftCardStack: UIStackView!
    
    
    
    @IBOutlet weak var rightCardStack: UIStackView!
    
    
    // At the beginning of the record, the size and frame of the three Views
    var initialScrollComponentContentSize: CGSize?
    var initialLeftCardStackFrame: CGRect?
    var initialRightCardStackFrame: CGRect?
    

    
    @IBAction func gotoSearchPageAction(_ sender: Any) {
        performSegue(withIdentifier: "goToSearchPage", sender: self)
    }
    
    
    // home page init
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // obtain the connection for database controller
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.databaseController

        // Do any additional setup after loading the view.
        // assign value
        initialScrollComponentContentSize = scrollComponent.contentSize
        initialLeftCardStackFrame = leftCardStack.frame
        initialRightCardStackFrame = rightCardStack.frame
        
        // init HorizontalMenuComponent
        self.HorizontalMenuBarComponent = HorizontalMenuComponent(VStackViewMenu: HorizontalMenu, ScrollViewMenuBar: HorizontalMenuBar)
        
        // init ExploreComponent
        self.ExploreViewComponent = ExploreComponent(scrollComponent: scrollComponent, leftStack: leftCardStack, rightStack: rightCardStack)
                
//        self.ExploreViewComponent?.fillNewCards(cards: CardFactory().ONLY_TEST_BUILD_CARD())

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        databaseController?.addListener(listener: self)
        
        
//        self.HorizontalMenuBarComponent?.buildComponent()
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        databaseController?.removeListener(listener: self)
        
        // when we leave this page, we will clean all card for ExploreViewComponent
        self.ExploreViewComponent?.clearAll(initialScrollComponentContentSize: initialScrollComponentContentSize!, initialLeftCardStackFrame: initialLeftCardStackFrame!, initialRightCardStackFrame: initialRightCardStackFrame!)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    func onExploreChange(change: DatabaseChange, cards: [Card]) {
        
        print("onExploreChangeonExploreChangeonExploreChange")
        print(cards.count)
        print("onExploreChangeonExploreChangeonExploreChange")
        
        
        // clean list
        var list:[CardView] = []
        
        // load all card view
        cards.forEach{ card in
            let cardView = CardFactory().buildACardView(username: card.username!, title: card.title!, imagePath: card.cover!, homepageViewControl: self, card: card)
            
            list.append(cardView)
        }
        
        // if chang type == reload, means we need to resize the stack view and scroll view length
        // reload means we change the tag
        if change == .reload{
            self.ExploreViewComponent?.clearAll(initialScrollComponentContentSize: initialScrollComponentContentSize!, initialLeftCardStackFrame: initialLeftCardStackFrame!, initialRightCardStackFrame: initialRightCardStackFrame!)
        }
        
        // fill cards to ExploreViewComponent, it will fix the view length by numbers of cards
        self.ExploreViewComponent?.fillNewCards(cards: list)
        
        view.setNeedsLayout()
        view.layoutIfNeeded()
        
    }
    
    func onTagChange(change: DatabaseChange, tags: [Tag]) {
        // using the singleton TagManager
        let singleton = TagManager.shared
        // remove all without explore
        singleton.removeAllTags()
        
        // create TagBean throuhg Tag, and store them to TagManager
        tags.forEach{ tag in
            singleton.addTag(name: tag.name!)
        }
        
        // build HorizontalMenuBarComponent
        self.HorizontalMenuBarComponent?.buildComponent()
        
//        view.setNeedsLayout()
//        view.layoutIfNeeded()
        
    }
    
    func onAuthChange(change: DatabaseChange, userIsLoggedIn: Bool, error: String) {
        // nothing to do
    }
    
    func onPersonChange(change: DatabaseChange, postsCards: [Card], likesCards: [Card], collectionsCards: [Card]) {
        // nothing to do
    }

    
    func loadCardDetail(_ card: Card) {
        self.performSegue(withIdentifier: "showCardDetailPage", sender: card)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showCardDetailPage", let detailView = segue.destination as? DetailViewController, let data = sender as? Card{
            detailView.card = data
        }
    }
    
    
    

    
    
    


}
