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
    var messagesDic = [String: Message]()
    var messages : [Message] = []

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
        let autoId = DBProvider.shared.messages.childByAutoId()
        autoId.updateChildValues(["txt":txt, "toId":self.user?.id ?? 0, "fromId": fromID,"timeStamp":timeStamp]) { (error, ref) in
            if error != nil {
                print(error as Any)
                return
            }
            DBProvider.shared.dataref.child("User-Messages").child(fromID).updateChildValues([autoId.key: txt])
            DBProvider.shared.dataref.child("User-Messages").child(self.user?.id ?? "").updateChildValues([autoId.key: txt])
        }
        collectionView.reloadData()
        txtField.text = ""
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        observeUserMessages {
            self.collectionView.reloadData()
            self.collectionView.scrollToItem(at: IndexPath(row: self.messages.count-1, section: 0), at: .top, animated: false)
        }
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }

     func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

     func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! CollectionViewCell
        cell.txtLabel.text = messages[indexPath.row].text
        if messages[indexPath.row].toID == AuthProvider.shared.getCurrentContactID() {
            cell.bubbleView.backgroundColor = .lightGray
            cell.txtLabel.textColor = .black
            cell.trailingConstraint.constant = 80
            cell.leadingConstraint.constant = 20
            cell.labelTrailing.priority = .defaultLow
            cell.labelLeading.priority = .defaultHigh
            let size = calculateCellHeight(text: cell.txtLabel.text ?? "")
            cell.labelWidth.constant = size.width
        } else {
            cell.bubbleView.backgroundColor = UIColor(red: 0, green: 137/255, blue: 249/255, alpha: 1)
            cell.txtLabel.textColor = .white
            cell.leadingConstraint.constant = 80
            cell.trailingConstraint.constant = 20
            cell.labelLeading.priority = .defaultLow
            cell.labelTrailing.priority = .defaultHigh
            let size = calculateCellHeight(text: cell.txtLabel.text ?? "")
            cell.labelWidth.constant = size.width
        }
        cell.bubbleView.layer.masksToBounds = true
        cell.bubbleView.layer.cornerRadius = 12
        return cell
    }

    func calculateCellHeight(text: String) -> CGSize{
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: view.frame.width - 56, height: 0))
        label.numberOfLines = 0
        label.text = text
        label.sizeToFit()
        return CGSize(width: label.frame.width, height: label.frame.height + 10)
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

    func observeUserMessages(closure: @escaping () -> Void) {
        DBProvider.shared.dataref.child("User-Messages").child(AuthProvider.shared.getCurrentContactID()).observe(.childAdded) { (snapShot) in

            let messageKey = snapShot.key
            DBProvider.shared.messages.child(messageKey).observeSingleEvent(of: .value, with: { (snapshot) in
                if let dic = snapshot.value as? [String:AnyObject] {

                    let message = Message(toId: (dic["toId"] as? String)!, fromId: dic["fromId"] as! String, text: dic["txt"] as! String, time: (dic["timeStamp"] as? TimeInterval)!)
                    if message.partnerId() == self.user?.id {
                        self.messages.append(message)
                        self.messages.sort(by: { (m1, m2) -> Bool in
                            return m1.time < m2.time
                        })
                    }
                }
                closure()
            })

            closure()
        }
    }
}
extension ChatViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let size = calculateCellHeight(text: messages[indexPath.row].text)
        return CGSize(width: view.frame.width, height: size.height)
    }
}
