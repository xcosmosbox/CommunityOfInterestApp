//
//  PageImageViewController.swift
//  CommunityOfInterestApp
//
//  Created by Yuxiang Feng on 30/4/2023.
//

import UIKit

class PageImageViewController: UIPageViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    
    var imagesLoader:[String]?
    
    public var pageNumber = 0
    
    let appDelegate = UIApplication.shared.delegate as? AppDelegate
    weak var databaseController: DatabaseProtocol?
    
    var didChangePage: ((Int) -> Void)?

    override func viewDidLoad() {
        databaseController = appDelegate?.databaseController
        imagesLoader = databaseController?.getOneCardCache().picture
        
        print("1")
        
        super.viewDidLoad()

        print("2")
        // Do any additional setup after loading the view.
        
        
        dataSource = self
        delegate = self
        
        print("+++****+++++********")
        print(imagesLoader)
        print((imagesLoader?.first)!)
        print("+++****+++++********")
        
        let initialViewImageController = PicturesViewController(imagePath: (imagesLoader?.first)!)
        
        
        self.setViewControllers([initialViewImageController], direction: .forward, animated: false, completion: nil)
        
        self.pageNumber = imagesLoader!.count
        
        
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
            
//            didChangePage?(newIndex)
            
//            print("before \(newIndex)")
            let page = PicturesViewController(imagePath: imagesLoader![newIndex])
//            updateImagePageNumer(viewController: page)
            return page
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
            
//            didChangePage?(newIndex)
            
//            databaseController?.updateCurrentImagePageNumber(pageNumber: newIndex)
            let page = PicturesViewController(imagePath: imagesLoader![newIndex])
            return page
        }
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {
        guard let viewController = pendingViewControllers.first as? PicturesViewController else { return }
        guard let newIndex = imagesLoader?.firstIndex(of: viewController.imagePath) else { return }
        didChangePage?(newIndex)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if !completed {
            guard let viewController = previousViewControllers.first as? PicturesViewController else { return }
            guard let newIndex = imagesLoader?.firstIndex(of: viewController.imagePath) else { return }
            didChangePage?(newIndex)
        }
    }
    


}

