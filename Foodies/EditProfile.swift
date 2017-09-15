//
//  EditProfile.swift
//  Foodies
//
//  Created by Roberto Pirck Valdés on 14/9/17.
//  Copyright © 2017 Roberto Pirck Valdés. All rights reserved.
//

import UIKit
import Firebase
import KMPlaceholderTextView

class EditProfile: UIViewController , UITextViewDelegate, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate,UICollectionViewDelegateFlowLayout,  UICollectionViewDelegate, UICollectionViewDataSource{
    
    var bioTextViewHeightConstraint: NSLayoutConstraint?
    var bottomBioSeparatorViewToptConstraint: NSLayoutConstraint?
    var user: User? = nil
    
    var imagePicker: UIImagePickerController = {
        let picker = UIImagePickerController()
        picker.allowsEditing = true
        picker.sourceType = .photoLibrary
//        picker.mediaTypes = UIImagePickerController.availableMediaTypes(for: .photoLibrary)!
        return picker
    }()
    
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
    
    var changeProfileImageButton: UIButton = {
        let button = UIButton()
        button.addTarget(self, action: #selector(chooseImage), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    let usernameTextfield: UITextField = {
        let textfield = UITextField()
        textfield.backgroundColor = .white
        textfield.textColor = .black
        textfield.translatesAutoresizingMaskIntoConstraints = false
        return textfield
    }()
    
    let bioTextView: KMPlaceholderTextView = {
        let textView = KMPlaceholderTextView()
        textView.backgroundColor = .white
        textView.textColor = .black
        textView.layer.cornerRadius = 8
        textView.clipsToBounds = true
        textView.clearsContextBeforeDrawing = true
        textView.isScrollEnabled = true
        textView.translatesAutoresizingMaskIntoConstraints = false
        return textView
    }()
    
    let dishesLabel : UILabel = {
        let label = UILabel()
        label.text = "Favourite dishes"
        label.font = UIFont(name: "HelveticaNeue-Bold", size: 20)!
        label.textColor = .black
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
        
    }()
    
    let changeDishesButton: UIButton = {
        let button = UIButton(type: .contactAdd)
        button.tintColor =  UIColor(red: 241/155, green: 196/255, blue: 15/255, alpha: 1)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(goToChooseDishesTable), for: .touchUpInside)
        return button
    }()
    
    
    var dishesCollection: UICollectionView = {
        var layout = UICollectionViewFlowLayout()
        var collection = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collection.register(DishCell.self, forCellWithReuseIdentifier: "CellId")
        collection.backgroundColor = .white
        collection.showsHorizontalScrollIndicator = false
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 10
        layout.headerReferenceSize = CGSize(width: 5, height: 5)
        layout.footerReferenceSize = CGSize(width: 5, height: 5)
        collection.translatesAutoresizingMaskIntoConstraints = false
        return collection
    }()


    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        setUpNavigationBar()
        setUpView()
        let tap: UITapGestureRecognizer = UITapGestureRecognizer( target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        getUserInfo()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func dismissKeyboard() {
        self.view.endEditing(true)
    }
    
    func goToChooseDishesTable(){
        if let user = self.user {
            let nextVC = ChooseDishesTable()
            nextVC.user = user
            navigationController?.pushViewController(nextVC, animated: true)
        }
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
        profileImage.image = image
        guard let userID = Auth.auth().currentUser?.uid else {
            print("Couldn't take current user ID")
            self.dismiss(animated: true, completion: nil)
            return
        }
        
        let imageName = NSUUID().uuidString
        let storageRef = Storage.storage().reference().child("Restaurant-Images").child("\(imageName).png")
        guard let uploadImage = UIImagePNGRepresentation(profileImage.image!) else {
            print("Couldn't take restaurant uploaded image")
            self.dismiss(animated: true, completion: nil)
            return
        }
        
        storageRef.putData(uploadImage, metadata: nil, completion: {
            (metadata, error) in
            if error != nil {
                print(error!)
                self.dismiss(animated: true, completion: nil)
                return
            }
            guard let imageUrl = metadata?.downloadURL()?.absoluteString else {
                self.dismiss(animated: true, completion: nil)
                return
            }
            
            let ref = Database.database().reference().child("Users").child(userID)
            ref.updateChildValues(["imageUrl": imageUrl])
            self.dismiss(animated: true, completion: nil)
        })
    }
    
    func setUpNavigationBar(){
        navigationController?.navigationBar.barTintColor = UIColor(red: 241/155, green: 196/255, blue: 15/255, alpha: 1)
        navigationController?.navigationBar.tintColor = UIColor.white
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white, NSFontAttributeName: UIFont(name: "HelveticaNeue-Bold", size: 20)!]
        navigationController?.navigationBar.isTranslucent = false
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(saveUserInfo))
    }
    
    func setUpView(){
        bioTextView.delegate = self
        usernameTextfield.delegate = self
        bioTextView.placeholder = "Enter bio"
        
        let usernameBackgroundView = UIView(frame: CGRect(x: 0, y: 0, width: 120, height: 120))
        usernameBackgroundView.translatesAutoresizingMaskIntoConstraints = false
        usernameBackgroundView.backgroundColor = .white
        
        let bioBackgroundView = UIView(frame: CGRect(x: 0, y: 0, width: 120, height: 120))
        bioBackgroundView.translatesAutoresizingMaskIntoConstraints = false
        bioBackgroundView.backgroundColor = .white
        
        let topSeparatorView = UIView(frame: CGRect(x: 0, y: 0, width: 120, height: 120))
        topSeparatorView.translatesAutoresizingMaskIntoConstraints = false
        topSeparatorView.backgroundColor = .lightGray
        
        let centerSeparatorView = UIView(frame: CGRect(x: 0, y: 0, width: 120, height: 120))
        centerSeparatorView.translatesAutoresizingMaskIntoConstraints = false
        centerSeparatorView.backgroundColor = .lightGray
        
        let bottomSeparatorView = UIView(frame: CGRect(x: 0, y: 0, width: 120, height: 120))
        bottomSeparatorView.translatesAutoresizingMaskIntoConstraints = false
        bottomSeparatorView.backgroundColor = .lightGray
        
        let bottomDishesLabelSeparator = UIView(frame: CGRect(x: 0, y: 0, width: 120, height: 120))
        bottomDishesLabelSeparator.translatesAutoresizingMaskIntoConstraints = false
        bottomDishesLabelSeparator.backgroundColor = .lightGray
        
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
        
        self.view.addSubview(changeProfileImageButton)
        changeProfileImageButton.leftAnchor.constraint(equalTo: profileImage.leftAnchor, constant: 0).isActive = true
        changeProfileImageButton.rightAnchor.constraint(equalTo: profileImage.rightAnchor, constant: 0).isActive = true
        changeProfileImageButton.topAnchor.constraint(equalTo: profileImage.topAnchor, constant: 0).isActive = true
        changeProfileImageButton.bottomAnchor.constraint(equalTo: profileImage.bottomAnchor, constant: 0).isActive = true
        
        self.view.addSubview(usernameBackgroundView)
        usernameBackgroundView.topAnchor.constraint(equalTo: self.profileImage.bottomAnchor, constant: 16).isActive = true
        usernameBackgroundView.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 0).isActive = true
        usernameBackgroundView.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: 0).isActive = true
        usernameBackgroundView.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        usernameBackgroundView.addSubview(topSeparatorView)
        topSeparatorView.topAnchor.constraint(equalTo: usernameBackgroundView.topAnchor, constant: 0).isActive = true
        topSeparatorView.leftAnchor.constraint(equalTo: usernameBackgroundView.leftAnchor, constant: 10).isActive = true
        topSeparatorView.rightAnchor.constraint(equalTo: usernameBackgroundView.rightAnchor, constant: -10).isActive = true
        topSeparatorView.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
        usernameBackgroundView.addSubview(centerSeparatorView)
        centerSeparatorView.bottomAnchor.constraint(equalTo: usernameBackgroundView.bottomAnchor, constant: 0).isActive = true
        centerSeparatorView.leftAnchor.constraint(equalTo: usernameBackgroundView.leftAnchor, constant: 10).isActive = true
        centerSeparatorView.rightAnchor.constraint(equalTo: usernameBackgroundView.rightAnchor, constant: -10).isActive = true
        centerSeparatorView.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
        usernameBackgroundView.addSubview(usernameTextfield)
        usernameTextfield.centerYAnchor.constraint(equalTo: usernameBackgroundView.centerYAnchor, constant: 0).isActive = true
        usernameTextfield.leftAnchor.constraint(equalTo: usernameBackgroundView.leftAnchor, constant: 20).isActive = true
        usernameTextfield.rightAnchor.constraint(equalTo: usernameBackgroundView.rightAnchor, constant: -20).isActive = true
        usernameTextfield.heightAnchor.constraint(equalToConstant: 30).isActive = true
        
        
        self.view.addSubview(bioBackgroundView)
        bioBackgroundView.topAnchor.constraint(equalTo: usernameBackgroundView.bottomAnchor, constant: 0).isActive = true
        bioBackgroundView.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 0).isActive = true
        bioBackgroundView.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: 0).isActive = true
        bioTextViewHeightConstraint = bioBackgroundView.heightAnchor.constraint(equalToConstant: 70)
        
