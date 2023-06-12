//
//  AddTagPageViewController.swift
//  CommunityOfInterestApp
//
//  Created by Yuxiang Feng on 10/4/2023.
//

import UIKit

class AddTagPageViewController: UIViewController {
    
    // import database controller
    weak var databaseController: DatabaseProtocol?
    
    
    @IBOutlet weak var TagName: UITextField!
    
    
    @IBAction func addTagAction(_ sender: Any) {
        // using add tag method to add new tag at local and firebase
        TagManager.shared.addTag(name: TagName.text!)
        databaseController?.addTag(name: TagName.text!)
        self.navigationController?.popViewController(animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        // set databaseController
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.databaseController
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
