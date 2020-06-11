//
//  FirebaseBroad.swift
//
//  Copyright © 2019 Rosberry. All rights reserved.
//

import ButterBroad
import Foundation

final public class FirebaseBroad: ButterBroad.Analytics {

    public lazy var activationHandler: (() -> Void)? = {
    }

    private let firebaseClass: NSObjectProtocol
    private let selector: Selector

    /// Creates an instance of FirebaseBroad. To use it one of the overrides of 'FirebaseApp.configure' methods should be called
    public init() {
        let selector = NSSelectorFromString("logEventWithName:parameters:")
        guard let firebaseClass = NSClassFromString("FIRAnalytics") as AnyObject as? NSObjectProtocol,
            firebaseClass.responds(to: selector)  else {
            fatalError("`Firebase` instance is not looks configured properly")
        }
        self.firebaseClass = firebaseClass
        self.selector = selector
    }

    public func log(_ event: Event) {
        firebaseClass.perform(selector, with: event.name, with: event.params)
    }
}
