//
//  User.swift
//  iOSBoilerplate
//
//  Created by Muhammad Adnan on 18/12/2015.
//  Copyright © 2015 test. All rights reserved.
//

import Foundation
import EVReflection

class User:EVObject{
    static var loggedInUser:User?
    static let LOGIN_TYPE_EMAIL:Int = 1
    static let LOGIN_TYPE_GOOGLE:Int  = 2
    static let LOGIN_TYPE_FACEBOOK:Int  = 3
    var url:String?
    var username:String?
    var email:String?
    var first_name:String?
    var last_name:String?
    var groups:[String]?
    var loginType:Int?
    var accessToken:String?
    var gender:String?
    var profilePictureUrl:String?
    var userId:String?
    
    func isFacebookUser()->Bool{
        return self.loginType == User.LOGIN_TYPE_FACEBOOK;
    }
    
    
}
