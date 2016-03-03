//
//  BaseVC.swift
//  iOSBoilerplate
//
//  Created by Muhammad Adnan on 16/12/2015.
//  Copyright © 2015 test. All rights reserved.
//

import Foundation

class BaseVC:UIViewController{
    
    func showProgress(){
        PKHUD.sharedHUD.contentView = PKHUDProgressView()
        PKHUD.sharedHUD.show()
    }
    
    func hideProgress(){
        
        PKHUD.sharedHUD.hide()
    }
    
    func showDialog(msg:String){
        let alert = UIAlertController(title: "Alert", message:msg, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
        
    }
    
    func convertStringToDictionary(text: String) -> [String:AnyObject]? {
        if let data = text.dataUsingEncoding(NSUTF8StringEncoding) {
            do {
                let json = try NSJSONSerialization.JSONObjectWithData(data, options: .MutableContainers) as? [String:AnyObject]
                return json
            } catch {
                print("Something went wrong while converting string to dictionary")
            }
        }
        return nil
    }

}
