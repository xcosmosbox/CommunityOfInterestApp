//
//  MultiSelectImagePageViewController.swift
//  CommunityOfInterestApp
//
//  Created by Yuxiang Feng on 6/5/2023.
//

import UIKit
import PhotosUI

class MultiSelectImagePageViewController: UIViewController,  PHPickerViewControllerDelegate  {
    
    var configuration:PHPickerConfiguration?
    var pickerViewController: PHPickerViewController?
    weak var databaseController: DatabaseProtocol?
    

    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.databaseController
    }
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        databaseController?.clearCurrentImages()
        
        configuration = PHPickerConfiguration()
        configuration?.filter = .images
        configuration?.selectionLimit = 9
        
        pickerViewController = PHPickerViewController(configuration: configuration!)
        pickerViewController!.delegate = self
        present(pickerViewController!, animated: true, completion: nil)
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        configuration = nil
        pickerViewController = nil
    }
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    func handleCancelAction() {
//        let storyboard = UIStoryboard(name: "HomePageMain", bundle: nil)
//        let destinationViewController = storyboard.instantiateViewController(withIdentifier: "homePageStoryboardEntry")
//        navigationController?.pushViewController(destinationViewController, animated: true)
        if let tabBarController = self.tabBarController {
                tabBarController.selectedIndex = 0
        }
    }

    
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true, completion: nil)
        
        // if results is empty, means user doesnot want to upload the iamge, then return to the last view page
        if results.isEmpty {
            handleCancelAction()
            return
        }
        
        var imagesArray:[UIImage] = []
        
        var loadImageConter = 0
        
        for result in results {
            result.itemProvider.loadObject(ofClass: UIImage.self) { (object, error) in
                
                DispatchQueue.main.async {
                    if let error = error {
                        print("load photo error: \(error.localizedDescription)")
                        loadImageConter += 1
                    } else if let image = object as? UIImage {
                        // process selected image
                        print("select photo: \(image)")
                        imagesArray.append(image)
                        
                        loadImageConter += 1
                        
                        if loadImageConter == results.count{
//                            self.JUSTTOTESTFUNCTION(imagesArray)
                            
                            // save image to the draft box
                            self.databaseController?.saveCurrentImagesAsDraft(images: imagesArray)

                            self.performSegue(withIdentifier: "toEditPostCardPage", sender: self)
                        }
                        
                    }
                }
                
            }
        }
     
//        databaseController?.saveCurrentImagesAsDraft(images: imagesArray)
        
//        self.JUSTTOTESTFUNCTION(imagesArray)
//
//        performSegue(withIdentifier: "toEditPostCardPage", sender: self)
    }
    
//    func JUSTTOTESTFUNCTION(_ images: [UIImage]){
////        var temp:[UIImage] = []
////        temp.append(UIImage(named: "food_0.pic")!)
////        temp.append(UIImage(named: "food_3.pic")!)
////        databaseController?.saveCurrentImagesAsDraft(images: temp)
//        databaseController?.saveCurrentImagesAsDraft(images: images)
//        print("lengthImage: \(images.count)")
//        print(images)
//        Task{
//            do{
//                databaseController?.uploadCurrentImagesForCard(title: "title_title", content: "this is contentcontentcontentcontentcontentcontentcontentcontentcontentcontentcontentcontentcontentcontent", selectedTags: ["Food","Pet"]){ result in
//                    DispatchQueue.main.async {
//                        print("TEST SUCCESS")
//                    }
//                }
//            }
//        }
//    }
    
    
    
    
    
    
    
    
    

}
