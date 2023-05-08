//
//  DetailViewController.swift
//  CommunityOfInterestApp
//
//  Created by Yuxiang Feng on 30/4/2023.
//

import UIKit

class DetailViewController: UIViewController{
    

    
    
    
    
    @IBOutlet weak var PageScrollController: UIScrollView!
    
    
    @IBOutlet weak var PageContainer: UIView!
    
    
    
    @IBOutlet weak var TitleTextLabel: UILabel!
    
    @IBOutlet weak var ContentTextLabel: UILabel!
    
    
    
    
    
    
    
    
    var card:Card? = nil
    
    

    override func viewDidLoad() {
        
        print("3")
        
        super.viewDidLoad()
        
        print("4")
        
        print("=====")
        print(card)
        print(card?.id)
        print(card?.username)
        print(card?.content)
        print(card?.title)
        print(card?.cover)
        print(card?.picture)
        print("+++++")
        
        
        
        
//        TitleTextLabel.numberOfLines = 0
        TitleTextLabel.text = card?.title
//        ContentTextLabel.numberOfLines = 0
        ContentTextLabel.text = card?.content
        
        var counter = 0.0
        counter += PageContainer.frame.height
        counter += TitleTextLabel.frame.height
        counter += ContentTextLabel.frame.height
        
        
        PageScrollController.contentSize = CGSize(width: 393, height: counter + 100.0)
        PageScrollController.showsVerticalScrollIndicator = false
        PageScrollController.addSubview(PageContainer)
        PageScrollController.addSubview(TitleTextLabel)
        PageScrollController.addSubview(ContentTextLabel)
        

        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    


}


protocol DetailChangeDelegate {
    func loadCardDetail(_ card: Card)
}

