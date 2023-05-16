//
//  VideoViewController.swift
//  CommunityOfInterestApp
//
//  Created by Yuxiang Feng on 16/5/2023.
//

import UIKit
import AVKit
import AVFoundation

class VideoViewController: UIViewController {
    
    
    let videoURL: String

    init(videoURL: String) {
        self.videoURL = videoURL.replacingOccurrences(of: "gs://", with: "https://storage.googleapis.com/")
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        guard let url = URL(string: self.videoURL) else {
            return
        }

        let player = AVPlayer(url: url)

        let playerViewController = AVPlayerViewController()
        playerViewController.player = player

        addChild(playerViewController)
        view.addSubview(playerViewController.view)
        playerViewController.view.frame = view.frame
        playerViewController.didMove(toParent: self)

        player.play()
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
