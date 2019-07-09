//
//  LoginViewController.swift
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
    @IBOutlet weak var loading: UIActivityIndicatorView!
    @IBOutlet weak var loadingIndication: NVActivityIndicatorView!
    var SelectedImg : UIImage = UIImage(named: "user")!
    @IBOutlet weak var loginBtnOutlet: UIButton!
    @IBOutlet weak var registerBtnOutlet: UIButton!
    @IBOutlet weak var segmentControl: UISegmentedControl!
    @IBAction func loginOrRegister(_ sender: Any) {
        switch segmentControl.selectedSegmentIndex {
        case 0:
            showLogin()
        default:
            showRegister()
        }

    }

    @IBAction func Login(_ sender: Any) {
        
        guard let usernameTxt = username?.text else{ return}
        guard let passwordTxt = password?.text else{ return}

        let viewModel: LoginViewModel = LoginViewModel()
        viewModel.login(username: usernameTxt, password: passwordTxt, success: {
            self.goToHistory()
        }, failureEmptyTxt: {
            self.showAlert(title: "Wrong", msg: "Please enter username or password", preferredStyle: .actionSheet)
        }) { msg in
            self.showAlert(title: "Wrong", msg: msg, preferredStyle: .actionSheet)
        }
    }
    
    func goToHistory() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let HistoryViewController = storyboard.instantiateViewController(withIdentifier: "HistoryViewController")
        username?.text = ""
        password?.text = ""
        present(HistoryViewController, animated: true, completion: nil)
    }

    func showAlert(title: String,
                   msg: String,
                   preferredStyle: UIAlertController.Style) {
        let alert = UIAlertController(title: "Wrong", message: msg, preferredStyle: preferredStyle)
        let action = UIAlertAction(title: "Ok", style: .destructive, handler: nil)
        alert.addAction(action)
        self.present(alert,animated: true,completion: nil)
    }
    
    @IBAction func register(_ sender: Any) {
        if !((username?.text?.isEmpty)!) && !((password?.text?.isEmpty)!){
            loadingIndication.isHidden = false
            loadingIndication.startAnimating()
            DBProvider.shared.saveImage(img :self.SelectedImg , name :(self.username?.text)!){
                AuthProvider.shared.register(username: (self.username?.text)!, password: (self.password?.text)!,image : self.SelectedImg) { [weak self] (msg) in
                guard let `self` = self else { return }
               
                if msg != nil {
                    let alert = UIAlertController(title: "Wrong", message: msg, preferredStyle: .actionSheet)
                    let action = UIAlertAction(title: "Ok", style: .destructive , handler: nil)
                    alert.addAction(action)
                    self.loadingIndication.isHidden = true
                    self.loadingIndication.stopAnimating()
                    self.present(alert,animated: true)
                }
                else {
                    let alert = UIAlertController(title: "completed", message: msg, preferredStyle: .actionSheet)
                    let action = UIAlertAction(title: "Ok", style: .destructive , handler: nil)
                    alert.addAction(action)
                    self.loadingIndication.isHidden = true
                    self.loadingIndication.stopAnimating()
                    self.present(alert,animated: true)
                    }
                    
                }
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        LoginView?.layer.cornerRadius = 5
        showLogin()
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
        }
        dismiss(animated: true, completion: nil)
    }

    func showLogin() {
        imgView.isHidden = true
        loginBtnOutlet.isHidden = false
        registerBtnOutlet.isHidden = true

    }
    func showRegister() {
        imgView.isHidden = false
        loginBtnOutlet.isHidden = true
        registerBtnOutlet.isHidden = false
    }
}

