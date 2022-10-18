//
//  AppDelegate.swift
//  OpenPassDevelopmentApp
//
//  Created by Brad Leege on 10/14/22.
//

import SwiftUI

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = UIHostingController(rootView: RootView())
        window?.makeKeyAndVisible()
        
        return true
    }

}