//        bioTextView.contentSize.height
        bioTextViewHeightConstraint?.isActive = true
        
        
        bioBackgroundView.addSubview(bioTextView)
        bioTextView.topAnchor.constraint(equalTo: bioBackgroundView.topAnchor, constant: 0).isActive = true
        bioTextView.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 18).isActive = true
        bioTextView.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: -18).isActive = true
        bioTextView.heightAnchor.constraint(equalToConstant: 60).isActive = true
        
        bioBackgroundView.addSubview(bottomSeparatorView)
        bottomBioSeparatorViewToptConstraint = bottomSeparatorView.topAnchor.constraint(equalTo: bioTextView.bottomAnchor, constant: 5)
        bottomBioSeparatorViewToptConstraint?.isActive = true
        bottomSeparatorView.leftAnchor.constraint(equalTo: bioBackgroundView.leftAnchor, constant: 10).isActive = true
        bottomSeparatorView.rightAnchor.constraint(equalTo: bioBackgroundView.rightAnchor, constant: -10).isActive = true
        bottomSeparatorView.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
        self.view.addSubview(dishesLabel)
        dishesLabel.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 18).isActive = true
        dishesLabel.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: -18).isActive = true
        dishesLabel.topAnchor.constraint(equalTo: bottomSeparatorView.bottomAnchor, constant: 20).isActive = true
        dishesLabel.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        self.view.addSubview(changeDishesButton)
        changeDishesButton.topAnchor.constraint(equalTo: dishesLabel.topAnchor, constant: 0).isActive = true
        changeDishesButton.rightAnchor.constraint(equalTo: dishesLabel.rightAnchor, constant: 0).isActive = true
        changeDishesButton.heightAnchor.constraint(equalTo: dishesLabel.heightAnchor, multiplier: 1).isActive = true
        changeDishesButton.widthAnchor.constraint(equalTo: changeDishesButton.heightAnchor, multiplier: 1).isActive = true
        
        dishesCollection.delegate = self
        dishesCollection.dataSource = self
        
        self.view.addSubview(dishesCollection)
        dishesCollection.topAnchor.constraint(equalTo: dishesLabel.bottomAnchor, constant: 8).isActive = true
        dishesCollection.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 25).isActive = true
        dishesCollection.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: 0).isActive = true
        dishesCollection.heightAnchor.constraint(equalToConstant: 80).isActive = true

    }
    
    func getUserInfo(){
        guard let userID = Auth.auth().currentUser?.uid else {
            print("no user id")
            return
        }
        
        let ref = Database.database().reference()
        ref.child("Users").child(userID).observeSingleEvent(of: .value, with: { (snapshot) in
            // Get user value
            guard let value = snapshot.value as? NSDictionary else {
                print("Couldn't take value dictionary for user")
                return
            }
            if (value["uid"] as? String)! == Auth.auth().currentUser?.uid {
                self.user = User(dictionary: value as! [String: Any])
                self.usernameTextfield.text = self.user?.username ?? ""
                self.usernameTextfield.placeholder = self.user?.username ?? ""
                if self.user?.bio == "" {
                    self.bioTextView.placeholder = "Enter bio"
                } else {
                    self.bioTextView.text = self.user?.bio ?? ""
                    self.bioTextView.placeholder = self.user?.bio ?? ""
                }
                self.bioTextView.text = self.user?.bio ?? ""
                self.bioTextView.placeholder = self.user?.bio ?? ""
                self.dishesCollection.reloadData()
                guard let url = URL.init(string: (self.user?.imageUrl)!) else {
                    print("Couldn't get url from restaurant object")
                    self.profileImage.image = #imageLiteral(resourceName: "logInImage")
                    return
                }
                
                self.profileImage.sd_setImage(with: url, placeholderImage: #imageLiteral(resourceName: "logInImage"))
                self.dishesCollection.reloadData()
            }
        }) { (error) in
            print(error.localizedDescription)
        }
        
    }
    
    func saveUserInfo(){
        var textChangedCount = 0
        var textChanged = ""
        guard let userID = Auth.auth().currentUser?.uid else {
            print("no user id")
            return
        }
        
        let ref = Database.database().reference().child("Users").child(userID)
        if let username = usernameTextfield.text, username != user?.username {
            ref.updateChildValues(["username": username])
            let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
            changeRequest?.displayName = username
            changeRequest?.commitChanges { (error) in
                if error == nil {
                    print("Successfully saved Auth.auth().currentUser?.displayName")
                } else {
                    print("Error while changing users username with error code:")
                    print(error!)
                }
            }
            textChangedCount += 1
            textChanged = " \r\n username"
        }
        if let bio = bioTextView.text, bio != user?.bio {
            ref.updateChildValues(["bio": bio])
            textChangedCount += 1
            textChanged = textChanged + " \r\n bio"
        }
        
        if textChangedCount > 0 {
            let savedAlert = UIAlertController(title: "Success!", message: "Successfully changed: \(textChanged)", preferredStyle: .alert)
            savedAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (UIAlertAction) in
                
            }))
            self.present(savedAlert, animated: true){
                
            }
        }
        
    }

    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        UIView.animate(withDuration: 0.1) {

            var textViewFrame = textView.frame
            textViewFrame.size.height = textView.contentSize.height
//            textView.frame = textViewFrame
            print(textView.contentSize.height)
//            self.bottomBioSeparatorViewToptConstraint?.constant = 0
//            self.bioTextViewHeightConstraint?.constant = textView.contentSize.height + 10
        }
        return true

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


}

//-(BOOL)textView:(UITextView *)_textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
//    [self adjustFrames];
//    return YES;
//}
//
//
//-(void) adjustFrames
//    {
//        CGRect textFrame = textView.frame;
//        textFrame.size.height = textView.contentSize.height;
//        textView.frame = textFrame;
//}
