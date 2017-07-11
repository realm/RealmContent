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
        let menu = storyboard.instantiateViewController(withIdentifier: "Main")
        self.window!.rootViewController = menu

        if !success {
            let alert = UIAlertController(title: "Couldn't connect to \(host)", message: "Still fine though! The demo app will use temporarily a local Realm file.\n----------------\n For a syncing demo start your ROS, adjust connection details in AppDelegate.swift, and restart the app.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Close", style: .default, handler: { _ in
                menu.dismiss(animated: true, completion: nil)
            }))
            menu.present(alert, animated: true, completion: nil)
        }
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
            conf.syncConfiguration = SyncConfiguration(user: user, realmURL: URL(string: "realm://\(host):9080/~/realmcontenttest1")!)
            Realm.Configuration.defaultConfiguration = conf

            //some demo data
            let realm = try! Realm()
            if realm.isEmpty {
                try! realm.write {
                    realm.add(Person(value: ["name": "Meghan", "dogs": [Dog(value: ["name": "Rex", "age": 1])]]))
                }
            }

            DispatchQueue.main.async { completion(true) }
        }
    }
}
