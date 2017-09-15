//
//  CreateRestaurant.swift
//  Foodies
//
//  Created by Roberto Pirck Valdés on 13/9/17.
//  Copyright © 2017 Roberto Pirck Valdés. All rights reserved.
//

import UIKit
import MapKit
import Firebase

class CreateRestaurant: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var restaurantLocation: CLLocationCoordinate2D?
    
    var imagePicker: UIImagePickerController = {
        let picker = UIImagePickerController()
        picker.allowsEditing = true
        picker.sourceType = .photoLibrary
//        picker.mediaTypes = [kUTTypeImage as String]
        return picker
    }()
    
    var restaurantImage: UIImageView = {
        let imageView = UIImageView()
        imageView.image = #imageLiteral(resourceName: "logInImage")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    var changeImageButton: UIButton = {
        let button = UIButton()
        button.addTarget(self, action: #selector(chooseImage), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    var restaurantNameTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Choose restaurant's name"
        textField.borderStyle = .roundedRect
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        setUpNavigationBar()
        setUpView()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func chooseImage(){
        imagePicker.delegate = self
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let image = info[UIImagePickerControllerEditedImage]  as! UIImage
        restaurantImage.image = image
        dismiss(animated: true, completion: nil)
    }
    
    func setUpNavigationBar(){
        navigationController?.navigationBar.barTintColor = UIColor(red: 241/155, green: 196/255, blue: 15/255, alpha: 1)
        navigationController?.navigationBar.tintColor = UIColor.white
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white, NSFontAttributeName: UIFont(name: "HelveticaNeue-Bold", size: 20)!]
        navigationController?.navigationBar.isTranslucent = false
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(saveRestaurant))
        let backButton = UIButton.init(type: .custom)
        backButton.setImage(#imageLiteral(resourceName: "backArrow"), for: UIControlState.normal)
        backButton.frame = CGRect.init(x: 0, y: 0, width: 12, height: 20)
        backButton.addTarget(self, action: #selector(dismissVC), for: .touchUpInside)
        
        let leftButtonItem = UIBarButtonItem.init(customView: backButton)
        navigationItem.leftBarButtonItem = leftButtonItem
    }
    
    func dismissVC(){
        navigationController?.popViewController(animated: true)
    }
    
    
    func saveRestaurant() {
        guard let name = restaurantNameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines), name != "" else {
            print("Couldn't take restaurant's name")
            return
        }
        
        guard let location = restaurantLocation else {
            print("Couldn't take restaurant's location")
            return
        }
        
        guard let user = Auth.auth().currentUser else {
            print("Couldn't take current user")
            return
        }
        
        let imageName = NSUUID().uuidString
        let storageRef = Storage.storage().reference().child("Restaurant-Images").child("\(imageName).png")
        guard let uploadImage = UIImagePNGRepresentation(restaurantImage.image!) else {
            print("Couldn't take restaurant uploaded image")
            return
        }
        
        storageRef.putData(uploadImage, metadata: nil, completion: {
            (metadata, error) in
                if error != nil {
                    print(error!)
                    return
                }
                guard let imageUrl = metadata?.downloadURL()?.absoluteString else {
                    
                    return
                }
                
                let ceo: CLGeocoder = CLGeocoder()
                var address : String = ""
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                let coordinates = CLLocation(latitude: location.latitude, longitude: location.longitude)
                ceo.reverseGeocodeLocation(coordinates, completionHandler:
                    {(placemarks, error) in
                        if (error != nil)
                        {
                            print("reverse geodcode fail: \(error!.localizedDescription)")
                        }
                        guard let pm = placemarks else {
                            print("no string address")
                            
                            return
                        }
                        
                        if pm.count > 0 {
                            let pm = placemarks![0]
                            if pm.thoroughfare != nil {
                                address = address + pm.thoroughfare! + ", "
                            }
                            
                            if pm.subThoroughfare != nil {
                                address = address + pm.subThoroughfare! + ", "
                            }
                            
                            if pm.postalCode != nil {
                                address = address + pm.postalCode! + " "
                            }
                            
                            if pm.locality != nil {
                                address = address + pm.locality! + ", "
                            }
                            if pm.country != nil {
                                address = address + pm.country!
                            }
                            
                            let ref = Database.database().reference()
                            let restaurantRef = ref.child("Restaurants").childByAutoId()
                            restaurantRef.updateChildValues(["userId": user.uid ,
                                                             "name": name,
                                                             "latitude": location.latitude,
                                                             "longitude": location.longitude,
                                                             "address": address,
                                                             "id": restaurantRef.key,
                                                             "imageUrl": imageUrl
                                                            ])
                            //
                            self.navigationController?.popToRootViewController(animated: true)
                        }
                })
        })
        navigationController?.popToRootViewController(animated: true)
    }
    
    func setUpView(){
        let shadowView = UIView(frame: CGRect(x: 0, y: 0, width: 200, height: 200))
        shadowView.translatesAutoresizingMaskIntoConstraints = false
        
        
        shadowView.addSubview(restaurantImage)
        restaurantImage.leftAnchor.constraint(equalTo: shadowView.leftAnchor, constant: 0).isActive = true
        restaurantImage.rightAnchor.constraint(equalTo: shadowView.rightAnchor, constant: 0).isActive = true
        restaurantImage.topAnchor.constraint(equalTo: shadowView.topAnchor, constant: 0).isActive = true
        restaurantImage.bottomAnchor.constraint(equalTo: shadowView.bottomAnchor, constant: 0).isActive = true
        restaurantImage.layer.cornerRadius = 20
        restaurantImage.clipsToBounds = true
        
        self.view.addSubview(shadowView)
        shadowView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 16).isActive = true
        shadowView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor, constant: 0).isActive = true
        shadowView.heightAnchor.constraint(equalToConstant: 200).isActive = true
        shadowView.widthAnchor.constraint(equalToConstant: 200).isActive = true
        shadowView.clipsToBounds = false
        shadowView.layer.shadowColor = UIColor.black.cgColor
        shadowView.layer.shadowOpacity = 1
        shadowView.layer.shadowOffset = CGSize.zero
        shadowView.layer.shadowRadius = 5
        shadowView.layer.shadowPath = UIBezierPath(roundedRect: shadowView.bounds, cornerRadius: 20).cgPath
        
        self.view.addSubview(changeImageButton)
        changeImageButton.leftAnchor.constraint(equalTo: restaurantImage.leftAnchor, constant: 0).isActive = true
        changeImageButton.rightAnchor.constraint(equalTo: restaurantImage.rightAnchor, constant: 0).isActive = true
        changeImageButton.topAnchor.constraint(equalTo: restaurantImage.topAnchor, constant: 0).isActive = true
        changeImageButton.bottomAnchor.constraint(equalTo: restaurantImage.bottomAnchor, constant: 0).isActive = true
        
        self.view.addSubview(restaurantNameTextField)
        restaurantNameTextField.topAnchor.constraint(equalTo: restaurantImage.bottomAnchor, constant: 20).isActive = true
        restaurantNameTextField.centerXAnchor.constraint(equalTo: self.view.centerXAnchor, constant: 0).isActive = true
        restaurantNameTextField.heightAnchor.constraint(equalToConstant: 30).isActive = true
        restaurantNameTextField.widthAnchor.constraint(equalToConstant: 250).isActive = true
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
