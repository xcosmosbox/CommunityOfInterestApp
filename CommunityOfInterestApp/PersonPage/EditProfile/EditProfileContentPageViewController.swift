//
//  EditProfileContentPageViewController.swift
//  CommunityOfInterestApp
//
//  Created by Yuxiang Feng on 10/5/2023.
//

import UIKit

class EditProfileContentPageViewController: UIViewController {
    weak var databaseController: DatabaseProtocol?
    
    @IBOutlet weak var newProfileContent: UITextField!
    

    override func viewDidLoad() {
        super.viewDidLoad()
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
    @IBAction func updateProfileContent(_ sender: Any) {
        // update the profile content
        databaseController?.updateUserProfileContent(content: newProfileContent.text!){
            self.displayMessage(title: "Update", message: "Update success")
        }
    }
    // UI Alert Controller
    func displayMessage(title:String, message:String) {
        let alertController = UIAlertController(title: title, message: message,
        preferredStyle: .alert)
        
        alertController.addAction(UIAlertAction(title: "Done", style: .default,
        handler: nil))
        
        self.present(alertController, animated: true, completion: nil)
    }
}
