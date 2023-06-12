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
    
    var lastFollowingDocument: DocumentSnapshot?
    var isLastFollowingPage = false

    var lastFollowerDocument: DocumentSnapshot?
    var isLastFollowerPage = false

    weak var databaseController: DatabaseProtocol? = (UIApplication.shared.delegate as? AppDelegate)?.databaseController

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        tableView.delegate = self
        tableView.dataSource = self
        
        // setup the refresh control
        refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        tableView.addSubview(refreshControl)
        
        segmentedControl.addTarget(self, action: #selector(segmentedControlChanged), for: .valueChanged)
    }
    
    @objc func refreshData() {
        // Fetch the data again and reload the table view
        // Remember to call refreshControl.endRefreshing() when the request is done
        followingUsers.removeAll()
        lastFollowingDocument = nil
        isLastFollowingPage = false

        followerUsers.removeAll()
        lastFollowerDocument = nil
        isLastFollowerPage = false

        fetchNextPage()

        refreshControl.endRefreshing()
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
        if segmentedControl.selectedSegmentIndex == 0 {
            fetchFollowing()
        } else if segmentedControl.selectedSegmentIndex == 1 {
            fetchFollowers()
        }
    }
    
    func fetchFollowing() {
        if isLastFollowingPage {
            return
        }

        var query = Firestore.firestore().collection("user")
            .document((databaseController?.getCurrentUserUID())!)
            .collection("following")
            .order(by: "name")
            .limit(to: 10)
        if let lastDocument = lastFollowingDocument {
            query = query.start(afterDocument: lastDocument)
        }

        query.getDocuments { snapshot, error in
            guard let documents = snapshot?.documents else {
                print("Error fetching documents: \(error!)")
                self.isFetchingData = false
                return
            }

            self.followingUsers.append(contentsOf: documents.map { $0.reference })
            self.lastFollowingDocument = documents.last
            self.isLastFollowingPage = documents.count < 20
            self.tableView.reloadData()
            self.isFetchingData = false
        }
    }
    
    func fetchFollowers() {
        if isLastFollowerPage {
            return
        }

        var query = Firestore.firestore().collection("user")
            .document((databaseController?.getCurrentUserUID())!)
            .collection("followers")
            .order(by: "name")
            .limit(to: 10)
        if let lastDocument = lastFollowerDocument {
            query = query.start(afterDocument: lastDocument)
        }

        query.getDocuments { snapshot, error in
            guard let documents = snapshot?.documents else {
                print("Error fetching documents: \(error!)")
                self.isFetchingData = false
                return
            }

            self.followerUsers.append(contentsOf: documents.map { $0.reference })
            self.lastFollowerDocument = documents.last
            self.isLastFollowerPage = documents.count < 20
            self.tableView.reloadData()
            self.isFetchingData = false
        }
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "CELL_USER_INFO", for: indexPath) as! UserTableViewCell
        if segmentedControl.selectedSegmentIndex == 0{
            cell.setupWithUser(userDocRef: followingUsers[indexPath.row], showFollowButton: true)
        } else{
            cell.setupWithUser(userDocRef: followerUsers[indexPath.row], showFollowButton: false)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //
        performSegue(withIdentifier: "showOtherUserDetail", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showOtherUserDetail"{
            if let indexPath = tableView.indexPathForSelectedRow{
                var userDocRef: DocumentReference?
                if segmentedControl.selectedSegmentIndex == 0{
                    userDocRef = followingUsers[indexPath.row]
                    let destination = segue.destination as? OtherUserDetailViewController
                    destination?.currentUserDocRef = userDocRef
                } else{
                    userDocRef = followerUsers[indexPath.row]
                    let destination = segue.destination as? OtherUserDetailViewController
                    destination?.currentUserDocRef = userDocRef
                }
            }
        }
    }

}
