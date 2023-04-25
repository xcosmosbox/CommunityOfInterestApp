//
//  HorizontalMenuButton.swift
//  CommunityOfInterestApp
//
//  Created by Yuxiang Feng on 10/4/2023.
//

import UIKit

class HorizontalMenuButton: UIButton, ObservableButton {

    
    var buttonLisenter:ObserverMenu?
    var selectedState:ButtonState?
    weak var databaseController: DatabaseProtocol?
    var title: String?
    
    
    init(buttonLisenter: ObserverMenu?, title: String) {
        super.init(frame: .infinite)
        self.buttonLisenter = buttonLisenter
        self.title = title
        setupButton(title:title)
        
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.databaseController
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    private func setupButton(title:String){
        // set title
        self.setTitle(title, for: .normal)
        self.setTitleColor(.black, for: .normal)
        
        // set background color
        self.backgroundColor = .gray
        
        // set the button's corner radius
        self.layer.cornerRadius = CGFloat(10)
        
        // set height?
        
        // disable button title's line wrapping
//        self.titleLabel?.lineBreakMode = .byClipping
//        self.titleLabel?.numberOfLines = 0
//        self.titleLabel?.sizeToFit()
        
        
//        self.configuration?.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20)
        
        
        
        self.frame.size.width = (self.titleLabel?.frame.width)!
        
        
        // set button state
        selectedState = .unselected
    }

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    // when user touch the button, the OS will auto-call this method
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        buttonLisenter?.buttonSelected(button: self)
        
        // change the explore component content
//        if self.title != " Explore " {
//
//        } else {
//
//        }
        print("!!!!!!Click!!!!!!")
        databaseController?.getCommunityContentByTag(tagNmae: self.title!)
        
        
        
    }
    
    
    func updateButtonState(state:ButtonState){
        self.selectedState = state
        if self.selectedState == .unselected{
            self.backgroundColor = .gray
        } else {
            self.backgroundColor = .blue
        }
    }
    
    
    func addObserver(observer: ObserverMenu) {
        buttonLisenter = observer
    }
    
    func removeObserver(observer: ObserverMenu) {
        buttonLisenter = nil
    }
    
    

}
