//
//  AppDelegate.swift
//  CrashlyticsBroadExample
//
//  Created by Nick Tyunin on 22/08/2019.
//  Copyright © 2019 Rosberry. All rights reserved.
//

import UIKit
import ButterBroad
import CrashlyticsBroad

extension Butter {
    static let crashlytics: CrashlyticsBroad = .init()
    static let common: Butter = .init(broads: crashlytics)
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        return true
    }
}

