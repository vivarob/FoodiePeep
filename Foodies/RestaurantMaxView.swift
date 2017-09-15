//
//  RestaurantMaxView.swift
//  Foodies
//
//  Created by Roberto Pirck Valdés on 14/9/17.
//  Copyright © 2017 Roberto Pirck Valdés. All rights reserved.
//

import UIKit
import Firebase
import MapKit

class RestaurantMaxView: UIViewController{
    
    var restaurant: Restaurant? = nil
    let picker = UIImagePickerController()
    let layout = UICollectionViewFlowLayout()
    var collectionView: UICollectionView?
    
    var restaurantImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    var restaurantNameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "HelveticaNeue-Bold" , size: 24)
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var restaurantDateLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "HelveticaNeue-Regular" , size: 18)
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var restaurantAdressLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "HelveticaNeue-Regular" , size: 18)
        label.textAlignment = .left
        label.adjustsFontSizeToFitWidth = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var restaurantMap: MKMapView = {
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
        self.title = "restaurant"
        
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
        guard let latitude = restaurant?.latitude, let longitude = restaurant?.longitude else  {
            print("Couldn't get latitude and longitude from the restaurant")
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
        mapItem.name = restaurant?.name
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




        let leftButtonItem = UIBarButtonItem.init(customView: backButton)
        navigationItem.leftBarButtonItem = leftButtonItem

        
        
        guard let user = Auth.auth().currentUser else {
            print("Not the current user")
            return
        }
        
        let ref = Database.database().reference().child("Users").child(user.uid)
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            // Get user value
            guard let value = snapshot.value as? NSDictionary else { return print("Couldn't get snapshot value")}
            guard let userDictionary = value as? [String: Any] else { return print("Couldn't get dictionary from value") }
            let user = User(dictionary: userDictionary)
            guard let restaurant = self.restaurant  else { return print("Couldn't get restaurant from self.restaurant") }
            if user.restaurants.contains(restaurant.id) {
                self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "favImage"), style: .plain, target: self, action: #selector(self.addToFavRestaurants))
            } else {
                self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "unFavImage"), style: .plain, target: self, action: #selector(self.addToFavRestaurants))
            }
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    func addToFavRestaurants(){
        guard let user = Auth.auth().currentUser else {
            print("Couldn't get user")
            return
        }
        let ref = Database.database().reference().child("Users").child(user.uid)
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            // Get user value
            guard let value = snapshot.value as? NSDictionary else { return print("Couldn't get snapshot value")}
            guard let userDictionary = value as? [String: Any] else { return print("Couldn't get dictionary from value") }
            let user = User(dictionary: userDictionary)
            var restaurants = user.restaurants
            guard let restaurant = self.restaurant  else { return print("Couldn't get restaurant from self.restaurant") }
            if user.restaurants.contains(restaurant.id) {
                restaurants.remove(at: restaurants.index(of: restaurant.id)!)
                self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "unFavImage"), style: .plain, target: self, action: #selector(self.addToFavRestaurants))
            } else {
                restaurants.append(restaurant.id)
                self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "favImage"), style: .plain, target: self, action: #selector(self.addToFavRestaurants))
            }
            ref.updateChildValues(["restaurants": restaurants])

            
            // ...
        }) { (error) in
            print(error.localizedDescription)
        }

        
    }
    
    func setUpView() {
        
        guard let restaurant = restaurant, let url = URL.init(string: restaurant.imageUrl) else {
            print("Couldn't get url from restaurant object")
            restaurantImageView.image = #imageLiteral(resourceName: "logInImage")
            return
        }
        
        restaurantImageView.sd_setImage(with: url, placeholderImage: #imageLiteral(resourceName: "logInImage"))

        self.view.addSubview(restaurantImageView)
        restaurantImageView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 0).isActive = true
        restaurantImageView.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 0).isActive = true
        restaurantImageView.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: 0).isActive = true
        restaurantImageView.heightAnchor.constraint(equalTo: self.view.heightAnchor, multiplier: 0.33).isActive = true
        
        restaurantNameLabel.text = restaurant.name
        self.view.addSubview(restaurantNameLabel)
        restaurantNameLabel.topAnchor.constraint(equalTo: self.restaurantImageView.bottomAnchor, constant: 6).isActive = true
        restaurantNameLabel.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 25).isActive = true
        restaurantNameLabel.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: -25).isActive = true
        restaurantNameLabel.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        restaurantAdressLabel.text = restaurant.address
        self.view.addSubview(restaurantAdressLabel)
        restaurantAdressLabel.topAnchor.constraint(equalTo: restaurantNameLabel.bottomAnchor, constant: 16).isActive = true
        restaurantAdressLabel.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 16).isActive = true
        restaurantAdressLabel.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: -16).isActive = true
        restaurantAdressLabel.heightAnchor.constraint(equalToConstant: 30).isActive = true
        
        self.view.addSubview(restaurantMap)
        restaurantMap.topAnchor.constraint(equalTo: self.restaurantAdressLabel.bottomAnchor, constant: 4).isActive = true
        restaurantMap.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 16).isActive = true
        restaurantMap.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: -16).isActive = true
        restaurantMap.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -66).isActive = true
        
        self.view.addSubview(goToMapsButton)
        goToMapsButton.topAnchor.constraint(equalTo: self.restaurantAdressLabel.topAnchor, constant: 0).isActive = true
        goToMapsButton.leftAnchor.constraint(equalTo: self.restaurantMap.leftAnchor, constant: 0).isActive = true
        goToMapsButton.rightAnchor.constraint(equalTo: self.restaurantMap.rightAnchor, constant: 0).isActive = true
        goToMapsButton.bottomAnchor.constraint(equalTo: self.restaurantMap.bottomAnchor, constant: 0).isActive = true
        
        
        let span = MKCoordinateSpanMake(0.005, 0.005)
        let region = MKCoordinateRegionMake(CLLocationCoordinate2D(latitude: restaurant.latitude, longitude: restaurant.longitude) , span)
        restaurantMap.setRegion(region, animated: true)
        let annotation = MKPointAnnotation()
        annotation.coordinate = CLLocationCoordinate2D(latitude: restaurant.latitude, longitude: restaurant.longitude)
        restaurantMap.addAnnotation(annotation)
        
    }
    
}


