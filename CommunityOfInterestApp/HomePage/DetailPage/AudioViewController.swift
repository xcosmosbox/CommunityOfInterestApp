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

class AudioViewController: MediaViewController {
    
    let audioURL: String
    let storage = Storage.storage()
//    var audioPlayer: AVAudioPlayer?
    
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
        
        if let gsURL = URL(string: mediaURL){
            let gsReference = storage.reference(forURL: gsURL.absoluteString)
            // download
            gsReference.getData(maxSize: 100 * 1024 * 1024){ (data, error) in
                if let error = error{
                    print("error for download AudioViewController: \(error)")
                    return
                }
                
                if let data = data{
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
                        
                        // play
//                        playerViewController.player?.play()
                        
                    } catch {
                        // error
                        print("Error writing file: \(error)")
                    }
                                
                } else{
                    print("no data !!!")
                }
                
            }
        }
        
//        if let gsURL = URL(string: audioURL) {
//            let gsReference = storage.reference(forURL: gsURL.absoluteString)
//
//            gsReference.getData(maxSize: 100 * 1024 * 1024) { (data, error) in
//                if let error = error {
//                    print("Error downloading audio: \(error)")
//                    return
//                }
//
//                if let data = data {
//                    print(data)
//                    let temporaryDirectory = NSTemporaryDirectory()
//                    let temporaryFileURL = URL(fileURLWithPath: temporaryDirectory).appendingPathComponent("temp_\(UUID().uuidString).mp3")
//                    print("dhjouahwuoda\(temporaryFileURL)")
//                    do {
//                        print("1")
//                        try data.write(to: temporaryFileURL)
//                        print("temo\(temporaryFileURL)")
//
//                        print("2")
//
//                        let audioPlayer = try AVAudioPlayer(contentsOf: temporaryFileURL)
//
//                        print("audio:\(audioPlayer)")
//
//
//                        audioPlayer.prepareToPlay()
////                        audioPlayer.play()
//
//                    } catch {
//                        print("Error writing or playing audio file: \(error)")
//                    }
//                } else {
//                    print("No data received for audio file.")
//                }
//            }
//        }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
//
//    override func viewWillDisappear(_ animated: Bool) {
//        self.audioPlayer?.stop()
//    }

}
