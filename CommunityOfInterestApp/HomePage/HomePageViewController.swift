//
//  HomePageViewController.swift
//  CommunityOfInterestApp
//
//  Created by Yuxiang Feng on 10/4/2023.
//

import UIKit

class HomePageViewController: UIViewController, DatabaseListener{
    var listenerType: ListenerType = .tagAndExp
    

    
    
    var HorizontalMenuBarComponent:HorizontalMenuComponent?
    var ExploreViewComponent:ExploreComponent?
    
    
    weak var databaseController: DatabaseProtocol?
    
    
    
    
    @IBOutlet weak var HorizontalMenu: UIStackView!
    
    @IBOutlet weak var HorizontalMenuBar: UIScrollView!
    
    
    
    @IBOutlet weak var scrollComponent: UIScrollView!
    
    
    
    @IBOutlet weak var leftCardStack: UIStackView!
    
    
    
    @IBOutlet weak var rightCardStack: UIStackView!
    
    
    var initialScrollComponentContentSize: CGSize?
    var initialLeftCardStackFrame: CGRect?
    var initialRightCardStackFrame: CGRect?
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.databaseController

        // Do any additional setup after loading the view.
        initialScrollComponentContentSize = scrollComponent.contentSize
        initialLeftCardStackFrame = leftCardStack.frame
        initialRightCardStackFrame = rightCardStack.frame
        
        self.HorizontalMenuBarComponent = HorizontalMenuComponent(VStackViewMenu: HorizontalMenu, ScrollViewMenuBar: HorizontalMenuBar)
        
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
        var list:[CardView] = []
        
        cards.forEach{ card in
            let cardView = CardFactory().buildACardView(username: card.username!, title: card.title!, imagePath: card.cover!)
            
            list.append(cardView)
        }
        
        if change == .reload{
            self.ExploreViewComponent?.clearAll(initialScrollComponentContentSize: initialScrollComponentContentSize!, initialLeftCardStackFrame: initialLeftCardStackFrame!, initialRightCardStackFrame: initialRightCardStackFrame!)
        }
        
        self.ExploreViewComponent?.fillNewCards(cards: list)
        
        view.setNeedsLayout()
        view.layoutIfNeeded()
        
    }
    
    func onTagChange(change: DatabaseChange, tags: [Tag]) {
        let singleton = TagManager.shared
        singleton.removeAllTags()
        
        tags.forEach{ tag in
            singleton.addTag(name: tag.name!)
        }
        
        self.HorizontalMenuBarComponent?.buildComponent()
        
        view.setNeedsLayout()
        view.layoutIfNeeded()
        
    }

    
    
    


}
