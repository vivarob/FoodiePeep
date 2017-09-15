//
//  ProfileController.swift
//  Foodies
//
//  Created by Roberto Pirck Valdés on 12/9/17.
//  Copyright © 2017 Roberto Pirck Valdés. All rights reserved.
//

import UIKit
import Firebase
import KMPlaceholderTextView

class ProfileController: UIViewController, UICollectionViewDelegateFlowLayout, UICollectionViewDelegate, UICollectionViewDataSource, UITableViewDelegate, UITableViewDataSource {
    
    var bioHeightConstraint: NSLayoutConstraint?
    var restaurantsIds = [String]()
    var restaurants = [Restaurant]()
    var dishesArray = [String]()
    var user: User?

    
    var profileImage: UIImageView = {
        let imageView = UIImageView()
        imageView.image = #imageLiteral(resourceName: "logInImage")
        imageView.layer.cornerRadius = 50
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.layer.shadowColor = UIColor.black.cgColor
        imageView.layer.shadowOffset = .zero
        imageView.layer.shadowOpacity = 1
        imageView.layer.shadowRadius = 4
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    var usernameLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont(name: "HelveticaNeue-Bold", size: 20)!
        label.adjustsFontSizeToFitWidth = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var bioTextView: KMPlaceholderTextView = {
        let textView = KMPlaceholderTextView()
        textView.textAlignment = .center
        textView.showsVerticalScrollIndicator = false
        textView.isEditable = false
        textView.isSelectable = false
        textView.font = UIFont(name: "HelveticaNeue-Medium", size: 16)!
        textView.adjustsFontForContentSizeCategory = true
        textView.translatesAutoresizingMaskIntoConstraints = false
        return textView
    }()
    
    var dishesCollection: UICollectionView = {
        var layout = UICollectionViewFlowLayout()
        var collection = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collection.register(DishCell.self, forCellWithReuseIdentifier: "CellId")
        collection.backgroundColor = .clear
        collection.showsHorizontalScrollIndicator = false
        collection.backgroundColor = .white
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 10
        layout.headerReferenceSize = CGSize(width: 5, height: 5)
        layout.footerReferenceSize = CGSize(width: 5, height: 5)
        collection.translatesAutoresizingMaskIntoConstraints = false
        return collection
    }()
    
    var restaurantsTable: UITableView = {
       let tableView = UITableView()
        tableView.backgroundColor = .white
        tableView.tableFooterView = UIView()
        tableView.register(FavouriteRestaurantCell.self, forCellReuseIdentifier: "CellId")
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.showsVerticalScrollIndicator = false
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Profile"
        self.view.backgroundColor = .white
        setUpView()
        setUpNavigationBar()
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setUpInfo()
    }
    
    func setUpInfo(){
        print("settingUpInfo")
        guard let userID = Auth.auth().currentUser?.uid else {
            print("no user id")
         return
        }
        
        let ref = Database.database().reference(fromURL: "https://foodies-19e91.firebaseio.com/")
        ref.child("Users").child(userID).observeSingleEvent(of: .value, with: { (snapshot) in
            // Get user value
            guard let value = snapshot.value as? NSDictionary else { return print("diccionario")}
            guard let userDictionary = value as? [String: Any] else { return print("diccionario 2") }
            let user = User(dictionary: userDictionary)
            self.user = user
            self.usernameLabel.text = user.username
            if user.bio == "" {
//                self.bioHeightConstraint?.constant = 0
                self.bioTextView.placeholder = "No bio determined yet!"
            } else {
                self.bioTextView.text = user.bio
            }
            
            self.dishesArray = user.dishes
            self.dishesCollection.reloadData()

            let restaurantsRef = Database.database().reference().child("Restaurants")
            self.restaurants.removeAll()
            self.restaurantsIds.removeAll()
            self.restaurantsTable.reloadData()
            restaurantsRef.observe(.childAdded , with: { (snapshot) in
                // Get user value
                print("entered")
                guard let value = snapshot.value as? NSDictionary else {
                    print("Couldn't take value for Restaurant")
                    return
                }
                if !self.restaurantsIds.contains((value["id"] as? String)!) && user.restaurants.contains((value["id"] as? String)!) {
                    self.restaurantsIds.append((value["id"] as? String)!)
                    self.restaurants.append(Restaurant(dictionary: value as! [String : Any]))
                }
                self.restaurantsTable.reloadData()
            }) { (error) in
                self.restaurantsTable.reloadData()
                print(error.localizedDescription)
            }
            self.restaurantsTable.reloadData()
            
            guard let url = URL.init(string: user.imageUrl) else {
                print("Couldn't get url from restaurant object")
                self.profileImage.image = #imageLiteral(resourceName: "logInImage")
                return
            }
            
            self.profileImage.sd_setImage(with: url, placeholderImage: #imageLiteral(resourceName: "logInImage"))
            
            // ...
        }) { (error) in
            print(error.localizedDescription)
        }
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setUpNavigationBar() {
        navigationController?.navigationBar.barTintColor = UIColor(red: 241/155, green: 196/255, blue: 15/255, alpha: 1)
        navigationController?.navigationBar.tintColor = UIColor.white
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white, NSFontAttributeName: UIFont(name: "HelveticaNeue-Bold", size: 20)!]
        navigationController?.navigationBar.isTranslucent = false
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "optionsImage"), style: .plain, target: self, action: #selector(openOptions))
    }
    
    func goToEditProfile(){
        navigationController?.pushViewController(EditProfile(), animated: true)
    }
    
    func openOptions(){
        
        let alertController = UIAlertController(title: nil, message: "Options", preferredStyle: .actionSheet)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { action in
            // ...
        }
        alertController.addAction(cancelAction)
        
        
        let logOut = UIAlertAction(title: "Log out", style: .default) { action in
            let firebaseAuth = Auth.auth()
            do {
                try firebaseAuth.signOut()
                self.present(HomeView(), animated: false, completion: nil)
            } catch let signOutError as NSError {
                print ("Error signing out: \(signOutError)")
            } catch {
                print("Unknown error.")
            }
        }
        alertController.addAction(logOut)
        
        let invitePeopleAction = UIAlertAction(title: "Edit profile", style: .default) { action in
            self.navigationController?.pushViewController(EditProfile(), animated: true)
        }
        alertController.addAction(invitePeopleAction)
        
        self.present(alertController, animated: true) {
            // ...
        }
    }

    
    func setUpView() {
        
        let profileImageShadowView = UIView(frame: CGRect(x: 0, y: 0, width: 120, height: 120))
        profileImageShadowView.translatesAutoresizingMaskIntoConstraints = false
        
        
        profileImageShadowView.addSubview(profileImage)
        profileImage.leftAnchor.constraint(equalTo: profileImageShadowView.leftAnchor, constant: 0).isActive = true
        profileImage.rightAnchor.constraint(equalTo: profileImageShadowView.rightAnchor, constant: 0).isActive = true
        profileImage.topAnchor.constraint(equalTo: profileImageShadowView.topAnchor, constant: 0).isActive = true
        profileImage.bottomAnchor.constraint(equalTo: profileImageShadowView.bottomAnchor, constant: 0).isActive = true
        profileImage.layer.cornerRadius = 60
        profileImage.clipsToBounds = true
        
        self.view.addSubview(profileImageShadowView)
        profileImageShadowView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        profileImageShadowView.widthAnchor.constraint(equalToConstant: 120).isActive = true
        profileImageShadowView.heightAnchor.constraint(equalToConstant: 120).isActive = true
        profileImageShadowView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 16).isActive = true
        profileImageShadowView.clipsToBounds = false
        profileImageShadowView.layer.shadowColor = UIColor.black.cgColor
        profileImageShadowView.layer.shadowOpacity = 1
        profileImageShadowView.layer.shadowOffset = CGSize.zero
        profileImageShadowView.layer.shadowRadius = 5
        profileImageShadowView.layer.shadowPath = UIBezierPath(roundedRect: profileImageShadowView.bounds, cornerRadius: 60).cgPath
        
        
        self.view.addSubview(usernameLabel)
        usernameLabel.topAnchor.constraint(equalTo: profileImageShadowView.bottomAnchor, constant: 16).isActive = true
        usernameLabel.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 22).isActive = true
        usernameLabel.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: -22).isActive = true
        usernameLabel.heightAnchor.constraint(equalToConstant: 30).isActive = true
        
        self.view.addSubview(bioTextView)
        bioTextView.topAnchor.constraint(equalTo: usernameLabel.bottomAnchor, constant: 8).isActive = true
        bioTextView.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 22).isActive = true
        bioTextView.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: -22).isActive = true
        bioHeightConstraint = bioTextView.heightAnchor.constraint(equalToConstant: 50)
        bioHeightConstraint?.isActive = true
        
        
        dishesCollection.delegate = self
        dishesCollection.dataSource = self
        
        self.view.addSubview(dishesCollection)
        dishesCollection.topAnchor.constraint(equalTo: bioTextView.bottomAnchor, constant: 8).isActive = true
        dishesCollection.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 25).isActive = true
        dishesCollection.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: 0).isActive = true
        dishesCollection.heightAnchor.constraint(equalToConstant: 80).isActive = true
        
        
        
        let restaurantsTableShadowView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width - 50, height: self.view.frame.height - 460))
        restaurantsTableShadowView.translatesAutoresizingMaskIntoConstraints = false
        
        restaurantsTable.delegate = self
        restaurantsTable.dataSource = self
        restaurantsTableShadowView.addSubview(restaurantsTable)
        restaurantsTable.leftAnchor.constraint(equalTo: restaurantsTableShadowView.leftAnchor, constant: 0).isActive = true
        restaurantsTable.rightAnchor.constraint(equalTo: restaurantsTableShadowView.rightAnchor, constant: 0).isActive = true
        restaurantsTable.topAnchor.constraint(equalTo: restaurantsTableShadowView.topAnchor, constant: 0).isActive = true
        restaurantsTable.bottomAnchor.constraint(equalTo: restaurantsTableShadowView.bottomAnchor, constant: 0).isActive = true
        restaurantsTable.layer.cornerRadius = 20
        restaurantsTable.clipsToBounds = true
        
        self.view.addSubview(restaurantsTableShadowView)
        restaurantsTableShadowView.topAnchor.constraint(equalTo: dishesCollection.bottomAnchor, constant: 8).isActive = true
        restaurantsTableShadowView.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 25).isActive = true
        restaurantsTableShadowView.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: -25).isActive = true
        restaurantsTableShadowView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -60).isActive = true
        restaurantsTableShadowView.clipsToBounds = false
        restaurantsTableShadowView.layer.shadowColor = UIColor.black.cgColor
        restaurantsTableShadowView.layer.shadowOpacity = 1
        restaurantsTableShadowView.layer.shadowOffset = CGSize.zero
        restaurantsTableShadowView.layer.shadowRadius = 5
        restaurantsTableShadowView.layer.shadowPath = UIBezierPath(roundedRect: restaurantsTableShadowView.bounds, cornerRadius: 20).cgPath
        
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let user = self.user else {
            return 0
        }
        if user.dishes.count == 0 {
            return 1
        } else {
            return user.dishes.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard let user = self.user else {
            return CGSize(width: 50, height: 50)
        }
        if user.dishes.count == 0 {
            return CGSize(width: collectionView.frame.width - 16, height: 50)
        } else {
            let width = user.dishes[indexPath.row].width(withConstraintedHeight: 50, font: UIFont(name: "HelveticaNeue-Medium", size: 20)!)
            return CGSize(width: width + 20, height: 50)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CellId", for: indexPath) as! DishCell
        cell.layer.shadowOpacity = 1
        cell.layer.shadowColor  = UIColor.black.cgColor
        cell.layer.shadowOffset = .zero
        cell.layer.shadowRadius = 3
        cell.layer.cornerRadius = 25
        guard let user = self.user else {
            return cell
        }
        if user.dishes.count == 0 {
            cell.backgroundColor = UIColor(red: 241/155, green: 196/255, blue: 15/255, alpha: 1)
            cell.dishLabel.text = "No favourite dishes"
        } else {
            cell.backgroundColor = UIColor(red: 241/155, green: 196/255, blue: 15/255, alpha: 1)
            cell.dishLabel.text = user.dishes[indexPath.row]
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if restaurants.count == 0 {
            return 1
        } else {
            return restaurants.count
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CellId", for: indexPath) as! FavouriteRestaurantCell
        if restaurants.count == 0 {
            cell.restaurantNameLabel.text = "No favourite restaurants"
            cell.restaurantAddressLabel.text = "Go to restaurants tab and choose someone"
        } else {
            cell.restaurantNameLabel.text = self.restaurants[indexPath.row].name
            cell.restaurantAddressLabel.text = self.restaurants[indexPath.row].address
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if restaurants.count == 0 {
            return
        } else {
            let restaurantMaxView = RestaurantMaxView()
            restaurantMaxView.restaurant = self.restaurants[indexPath.row]
            navigationController?.pushViewController(restaurantMaxView, animated: true)
            
        }
    }


}

extension String {
    func height(withConstrainedWidth width: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [NSFontAttributeName: font], context: nil)
        
        return ceil(boundingBox.height)
    }
    
    func width(withConstraintedHeight height: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: .greatestFiniteMagnitude, height: height)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [NSFontAttributeName: font], context: nil)
        
        return ceil(boundingBox.width)
    }
}

