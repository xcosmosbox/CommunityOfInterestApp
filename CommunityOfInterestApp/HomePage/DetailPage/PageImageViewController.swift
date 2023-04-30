//
//  PageImageViewController.swift
//  CommunityOfInterestApp
//
//  Created by Yuxiang Feng on 30/4/2023.
//

import UIKit

class PageImageViewController: UIPageViewController, UIPageViewControllerDataSource {
    
    var imagesLoader:[String]?
    
    public var number = 0
    
    let appDelegate = UIApplication.shared.delegate as? AppDelegate
    weak var databaseController: DatabaseProtocol?

    override func viewDidLoad() {
        databaseController = appDelegate?.databaseController
        imagesLoader = databaseController?.getOneCardCache().picture
        
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        
        dataSource = self
        
        var initialViewImageController = PicturesViewController(imagePath: (imagesLoader?.first)!)
        
        
        self.setViewControllers([initialViewImageController], direction: .forward, animated: false, completion: nil)
        
        self.number = imagesLoader!.count
        
        
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let currentIndex = imagesLoader!.firstIndex(of: (viewController as? PicturesViewController)!.imagePath) else {
            return nil
        }

        if currentIndex == 0 {
            return nil
        } else {
            let newIndex = currentIndex - 1
//            print("before \(newIndex)")
            return PicturesViewController(imagePath: imagesLoader![newIndex])
        }
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let currentIndex = imagesLoader!.firstIndex(of: (viewController as? PicturesViewController)!.imagePath) else {
            return nil
        }

        if currentIndex == imagesLoader!.count - 1 {
            return nil
        } else {
            let newIndex = currentIndex + 1
            return PicturesViewController(imagePath: imagesLoader![newIndex])
        }
    }
    

}

