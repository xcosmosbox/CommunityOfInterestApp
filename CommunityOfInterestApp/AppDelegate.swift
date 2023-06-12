//
//  AppDelegate.swift
//  CommunityOfInterestApp
//
//  Created by Yuxiang Feng on 10/4/2023.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    // Create a connection to Firebase
    var databaseController: DatabaseProtocol?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        // create instance of FirebaseController
        databaseController = FirebaseController()
        // configuration for weather API
        setDefaultAPIInfo()
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
    // set weather API
    func setDefaultAPIInfo() {
        let APIELink = "https://api.weatherapi.com/v1/current.json?key=dab97fb14a374905b6a134741231605"

        let defaults = UserDefaults.standard
        defaults.set(APIELink, forKey: "apiLink")
    }
    
    // get weather API
    func getAPIInfo() -> String {
        let defaults = UserDefaults.standard
        let apiLink = defaults.string(forKey: "apiLink")

        return apiLink!
    }


}

