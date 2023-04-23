//
//  HomePageViewController.swift
//  CommunityOfInterestApp
//
//  Created by Yuxiang Feng on 10/4/2023.
//

import UIKit

class HomePageViewController: UIViewController{
    
    var HorizontalMenuBarComponent:HorizontalMenuComponent?
    var ExploreViewComponent:ExploreComponent?
    
    
    
    
    
    
    
    @IBOutlet weak var HorizontalMenu: UIStackView!
    
    @IBOutlet weak var HorizontalMenuBar: UIScrollView!
    
    
    
    @IBOutlet weak var scrollComponent: UIScrollView!
    
    
    
    @IBOutlet weak var leftCardStack: UIStackView!
    
    
    
    @IBOutlet weak var rightCardStack: UIStackView!
    
    
    
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.HorizontalMenuBarComponent = HorizontalMenuComponent(VStackViewMenu: HorizontalMenu, ScrollViewMenuBar: HorizontalMenuBar)
        
        self.ExploreViewComponent = ExploreComponent(scrollComponent: scrollComponent, leftStack: leftCardStack, rightStack: rightCardStack)
                
        self.ExploreViewComponent?.fillNewCards(cards: CardFactory().ONLY_TEST_BUILD_CARD())

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.HorizontalMenuBarComponent?.buildComponent()
        
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    

    
    
    


}
