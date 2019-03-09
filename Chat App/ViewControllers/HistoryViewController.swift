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
        cell.textLabel?.text = getName(id: messages[indexPath.row].toID)//messages[indexPath.row].toID
        cell.detailTextLabel?.text = messages[indexPath.row].text
        return cell
    }
    
    
    var messages : [Message] = []
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
        let TableViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "TableViewController") as! TableViewController
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
        observeMessages() {
            self.tableview.reloadData()
        }
        
    }

    func observeMessages(closure: @escaping () -> Void){
        DBProvider.shared.messages.observe(.childAdded, with: { (snapShot) in
            
            if let dic = snapShot.value as? [String:AnyObject] {
                
                let message = Message(toId: (dic["toId"] as? String)!, fromId: dic["fromId"] as! String, text: dic["txt"] as! String)
                self.messages.append(message)
            }
            closure()
        }, withCancel: nil)
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
