//
//  DBProvider.swift
//  Chat App
//
//  Created by Mohamed Mahmoud Zaki on 8/6/18.
//  Copyright © 2018 Mohamed Mahmoud Zaki. All rights reserved.
//

import Foundation
import FirebaseDatabase
import FirebaseStorage
protocol fetchdata : class {
    func dataReceived (cont : [Contact])
    func user (name :String)
     func getAllimage(imagesData:Data)
}
class DBProvider {
    
    let imageCache = NSCache<AnyObject, AnyObject>()
    private static let Shared = DBProvider()
    weak var delegate : fetchdata?
    static var shared :DBProvider {
        return Shared
    }
    
    //DataBase
    var dataref : DatabaseReference {
        return Database.database().reference()
    }
    var contacts : DatabaseReference{
        return dataref.child("contacts")
    }
    var messages : DatabaseReference{
        return dataref.child("messages")
    }
    var MediaMessages : DatabaseReference{
        return dataref.child("MediaMessages")
    }
    //Storage
    var storageRef : StorageReference {
        return Storage.storage().reference(forURL: "gs://mychatapp-3d843.appspot.com")
    }
    var imageStorageRef : StorageReference {
        return storageRef.child("Image Storage")
    }
    var VideoStorageRef : StorageReference {
        return storageRef.child("Video Storage")
    }
    func saveUser(email :String , password :String, img : String, id :String){
        let data :Dictionary<String,Any> = ["Username" : email , "Password" : password, "Image" : img]
   // self.contacts.child(id).setValue(data)
        self.contacts.child(id).updateChildValues(data)
        
    }
 
    func getContacts() {
        var con = [Contact]()
        contacts.observeSingleEvent(of: DataEventType.value) { (snapshot:DataSnapshot) in
            if let myCon = snapshot.value as? NSDictionary {
                for (key,value) in myCon {
                    if let contactData = value as? NSDictionary , let id = key as? String {
                        if let email = contactData["Username"] as? String,let image = contactData["Image"] as? String {
                            let newContact = Contact(name: email, id: id,imageURL : image)
                            con.append(newContact)
                        }
                    }
              
                }
            }
            self.delegate?.dataReceived(cont: con)
        }
       
    }
    
    func getCurrentContact()  {
        var UserName = ""
        let uid = AuthProvider.shared.getCurrentContactID()
        contacts.child(uid).observeSingleEvent(of: .value) { (snapshot) in
            if let dic = snapshot.value as? [String:AnyObject] {
                UserName = (dic["Username"] as? String)!
            }
           
          self.delegate?.user(name: UserName)
        }
    }

    func saveImage (img : UIImage ,categoryName: String, name : String, closure : @escaping () -> Void ) {
        
        if let uploadedImage = UIImageJPEGRepresentation(img, 0.3){
           let ch =  DBProvider.shared.storageRef.child(categoryName).child(name)
            ch.putData(uploadedImage, metadata: nil) { (metadata, error) in
                if error != nil {
                    print(error as Any)
                    return
                }
                else {
                    ch.downloadURL(completion: { (url, error) in
                        if error != nil {
                            print(error as Any)
                            return
                        }
                        print(url as Any)
                    })
                }
                closure()
            }
        }
    }
    
    func  downloadImage (con: Contact, closure:  @escaping (UIImage) -> Void){
        if let cache = imageCache.object(forKey: con.imageURL as AnyObject){
            closure(cache as! UIImage)
            return
        }
        let url = URL(string: con.imageURL)
        URLSession.shared.dataTask(with: url!) { (data, response, error) in
            if error != nil {
                print(error)
                return
            }
//            DispatchQueue.main.async {
//                Caching the data
//                self.imageCache.setObject(UIImage(data: data!)!, forKey: con.imageURL as AnyObject)
                closure(UIImage(data:data!)!)
//            }
        }.resume()
    }
    
}
