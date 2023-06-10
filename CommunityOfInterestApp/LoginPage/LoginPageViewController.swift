//
//  LoginPageViewController.swift
//  CommunityOfInterestApp
//
//  Created by Yuxiang Feng on 2/5/2023.
//

import UIKit

class LoginPageViewController: UIViewController, DatabaseListener {
    
    var listenerType: ListenerType = .auth
    
    weak var databaseController: DatabaseProtocol?
    
    
    
    @IBOutlet weak var emailTextField: UITextField!
    
    
    @IBOutlet weak var passwordTextField: UITextField!
    
    
    
    @IBAction func login(_ sender: Any) {
        
        // get eamil and password value
        let email = emailTextField.text
        let password = passwordTextField.text
        
        if let email = email, let password = password {
            // check eamil and password is valid
            if checkPassword(password: password) == true {
                // using firebase to login
                databaseController?.login(email: email, password: password)
            }
            
            else {
                displayMessage(title: "Error", message: "Invalid email or password")
            }
        }
        
    }
    
    
    
    @IBAction func signup(_ sender: Any) {
        
        let eamil = emailTextField.text
        let password = passwordTextField.text
        
        if let email = eamil, let password = password{
            if checkPassword(password: password){
                databaseController?.signup(newEmail: email, newPassword: password)
                DispatchQueue.main.async {
                    self.performSegue(withIdentifier: "toSelectTagPage", sender: nil)
                }
//                performSegue(withIdentifier: "toSelectTagPage", sender: nil)
            } else{
                displayMessage(title: "Error", message: "Invalid email or password")
            }
        }
        
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        passwordTextField.isSecureTextEntry = true
        
        // get firebase reference
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.databaseController
        
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        databaseController?.addListener(listener: self)
        
        let defaults = UserDefaults.standard
        var isLogin = defaults.bool(forKey: "isLogin")
        
        print("isLogin == true")
        print(isLogin)
        print("isLogin == true")
        
        if isLogin == true{
            let email = defaults.string(forKey: "email")
            let password = defaults.string(forKey: "password")
            databaseController?.login(email: email!, password: password!)
            DispatchQueue.main.async {
                self.performSegue(withIdentifier: "showAppPage", sender: nil)
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        databaseController?.removeListener(listener: self)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    func checkPassword(password: String) -> Bool {
        if password.isEmpty == false {
            return true
        }
        else {
            return false
        }
    }
    
    
    func onExploreChange(change: DatabaseChange, cards: [Card]) {
        // nothing to do
    }
    
    func onTagChange(change: DatabaseChange, tags: [Tag]) {
        // nothing to do
    }
    
    func onAuthChange(change: DatabaseChange, userIsLoggedIn: Bool, error: String) {
        if userIsLoggedIn == true{
            DispatchQueue.main.async {
                self.performSegue(withIdentifier: "showAppPage", sender: nil)
            }
            
        }
    }
    
    func onPersonChange(change: DatabaseChange, postsCards: [Card], likesCards: [Card], collectionsCards: [Card]) {
        // nothing to do
    }
    
    
    
    func displayMessage(title: String, message: String){
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: .default,handler: nil ))
        self.present(alertController, animated: true, completion: nil)
    }

}
