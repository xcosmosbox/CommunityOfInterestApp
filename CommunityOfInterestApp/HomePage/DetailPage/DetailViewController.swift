//
//  DetailViewController.swift
//  CommunityOfInterestApp
//
//  Created by Yuxiang Feng on 30/4/2023.
//

import UIKit

class DetailViewController: UIViewController {
    
    var card:Card? = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("=====")
        print(card)
        print("+++++")

        // Do any additional setup after loading the view.
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


protocol DetailChangeDelegate {
    func loadCardDetail(_ card: Card)
}

