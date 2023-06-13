//
//  SelectTagsPageViewController.swift
//  CommunityOfInterestApp
//
//  Created by Yuxiang Feng on 2/5/2023.
//

import UIKit

class SelectTagsPageViewController: UIViewController {
    
    
    var selectedTags:[String] = []
    weak var databaseController: DatabaseProtocol?
    
    
    @IBOutlet var tagsButtonCollection: [CouldSelectedButton]!
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        // get firebase reference
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.databaseController

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
    
    
    
    
    @IBAction func selectTagAction(_ sender: CouldSelectedButton) {
        sender.isSelectedSate.toggle()
        if sender.isSelectedSate == true{
            sender.backgroundColor = .systemBlue
        } else {
            sender.backgroundColor = .systemGray5
        }
    }
    
    
    @IBAction func setupUserTags(_ sender: Any) {
        tagsButtonCollection.forEach{ button in
            if button.isSelectedSate == true{
                selectedTags.append((button.titleLabel?.text)!)
            }
        }
        
        // set the user's tags field
        var flag = databaseController?.setupUserSelectedTags(tags: selectedTags)
        
        if flag == true{
            performSegue(withIdentifier: "signupShowApp", sender: nil)
        }
        
        
    }
    
    
    
    

}
