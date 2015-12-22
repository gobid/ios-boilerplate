//
//  ServerAccessToken.swift
//  iOSBoilerplate
//
//  Created by Muhammad Adnan on 18/12/2015.
//  Copyright © 2015 test. All rights reserved.
//

import Foundation
import EVReflection
class ServerAccessToken:EVObject{

    var access_token: String?
    var token_type: String?
    var expires_in: Int?
    var refresh_token: String?
    var scope: String?
    
}
