//
//  HorizontalMenuBarComponent.swift
//  CommunityOfInterestApp
//
//  Created by Yuxiang Feng on 10/4/2023.
//

import Foundation
import UIKit


class HorizontalMenuComponent: ObserverMenu {
    
    // an empty array to store all button
    var HorizontalMenuManager:[HorizontalMenuButton] = []
    
    // two important view
    let HStackViewMenu:UIStackView
    let ScrollViewMenuBar: UIScrollView
    
    // set the spacing for all button
    let ButtonSpacingNumer = 12
    
    // init
    init(VStackViewMenu:UIStackView!, ScrollViewMenuBar: UIScrollView!) {
        // init HStackViewMenu
        self.HStackViewMenu = VStackViewMenu
        
        // set the frame for HStackViewMenu
        self.HStackViewMenu.distribution = .fill
        self.HStackViewMenu.axis = .horizontal
        self.HStackViewMenu.spacing = CGFloat(ButtonSpacingNumer)
        self.HStackViewMenu.alignment = .center
        
        // init ScrollViewMenuBar
        self.ScrollViewMenuBar = ScrollViewMenuBar
        
        // set the frame for ScrollViewMenuBar
        self.ScrollViewMenuBar.contentSize = CGSize(width: self.HStackViewMenu.frame.width + 50, height: self.ScrollViewMenuBar .frame.height)
        self.ScrollViewMenuBar.showsHorizontalScrollIndicator = false
        self.ScrollViewMenuBar.addSubview(self.HStackViewMenu)
    }
    
    
    // Build the corresponding Button according to the data given by TagManager
    func buildComponent() {
        HorizontalMenuManager = []
        self.HStackViewMenu.removeAllArrangedSubviews()
        let singleton = TagManager.shared
        for tag in singleton.getAllTag(){
            HorizontalMenuManager.append(HorizontalMenuButton(buttonLisenter: self, title: tag.getContent()))
        }
        
        // The first Button is selected by default
        var counter = 1
        self.HorizontalMenuManager.forEach{ oneButton in
            self.HStackViewMenu.addArrangedSubview(oneButton)
            if counter == 1{
                oneButton.updateButtonState(state: .selected)
            } else {
                oneButton.updateButtonState(state: .unselected)
            }
            counter += 1
        }
        
        // Resize two views according to the number of Buttons
        refreshComponent()
    }
    
    
    // refresh this component
    func refreshComponent(){
        // init variable
        var totalLength: CGFloat = 0.0
        var subviewconter = 0
        
        // counter for all views length
        for subview in self.HStackViewMenu.arrangedSubviews {
            totalLength += subview.frame.size.width
            subviewconter += 1
        }
        
        // fix the HStackViewMenu frame
        self.HStackViewMenu.frame.size.width = totalLength + CGFloat(ButtonSpacingNumer * (subviewconter-1))
        
        // fix the ScrollViewMenuBar frame
        self.ScrollViewMenuBar.contentSize = CGSize(width: self.HStackViewMenu.frame.width + 50, height: self.ScrollViewMenuBar.frame.height)
    }
    
    // when a Button is selected, cancel the previously selected Button
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


extension UIStackView {
    func removeAllArrangedSubviews() {
        for arrangedSubview in self.arrangedSubviews {
            arrangedSubview.removeFromSuperview()
        }
    }
}
