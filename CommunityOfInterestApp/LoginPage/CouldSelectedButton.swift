//
//  CouldSelectedButton.swift
//  CommunityOfInterestApp
//
//  Created by Yuxiang Feng on 2/5/2023.
//

import UIKit

class CouldSelectedButton: UIButton {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    // style for selected tag which used as to init the new person
    var isSelectedSate = false
    var unselectedColor: UIColor = .systemGray5
    var selectedColor: UIColor = .systemBlue
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = unselectedColor
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        backgroundColor = unselectedColor
    }
    
    func changeState(){
        isSelectedSate.toggle()
        backgroundColor = isSelected ? selectedColor : unselectedColor
    }

}
