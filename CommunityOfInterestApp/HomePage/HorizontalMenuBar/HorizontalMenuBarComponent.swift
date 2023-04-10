//
//  HorizontalMenuBarComponent.swift
//  CommunityOfInterestApp
//
//  Created by Yuxiang Feng on 10/4/2023.
//

import Foundation
import UIKit


class HorizontalMenuComponent {
    var HorizontalMenuManager:[HorizontalMenuButton] = []
    
    let VStackViewMenu:UIStackView
    let ScrollViewMenuBar: UIScrollView
    
    let ButtonSpacingNumer = 12
    
    init(VStackViewMenu:UIStackView!, ScrollViewMenuBar: UIScrollView!) {
        self.VStackViewMenu = VStackViewMenu
        
        self.VStackViewMenu.distribution = .fill
        self.VStackViewMenu.axis = .horizontal
        self.VStackViewMenu.spacing = CGFloat(ButtonSpacingNumer)
        self.VStackViewMenu.alignment = .center
        
        
        self.ScrollViewMenuBar = ScrollViewMenuBar
        
        self.ScrollViewMenuBar .contentSize = CGSize(width: self.VStackViewMenu.frame.width + 50, height: self.ScrollViewMenuBar .frame.height)
        self.ScrollViewMenuBar .showsHorizontalScrollIndicator = false
        self.ScrollViewMenuBar .addSubview(self.VStackViewMenu)
    }
    
    
    
    
//    func setupHorizontalMenuBar(){
//
//    }
    
    
    public func TEST_setupHorizontalMenuBar(HorizontalMenuManager:[HorizontalMenuButton] ){
        
        self.HorizontalMenuManager = HorizontalMenuManager
        
        var counter = 1
        self.HorizontalMenuManager.forEach{ oneButton in
            self.VStackViewMenu.addArrangedSubview(oneButton)
            if counter == 1{
                oneButton.updateButtonState(state: .selected)
            }
            counter += 1
        }
        
        refreshComponent()
        
    }
    
    
    
    
    
    func refreshComponent(){
        var totalLength: CGFloat = 0.0
        var subviewconter = 0
        for subview in self.VStackViewMenu.arrangedSubviews {
            totalLength += subview.frame.size.width
            subviewconter += 1
        }
        
        self.VStackViewMenu.frame.size.width = totalLength + CGFloat(ButtonSpacingNumer * (subviewconter-1))
        
        self.ScrollViewMenuBar.contentSize = CGSize(width: self.VStackViewMenu.frame.width + 50, height: self.ScrollViewMenuBar.frame.height)
    }
    
    
    
    func updateButtonState(button: ObservableButton){
        HorizontalMenuManager.forEach{ oneButton in
            if oneButton == button as! HorizontalMenuButton {
                oneButton.updateButtonState(state: .selected)
            } else {
                oneButton.updateButtonState(state: .unselected)
            }
            
        }
    }
    
    
    
    
    
}
