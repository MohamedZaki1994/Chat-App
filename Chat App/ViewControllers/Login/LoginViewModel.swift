//
//  LoginViewModel.swift
//  Chat App
//
//  Created by Mohamed Mahmoud Zaki on 3/22/19.
//  Copyright © 2019 Mohamed Mahmoud Zaki. All rights reserved.
//

import Foundation
import UIKit

class LoginViewModel {


    func login (username: String?, password: String?,
                success: @escaping () -> Void,
                failureEmptyTxt: @escaping () -> Void,
                failureError: @escaping (String) -> Void) {
        guard let usernameTxt = username,
            let passwordTxt = password else {
                return
        }

        if !(usernameTxt.isEmpty), !(passwordTxt.isEmpty) {
            AuthProvider.shared.login(email: usernameTxt, password: passwordTxt) { (msg) in
                if let msg = msg {
                    failureError(msg)
                }
                else {
                    success()
                }
            }
        } else {
            failureEmptyTxt()
            
        }
    }
}
