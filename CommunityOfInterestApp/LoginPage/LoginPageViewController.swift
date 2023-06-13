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
    
    let activityIndicator = UIActivityIndicatorView(style: .large)
    
    
    
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
        
        // check the eamil and passwor is valid
        if let email = eamil, let password = password{
            if checkPassword(password: password){
                // using firebase to sign up
                databaseController?.signup(newEmail: email, newPassword: password)
                DispatchQueue.main.async {
                    self.performSegue(withIdentifier: "toSelectTagPage", sender: nil)
                }
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
        
        

        activityIndicator.color = .gray
        activityIndicator.center = view.center
        activityIndicator.hidesWhenStopped = true
        view.addSubview(activityIndicator)

        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        activityIndicator.startAnimating()

        databaseController?.addListener(listener: self)

        // check the value of 'isLogin'
        let defaults = UserDefaults.standard
        var isLogin = defaults.bool(forKey: "isLogin")

        // if true, means we can auto-complete the email and password
        if isLogin == true{
            let email = defaults.string(forKey: "email")
            let password = defaults.string(forKey: "password")
            // auto-call the login function
            databaseController?.login(email: email!, password: password!)
        } else{
            self.activityIndicator.stopAnimating()
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
                self.activityIndicator.stopAnimating()
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
