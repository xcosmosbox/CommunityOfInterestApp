//
//  ObserveMenuProtocol.swift
//  CommunityOfInterestApp
//
//  Created by Yuxiang Feng on 10/4/2023.
//

import Foundation

// button state enum
enum ButtonState{
    case unselected
    case selected
}

// design pattern for observer method
protocol ObserverMenu: AnyObject{
    func buttonSelected(button:ObservableButton)
}

protocol ObservableButton: AnyObject {
    func addObserver(observer:ObserverMenu)
    func removeObserver(observer:ObserverMenu)
}

