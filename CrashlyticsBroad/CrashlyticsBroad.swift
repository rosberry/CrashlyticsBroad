//
//  AppDelegate.swift
//
//  Copyright © 2019 Rosberry. All rights reserved.
//

import ButterBroad
import Firebase

final public class CrashlyticsBroad: ButterBroad.Analytics {

    /// Creates an instance of CrashlyticsBroad. To use it one of the overrides of 'FirebaseApp.configure' methods should be called
    public init() {
    }

    public func log(_ event: Event) {
        Firebase.Analytics.logEvent(event.name, parameters: event.params)
    }
}
