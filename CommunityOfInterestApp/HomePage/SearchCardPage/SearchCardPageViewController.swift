//
//  SearchCardPageViewController.swift
//  CommunityOfInterestApp
//
//  Created by Yuxiang Feng on 16/5/2023.
//

import UIKit
import Firebase
import FirebaseFirestoreSwift


class SearchCardPageViewController: UIViewController, UIScrollViewDelegate {
    
    @IBOutlet weak var serachBar: UITextField!
    
    @IBOutlet weak var optionsSegment: UISegmentedControl!
    
    
    @IBOutlet weak var scrollViewComponent: UIScrollView!
    
    @IBOutlet weak var leftStack: UIStackView!
    
    @IBOutlet weak var rightStack: UIStackView!
    
    

    
    @IBAction func optionsSegmentedAction(_ sender: Any) {
        // set the segmented bar
        clearScrollViewComponent(initialScrollComponentContentSize: initialScrollComponentContentSize!, initialLeftCardStackFrame: initialLeftCardStackFrame!, initialRightCardStackFrame: initialRightCardStackFrame!)
        // init
        serachBar.text = ""
        serachBar.placeholder = "Enter search content"
    }
    
    
    
    
    @IBAction func buttonSearchAction(_ sender: Any) {
        // using database controller to get all result of the search
        databaseController?.fetchPostsForSearch(serachType: optionsSegment.titleForSegment(at: optionsSegment.selectedSegmentIndex)!, searchText: serachBar.text!){ searchResult in
            
            // fill the explore scroll view component
            var counter = 0
            if self.left_card_list.count > self.right_card_list.count{
                counter = 1
            } else{
                counter = 0
            }
            
            // fill the stack view
            for card in searchResult{
                if counter == 0{
                    let aCardView = CardFactory().buildACardView(username: card.username!, title: card.title!, imagePath: card.cover!, homepageViewControl: self, card: card)
                    self.left_card_list.append(aCardView)
                    self.leftStack.addArrangedSubview(aCardView)
                    counter = 1
                } else{
                    let aCardView = CardFactory().buildACardView(username: card.username!, title: card.title!, imagePath: card.cover!, homepageViewControl: self, card: card)
                    self.right_card_list.append(aCardView)
                    self.rightStack.addArrangedSubview(aCardView)
                    counter = 0
                    
                }
            }
            
            self.refresh()
            
        }
    }
    
    
    
    var posts: [Card] = []

    
    
    var searchType: String = "Tag"
    var serachText: String = ""
    
    var left_card_list:[CardView] = []
    var right_card_list:[CardView] = []
    
    // connection for database
    weak var databaseController: DatabaseProtocol?
    
    // record the frame data
    var initialScrollComponentContentSize: CGSize?
    var initialLeftCardStackFrame: CGRect?
    var initialRightCardStackFrame: CGRect?

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // obtain the connection for database controller
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.databaseController
        
        // Do any additional setup after loading the view.
        
        // init
        scrollViewComponent.delegate = self
        
        initialScrollComponentContentSize = scrollViewComponent.contentSize
        initialLeftCardStackFrame = leftStack.frame
        initialRightCardStackFrame = rightStack.frame
        
        serachBar.placeholder = "Enter search content"
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    func refresh(){
        var max_height = 0
        
        leftStack.frame.size.height = CGFloat(left_card_list.count * 250 + 30 * left_card_list.count)
        rightStack.frame.size.height = CGFloat(right_card_list.count * 250 + 30 * right_card_list.count)
        
        if leftStack.frame.height > rightStack.frame.height{
            max_height = Int(leftStack.frame.height)
        }else{
            max_height = Int(rightStack.frame.height)
        }
        
        scrollViewComponent.contentSize = CGSize(width: scrollViewComponent.frame.width, height: CGFloat(max_height))
        
        scrollViewComponent.alwaysBounceVertical = true
    }
    
    
    func clearScrollViewComponent(initialScrollComponentContentSize: CGSize, initialLeftCardStackFrame: CGRect, initialRightCardStackFrame: CGRect){
        
        left_card_list = []
        right_card_list = []
        
        // remove all subview from the stack
        for view in leftStack.subviews{
            view.removeFromSuperview()
        }
        for view in rightStack.subviews{
            view.removeFromSuperview()
        }
        
        // restore default frame
        leftStack.frame = initialLeftCardStackFrame
        rightStack.frame = initialRightCardStackFrame
        scrollViewComponent.contentSize = initialScrollComponentContentSize
        
    }
    

    
    

}
