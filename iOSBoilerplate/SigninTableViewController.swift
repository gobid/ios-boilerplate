//
//  SigninTableViewController.swift
//  iOSBoilerplate
//
//  Created by user on 11/26/15.
//  Copyright © 2015 test. All rights reserved.
//

import UIKit
import FBSDKLoginKit

import Alamofire
import PKHUD
import SwiftyUserDefaults


class SigninTableViewController: BaseVC, UITextFieldDelegate, FBSDKLoginButtonDelegate, GPPSignInDelegate {
    @IBOutlet weak var gppSignInButton: GPPSignInButton!
    @IBOutlet weak var loginButton: FBSDKLoginButton!
    @IBOutlet var txtPassword: MKTextField!
    @IBOutlet var txtUserName: MKTextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        loginButton.delegate = self;
        
        gppSignInButton?.colorScheme = kGPPSignInButtonColorSchemeDark
        gppSignInButton?.style = kGPPSignInButtonStyleWide
        
        let signIn = GPPSignIn.sharedInstance()
        signIn?.shouldFetchGooglePlusUser = true
        signIn?.shouldFetchGoogleUserEmail = true
        signIn?.shouldFetchGoogleUserID = true
        signIn?.clientID = Constants.GOOGLE_CLIENT_ID
        signIn?.scopes = [kGTLAuthScopePlusLogin]
        signIn?.delegate = self
        
        txtUserName.layer.borderColor = UIColor.clearColor().CGColor
        txtUserName.floatingPlaceholderEnabled = true
        txtUserName.placeholder = "Email"
        txtUserName.tintColor = UIColor.MKColor.Blue
        txtUserName.rippleLocation = .Center
        txtUserName.cornerRadius = 0
        txtUserName.bottomBorderEnabled = true
        
