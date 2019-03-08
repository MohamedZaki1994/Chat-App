//
//  TableViewController.swift
//  Chat App
//
//  Created by Mohamed Mahmoud Zaki on 7/19/18.
//  Copyright © 2018 Mohamed Mahmoud Zaki. All rights reserved.
//

import UIKit

class TableViewController: UITableViewController , fetchdata{
    func getAllimage(imagesData: Data) {
        
    }
    
//    func getAllimage(imagesData: Data) {
//        self.images.append(UIImage(data: imagesData)!)
//    }
    
    
    @IBOutlet weak var Head: UINavigationItem!
    var Username : String = ""
    var Images = [UIImage]()
    func dataReceived(cont: [Contact]) {
     self.contacts = cont
            for con in  cont {
                DBProvider.shared.downloadImage(con: con){ img in
                    
                    self.images.append(img)
                    self.tableView.reloadData()
                }
            }
        
        tableView.reloadData()
    }
    func user (name : String) {
       Head.title? = name
        Username = name
    }
    
    var contacts = [Contact]()
    var images = [UIImage]()
    @IBAction func logut(_ sender: Any) {
        if AuthProvider.shared.logout() {
        dismiss(animated: true, completion: nil)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        DBProvider.shared.delegate = self
 DBProvider.shared.getContacts()
    DBProvider.shared.getCurrentContact()
            }
    
    override var preferredStatusBarStyle: UIStatusBarStyle
    {
        return .default
    }


    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contacts.count
        
    }

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let cell = tableView.dequeueReusableCell(withIdentifier: "header")
        return cell
    }
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! TableViewCell
        if contacts.count > 0 {

            cell.lbl.text = contacts[indexPath.row].name
            cell.imgView.image = UIImage(named: "h")
            if images.count != 0 , images.count > indexPath.row{
                cell.imgView.image =  images[indexPath.row]
                cell.imgView.contentMode = .scaleAspectFill
            }
            if Username == contacts[indexPath.row].name{
                cell.lbl.text?.append("(you)")
            }
            //
        }
        return cell
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let chatViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ChatViewController") as! ChatViewController
        chatViewController.user = contacts[indexPath.row]
        navigationController?.pushViewController(chatViewController, animated: true)
    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
