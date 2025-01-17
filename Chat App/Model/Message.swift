//
//  Message.swift
//  Chat App
//
//  Created by Mohamed Mahmoud Zaki on 10/31/18.
//  Copyright © 2018 Mohamed Mahmoud Zaki. All rights reserved.
//

import Foundation

class Message {
    
    private var _toId : String
    private var _fromId : String
    private var _text : String
    private var _time: TimeInterval
    private var _imageURL : String

    var toID: String {
        return _toId
    }
    
    var fromId:String {
        return _fromId
    }
    
    var text: String {
        return _text
    }

    var imageURL: String {
        return _imageURL
    }
    var time: TimeInterval {
        return _time
    }
    
    init(toId: String, fromId: String, text: String, time: TimeInterval, imageURL: String) {
        self._toId = toId
        self._fromId = fromId
        self._text = text
        self._time = time
        self._imageURL = imageURL
    }

    func partnerId() -> String {
        return AuthProvider.shared.getCurrentContactID() == toID ? fromId : toID
    }
}
