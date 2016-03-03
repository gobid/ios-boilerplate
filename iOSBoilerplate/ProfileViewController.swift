//
//  ProfileViewController.swift
//  iOSBoilerplate
//
//  Created by user on 11/25/15.
//  Copyright © 2015 test. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyUserDefaults
import JDSwiftAvatarProgress
class ProfileViewController: BaseVC {
    
    
    @IBOutlet weak var emailTextField: MKTextField!
    @IBOutlet weak var lastNameText: MKTextField!
    @IBOutlet weak var firstNameText: MKTextField!
    @IBOutlet weak var userNameText: MKTextField!
    
    @IBOutlet var profileImageView:JDAvatarProgress!
    var djangoUserId:Int=0;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        profileImageView.image = UIImage(named: "default_profile")!
        
        // Do any additional setup after loading the view.
        emailTextField.layer.borderColor = UIColor.clearColor().CGColor
        emailTextField.floatingPlaceholderEnabled = true
        emailTextField.placeholder = "Email"
        emailTextField.tintColor = UIColor.MKColor.Blue
        emailTextField.rippleLocation = .Center
        emailTextField.cornerRadius = 0
        emailTextField.bottomBorderEnabled = true

        
        // Do any additional setup after loading the view.
        lastNameText.layer.borderColor = UIColor.clearColor().CGColor
        lastNameText.floatingPlaceholderEnabled = true
        lastNameText.placeholder = "Last Name"
        lastNameText.tintColor = UIColor.MKColor.Blue
        lastNameText.rippleLocation = .Center
        lastNameText.cornerRadius = 0
        lastNameText.bottomBorderEnabled = true

        
        // Do any additional setup after loading the view.
        firstNameText.layer.borderColor = UIColor.clearColor().CGColor
        firstNameText.floatingPlaceholderEnabled = true
        firstNameText.placeholder = "First Name"
        firstNameText.tintColor = UIColor.MKColor.Blue
        firstNameText.rippleLocation = .Center
        firstNameText.cornerRadius = 0
        firstNameText.bottomBorderEnabled = true

        
        // Do any additional setup after loading the view.
        userNameText.layer.borderColor = UIColor.clearColor().CGColor
        userNameText.floatingPlaceholderEnabled = true
        userNameText.placeholder = "User Name"
        userNameText.tintColor = UIColor.MKColor.Blue
        userNameText.rippleLocation = .Center
        userNameText.cornerRadius = 0
        userNameText.bottomBorderEnabled = true
        
        self.getProfile()
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func logout(sender: AnyObject) {
        if ( GPPSignIn.sharedInstance().userID != nil ) {
            GPPSignIn.sharedInstance().signOut()
        }
        
        if ( FBSDKAccessToken.currentAccessToken() != nil ) {
            FBSDKLoginManager().logOut()
        }
        
        let viewcontroller:UIViewController = (self.storyboard?.instantiateViewControllerWithIdentifier("signin"))!
        
        self.presentViewController(viewcontroller, animated: true, completion: nil)
    }
    
    func getProfile() {
        //  if(!validateFields()){return}
        showProgress()
        
        // let json = Defaults[.serverToken]
        // let jsonDic = convertStringToDictionary(json)
        let accessToken = ServerAccessToken(dictionary: Defaults[.serverToken])
        
        let headers = [
            "Authorization": " Django " + accessToken.access_token!
        ]
        
        Alamofire.request(.GET, Constants.BASE_SERVER_URL + Constants.NAMESPACE_ME, headers:headers)
            .responseJSON { response in
                if response.response == nil {
                    self.hideProgress();

                    self.showDialog("Unable to get user data.\nPlease try again later.")
                    return;
                }
                
                if (response.response?.statusCode)! != 200 {
                    self.hideProgress();

                    self.showDialog("Unable to get user data.\nPlease try again later.")
                    
                    return
                }
                
                let jsonDic = response.result.value as! NSDictionary
                self.djangoUserId = Int(jsonDic.objectForKey("id")!.intValue)
                
                
                Alamofire.request(.GET, Constants.BASE_SERVER_URL + Constants.NAMESPACE_ME, headers:headers)
                    .responseJSON { response in
                        if response.response == nil {
                            self.hideProgress();
                            self.showDialog("Unable to get user data.\nPlease try again later.")
                            return;
                        }
                        
                        if (response.response?.statusCode)! != 200 {
                            self.hideProgress();
                            self.showDialog("Unable to get user data.\nPlease try again later.")
                            return
                        }
                        
                        let jsonDic = response.result.value as! NSDictionary
                        self.djangoUserId = Int(jsonDic.objectForKey("id")!.intValue)
                        
                        Alamofire.request(.GET, Constants.BASE_SERVER_URL + Constants.NAMESPACE_ME_INFO.stringByReplacingOccurrencesOfString("#", withString: String(self.djangoUserId)), headers:headers)
                            .responseJSON { response in
                                self.hideProgress();
                                if response.response == nil {
                                    self.showDialog("Unable to get user data.\nPlease try again later.")
                                    return;
                                }
                                
                                if (response.response?.statusCode)! != 200 {
                                    self.showDialog("Unable to get user data.\nPlease try again later.")
                                    return
                                }
                                
                                let jsonDic = response.result.value as! NSDictionary
                                
                                let user = User(dictionary:jsonDic)
                                user.loginType = User.loggedInUser?.loginType
                                user.profilePictureUrl = User.loggedInUser?.profilePictureUrl
                                self.loadData(user);
                        }
  
                }
        }
    }
    
    @IBAction func updateProfile(sender: AnyObject) {
        if(!validateFields()){
            return
        }
        
        showProgress()
        
        let accessToken = ServerAccessToken(dictionary: Defaults[.serverToken])
        
        let headers = [
            "Authorization": " Django " + accessToken.access_token!
        ]
        
        let parameters = [
            "first_name": firstNameText.text!,
            "last_name": lastNameText.text!
        ]
        
        Alamofire.request(.PATCH, Constants.BASE_SERVER_URL + Constants.NAMESPACE_ME_INFO.stringByReplacingOccurrencesOfString("#", withString: String(self.djangoUserId)), headers:headers, parameters:parameters)
            .responseJSON { response in
                
                self.hideProgress();
                
                if response.response == nil {
                    self.showDialog("Unable to update profile data.\nPlease try again later.")
                    return;
                }
                
                if (response.response?.statusCode)! != 200 {
                    self.showDialog("Unable to update user data.\nPlease try again later.")
                    return
                }
                
                let jsonDic = response.result.value as! NSDictionary
                
                let user = User(dictionary:jsonDic)
                
                user.loginType = User.loggedInUser?.loginType
                user.profilePictureUrl = User.loggedInUser?.profilePictureUrl
                self.loadData(user);
        }
    }
    
    func loadData(user:User){
        if user.loginType != User.LOGIN_TYPE_EMAIL && user.profilePictureUrl != nil {
            profileImageView.setImageWithURL(NSURL(string: user.profilePictureUrl!)!)
        }
        
        emailTextField.text = user.email
        firstNameText.text = user.first_name
        lastNameText.text = user.last_name
        userNameText.text = user.username
    }
    
    func validateFields()->Bool{
        var errMsg = ""
        
        if (firstNameText.text == "") {
            errMsg = "Please enter a valid first name"
        }
        else if (lastNameText.text == "") {
            errMsg = "Please enter a valid last name"
        }
        
        if errMsg != ""{
            showDialog(errMsg);
            return false
        }
        
        return true
    }
    
    @IBAction func backToMenu(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}
