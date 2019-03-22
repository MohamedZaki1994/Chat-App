//
//  HistoryViewController.swift
//  Chat App
//
//  Created by Mohamed Mahmoud Zaki on 10/3/18.
//  Copyright © 2018 Mohamed Mahmoud Zaki. All rights reserved.
//

import UIKit

class HistoryViewController: UIViewController , fetchdata , UITableViewDelegate , UITableViewDataSource{
    
    @IBOutlet weak var tableview: UITableView!
    var contacts: [Contact] = []
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let timeStamp = NSDate(timeIntervalSince1970: messages[indexPath.row].time)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "hh:mm:ss a"
        var receivedUser = ""
        if messages[indexPath.row].toID == AuthProvider.shared.getCurrentContactID() {
            receivedUser = messages[indexPath.row].fromId
        } else {
            receivedUser = messages[indexPath.row].toID
        }
        cell.textLabel?.text = receivedUser + "    \(dateFormatter.string(from: timeStamp as Date))"
        cell.detailTextLabel?.text = messages[indexPath.row].text
        return cell
    }
    
    
    var messages : [Message] = []
    var messagesDic = [String: Message]()
    func getAllimage(imagesData: Data) {
        
    }
    
    func dataReceived(cont: [Contact]) {
        self.contacts = cont
        self.tableview.reloadData()
    }
    
    func user(name: String) {
        nav.title = name
    }
    

    @IBOutlet weak var nav: UINavigationItem!
    
    @IBAction func Logout(_ sender: Any) {
        if AuthProvider.shared.logout() {
            dismiss(animated: true, completion: nil)
        }
    }
    
    
    @IBAction func chatBtn(_ sender: Any) {
        let TableViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "TableViewController") as! ContactTableViewController
        navigationController?.pushViewController(TableViewController, animated: true)

    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        

    }
    override func viewDidLoad() {
        super.viewDidLoad()
        DBProvider.shared.delegate = self
        DBProvider.shared.getCurrentContact()
        DBProvider.shared.getContacts()
        observeUserMessages {
            self.tableview.reloadData()
        }

    }

    func observeMessages(closure: @escaping () -> Void){
        DBProvider.shared.messages.observe(.childAdded, with: { (snapShot) in
            
            if let dic = snapShot.value as? [String:AnyObject] {
                
                let message = Message(toId: (dic["toId"] as? String)!, fromId: dic["fromId"] as! String, text: dic["txt"] as! String, time: (dic["timeStamp"] as? TimeInterval)!)
                self.messagesDic[message.toID] = message
                self.messages = Array(self.messagesDic.values)
                self.messages.sort(by: { (m1, m2) -> Bool in
                    return m1.time > m2.time
                })
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
                    self.messagesDic[message.toID] = message
                    self.messages = Array(self.messagesDic.values)
                    self.messages.sort(by: { (m1, m2) -> Bool in
                        return m1.time > m2.time
                    })
                }
                closure()
            })

            closure()
        }
    }

    func getName(id: String) -> String {
        for contact in contacts {
            if id == contact.id {
                for message in messages{
                    if contact.id == message.toID {
                        return contact.name
                    }
                }
            }
        }
        return "None"
    }
}
