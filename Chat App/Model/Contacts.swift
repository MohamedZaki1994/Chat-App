//
//  Contacts.swift
//  Chat App
//
//  Created by Mohamed Mahmoud Zaki on 9/16/18.
//  Copyright © 2018 Mohamed Mahmoud Zaki. All rights reserved.
//

import Foundation
class Contact {

    private var _name : String
    private var _id : String
    private var _imageURL : String
    var name :String {
        return _name
    }
    var id : String {
        return _id
    }
    var imageURL :String {
        return _imageURL
    }
    init(name :String , id:String, imageURL : String) {
        self._name = name
        self._id = id
        self._imageURL = imageURL
    }
}
