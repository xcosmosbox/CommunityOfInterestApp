//
//  AddTagPageViewController.swift
//  CommunityOfInterestApp
//
//  Created by Yuxiang Feng on 10/4/2023.
//

import UIKit

class AddTagPageViewController: UIViewController {
    
    
    
    @IBOutlet weak var TagName: UITextField!
    
    
    
    @IBAction func addTagAction(_ sender: Any) {
        TagManager.shared.addTag(name: TagName.text!)
        self.navigationController?.popViewController(animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

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
