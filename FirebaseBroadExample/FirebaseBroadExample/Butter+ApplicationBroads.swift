//
//  Butter+ApplicationBroads.swift
//
//  Copyright © 2019 Rosberry. All rights reserved.
//

import ButterBroad
import FirebaseBroad
import Firebase

extension Butter {
    static let firebase: FirebaseBroad = .init(Firebase.Analytics.self)
    static let common: Butter = .init(broads: firebase)
}
