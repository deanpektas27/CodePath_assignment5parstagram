//
//  CameraViewController.swift
//  CodePath_assignment5parstagram
//
//  Created by Dean Pektas on 3/23/19.
//  Copyright © 2019 Dean Pektas. All rights reserved.
//

import UIKit
import AlamofireImage
import Parse

class CameraViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var commentField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func onSubmitButton(_ sender: Any) {
        let post = PFObject(className: "posts")
        
        post["caption"] = commentField.text
        post["author"] = PFUser.current()!//sets author to currently logged in user
        
        let imageData = imageView.image!.pngData()
        let file = PFFileObject(data: imageData!)//creates a PF File object out of the image so that it can be passed into the database in a SEPERATE table
        
        post["image"] = file //this column will hold URL to image
        
        post.saveInBackground { (success, error) in
            if success {
                self.dismiss(animated: true, completion: nil)
                    print("saved!")
                
            } else {
                print("error")
            }
        }
        
        
    }
    
    @IBAction func onCameraButton(_ sender: Any) {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            picker.sourceType = .camera //if camera is available, use it
        } else { //if not, then automatically go to photo lib
            picker.sourceType = .photoLibrary
        }
        
        present(picker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let image = info[.editedImage] as! UIImage //takes image that was edited
        
        let size = CGSize(width: 300, height: 300) //creates variable that presets a size for the image being passed
        let scaledImage = image.af_imageScaled(to: size)
        
        imageView.image = scaledImage
        
        dismiss(animated: true, completion: nil)//gets rid of camera editing page after passing image
        
        
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
