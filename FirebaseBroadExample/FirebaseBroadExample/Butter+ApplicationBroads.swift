//
//  Butter+ApplicationBroads.swift
//
//  Copyright © 2019 Rosberry. All rights reserved.
//

import ButterBroad
import FirebaseBroad

extension Butter {
    static let Firebase: FirebaseBroad = .init()
    static let common: Butter = .init(broads: Firebase)
}
