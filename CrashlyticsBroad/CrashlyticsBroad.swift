//
//  CrashlyticsBroad.swift
//  CrashlyticsBroad
//
//  Created by Nick Tyunin on 22/08/2019.
//  Copyright © 2019 Rosberry. All rights reserved.
//

import ButterBroad
import Fabric
import Firebase
import Crashlytics

final public class CrashlyticsBroad: ButterBroad.Analytics {
    
    private var isFireBaseEnabled: Bool
    
    public init(withFirebase isFireBaseEnabled: Bool = true) {
        self.isFireBaseEnabled = isFireBaseEnabled
        Fabric.with([Crashlytics.self])
        if isFireBaseEnabled {
            FirebaseApp.configure()
        }
    }

    public func log(_ event: Event) {
        Answers.logCustomEvent(withName: event.name, customAttributes: event.params)
        if isFireBaseEnabled {
            Firebase.Analytics.logEvent(event.name, parameters: event.params)
        }
    }
}
