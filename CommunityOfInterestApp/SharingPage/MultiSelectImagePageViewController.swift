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
        databaseController?.clearCurrentVideos()
        
        configuration = PHPickerConfiguration()
        configuration?.filter = .images
//        configuration?.filter = .any(of: [.images, .videos])
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
        var videosArray: [AVAsset] = []
        
        var loadMediaCounter = 0
        
        for result in results {
            if result.itemProvider.canLoadObject(ofClass: UIImage.self){
                result.itemProvider.loadObject(ofClass: UIImage.self) { (object, error) in
                    
                    DispatchQueue.main.async {
                        if let error = error {
                            print("load photo error: \(error.localizedDescription)")
                            loadMediaCounter += 1
                        } else if let image = object as? UIImage {
                            // process selected image
                            print("select photo: \(image)")
                            imagesArray.append(image)
                            
                            loadMediaCounter += 1
                            
                            self.checkMediaLoadCompletion(totalCount: results.count, counter: loadMediaCounter, images: imagesArray, videos: videosArray)
                            
                        }
                    }
                    
                }
                
            } else{
                result.itemProvider.loadFileRepresentation(forTypeIdentifier: UTType.movie.identifier){ (url, error) in
                    DispatchQueue.main.async {
                        if let error = error {
                            print("load video error: \(error.localizedDescription)")
                        } else if let url = url {
                            let asset = AVAsset(url: url)
                            videosArray.append(asset)
                            
                            loadMediaCounter += 1
                            self.checkMediaLoadCompletion(totalCount: results.count, counter: loadMediaCounter, images: imagesArray, videos: videosArray)
                        }
                    }
                    
                    
                }
            }
            
        }
     
    }
    
    
    func checkMediaLoadCompletion(totalCount: Int, counter: Int, images:[UIImage], videos:[AVAsset]){
        if totalCount == counter{
            self.databaseController?.saveCurrentImagesAsDraft(images: images)
            self.databaseController?.saveCurrentVideosAsDraft(videos: videos)
            self.performSegue(withIdentifier: "toEditPostCardPage", sender: self)
        }
    }
    
    
    
    
    
    
    
    
    
    

}
