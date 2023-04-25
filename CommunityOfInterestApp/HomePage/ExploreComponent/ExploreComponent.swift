//
//  ExploreComponent.swift
//  CommunityOfInterestApp
//
//  Created by Yuxiang Feng on 11/4/2023.
//

import Foundation
import UIKit





class ExploreComponent{
    
    let scrollComponent: UIScrollView
    let leftStack: UIStackView!
    let rightStack: UIStackView!
    
    var left_card_list:[CardView] = []
    var right_card_list:[CardView] = []
    
    let STACK_SPACING:CGFloat?

    init(scrollComponent: UIScrollView, leftStack: UIStackView, rightStack: UIStackView) {
        self.scrollComponent = scrollComponent
        self.leftStack = leftStack
        self.rightStack = rightStack
        self.STACK_SPACING = leftStack.spacing
    }
    
    
    func fillNewCards(cards:[CardView]) {
        var counter = 0
        if left_card_list.count > right_card_list.count{
            counter = 1
        } else{
            counter = 0
        }
        
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
    
    func clearAll(initialScrollComponentContentSize: CGSize, initialLeftCardStackFrame: CGRect, initialRightCardStackFrame: CGRect){
//        var initialScrollComponentContentSize: CGSize?
//        var initialLeftCardStackFrame: CGRect?
//        var initialRightCardStackFrame: CGRect?
        left_card_list = []
        right_card_list = []
        
        for view in leftStack.subviews{
            view.removeFromSuperview()
        }
        
        for view in rightStack.subviews{
            view.removeFromSuperview()
        }
        
        leftStack.frame = initialLeftCardStackFrame
        rightStack.frame = initialRightCardStackFrame
        scrollComponent.contentSize = initialScrollComponentContentSize
        
        
    }
    
    
    
    
    
    
    
    
    
    
}





