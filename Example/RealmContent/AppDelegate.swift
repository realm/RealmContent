//
//  AppDelegate.swift
//
//  Created by Marin Todorov
//  Copyright © 2017 - present Realm. All rights reserved.
//

import UIKit
import RealmSwift

/// configuration
let shouldConnectToROS = true
let host = "localhost"
let username = "test@host"
let password = "password"

/// app delegate
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

        if shouldConnectToROS {
            // syncs content from ROS
            connect(host: host, username: username, password: password, completion: showMainViewController)

        } else {
            // shows content from local realm
            showMainViewController()
        }

        return true
    }

    private func showMainViewController(success: Bool = true) {
        let storyboard = self.window!.rootViewController!.storyboard!
        self.window!.rootViewController = storyboard.instantiateViewController(withIdentifier: "Main")
    }
}

extension AppDelegate {
    // connect to a Realm Object Server

    func connect(host: String, username: String, password: String, completion: @escaping ((Bool)->Void) = {_ in}) {
        let credentials = SyncCredentials.usernamePassword(username: username, password: password)
        let serverUrl = URL(string: "http://\(host):9080")!

        SyncUser.logIn(with: credentials, server: serverUrl) { user, error in
            guard let user = user else {
                DispatchQueue.main.async { completion(false) }
                return
            }

            var conf = Realm.Configuration.defaultConfiguration
            conf.syncConfiguration = SyncConfiguration(user: user, realmURL: URL(string: "realm://\(host):9080/~/realmcontenttest")!)
            Realm.Configuration.defaultConfiguration = conf

            DispatchQueue.main.async { completion(true) }
        }
    }
}
