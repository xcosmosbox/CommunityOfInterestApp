//
//  ExploreComponent.swift
//  CommunityOfInterestApp
//
//  Created by Yuxiang Feng on 11/4/2023.
//

import Foundation
import UIKit





class ExploreComponent{
    
    /**
     ExploreComponent has three view
     There are two VStacks left and right in the scrollComponent
     These two VStacks will be used to store CardView
     */
    let scrollComponent: UIScrollView
    let leftStack: UIStackView!
    let rightStack: UIStackView!
    
    var left_card_list:[CardView] = []
    var right_card_list:[CardView] = []
    
    let STACK_SPACING:CGFloat?

    // init
    init(scrollComponent: UIScrollView, leftStack: UIStackView, rightStack: UIStackView) {
        self.scrollComponent = scrollComponent
        self.leftStack = leftStack
        self.rightStack = rightStack
        self.STACK_SPACING = leftStack.spacing
    }
    
    
    // using cardviews to fill stack view
    func fillNewCards(cards:[CardView]) {
        
        // Prioritize filling VStack Views with fewer CardViews
        var counter = 0
        if left_card_list.count > right_card_list.count{
            counter = 1
        } else{
            counter = 0
        }
        
        // fill stack
        for card in cards{
            if counter == 0{
                left_card_list.append(card)
                leftStack.addArrangedSubview(card)
                counter = 1
            } else{
                right_card_list.append(card)
                rightStack.addArrangedSubview(card)
                counter = 0
            }
        }
        
        refresh()
    }
    
    
    // resize the view frame
    func refresh(){
        var max_height = 0
        
        leftStack.frame.size.height = CGFloat(left_card_list.count * 250 + 30 * left_card_list.count + 10)
        rightStack.frame.size.height = CGFloat(right_card_list.count * 250 + 30 * right_card_list.count + 10)
        
        if leftStack.frame.height > rightStack.frame.height{
            max_height = Int(leftStack.frame.height)
        }else{
            max_height = Int(rightStack.frame.height)
        }
        
        scrollComponent.contentSize = CGSize(width: scrollComponent.frame.width, height: CGFloat(max_height + 10))
        
        scrollComponent.alwaysBounceVertical = true
        
        
    }
    
    // when we goto the new tag
    // we need to clean all cardview for now stack
    func clearAll(initialScrollComponentContentSize: CGSize, initialLeftCardStackFrame: CGRect, initialRightCardStackFrame: CGRect){
        
        // remove all cardview
        left_card_list = []
        right_card_list = []
        
        // remove all subview from stack
        for view in leftStack.subviews{
            view.removeFromSuperview()
        }
        
        for view in rightStack.subviews{
            view.removeFromSuperview()
        }
        
        // restore default frame
        leftStack.frame = initialLeftCardStackFrame
        rightStack.frame = initialRightCardStackFrame
        scrollComponent.contentSize = initialScrollComponentContentSize
        
        
    }
    
    
    
    
    
    
    
    
    
    
}





