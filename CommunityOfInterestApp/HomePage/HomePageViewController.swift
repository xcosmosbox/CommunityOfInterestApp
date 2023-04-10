//
//  HomePageViewController.swift
//  CommunityOfInterestApp
//
//  Created by Yuxiang Feng on 10/4/2023.
//

import UIKit

class HomePageViewController: UIViewController, ObserverMenu {
    
    var HorizontalMenuManager:[HorizontalMenuButton] = []
    
    var HorizontalMenuBarComponent:HorizontalMenuComponent?
    
    
    
    
    
    
    
    
    @IBOutlet weak var HorizontalMenu: UIStackView!
    
    @IBOutlet weak var HorizontalMenuBar: UIScrollView!
    
    
    
    
    
    
    
    
    
    
    
    
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.HorizontalMenuBarComponent = HorizontalMenuComponent(VStackViewMenu: HorizontalMenu, ScrollViewMenuBar: HorizontalMenuBar)
        
        setupHorizontalMenuBar()
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    func setupHorizontalMenuBar() {
        
        // ONLY TEST
        TEST_HorizontalMenuBarComponent()
        self.HorizontalMenuBarComponent?.TEST_setupHorizontalMenuBar(HorizontalMenuManager: self.HorizontalMenuManager)
        
        
        
    }
    
    
    
    
    
    func buttonSelected(button: ObservableButton) {
        self.HorizontalMenuBarComponent?.updateButtonState(button: button)
    }
    
    
    
    
    
    
    /// ONLY TEST
    func TEST_HorizontalMenuBarComponent(){
        // ONLY TEST
        HorizontalMenuManager.append(HorizontalMenuButton(buttonLisenter: self, title: "Title 1"))
        HorizontalMenuManager.append(HorizontalMenuButton(buttonLisenter: self, title: " Title 2 "))
        HorizontalMenuManager.append(HorizontalMenuButton(buttonLisenter: self, title: " Title 3 "))
        HorizontalMenuManager.append(HorizontalMenuButton(buttonLisenter: self, title: " Title 4 djaosijdioa "))
        HorizontalMenuManager.append(HorizontalMenuButton(buttonLisenter: self, title: " Title 5 "))
        HorizontalMenuManager.append(HorizontalMenuButton(buttonLisenter: self, title: " Title 6 "))
        HorizontalMenuManager.append(HorizontalMenuButton(buttonLisenter: self, title: " Title 7 "))
        HorizontalMenuManager.append(HorizontalMenuButton(buttonLisenter: self, title: " Title 8 "))
    }

}
