//
//  FirebaseBroad.swift
//
//  Copyright © 2019 Rosberry. All rights reserved.
//

import ButterBroad
import Firebase

final public class FirebaseBroad: ButterBroad.Analytics {

    private var needsConfigureApp: Bool

    public lazy var activationHandler: (() -> Void)? = {
        if self.needsConfigureApp {
            FirebaseApp.configure()
        }
    }

    /// Creates an instance of FirebaseBroad. To use it one of the overrides of 'FirebaseApp.configure' methods should be called
    public init(needsConfigureApp: Bool = false) {
        self.needsConfigureApp = needsConfigureApp
    }

    public func log(_ event: Event) {
        Firebase.Analytics.logEvent(event.name, parameters: event.params)
    }
}
