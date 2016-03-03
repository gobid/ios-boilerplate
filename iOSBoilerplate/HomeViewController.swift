//
//  HomeViewController.swift
//  iOSBoilerplate
//
//  Created by user on 11/25/15.
//  Copyright © 2015 test. All rights reserved.
//

import UIKit
import SwiftyUserDefaults

class HomeViewController: UIViewController {

    @IBOutlet weak var emailText: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    @IBAction func btnViewProfileClicked(sender: AnyObject) {
        let viewcontroller:UIViewController = (self.storyboard?.instantiateViewControllerWithIdentifier("profile"))!
        self.presentViewController(viewcontroller, animated: true, completion: nil)
    }
    
    
    @IBAction func logout(sender: AnyObject) {
        if ( GPPSignIn.sharedInstance().userID != nil ) {
            GPPSignIn.sharedInstance().signOut()
        }
        
        if ( FBSDKAccessToken.currentAccessToken() != nil ) {
            FBSDKLoginManager().logOut()
        }
        
        Defaults[.email] = nil

        let viewcontroller:UIViewController = (self.storyboard?.instantiateViewControllerWithIdentifier("signin"))!
        
        self.presentViewController(viewcontroller, animated: true, completion: nil)
    }
}
