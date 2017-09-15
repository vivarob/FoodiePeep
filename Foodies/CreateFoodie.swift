//
//  CreateFoodie.swift
//  Foodies
//
//  Created by Roberto Pirck Valdés on 13/9/17.
//  Copyright © 2017 Roberto Pirck Valdés. All rights reserved.
//

import UIKit
import MapKit
import Firebase

class CreateFoodie: UIViewController {
    
    var location: CLLocationCoordinate2D?
    
    var foodieNameTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Choose foodie's name"
        textField.borderStyle = .roundedRect
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    var datePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.minimumDate = Date()
        picker.minuteInterval = 5
        picker.translatesAutoresizingMaskIntoConstraints = false
        return picker
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
    
    func setUpNavigationBar(){
        navigationController?.navigationBar.barTintColor = UIColor(red: 241/155, green: 196/255, blue: 15/255, alpha: 1)
        navigationController?.navigationBar.tintColor = UIColor.white
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white, NSFontAttributeName: UIFont(name: "HelveticaNeue-Bold", size: 20)!]
        navigationController?.navigationBar.isTranslucent = false
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(saveFoodie))
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
    
    
    func saveFoodie(){
        if datePicker.date < Date(){
            print("fecha anterior de hoy")
        } else {
            let ceo: CLGeocoder = CLGeocoder()
            var address : String = ""
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            
            guard let foodieLocation = location else {
                print("no location")
                
                return }
            
            guard let name = self.foodieNameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) else {return}
            
            if name == "" {
                let noName = UIAlertController(title: "Wait!", message: "You have to choose a name for your foodie", preferredStyle: .alert)
                noName.addAction(UIAlertAction(title: "OK", style: .default, handler: { (UIAlertAction) in
                    return
                }))
                self.present(noName, animated: true){
                    return
                }

            }
            
            let coordinates = CLLocation(latitude: foodieLocation.latitude, longitude: foodieLocation.longitude)
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
                        
                        
                        let formatter = DateFormatter()
                        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                        
                        guard let userID = Auth.auth().currentUser?.uid else {
                            print("no user id")
                            return
                            
                        }
                        
                        let foodieDictionary = ["name" : name,
                                                "date": formatter.string(from: self.datePicker.date),
                                                "id": "",
                                                "userId": userID,
                                                "longitude": foodieLocation.longitude,
                                                "latitude": foodieLocation.latitude,
                                                "images" : [],
                                                "invitedIds" : [],
                                                "address" : address
                        ] as [String : Any]
                        let foodie = Foodie(dictionary: foodieDictionary)
                        let nextVC = InvitePeepsViewController()
                        nextVC.foodie = foodie
                        self.navigationController?.pushViewController(nextVC, animated: true)
                    }
            })
        }
    }
    
    func setUpView() {
        
        self.view.addSubview(foodieNameTextField)
        foodieNameTextField.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 26).isActive = true
        foodieNameTextField.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 25).isActive = true
        foodieNameTextField.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: -25).isActive = true
        foodieNameTextField.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        self.view.addSubview(datePicker)
        datePicker.topAnchor.constraint(equalTo: foodieNameTextField.bottomAnchor, constant: 8).isActive = true
        datePicker.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 25).isActive = true
        datePicker.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: -25).isActive = true
        datePicker.heightAnchor.constraint(equalTo: self.view.heightAnchor, multiplier: 0.4).isActive = true
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
