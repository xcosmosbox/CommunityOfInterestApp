//
//  PageImageViewController.swift
//  CommunityOfInterestApp
//
//  Created by Yuxiang Feng on 30/4/2023.
//

import UIKit

// PageImageViewController implements the UIPage
class PageImageViewController: UIPageViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    
    // media loader is an array of the tuple
    // tuple has two attributes
    // first is the media type
    // second is the url
    var mediaLoader: [(type: MediaType, url: String)]? = []
    
    public var pageNumber = 0
    
    let appDelegate = UIApplication.shared.delegate as? AppDelegate
    weak var databaseController: DatabaseProtocol?
    
    var didChangePage: ((Int) -> Void)?

    override func viewDidLoad() {
        // set the database controller
        databaseController = appDelegate?.databaseController
        let cardCache = databaseController?.getOneCardCache()
        
        // set the mediaLoader
        cardCache?.picture?.forEach{ pic in
            mediaLoader?.append((MediaType.image, pic))
        }
        
        cardCache?.video?.forEach{ videoURL in
            mediaLoader?.append((MediaType.video, videoURL))
        }
        
        cardCache?.audio?.forEach{ audioURL in
            mediaLoader?.append((MediaType.audio, audioURL))
        }
        
        
        
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        // implements the dataSource and delegate
        dataSource = self
        delegate = self

        
        // produce the first media
        let initialViewImageController = produceMediaView(for: mediaLoader?.first)
        
        // set the page
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
        guard let currentIndex = mediaLoader?.firstIndex(where: {$0.url == (viewController as? MediaViewController)?.mediaURL}) else{
            return nil
        }

        if currentIndex == 0 {
            return nil
        } else {
            let newIndex = currentIndex - 1
            let page = produceMediaView(for: mediaLoader![newIndex])
            return page
        }
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let currentIndex = mediaLoader?.firstIndex(where: {$0.url == (viewController as? MediaViewController)?.mediaURL}) else{
            return nil
        }

        if currentIndex == mediaLoader!.count - 1 {
            return nil
        } else {
            let newIndex = currentIndex + 1
            let page = produceMediaView(for: mediaLoader![newIndex])
            return page
        }
    }
    
    // using these two method to chage the page control bar
    func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {
        guard let viewController = pendingViewControllers.first as? MediaViewController else { return }
        guard let newIndex = mediaLoader?.firstIndex(where: { $0.url == viewController.mediaURL }) else { return }
        didChangePage?(newIndex)
    }
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if !completed {
            guard let viewController = previousViewControllers.first as? MediaViewController else { return }
            guard let newIndex = mediaLoader?.firstIndex(where: { $0.url == viewController.mediaURL }) else { return }
            didChangePage?(newIndex)
        }
    }
    
    // according to the different media type to return the page
    func produceMediaView(for media:(type: MediaType, url: String)?) -> UIViewController{
        switch media?.type{
        case .image:
            return PicturesViewController(imagePath: media!.url)
        case .video:
            return VideoViewController(videoURL: media!.url)
        case .audio:
            return AudioViewController(audioURL: media!.url)
        default:
            return UIViewController()
        }
    }
    


}

