//
//  ChatViewController.swift
//  Chat App
//
//  Created by Mohamed Mahmoud Zaki on 9/26/18.
//  Copyright © 2018 Mohamed Mahmoud Zaki. All rights reserved.
//

import UIKit
import MobileCoreServices
import AVKit
class ChatViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {

    @IBOutlet weak var nav: UINavigationItem!
    
    @IBOutlet weak var txtField: UITextField!
    var messageContent = [String]()
    var user : Contact? {
        didSet {
            nav.title = user?.name
        }
    }
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var inputSendView: NSLayoutConstraint!
    
    
    @IBAction func sendBtn(_ sender: Any) {
        guard let txt = txtField.text else {
            return
        }
       let fromID = AuthProvider.shared.getCurrentContactID()
        let timeStamp = NSDate().timeIntervalSince1970
        DBProvider.shared.messages.childByAutoId().updateChildValues(["txt":txt, "toId":self.user?.id ?? 0, "fromId": fromID,"timeStamp":timeStamp])
        collectionView.reloadData()
        txtField.text = ""
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        observeMessages {
            self.collectionView.reloadData()
        }
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messageContent.count
    }
     func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
     func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! CollectionViewCell
        cell.txtLabel.text = messageContent[indexPath.row]
        return cell
    }

    func observeMessages(closure: @escaping () -> Void){
        DBProvider.shared.messages.observe(.childAdded, with: { (snapShot) in

            if let dic = snapShot.value as? [String:AnyObject] {

                let message = Message(toId: (dic["toId"] as? String)!, fromId: dic["fromId"] as! String, text: dic["txt"] as! String, time: (dic["timeStamp"] as? Double)!)
                self.messageContent.append(message.text)
            }
            closure()
        }, withCancel: nil)
    }

}
