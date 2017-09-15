//
//  RestaurantMap.swift
//  Foodies
//
//  Created by Roberto Pirck Valdés on 13/9/17.
//  Copyright © 2017 Roberto Pirck Valdés. All rights reserved.
//

import UIKit
import MapKit
import Photos

class RestaurantMap: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, CLLocationManagerDelegate, MKMapViewDelegate{
    
    var locationManager = CLLocationManager()
    var centered: Bool?
    var markerImageBottomConstraint: NSLayoutConstraint?
    
    var markerImage: UIImageView = {
        let imageView = UIImageView()
        imageView.image = #imageLiteral(resourceName: "marker")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    var shadowImage: UIImageView = {
        let imageView = UIImageView()
        imageView.image = #imageLiteral(resourceName: "shadow")
        imageView.isHidden = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    var imagePicker: UIImagePickerController = {
        let picker = UIImagePickerController()
        picker.allowsEditing = true
        picker.sourceType = .photoLibrary
//        picker.mediaTypes = UIImagePickerController.availableMediaTypes(for: .photoLibrary)!
        return picker
    }()
    
    var restaurantMap: MKMapView = {
        let map = MKMapView()
        map.mapType = .standard
        map.showsUserLocation = false
        map.isScrollEnabled = true
        map.isZoomEnabled = true
        map.translatesAutoresizingMaskIntoConstraints = false
        return map
    }()
    
    var centerMapButton: UIButton = {
        let button = UIButton()
        button.setImage(#imageLiteral(resourceName: "centerImage"), for: .normal)
        button.layer.cornerRadius = 25
        button.clipsToBounds = true
        button.addTarget(self, action: #selector(centerMapButtonPressed), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpNavigationBar()
        setUpLocationPermissions()
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
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Next", style: .plain, target: self, action: #selector(nextVC))
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

    
    func centerMapButtonPressed(){
        guard let location = locationManager.location?.coordinate else {
            print("Couldn't get user position")
            return
        }
        restaurantMap.setCenter(location, animated: true)
    }
    
    func nextVC(){
        imagePicker.delegate = self
        let authStatus = PHPhotoLibrary.authorizationStatus()
        if (authStatus == PHAuthorizationStatus.authorized) {
            self.present(self.imagePicker, animated: true, completion: nil)
        } else if authStatus == .notDetermined || authStatus == .denied {
            PHPhotoLibrary.requestAuthorization({ (status) in
                if status == PHAuthorizationStatus.authorized {
                    print("entro aqui")
                    self.present(self.imagePicker, animated: true, completion: nil)
                } else {
                    let noAccesAlert = UIAlertController(title: "Sorry", message: "Actuallly we don't have acces to your library for getting the restaurants image, please allow us to access to your Photolibrary", preferredStyle: .alert)
                    noAccesAlert.addAction(UIAlertAction(title: "Allow", style: .default, handler: { (UIAlertAction) in
                        UIApplication.shared.open(URL(string: UIApplicationOpenSettingsURLString)! , options: [:], completionHandler: nil)
                    }))
                    
                    noAccesAlert.addAction(UIAlertAction(title: "Don't", style: .destructive, handler: nil))
                    
                    self.present(noAccesAlert, animated: true, completion: nil)
                }
            })
        }

    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let image = info[UIImagePickerControllerEditedImage]  as! UIImage
        
        dismiss(animated: true) {
            let nextVC = CreateRestaurant()
            nextVC.restaurantImage.image = image
            nextVC.restaurantLocation = self.restaurantMap.centerCoordinate
            self.navigationController?.pushViewController(nextVC, animated: true)
        }
    }
    
    func setUpView(){
        restaurantMap.delegate = self
        self.view.addSubview(restaurantMap)
        restaurantMap.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 0).isActive = true
        restaurantMap.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: 0).isActive = true
        restaurantMap.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 0).isActive = true
        restaurantMap.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: 0).isActive = true
        
        self.view.addSubview(markerImage)
        markerImage.centerXAnchor.constraint(equalTo: restaurantMap.centerXAnchor, constant: 0).isActive = true
        markerImageBottomConstraint = markerImage.bottomAnchor.constraint(equalTo: restaurantMap.centerYAnchor, constant: -20)
        markerImageBottomConstraint?.isActive = true
        markerImage.widthAnchor.constraint(equalToConstant: 80).isActive = true
        markerImage.heightAnchor.constraint(equalToConstant: 80).isActive = true
        
        self.view.addSubview(shadowImage)
        shadowImage.centerXAnchor.constraint(equalTo: restaurantMap.centerXAnchor, constant: 0).isActive = true
        shadowImage.topAnchor.constraint(equalTo: restaurantMap.centerYAnchor, constant: -20).isActive = true
        shadowImage.widthAnchor.constraint(equalToConstant: 20).isActive = true
        shadowImage.heightAnchor.constraint(equalToConstant: 20).isActive = true
        
        self.view.addSubview(centerMapButton)
        centerMapButton.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: -26).isActive = true
        centerMapButton.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -66).isActive = true
        centerMapButton.widthAnchor.constraint(equalToConstant: 50).isActive = true
        centerMapButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
    }
    
    func setUpLocationPermissions(){
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.startUpdatingLocation()
            //locationManager.startUpdatingHeading()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let userLocation:CLLocation = locations[0] as CLLocation
        if centered != true {
            let span = MKCoordinateSpanMake(0.01, 0.01)
            let region = MKCoordinateRegionMake(userLocation.coordinate, span)
            restaurantMap.setRegion(region, animated: true)
            centered = true
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error)
    {
        print("Error \(error)")
    }
    
    func mapView(_ mapView: MKMapView, regionWillChangeAnimated animated: Bool) {
        print("up")
        UIView.animate(withDuration: 3, animations: {
            self.markerImageBottomConstraint?.constant = -40
            self.shadowImage.isHidden = false
        }, completion: nil)
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        print("down")
        UIView.animate(withDuration: 3, animations: {
            self.markerImageBottomConstraint?.constant = -20
            self.shadowImage.isHidden = true
        }, completion: nil)

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
