//
//  ViewController.swift
//  MemeMe 1.0
//
//  Created by Jonathan on 11/15/18.
//  Copyright © 2018 Jonathan. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var topCaption: UITextField!
    @IBOutlet weak var bottomCaption: UITextField!
    @IBOutlet weak var memeImage: UIImageView!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var toolBar: UIToolbar!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navSetup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setUI()
        initializeTextfields()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidAppear(animated)
        unsubscribeFromKeyboardNotifications()
    }
    
    fileprivate func navSetup() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(save))
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(reset))
    }
    
    fileprivate func setUI() {
        view.backgroundColor = .black
        memeImage.contentMode = .scaleAspectFit
        cameraButton.isEnabled = UIImagePickerController.isSourceTypeAvailable(.camera)
    }
    
}



extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let editedImage = info[.editedImage] as? UIImage {
            memeImage.image = editedImage
            picker.dismiss(animated: true, completion: nil)
        } else if let image = info[.originalImage] as? UIImage {
            memeImage.image = image
            picker.dismiss(animated: true, completion: nil)
            save()
        }
    }
    
    @IBAction func openCamera(_ sender: Any) {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.sourceType = .camera
        present(imagePickerController, animated: true, completion: nil)
        
    }
    
    @IBAction func pickAnImage(_ sender: Any) {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.allowsEditing = true
        present(imagePickerController, animated: true, completion: nil)
        
    }
    
    func generateMemeImage() -> UIImage {
        self.navigationController?.navigationBar.isHidden = true
        self.toolBar.isHidden = true
        UIGraphicsBeginImageContext(self.view.frame.size)
        view.drawHierarchy(in: self.view.frame, afterScreenUpdates: true)
        let memedImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        self.navigationController?.navigationBar.isHidden = false
        self.toolBar.isHidden = false
        return memedImage
    }
    
    @objc func save() {
        guard let topText = topCaption.text else { return }
        guard let bottomText = bottomCaption.text else { return }
        guard let image = memeImage.image else { return }
        self.view.endEditing(true)
        let meme = Meme(topTextField: topText, bottomTextField: bottomText, originalImage: image, memedImage: generateMemeImage())
        let vc = UIActivityViewController(activityItems: [meme.memedImage!], applicationActivities: [])
        present(vc, animated: true, completion: nil)
    }
    
    @objc func reset() {
        topCaption.text = "TOP"
        bottomCaption.text = "BOTTOM"
        memeImage.image = nil
    }
}

extension ViewController {
    
    fileprivate func initializeTextfields() {
        let textAttributes = [
            NSAttributedString.Key.strokeColor.rawValue : UIColor.black,
            NSAttributedString.Key.foregroundColor : UIColor.white,
            NSAttributedString.Key.font : UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
            NSAttributedString.Key.strokeWidth : -3.0
            ] as! [NSAttributedString.Key : Any]
        topCaption.defaultTextAttributes = textAttributes
        topCaption.text = "TOP"
        topCaption.textAlignment = .center
        bottomCaption.defaultTextAttributes = textAttributes
        bottomCaption.text = "BOTTOM"
        bottomCaption.textAlignment = .center
        topCaption.layer.zPosition = .greatestFiniteMagnitude
        bottomCaption.layer.zPosition = .greatestFiniteMagnitude
        topCaption.delegate = self
        bottomCaption.delegate = self
    }
    
    
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if bottomCaption.isFirstResponder {
            subscribeToKeyboardNotifications()
            bottomCaption.text = ""
        } else if topCaption.isFirstResponder {
            topCaption.text = ""
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        unsubscribeFromKeyboardNotifications()
        return true
    }
    
    func subscribeToKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
    }
    
    @objc func keyboardWillShow(_ notification:Notification) {
        view.frame.origin.y -= getKeyboardHeight(notification)
    }
    
    func getKeyboardHeight(_ notification:Notification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue
        return keyboardSize.cgRectValue.height
    }
    
    func keyboardWillHide() {
        UIView.animate(withDuration: 0.2) {
            self.view.frame.origin.y = 0
        }
    }
    
    func unsubscribeFromKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        keyboardWillHide()
    }
}
