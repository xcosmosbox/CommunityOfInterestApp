//
//  DetailViewController.swift
//  CommunityOfInterestApp
//
//  Created by Yuxiang Feng on 30/4/2023.
//

import UIKit

class DetailViewController: UIViewController{
    
    weak var databaseController: DatabaseProtocol?

    
    
    
    
    @IBOutlet weak var PageScrollController: UIScrollView!
    
    
    @IBOutlet weak var PageContainer: UIView!
    
    
    @IBOutlet weak var pageControlBar: UIPageControl!
    
    @IBOutlet weak var TitleTextLabel: UILabel!
    
    @IBOutlet weak var ContentTextLabel: UILabel!
    
    
    @IBAction func MenuToSelectLikesAndCollections(_ sender: UIBarButtonItem) {
        // create the alert controller
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

        // set the first menu
        let option1Action = UIAlertAction(title: "Like", style: .default) { _ in
            // add this post to user's likes field
            self.databaseController?.addPostToUserLikesField(id: (self.card?.id)!){ () in
                print("add card to likes field success")
                
            }
        }
        alertController.addAction(option1Action)

        // set the second menu
        let option2Action = UIAlertAction(title: "Collect", style: .default) { _ in
            // add this post to user's collections field
            self.databaseController?.addPostToUserCollectionsField(id: (self.card?.id)!){ () in
                print("add card to collection field success")
                
            }
        }
        alertController.addAction(option2Action)

        //show menu
        present(alertController, animated: true, completion: nil)

    }
    
    
    
    
    
    
    var card:Card? = nil
    
    

    override func viewDidLoad() {
        
        print("3")
        
        super.viewDidLoad()
        
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.databaseController
        
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
        
        
        pageControlBar.numberOfPages = (card?.picture!.count)!
        
        
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
        
        for child in children{
            if let childPage = child as? PageImageViewController{
                childPage.didChangePage = { [weak self] currentPage in
                    self?.pageControlBar.currentPage = currentPage
                    
                }
                break
            }
        }
        
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

