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
    

    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    
    
    override func viewWillAppear(_ animated: Bool) {
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
    
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true, completion: nil)
        
        for result in results {
            result.itemProvider.loadObject(ofClass: UIImage.self) { (object, error) in
                if let error = error {
                    print("load photo error: \(error.localizedDescription)")
                } else if let image = object as? UIImage {
                    // process selected image
                    print("select photo: \(image)")
                    
                }
            }
        }
        
        performSegue(withIdentifier: "goToNextPage", sender: self)
    }
    
    
    
    
    
    
    
    
    

}
