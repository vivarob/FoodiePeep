//
//  FoodieMaxView.swift
//  Foodies
//
//  Created by Roberto Pirck Valdés on 14/9/17.
//  Copyright © 2017 Roberto Pirck Valdés. All rights reserved.
//

import UIKit
import Firebase
import MapKit

class FoodieMaxView: UIViewController , UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    var foodie: Foodie? = nil
    let picker = UIImagePickerController()
    let layout = UICollectionViewFlowLayout()
    var collectionView: UICollectionView?
    
    var foodieImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    var foodieNameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "HelveticaNeue-Bold" , size: 24)
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var foodieDateLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "HelveticaNeue-Regular" , size: 18)
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var foodieAdressLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "HelveticaNeue-Regular" , size: 18)
        label.textAlignment = .left
        label.adjustsFontSizeToFitWidth = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var foodieMap: MKMapView = {
        let mapView = MKMapView()
        mapView.mapType = .standard
        mapView.isZoomEnabled = false
        mapView.isScrollEnabled = false
        mapView.translatesAutoresizingMaskIntoConstraints = false
        mapView.showsUserLocation = false
        mapView.layer.cornerRadius = 20
        return mapView
    }()
    
    var goToMapsButton:UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(openMapForPlace), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "foodie"
        
        self.view.backgroundColor = .white
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setUpNavigationController()
        setUpView()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func dismissVC(){
        navigationController?.popViewController(animated: true)
    }
    
    func openMapForPlace() {
        guard let latitude = foodie?.latitude, let longitude = foodie?.longitude else  {
            print("Couldn't get latitude and longitude from the foodie")
            return
        }
        
        let regionDistance:CLLocationDistance = 1000
        let coordinates = CLLocationCoordinate2DMake(latitude, longitude)
        let regionSpan = MKCoordinateRegionMakeWithDistance(coordinates, regionDistance, regionDistance)
        let options = [
            MKLaunchOptionsMapCenterKey: NSValue(mkCoordinate: regionSpan.center),
            MKLaunchOptionsMapSpanKey: NSValue(mkCoordinateSpan: regionSpan.span)
        ]
        let placemark = MKPlacemark(coordinate: coordinates, addressDictionary: nil)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = foodie?.name
        mapItem.openInMaps(launchOptions: options)
    }
    
    func setUpNavigationController() {
        print("setting navbar")
        navigationController?.navigationBar.barTintColor = UIColor(red: 241/155, green: 196/255, blue: 15/255, alpha: 1)
        navigationController?.navigationBar.tintColor = UIColor.white
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white, NSFontAttributeName: UIFont(name: "HelveticaNeue-Bold", size: 20)!]
        navigationController?.navigationBar.isTranslucent = false
        
        navigationController?.navigationBar.isTranslucent = false
        let backButton = UIButton.init(type: .custom)
        backButton.setImage(#imageLiteral(resourceName: "backArrow"), for: UIControlState.normal)
        backButton.frame = CGRect.init(x: 0, y: 0, width: 12, height: 20)
        backButton.addTarget(self, action: #selector(dismissVC), for: .touchUpInside)
//
        
        let uploadButton = UIButton.init(type: .custom)
        uploadButton.setImage(#imageLiteral(resourceName: "optionsImage"), for: UIControlState.normal)
        uploadButton.frame = CGRect.init(x: 0, y: 0, width: 25, height: 25)
        uploadButton.addTarget(self, action: #selector(openOptions), for: .touchUpInside)
        
        let leftButtonItem = UIBarButtonItem.init(customView: backButton)
        navigationItem.leftBarButtonItem = leftButtonItem
//
        setUpImagePicker()
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(openOptions))
        navigationItem.rightBarButtonItem?.setTitleTextAttributes([NSForegroundColorAttributeName: UIColor.white], for: .normal)
    }

    
    func setUpImagePicker(){
        print("picker")
        picker.delegate = self
        picker.allowsEditing = true
        picker.sourceType = .photoLibrary
//        picker.mediaTypes = UIImagePickerController.availableMediaTypes(for: .photoLibrary)!
    }
    
    func openOptions(){
        
        if Reachability.isConnectedToNetwork() {
            let alertController = UIAlertController(title: nil, message: "Options", preferredStyle: .actionSheet)
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { action in
                // ...
            }
            alertController.addAction(cancelAction)
            
            if let user = Auth.auth().currentUser, foodie?.userId == user.uid {
                
                let uploadImageAction = UIAlertAction(title: "Upload image", style: .default) { action in
                    self.present(self.picker, animated: true, completion: nil)
                }
                alertController.addAction(uploadImageAction)
                
                let invitePeopleAction = UIAlertAction(title: "Invite people", style: .default) { action in
                    let nextVC = InvitePeepsViewController()
                    nextVC.foodie = self.foodie
                    self.navigationController?.pushViewController(nextVC, animated: true)
                }
                alertController.addAction(invitePeopleAction)
                
                let deleteFoodieAction = UIAlertAction(title: "Delete foodie", style: .destructive) { action in
                    Database.database().reference().root.child("Foodies").child((self.foodie?.id)!).removeValue { (error, ref) in
                        if error != nil {
                            print("Error while deleting foodie object with error code: \(error!)")
                        }
                    }
                    self.navigationController?.popToRootViewController(animated: true)
                }
                alertController.addAction(deleteFoodieAction)
            } else {
                let uploadImageAction = UIAlertAction(title: "Upload image", style: .default) { action in
                    self.present(self.picker, animated: true, completion: nil)
                }
                alertController.addAction(uploadImageAction)
                
                let leaveFoodie = UIAlertAction(title: "Leave foodie", style: .default) { action in
                    guard let uid = Auth.auth().currentUser?.uid else {
                        print("Couldn't take current user uid")
                       return
                    }
                    
                    var invitedIds = self.foodie?.invitedIds
                    invitedIds?.remove(at: (invitedIds?.index(of: uid))!)
                    Database.database().reference().root.child("Foodies").child((self.foodie?.id)!).updateChildValues(["invitedIds": invitedIds!])
                    self.navigationController?.popToRootViewController(animated: true)
                }
                alertController.addAction(leaveFoodie)
            }
            
            self.present(alertController, animated: true) {
                // ...
            }
            
        } else {
            let noInternetAlert = UIAlertController(title: "Sorry!", message: "You actually don't have access to network, please wait until you have connection.", preferredStyle: .alert)
            noInternetAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (UIAlertAction) in
                
            }))
            self.present(noInternetAlert, animated: true){
                
            }
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated:true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let chosenImage = info[UIImagePickerControllerEditedImage] as! UIImage
        var images = foodie?.images
        let imageName = NSUUID().uuidString
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let storageRef = Storage.storage().reference().child("foodie_image").child("\(imageName).png")
        guard let uploadImage = UIImagePNGRepresentation(chosenImage) else {
            print("Couldn't take foodie new image pngrepresentation")
            return
        }
        storageRef.putData(uploadImage, metadata: nil, completion:
            {(metadata, error) in
                if error != nil {
                    print(error!)
                    return
                }
                guard let imageUrl = metadata?.downloadURL()?.absoluteString else {
                    print("Couldn't take foodie new image url")
                    return
                }
                images?.append(imageUrl)
                Database.database().reference().root.child("Foodies").child((self.foodie?.id)!).updateChildValues(["images": images!])
                guard let newFoodie = self.foodie else {
                    print("Couldn't take foodie structure")
                    return
                }
                self.foodie = Foodie(userId: newFoodie.userId, id: newFoodie.id, name: newFoodie.name, longitude: newFoodie.longitude, latitude: newFoodie.latitude, address: newFoodie.address, date: formatter.string(from: newFoodie.date), images: images!, invitedIds: newFoodie.invitedIds)
            
                self.dismiss(animated:true){
                    self.collectionView?.reloadData()
                }
        })
    }
    
    func setUpView() {
        
        //        foodieImageView.image = #imageLiteral(resourceName: "LogInImage")
        //        self.view.addSubview(foodieImageView)
        //        foodieImageView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 0).isActive = true
        //        foodieImageView.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 25).isActive = true
        //        foodieImageView.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: -25).isActive = true
        //        foodieImageView.heightAnchor.constraint(equalTo: self.view.heightAnchor, multiplier: 0.33).isActive = true
        
        foodieNameLabel.text = foodie?.name
        self.view.addSubview(foodieNameLabel)
        foodieNameLabel.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 6).isActive = true
        foodieNameLabel.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 25).isActive = true
        foodieNameLabel.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: -25).isActive = true
        foodieNameLabel.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM dd, yyyy' at 'h:mm a"
        foodieDateLabel.text = formatter.string(from: (foodie?.date)!)
        self.view.addSubview(foodieDateLabel)
        foodieDateLabel.topAnchor.constraint(equalTo: self.foodieNameLabel.bottomAnchor, constant: 8).isActive = true
        foodieDateLabel.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 25).isActive = true
        foodieDateLabel.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: -25).isActive = true
        foodieDateLabel.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        
        
        collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        collectionView?.register(FoodCell.self, forCellWithReuseIdentifier: "CellId")
        collectionView?.dataSource = self
        collectionView?.delegate = self
        layout.scrollDirection = .horizontal
        collectionView?.backgroundColor = .white
        collectionView?.showsHorizontalScrollIndicator = false
        collectionView?.translatesAutoresizingMaskIntoConstraints = false
        
        self.view.addSubview(collectionView!)
        collectionView?.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 18).isActive = true
        collectionView?.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: 0).isActive = true
        collectionView?.topAnchor.constraint(equalTo: self.foodieDateLabel.bottomAnchor, constant: 16).isActive = true
        collectionView?.heightAnchor.constraint(equalTo: self.view.heightAnchor, multiplier: 0.2).isActive = true
        
        
        foodieAdressLabel.text = foodie?.address
        self.view.addSubview(foodieAdressLabel)
        foodieAdressLabel.topAnchor.constraint(equalTo: (self.collectionView?.bottomAnchor)!, constant: 10).isActive = true
        foodieAdressLabel.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 16).isActive = true
        foodieAdressLabel.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: -16).isActive = true
        foodieAdressLabel.heightAnchor.constraint(equalToConstant: 30).isActive = true
        
        self.view.addSubview(foodieMap)
        foodieMap.topAnchor.constraint(equalTo: self.foodieAdressLabel.bottomAnchor, constant: 4).isActive = true
        foodieMap.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 16).isActive = true
        foodieMap.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: -16).isActive = true
        foodieMap.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -66).isActive = true
        
        self.view.addSubview(goToMapsButton)
        goToMapsButton.topAnchor.constraint(equalTo: self.foodieAdressLabel.topAnchor, constant: 0).isActive = true
        goToMapsButton.leftAnchor.constraint(equalTo: self.foodieMap.leftAnchor, constant: 0).isActive = true
        goToMapsButton.rightAnchor.constraint(equalTo: self.foodieMap.rightAnchor, constant: 0).isActive = true
        goToMapsButton.bottomAnchor.constraint(equalTo: self.foodieMap.bottomAnchor, constant: 0).isActive = true
        
       guard let latitude = foodie?.latitude, let longitude = foodie?.longitude  else {
            print("Couldn't take longitude and latitude fron foodie")
            return
        }
        
        let span = MKCoordinateSpanMake(0.005, 0.005)
        let region = MKCoordinateRegionMake(CLLocationCoordinate2D(latitude: latitude, longitude: longitude) , span)
        foodieMap.setRegion(region, animated: true)
        let annotation = MKPointAnnotation()
        annotation.coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        foodieMap.addAnnotation(annotation)
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if self.foodie?.images.count == 0 {
            return CGSize(width: collectionView.frame.width - 16, height: collectionView.frame.height - 8)
        } else {
            return CGSize(width: collectionView.frame.height - 8, height: collectionView.frame.height - 8)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CellId", for: indexPath) as! FoodCell
        
        if self.foodie?.images.count == 0 {
            cell.foodLabel.text = "No images uploaded on this foodie"
        } else {
            guard let url = URL.init(string: (self.foodie?.images[indexPath.row])!) else {
                cell.foodImage.image = #imageLiteral(resourceName: "logInImage")
                return cell
            }
            
            print("descargando imagen")
            cell.foodImage.sd_setImage(with: url, placeholderImage: #imageLiteral(resourceName: "logInImage"))
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if self.foodie?.images.count == 0 {
            return 1
        } else {
            return (self.foodie?.images.count)!
        }
    }
    
    


}
