//
//  ProfileImageEditViewController.swift
//  CommunityOfInterestApp
//
//  Created by Yuxiang Feng on 10/5/2023.
//

import UIKit

class ProfileImageEditViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    weak var databaseController: DatabaseProtocol?
    
    
    @IBOutlet weak var profileImageUIImageView: UIImageView!
    
    var profileImage:UIImage?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.databaseController
        
        // Do any additional setup after loading the view.
        
        profileImageUIImageView.image = profileImage
    }
    
    
    @IBAction func uploadImage(_ sender: Any) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        imagePicker.allowsEditing = false
        present(imagePicker, animated: true, completion: nil)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let selectedImage = info[.originalImage] as? UIImage else {
           dismiss(animated: true, completion: nil)
           return
        }
        
        // user update the profile image
        databaseController?.updateUserProfileImage(image: selectedImage){ () in
            self.profileImageUIImageView.image = selectedImage
        }
        self.dismiss(animated: true, completion: nil)
        
        
    }
    
    
    
    

}
