//
//  DefaultKeyExtension.swift
//  iOSBoilerplate
//
//  Created by Muhammad Adnan on 18/12/2015.
//  Copyright © 2015 test. All rights reserved.
//

import Foundation
import SwiftyUserDefaults

extension DefaultsKeys {
    static let username = DefaultsKey<String?>("username")
    static let email = DefaultsKey<String?>("email")
    static let serverToken = DefaultsKey<NSDictionary>("token")
}