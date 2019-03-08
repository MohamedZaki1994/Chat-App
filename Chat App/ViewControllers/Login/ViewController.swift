//
//  ViewController.swift
//  Chat App
//
//  Created by Mohamed Mahmoud Zaki on 7/19/18.
//  Copyright © 2018 Mohamed Mahmoud Zaki. All rights reserved.
//

import UIKit
import NVActivityIndicatorView
class ViewController: UIViewController , UIImagePickerControllerDelegate , UINavigationControllerDelegate{

    @IBOutlet weak var ChoosePicLabel: UILabel!
    @IBOutlet weak var LoginView: UIView?
    
    @IBOutlet weak var username: UITextField?
    
    @IBOutlet weak var imgView: UIView!
    
    @IBOutlet weak var password: UITextField?
    
    var SelectedImg : UIImage = UIImage(named: "user")!

    @IBOutlet weak var loading: UIActivityIndicatorView!
    
    @IBOutlet weak var loadingIndication: NVActivityIndicatorView!
    
    @IBAction func Login(_ sender: Any) {
        
        guard let usernameTxt = username?.text else{ return}
        guard let passwordTxt = password?.text else{ return}

        if !(usernameTxt.isEmpty), !(passwordTxt.isEmpty){
            
        
            AuthProvider.shared.login(email: usernameTxt, password: passwordTxt) { (msg) in
                
                if msg != nil {
                    let alert = UIAlertController(title: "Wrong", message: msg, preferredStyle: .actionSheet)
                    let action = UIAlertAction(title: "Ok", style: .destructive, handler: nil)
                    alert.addAction(action)
                    self.present(alert,animated: true,completion: nil)
                }
                else {
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let HistoryViewController = storyboard.instantiateViewController(withIdentifier: "HistoryViewController")
                    self.username?.text = ""
                    self.password?.text = ""
                    self.present(HistoryViewController, animated: true, completion: nil)
                    
                }
            }
        } else {
            let alert = UIAlertController(title: "Wrong", message: "Please enter username or password", preferredStyle: .actionSheet)
            let action = UIAlertAction(title: "Ok", style: .destructive, handler: nil)
            alert.addAction(action)
        present(alert,animated: true,completion: nil)

        }
    }
    
    @IBAction func register(_ sender: Any) {
        if !((username?.text?.isEmpty)!) && !((password?.text?.isEmpty)!){
            loadingIndication.isHidden = false
            loadingIndication.startAnimating()
//            self.loading.isHidden = false
//            self.loading.startAnimating()
            DBProvider.shared.saveImage(img :self.SelectedImg , name :(self.username?.text)!){
                AuthProvider.shared.register(username: (self.username?.text)!, password: (self.password?.text)!,image : self.SelectedImg) { [weak self] (msg) in
                guard let `self` = self else { return }
               
                if msg != nil {
                    let alert = UIAlertController(title: "Wrong", message: msg, preferredStyle: .actionSheet)
                    let action = UIAlertAction(title: "Ok", style: .destructive , handler: nil)
                    alert.addAction(action)
                    self.loadingIndication.isHidden = true
                    self.loadingIndication.stopAnimating()
//                    self.loading.stopAnimating()
//                    self.loading.isHidden = true
                    self.present(alert,animated: true)
                }
                else {
                    let alert = UIAlertController(title: "completed", message: msg, preferredStyle: .actionSheet)
                    let action = UIAlertAction(title: "Ok", style: .destructive , handler: nil)
                    alert.addAction(action)
//                    if let slcImg = self.SelectedImg{
//                        DBProvider.shared.saveImage(img :self.SelectedImg , name :(self.username?.text)!){
                    self.loadingIndication.isHidden = true
                    self.loadingIndication.stopAnimating()
//                            self.loading.stopAnimating()
//                            self.loading.isHidden = true
                            self.present(alert,animated: true)

                        }
//                    }
                    
                }
            }
                    }
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        LoginView?.layer.cornerRadius = 5
        loading.isHidden = true
        
    }
    func addgesture() {
        if !AuthProvider.shared.isloggedin(){
            ChoosePicLabel.isHidden = false
        }
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap))
        imgView.addGestureRecognizer(tap)
       imgView.isUserInteractionEnabled = true

    }
    @objc func handleTap() {
        ChoosePicLabel.isHidden = true
        let picker = UIImagePickerController()
        picker.delegate = self
        present(picker, animated: true, completion: nil)
        picker.allowsEditing = true
    }
    override func viewDidAppear(_ animated: Bool) {
        
        super.viewDidAppear(animated)
        if AuthProvider.shared.isloggedin() {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let tableview = storyboard.instantiateViewController(withIdentifier: "HistoryViewController")
            self.present(tableview, animated: true, completion: nil)
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        addgesture()
        let backgroundImage = UIImageView(frame: UIScreen.main.bounds)
        backgroundImage.image = UIImage(named: "bk")
        backgroundImage.contentMode = UIViewContentMode.scaleAspectFill
        self.view.insertSubview(backgroundImage, at: 0)
        loadingIndication.isHidden = true
        loadingIndication.type = NVActivityIndicatorType(rawValue: 26)!
        loadingIndication.color = UIColor.green
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        var selectedImage : UIImage?
        if let editImage = info["UIImagePickerControllerCropRect"] as? UIImage {
        selectedImage = editImage
        }
        else if let originalImage = info["UIImagePickerControllerOriginalImage"] as? UIImage{
         selectedImage = originalImage
        }
        if let selectedImg = selectedImage {
            let Image = UIImageView()
            Image.image = selectedImage
            Image.frame.size = imgView.frame.size
            Image.contentMode = .scaleToFill
            imgView.addSubview(Image)
            SelectedImg = selectedImg
//            DBProvider.shared.saveImage(SelectedImg!)
        }
        dismiss(animated: true, completion: nil)
    }
    
}

