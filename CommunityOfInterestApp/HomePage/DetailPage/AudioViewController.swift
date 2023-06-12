//
//  AudioViewController.swift
//  CommunityOfInterestApp
//
//  Created by Yuxiang Feng on 16/5/2023.
//

import UIKit
import AVKit
import AVFoundation
import FirebaseStorage

// audio class to play the audio file
class AudioViewController: MediaViewController {
    
    // set the url and firebase storage
    let audioURL: String
    let storage = Storage.storage()
    
    init(audioURL: String) {
        self.audioURL = audioURL
        super.init(mediaURL: audioURL)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        // using storage to download the audio file
        if let gsURL = URL(string: mediaURL){
            let gsReference = storage.reference(forURL: gsURL.absoluteString)
            // download
            gsReference.getData(maxSize: 100 * 1024 * 1024){ (data, error) in
                if let error = error{
                    print("error for download AudioViewController: \(error)")
                    return
                }
                
                // download success
                if let data = data{
                    // set the audio player
                    let temporaryDirectory = NSTemporaryDirectory()
                    let temporaryFileURL = URL(fileURLWithPath: temporaryDirectory).appendingPathComponent("temp_\(UUID().uuidString).mp3")
                    
                    do {
                        // write data
                        try data.write(to: temporaryFileURL)
                        
                        // crate AVPlayerItem to load the temp data
                        let playerItem = AVPlayerItem(url: temporaryFileURL)
                        
                        // create AVPlayer and link to AVPlayerItem
                        let player = AVPlayer(playerItem: playerItem)
                        
                        // create AVPlayerViewController and link to AVPlayer
                        let playerViewController = AVPlayerViewController()
                        playerViewController.player = player
                        
                        
                        self.addChild(playerViewController)
                        self.view.addSubview(playerViewController.view)
                        playerViewController.view.frame = self.view.frame
                        playerViewController.didMove(toParent: self)
                        
                    } catch {
                        // error
                        print("Error writing file: \(error)")
                    }
                                
                } else{
                    print("no data !!!")
                }
                
            }
        }
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
