//
//  PageImageViewController.swift
//  CommunityOfInterestApp
//
//  Created by Yuxiang Feng on 30/4/2023.
//

import UIKit

class PageImageViewController: UIPageViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    
//    var mediaLoader:[String]?
    var mediaLoader: [(type: MediaType, url: String)]? = []
    
    public var pageNumber = 0
    
    let appDelegate = UIApplication.shared.delegate as? AppDelegate
    weak var databaseController: DatabaseProtocol?
    
    var didChangePage: ((Int) -> Void)?

    override func viewDidLoad() {
        print("1")
        databaseController = appDelegate?.databaseController
        let cardCache = databaseController?.getOneCardCache()
        
        
        cardCache?.picture?.forEach{ pic in
            print("pic: \(pic)")
            mediaLoader?.append((MediaType.image, pic))
        }
        
        cardCache?.video?.forEach{ videoURL in
            print("video: \(videoURL)")
            mediaLoader?.append((MediaType.video, videoURL))
        }
        
        
        
        super.viewDidLoad()

        print("2")
        // Do any additional setup after loading the view.
        
        
        dataSource = self
        delegate = self
        
        print("+++****+++++********")
        print(mediaLoader)
        mediaLoader?.forEach{ context in
            print(context.url)
            
        }
//        print((mediaLoader?.first)!)
        print("+++****+++++********")
        
//        let initialViewImageController = PicturesViewController(imagePath: (mediaLoader?.first)!)
        let initialViewImageController = produceMediaView(for: mediaLoader?.first)
        
        
        self.setViewControllers([initialViewImageController], direction: .forward, animated: false, completion: nil)
        
        self.pageNumber = mediaLoader!.count
        
        
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
//        guard let currentIndex = mediaLoader!.firstIndex(of: (viewController as? PicturesViewController)!.imagePath) else {
//            return nil
//        }
        guard let currentIndex = mediaLoader?.firstIndex(where: {$0.url == (viewController as? MediaViewController)?.mediaURL}) else{
            return nil
        }

        if currentIndex == 0 {
            return nil
        } else {
            let newIndex = currentIndex - 1
            
//            didChangePage?(newIndex)
            
//            print("before \(newIndex)")
//            let page = PicturesViewController(imagePath: mediaLoader![newIndex])
//            updateImagePageNumer(viewController: page)
            let page = produceMediaView(for: mediaLoader![newIndex])
            return page
        }
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
//        guard let currentIndex = mediaLoader!.firstIndex(of: (viewController as? PicturesViewController)!.imagePath) else {
//            return nil
//        }
        guard let currentIndex = mediaLoader?.firstIndex(where: {$0.url == (viewController as? MediaViewController)?.mediaURL}) else{
            return nil
        }

        if currentIndex == mediaLoader!.count - 1 {
            return nil
        } else {
            let newIndex = currentIndex + 1
            
//            didChangePage?(newIndex)
            
//            databaseController?.updateCurrentImagePageNumber(pageNumber: newIndex)
//            let page = PicturesViewController(imagePath: mediaLoader![newIndex])
            let page = produceMediaView(for: mediaLoader![newIndex])
            return page
        }
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {
//        guard let viewController = pendingViewControllers.first as? PicturesViewController else { return }
//        guard let newIndex = mediaLoader?.firstIndex(of: viewController.imagePath) else { return }
        guard let viewController = pendingViewControllers.first as? MediaViewController else { return }
        guard let newIndex = mediaLoader?.firstIndex(where: { $0.url == viewController.mediaURL }) else { return }
        didChangePage?(newIndex)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if !completed {
//            guard let viewController = previousViewControllers.first as? PicturesViewController else { return }
//            guard let newIndex = mediaLoader?.firstIndex(of: viewController.imagePath) else { return }
            guard let viewController = previousViewControllers.first as? MediaViewController else { return }
            guard let newIndex = mediaLoader?.firstIndex(where: { $0.url == viewController.mediaURL }) else { return }
            didChangePage?(newIndex)
        }
    }
    
    func produceMediaView(for media:(type: MediaType, url: String)?) -> UIViewController{
        switch media?.type{
        case .image:
            return PicturesViewController(imagePath: media!.url)
        case .video:
            return VideoViewController(videoURL: media!.url)
        default:
            return UIViewController()
        }
    }
    


}

