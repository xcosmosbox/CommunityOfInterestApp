//
//  FollowingFollowerViewController.swift
//  CommunityOfInterestApp
//
//  Created by Yuxiang Feng on 12/5/2023.
//

import UIKit
import Firebase
import FirebaseFirestoreSwift

class FollowingFollowerViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate {

    
    
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    @IBOutlet weak var tableView: UITableView!
    
    
    var followingUsers: [DocumentReference] = []
    var followerUsers: [DocumentReference] = []
    
    let refreshControl = UIRefreshControl()
    var isFetchingData = false // to avoid fetching data multiple items
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "UserTableViewCell", bundle: nil), forCellReuseIdentifier: "UserTableViewCell")
        
        // setup the refresh control
        refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        tableView.addSubview(refreshControl)
        
        segmentedControl.addTarget(self, action: #selector(segmentedControlChanged), for: .valueChanged)
    }
    
    @objc func refreshData() {
        // Fetch the data again and reload the table view
        // Remember to call refreshControl.endRefreshing() when the request is done
    }
    
    @objc func segmentedControlChanged() {
        tableView.reloadData()
    }

    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    // scroll view
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        if offsetY > contentHeight - scrollView.frame.height * 4 {
            // You're at the bottom of the table view, fetch the next page of data
            // Check isFetchingData to avoid fetching data multiple times
            if !isFetchingData {
                isFetchingData = true
                fetchNextPage()
            }
        }
    }
    
    func fetchNextPage() {
        // Fetch the next page of data here
        // Remember to set isFetchingData = false when the request is done
    }
    
    
    
    // table view
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if segmentedControl.selectedSegmentIndex == 0{
            return followingUsers.count
        } else{
            return followerUsers.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "UserTableViewCell", for: indexPath) as! UserTableViewCell
        if segmentedControl.selectedSegmentIndex == 0{
            cell.setupWithUser(userDocRef: followingUsers[indexPath.row], showFollowButton: true)
        } else{
            cell.setupWithUser(userDocRef: followerUsers[indexPath.row], showFollowButton: false)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //
    }

}
