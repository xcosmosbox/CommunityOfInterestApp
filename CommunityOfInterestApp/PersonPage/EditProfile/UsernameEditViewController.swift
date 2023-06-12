//
//  UsernameEditViewController.swift
//  CommunityOfInterestApp
//
//  Created by Yuxiang Feng on 10/5/2023.
//

import UIKit

class UsernameEditViewController: UIViewController {
    weak var databaseController: DatabaseProtocol?
    
    var username:String?

    @IBOutlet weak var oldName: UILabel!
    
    @IBOutlet weak var newNameTextField: UITextField!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.databaseController
        
        oldName.text = username
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    @IBAction func modifyUsername(_ sender: Any) {
        // user update account name
        databaseController?.updateUserName(name: newNameTextField.text!){ () in
            print("modify success")
            self.displayMessage(title: "Modify Username", message: "Modify success")
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
