//
//  AuthProvider.swift
//  Chat App
//
//  Created by Mohamed Mahmoud Zaki on 7/31/18.
//  Copyright © 2018 Mohamed Mahmoud Zaki. All rights reserved.
//

import Foundation
import FirebaseAuth


typealias loginHandlerError = (_ msg :String?) -> Void

struct errorTypes {
    static let  Invalid_Email = "Invalid Email"
    static let  Wrong_Pass = "Wrong password"
    static let User_Notfound = "User not found"
    static let random = "random error"
}
class AuthProvider {
    private static let Shared = AuthProvider()
    static var shared: AuthProvider  {
        return Shared
    }
    private var _username = ""
    var username : String {
        return _username
    }
    func login(email:String, password :String , loginhanlder: loginHandlerError?) {
        
        Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
            if error != nil{
                self.handleErrors(error: error! as NSError, loginhandler: loginhanlder)
            }
            else {
                self._username = email
                loginhanlder?(nil)
            }
        }
    }
    private func handleErrors (error : NSError, loginhandler : loginHandlerError?){
        
        if  let errcode = AuthErrorCode(rawValue: error.code){
     
        switch errcode {
        case .wrongPassword :
            loginhandler?(errorTypes.Wrong_Pass)
            break
        case .userNotFound:
            loginhandler?(errorTypes.User_Notfound)

                break
        case .invalidEmail:
            loginhandler?(errorTypes.Invalid_Email)

                break
        default: loginhandler?(errorTypes.random)
            break
        }
        }
    }
    func register (username:String, password:String,image : UIImage, loginhandler:loginHandlerError?){
        Auth.auth().createUser(withEmail: username, password: password) { (user, error) in
            if error != nil {
                self.handleErrors(error: error! as NSError, loginhandler: loginhandler)
            }
            else {
                if user?.user.uid != nil {
//                    if let uploadedImage = UIImagePNGRepresentation(image)
                    DBProvider.shared.imageStorageRef.child(username).downloadURL(completion: { (url, error) in
                        if error != nil {
                            return
                        }
                        else {
                            DBProvider.shared.saveUser(email: username, password: password, img : (url?.absoluteString)!, id: (Auth.auth().currentUser?.uid )!)
                            
                            self.login(email: username, password: password, loginhanlder: loginhandler)
                        }
                    })
                    
                
                }
            }
        }
    }
    func logout () -> Bool {
        if Auth.auth().currentUser != nil {
            do {
                try Auth.auth().signOut()
                return true
            }
            catch {
              return false
            }
        }
        return true
    }
    func isloggedin () -> Bool {
        if Auth.auth().currentUser != nil {
            return true
        }
        else {
            return false
        }
    }
    func getCurrentContactID() -> String{
        if Auth.auth().currentUser != nil {
            
            return (Auth.auth().currentUser?.uid)!

        }
        return ""
    }
}