        txtPassword.layer.borderColor = UIColor.clearColor().CGColor
        txtPassword.floatingPlaceholderEnabled = true
        txtPassword.placeholder = "Password"
        txtPassword.tintColor = UIColor.MKColor.Blue
        txtPassword.rippleLocation = .Center
        txtPassword.cornerRadius = 0
        txtPassword.bottomBorderEnabled = true
    }
    
    override func viewDidAppear(animated: Bool) {
        if (FBSDKAccessToken.currentAccessToken() != nil) {
            self.fetchUserInforFromFacebook({(success) -> () in
                NSLog("FetchFinished")
                // FBSDKLoginManager().logOut()
                self.userLoggedInWithSocialMedia()
            })
        }
        else {
            loginButton.readPermissions = ["public_profile", "email", "user_friends"]
        }
        
        let email = Defaults[.email]
        
        if(email != nil) {
            let dict = Defaults[.serverToken] as NSDictionary!
            let acct:ServerAccessToken =  ServerAccessToken(dictionary:dict)
            if acct.access_token != nil {
                gotoDashboard()
            }
        }
        
        let signIn = GPPSignIn.sharedInstance()

        if (( signIn?.idToken ) != nil) {
            // NSLog("SignINToken = %@",(signIn?.idToken)!)
            // signIn?.signOut()
            signIn.trySilentAuthentication()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    //    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    //        // #warning Incomplete implementation, return the number of sections
    //        return 0
    //    }
    //
    //    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    //        // #warning Incomplete implementation, return the number of rows
    //        return 0
    //    }
    
    /*
        override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier", forIndexPath: indexPath)
    
            // Configure the cell...
            return cell
        }
    */
    
    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
    // Return false if you do not want the specified item to be editable.
        return true
    }
    */
    
    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
    }
    */
    
    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {
    }
    */
    
    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
    // Return false if you do not want the item to be re-orderable.
    return true
    }
    */
    
    /*
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    // Get the new view controller using segue.destinationViewController.
    // Pass the selected object to the new view controller.
    }
    */
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }
    
    
    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!) {
        if ((error) != nil) {
            // Process error
        }
        else if result.isCancelled {
            // Handle cancellations
        }
        else {
            // If you ask for multiple permissions at once, you
            // should check if specific permissions missing
            // if result.grantedPermissions.contains("email") {
            // Do work
            NSLog("TokenString=%@", FBSDKAccessToken.currentAccessToken().tokenString)
            NSLog("UserID=%@", FBSDKAccessToken.currentAccessToken().userID)
            self.fetchUserInforFromFacebook({ (success) -> () in
                NSLog("FetchFinished")
                if success {
                    self.userLoggedInWithSocialMedia()
                }
            })
            // }
        }
    }
    
    func fetchUserInforFromFacebook(withcompletionHandler: (success:Bool) ->()){
        if ((FBSDKAccessToken.currentAccessToken()) != nil){
            let request = FBSDKGraphRequest(graphPath:"me", parameters:["fields":"id,email,name,first_name,last_name,picture.width(480).height(480)"])
            request.startWithCompletionHandler({connection, result, error in
                if error == nil {
                    let user =  User();
                    user.userId=FBSDKAccessToken.currentAccessToken().userID
                    user.email = result.valueForKey("email") as? String
                    user.profilePictureUrl = "https://graph.facebook.com/"
                        + FBSDKAccessToken.currentAccessToken().userID + "/picture?type=large";
                    
                    user.accessToken=FBSDKAccessToken.currentAccessToken().tokenString;
                    user.loginType = User.LOGIN_TYPE_FACEBOOK;
                    user.first_name = result.valueForKey("first_name") as? String
                    user.last_name=result.valueForKey("last_name") as? String
                    
                    
                    User.loggedInUser=user;
                    self.resetForm();
                    withcompletionHandler(success: true)
                }
                else {
                    withcompletionHandler(success: false)
                }
            })
        }
    }
    
    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
    }
    
    func loginButtonWillLogin(loginButton: FBSDKLoginButton!) -> Bool {
        return true
    }
    
    func finishedWithAuth(auth: GTMOAuth2Authentication!, error: NSError!) {
        if (( error ) != nil) {
            NSLog("google auth failed!")
        }
        else {
            NSLog("finished with auth!")
            
            let signIn = GPPSignIn.sharedInstance()
            if (( signIn?.idToken ) != nil) {
                NSLog("SignINToken = %@",(signIn?.idToken)!)
            }
            
            if ( signIn.userID != nil ) {
                NSLog("ID=%@", signIn.userID)
                NSLog("Email=%@", signIn.userEmail)
                
                let usr = GPPSignIn.sharedInstance().googlePlusUser
                
                if (( usr ) != nil) {
                    NSLog("UsernameFirst=%@", usr.name.givenName)
                    NSLog("UsernameLast=%@", usr.name.familyName)
                    
                    // appDelegate.firstName = usr.name.givenName
                    // appDelegate.lastName = usr.name.familyName
                }
                
                //appDelegate.email = signIn.userEmail
                
                let user =  User();
                user.email = signIn.userEmail
                user.profilePictureUrl = usr.image.url;
                user.accessToken=signIn.authentication.accessToken;
                user.loginType = User.LOGIN_TYPE_GOOGLE;
                user.first_name = usr.name.givenName
                user.last_name=usr.name.familyName
                
                User.loggedInUser=user;
                self.resetForm();
                self.userLoggedInWithSocialMedia();
            }
        }
    }
    
    func userLoggedInWithSocialMedia(){
        
        // if (!TextUtils.isEmpty(Prefs.getString(mContext.getString(R.string.key_user_access_token), ""))) { 
        // Already Logged in
        //     goToLandingPage();
        //     return;
        // }
        // showProgressDialog(R.string.msg_sigining_in);
        
        showProgress();
        Alamofire.request(.POST,Constants.BASE_SERVER_URL + Constants.NAMESPACE_TOKEN_EXCHANGE,  parameters: [Constants.KEY_CLIENT_ID: Constants.CLIENT_ID,Constants.KEY_CLIENT_SECRITE: Constants.CLIENT_SECRIT,"backend":User.loggedInUser!.isFacebookUser() ? "facebook" : "google-oauth2","token":(User.loggedInUser?.accessToken)!,"grant_type":"convert_token"]).responseJSON { response in
                self.hideProgress();
            
                if response.response == nil {
                    self.showDialog("Unable to login into server.\nPlease try again later.")
                    return;
                }
                
                if (response.response?.statusCode)! != 200 {
                    self.showDialog("Unable to login into server. Please try again later")
                    self.resetForm()
                    return
                }
                
                let jsonDic = response.result.value as! NSDictionary
                let serverAccessToken = ServerAccessToken(dictionary: jsonDic)
                
                Defaults[.serverToken] = jsonDic
                User.loggedInUser?.accessToken=serverAccessToken.access_token;
                self.resetForm();
                self.gotoDashboard();
        }
        // on server login
    }
    
    func didDisconnectWithError ( error: NSError) -> Void {
        NSLog("didDisconnectWithError!")
    }
    
    @IBAction func loginClicked(sender: AnyObject) {
        showProgress();
        Alamofire.request(.POST, Constants.BASE_SERVER_URL + Constants.NAMESPACE_EMAIL_SIGN_IN,  parameters: [Constants.KEY_CLIENT_ID: Constants.CLIENT_ID,Constants.KEY_CLIENT_SECRITE: Constants.CLIENT_SECRIT,"username": (txtUserName?.text)!,"password":txtPassword.text!,"grant_type":"password"])
            .responseJSON { response in
                self.hideProgress();
                
                if response.response == nil {
                    self.showDialog("Unable to login into server.\nPlease try again later.")
                    return;
                }
                
                if (response.response?.statusCode)! != 200 {
                    self.showDialog("Invalid username/password or your account is not activated yet. Please check your email for activation link.")
                    self.resetForm()
                    return
                }
                
                let jsonDic = response.result.value as! NSDictionary
                let serverAccessToken = ServerAccessToken(dictionary: jsonDic)
                
                Defaults[.email] = self.txtUserName.text
                Defaults[.serverToken] = jsonDic
                let user =  User();
                user.email = self.txtUserName.text;
                user.accessToken=serverAccessToken.access_token;
                user.loginType = User.LOGIN_TYPE_EMAIL;
                User.loggedInUser=user;
                self.resetForm();
                self.gotoDashboard();
        }
    }
    
    @IBAction func signUpClicked(sender: AnyObject) {
        showProgress();
        Alamofire.request(.POST, Constants.BASE_SERVER_URL + Constants.NAMESPACE_EMAIL_SIGNUP,  parameters: [Constants.KEY_CLIENT_ID: Constants.CLIENT_ID,Constants.KEY_CLIENT_SECRITE: Constants.CLIENT_SECRIT,"username": (txtUserName?.text)!,"password":txtPassword.text!,"email": txtUserName.text!])
            .response { request, response, data, error in
                self.hideProgress();
                
                if (error != nil) {
                    self.showDialog("Unable to signup right now. Please try again later.");
                    return;
                }
                
                let statusCode = (response?.statusCode)!
                
                if (statusCode != 201) {
                    self.showDialog("Unable to signup right now. Please try again later.");
                    return;
                }
                
                self.resetForm();
                self.showDialog("Your account has been created successfully. Please check your email for activation link.");
                self.resetForm();
        }
    }
    
    func validateFields()->Bool{
        var errMsg = ""
        
        if !isValidEmail(){
            errMsg = "Please enter a valid email"
            
        } else if !isValidPassword(){
            errMsg = "Please enter a valid password"
        }
        
        if errMsg != ""{
            showDialog(errMsg);
            return false
        }
        
        return true
    }
    
    
    func isValidEmail() -> Bool {
        let testStr = txtUserName.text;
        // println("validate calendar: \(testStr)")
        let emailRegEx = "^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluateWithObject(testStr)
    }
    
    func isValidPassword() -> Bool {
        return txtUserName.text != ""
    }
    
    @IBAction func forgotPasswordClicked(sender: AnyObject) {
        if !isValidEmail(){
            showDialog("Please enter a valid email")
            return
        }
        showProgress();
        
        Alamofire.request(.POST, Constants.BASE_SERVER_URL + Constants.NAMESPACE_PASSWORD_RESET, parameters: [Constants.KEY_CLIENT_ID: Constants.CLIENT_ID,Constants.KEY_CLIENT_SECRITE: Constants.CLIENT_SECRIT,"email": (txtUserName?.text)!])
            .response { request, response, data, error in
                self.hideProgress();
                
                if(error != nil){
                    self.showDialog("Unable to login into server.\nPlease try again later.")
                    return;
                }
                
                let statusCode = (response?.statusCode)!
                
                if (statusCode != 200) {
                    self.showDialog("Invalid token received from server. Please try again later.");
                    return;
                }
                
                self.resetForm();
                self.showDialog("A password reset link has been sent to your email.")
        }
        
    }
    
    func resetForm(){
        txtUserName.text = ""
        txtPassword.text=""
    }
    
    func gotoDashboard(){
        let viewcontroller = self.storyboard?.instantiateViewControllerWithIdentifier("home")
        self.presentViewController(viewcontroller!, animated: true, completion: nil)
    }
}
