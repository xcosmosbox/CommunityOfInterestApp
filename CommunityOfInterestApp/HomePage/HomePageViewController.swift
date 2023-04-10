//
//  HomePageViewController.swift
//  CommunityOfInterestApp
//
//  Created by Yuxiang Feng on 10/4/2023.
//

import UIKit

class HomePageViewController: UIViewController, ObserverMenu {
    
    var HorizontalMenuManager:[HorizontalMenuButton] = []
    

    
    
    
    
    
    
    
    
    @IBOutlet weak var HorizontalMenu: UIStackView!
    
    @IBOutlet weak var HorizontalMenuBar: UIScrollView!
    
    
    
    
    
    
    
    
    
    
    
    
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
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
        HorizontalMenu.distribution = .fill
        HorizontalMenu.axis = .horizontal
//        HorizontalMenu.distribution = .equalSpacing
        
        HorizontalMenu.spacing = 12
        HorizontalMenu.alignment = .center
        
  
        // ONLY TEST
        var button1 = HorizontalMenuButton(buttonLisenter: self, title: "Title 1")
        HorizontalMenuManager.append(button1)
        var button2 = HorizontalMenuButton(buttonLisenter: self, title: " Title 2 ")
        HorizontalMenuManager.append(button2)
        var button3 = HorizontalMenuButton(buttonLisenter: self, title: " Title 3 ")
        HorizontalMenuManager.append(button3)
        var button4 = HorizontalMenuButton(buttonLisenter: self, title: " Title 4 djaosijdioa ")
        HorizontalMenuManager.append(button4)
        var button5 = HorizontalMenuButton(buttonLisenter: self, title: " Title 5 ")
        HorizontalMenuManager.append(button5)
        var button6 = HorizontalMenuButton(buttonLisenter: self, title: " Title 6 ")
        HorizontalMenuManager.append(button6)
        var button7 = HorizontalMenuButton(buttonLisenter: self, title: " Title 7 ")
        HorizontalMenuManager.append(button7)
        var button8 = HorizontalMenuButton(buttonLisenter: self, title: " Title 8 ")
        HorizontalMenuManager.append(button8)
        
        HorizontalMenu.addArrangedSubview(button2)
        HorizontalMenu.addArrangedSubview(button3)
        HorizontalMenu.addArrangedSubview(button4)
        HorizontalMenu.addArrangedSubview(button5)
        HorizontalMenu.addArrangedSubview(button6)
        HorizontalMenu.addArrangedSubview(button7)
        HorizontalMenu.addArrangedSubview(button8)
        
        var totalLength: CGFloat = 0.0
        var subviewconter = 0
        for subview in HorizontalMenu.arrangedSubviews {
            totalLength += subview.frame.size.width
            subviewconter += 1
        }
        
        HorizontalMenu.frame.size.width = totalLength + CGFloat(12 * (subviewconter-1))
        
        
        
        
//        HorizontalMenuBar.contentSize = HorizontalMenu.intrinsicContentSize
        HorizontalMenuBar.contentSize = CGSize(width: HorizontalMenu.frame.width + 50, height: HorizontalMenuBar.frame.height)
        HorizontalMenuBar.showsHorizontalScrollIndicator = false
        HorizontalMenuBar.addSubview(HorizontalMenu)
        
        
        
    }
    
    
    
    
    
    func buttonSelected(button: ObservableButton) {
        HorizontalMenuManager.forEach{ oneButton in
            if oneButton == button as! HorizontalMenuButton {
                oneButton.updateButtonState(state: .selected)
            } else {
                oneButton.updateButtonState(state: .unselected)
            }
            
        }
    }
    
    

}
