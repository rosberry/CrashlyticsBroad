//
//  Butter+ApplicationBroads.swift
//
//  Copyright © 2019 Rosberry. All rights reserved.
//

import ButterBroad

extension Butter {
    static let firebase: FirebaseBroad = .init()
    static let common: Butter = .init(broads: firebase)
}
