//
//  AppDelegate.swift
//
//  Copyright © 2019 Rosberry. All rights reserved.
//

import ButterBroad
import CrashlyticsBroad

extension Butter {
    static let crashlytics: CrashlyticsBroad = .init()
    static let common: Butter = .init(broads: crashlytics)
}
