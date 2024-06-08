//
//  UploadViewController.swift
//  SwiftInstagramCloneFirebase
//
//  Created by Rodrigo Silva on 07/06/24.
//

import UIKit
import FirebaseStorage
import FirebaseFirestore
import FirebaseAuth

class UploadViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var commentText: UITextField!
    
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var uploadButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imageView.isUserInteractionEnabled = true
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(chooseImage))
        imageView.addGestureRecognizer(gestureRecognizer)
    }
    
    @objc func chooseImage() {
        let pickerController = UIImagePickerController()
        pickerController.delegate = self
        pickerController.sourceType = .photoLibrary
        present(pickerController, animated: true, completion: nil)
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        imageView.image = info[.originalImage] as? UIImage
        self.dismiss(animated: true, completion: nil)
    }
    
    func makeAlert(title: String?, message: String?){
        let alert = UIAlertController(title: title ?? "Error", message: message ?? "Error to upload" , preferredStyle: UIAlertController.Style.alert)
        let okButton = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil)
        
        alert.addAction(okButton)
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func actionButtonClicked(_ sender: Any) {
        let storage = Storage.storage()
        let storageReference = storage.reference()
        
        let currentDateTime = Date()
        let dateFormatted = currentDateTime.actualDateFormatted()
        
        
        let mediaFolder = storageReference.child("media")
        
        if let data = imageView.image?.jpegData(compressionQuality: 0.5){
            
            let uuid = UUID().uuidString
            
            let imageReferece = mediaFolder.child("\(uuid).jpg")
            imageReferece.putData(data, metadata: nil) { (metadata, error) in
                if error != nil {
                    self.makeAlert(title: nil, message: error!.localizedDescription)
                }else {
                    
                    imageReferece.downloadURL { (url, error) in
                        if error == nil {
                            let imageUrl = url?.absoluteString
                            
                            let firestoreDatabase = Firestore.firestore()
                            var firestoreReference : DocumentReference? = nil
                            
                            let firestorePost = [
                                "imageUrl" : imageUrl!,
                                "postedBy": Auth.auth().currentUser!.email!,
                                "comment": self.commentText.text ?? "",
                                "date":"\(dateFormatted)",
                                "likes": 0
                            ] as [String : Any]
                            
                            firestoreReference = firestoreDatabase.collection("Posts").addDocument(data: firestorePost, completion: { (error) in
                                if error != nil {
                                    self.makeAlert(title: nil, message: error!.localizedDescription)
                                }else {
                                    self.imageView.image = UIImage(named: "select.png")
                                    self.commentText.text = ""
                                    self.tabBarController?.selectedIndex = 0
                                }
                            })
                            
                            
                        }
                    }
                }
            }
        }
    }
}
