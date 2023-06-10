//
//  SettingPageViewController.swift
//  CommunityOfInterestApp
//
//  Created by Yuxiang Feng on 10/6/2023.
//

import UIKit
import Firebase

class SettingPageViewController: UIViewController {
    
    weak var databaseController: DatabaseProtocol?
   
    
    
    @IBAction func LogoutAction(_ sender: Any) {
        let defaults = UserDefaults.standard
        defaults.set(false, forKey: "isLogin")
        
        databaseController?.userLoginState = false
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let loginNavController = storyboard.instantiateViewController(withIdentifier: "LoginNavigationController") as? UINavigationController {
            if let sceneDelegate = self.view.window?.windowScene?.delegate as? SceneDelegate {
                sceneDelegate.window?.rootViewController = loginNavController
            }
        }

    }
    
    
   override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
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
