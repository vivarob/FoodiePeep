//
//  HomeView.swift
//  Foodies
//
//  Created by Roberto Pirck Valdés on 12/9/17.
//  Copyright © 2017 Roberto Pirck Valdés. All rights reserved.
//

import UIKit
import Firebase

class HomeView: UIViewController, UITextFieldDelegate{
    
    var handle : AuthStateDidChangeListenerHandle?
    var centerViewTopConstraint: NSLayoutConstraint?
    var centerViewHeightConstraint: NSLayoutConstraint?
    var usernameTopConstraint: NSLayoutConstraint?
    var usernameHeightConstraint: NSLayoutConstraint?
    var action = "signup"
    
    var loginImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = #imageLiteral(resourceName: "logInImage")
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    var centerView: UIView = {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width * 0.6 , height: 220))
        view.backgroundColor = .white
        view.layer.cornerRadius = 10
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = .zero
        view.layer.shadowOpacity = 1
        view.layer.shadowRadius = 4
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    var usernameTextField: UITextField = {
        let textField = UITextField()
        textField.keyboardType = .namePhonePad
        textField.borderStyle = .roundedRect
        textField.placeholder = "Username"
        textField.layer.shadowColor = UIColor.black.cgColor
        textField.layer.shadowOffset = .zero
        textField.layer.shadowOpacity = 1
        textField.layer.shadowRadius = 2
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    var emailTextField: UITextField = {
        let textField = UITextField()
        textField.keyboardType = .emailAddress
        textField.borderStyle = .roundedRect
        textField.placeholder = "Email"
        textField.layer.shadowColor = UIColor.black.cgColor
        textField.layer.shadowOffset = .zero
        textField.layer.shadowOpacity = 1
        textField.layer.shadowRadius = 2
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    var passwordTextField: UITextField = {
        let textField = UITextField()
        textField.isSecureTextEntry = true
        textField.borderStyle = .roundedRect
        textField.placeholder = "Password"
        textField.layer.shadowColor = UIColor.black.cgColor
        textField.layer.shadowOffset = .zero
        textField.layer.shadowOpacity = 1
        textField.layer.shadowRadius = 2
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    var actionButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = UIColor(red: 241/155, green: 196/255, blue: 15/255, alpha: 1)
        button.setTitle("Resgister", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont(name: "HelveticaNeue-Medium", size: 16)!
        button.layer.cornerRadius = 20
        button.addTarget(self, action: #selector(signUp), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    var changeButton: UIButton = {
        let button = UIButton()
//        button.backgroundColor = UIColor(red: 241/155, green: 196/255, blue: 15/255, alpha: 1)
        button.setTitle("Already have an account?", for: .normal)
        button.setTitleColor(.red, for: .normal)
        button.titleLabel?.font = UIFont(name: "HelveticaNeue-Medium", size: 16)!
        button.layer.cornerRadius = 20
        button.addTarget(self, action: #selector(changeCenterView), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Foodie"
        let tap: UITapGestureRecognizer = UITapGestureRecognizer( target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
//        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
//        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white, NSFontAttributeName: UIFont(name: "HelveticaNeue-Bold", size: 22)!]
        navigationController?.navigationBar.barTintColor = UIColor(red: 241/155, green: 196/255, blue: 15/255, alpha: 1)
        self.view.backgroundColor = .white
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        handle = Auth.auth().addStateDidChangeListener { (auth, user) in
            guard let currentUser = user else {
                self.setUpView()
                return
            }
            
            let ref = Database.database().reference(fromURL: "https://foodies-19e91.firebaseio.com/")
            ref.child("Users").child(currentUser.uid).observeSingleEvent(of: .value, with: { (snapshot) in
                // Get user value
                guard let value = snapshot.value as? NSDictionary else { return  self.setUpView() }
                guard let userDictionary = value as? [String: Any] else { return  self.setUpView() }
                let _ = User(dictionary: userDictionary)
                self.present(FoodiesTabBarController(), animated: false, completion: nil)
            }) { (error) in
                print(error.localizedDescription)
            }
            print("User currently logged in")
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        Auth.auth().removeStateDidChangeListener(handle!)
    }
    
    func changeCenterView(){
        switch action {
        case "login":
            UIView.transition(with: centerView, duration: 0.3, options: .transitionFlipFromLeft, animations: {
                self.actionButton.setTitle("Register", for: .normal)
                self.changeButton.setTitle("Already have an account?", for: .normal)
                self.usernameTopConstraint?.constant = 22
                self.usernameHeightConstraint?.constant = 30
                self.centerViewHeightConstraint?.constant = 220
                self.usernameTextField.isHidden = false
                self.action = "signup"

            }, completion: nil)
            UIView.transition(with: usernameTextField, duration: 0.3, options: .transitionFlipFromLeft, animations: nil, completion: nil)
            UIView.transition(with: emailTextField, duration: 0.3, options: .transitionFlipFromLeft, animations: nil, completion: nil)
            UIView.transition(with: passwordTextField, duration: 0.3, options: .transitionFlipFromLeft, animations: nil, completion: nil)
            UIView.transition(with: actionButton, duration: 0.3, options: .transitionFlipFromLeft, animations: nil, completion: nil)

            
        case "signup":
            UIView.transition(with: centerView, duration: 0.3, options: .transitionFlipFromRight, animations: {
                self.actionButton.setTitle("Log in", for: .normal)
                self.changeButton.setTitle("I have no account, i want to register.", for: .normal)
                self.usernameTopConstraint?.constant = 6
                self.usernameHeightConstraint?.constant = 0
                self.centerViewHeightConstraint?.constant = 174
                self.usernameTextField.isHidden = true
                self.action = "login"
            }, completion: nil)
            UIView.transition(with: usernameTextField, duration: 0.3, options: .transitionFlipFromRight, animations: nil, completion: nil)
            UIView.transition(with: emailTextField, duration: 0.3, options: .transitionFlipFromRight, animations: nil, completion: nil)
            UIView.transition(with: passwordTextField, duration: 0.3, options: .transitionFlipFromRight, animations: nil, completion: nil)
            UIView.transition(with: actionButton, duration: 0.3, options: .transitionFlipFromRight, animations: nil, completion: nil)

        default:
            break
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func dismissKeyboard() {
        self.view.endEditing(true)
    }
    
    func setUpView(){
        
        usernameTextField.delegate = self
        emailTextField.delegate = self
        passwordTextField.delegate = self

        
        self.view.addSubview(loginImageView)
        loginImageView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 70).isActive = true
        loginImageView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor, constant: 0).isActive = true
        loginImageView.widthAnchor.constraint(equalToConstant: 200).isActive = true
        loginImageView.heightAnchor.constraint(equalToConstant: 200).isActive = true
        
        self.view.addSubview(centerView)
        centerViewTopConstraint = centerView.topAnchor.constraint(equalTo: loginImageView.bottomAnchor, constant: 20)
        centerViewTopConstraint?.isActive = true
        centerView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor, constant: 0).isActive = true
        centerView.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.6).isActive = true
        centerViewHeightConstraint = centerView.heightAnchor.constraint(equalToConstant: 220)
        centerViewHeightConstraint?.isActive = true
        
        self.view.addSubview(usernameTextField)
        usernameTopConstraint = usernameTextField.topAnchor.constraint(equalTo: centerView.topAnchor, constant: 22)
        usernameTopConstraint?.isActive = true
        usernameTextField.leftAnchor.constraint(equalTo: centerView.leftAnchor, constant: 16).isActive = true
        usernameTextField.rightAnchor.constraint(equalTo: centerView.rightAnchor, constant: -16).isActive = true
        usernameHeightConstraint = usernameTextField.heightAnchor.constraint(equalToConstant: 30)
        usernameHeightConstraint?.isActive = true
        
        self.view.addSubview(emailTextField)
        emailTextField.topAnchor.constraint(equalTo: usernameTextField.bottomAnchor, constant: 16).isActive = true
        emailTextField.leftAnchor.constraint(equalTo: centerView.leftAnchor, constant: 16).isActive = true
        emailTextField.rightAnchor.constraint(equalTo: centerView.rightAnchor, constant: -16).isActive = true
        emailTextField.heightAnchor.constraint(equalToConstant: 30).isActive = true
        
        self.view.addSubview(passwordTextField)
        passwordTextField.topAnchor.constraint(equalTo: emailTextField.bottomAnchor, constant: 16).isActive = true
        passwordTextField.leftAnchor.constraint(equalTo: centerView.leftAnchor, constant: 16).isActive = true
        passwordTextField.rightAnchor.constraint(equalTo: centerView.rightAnchor, constant: -16).isActive = true
        passwordTextField.heightAnchor.constraint(equalToConstant: 30).isActive = true
        
        self.view.addSubview(actionButton)
        actionButton.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor, constant: 16).isActive = true
        actionButton.centerXAnchor.constraint(equalTo: self.view.centerXAnchor, constant: 0).isActive = true
        actionButton.widthAnchor.constraint(equalTo: centerView.widthAnchor, multiplier: 0.6).isActive = true
        actionButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        self.view.addSubview(changeButton)
        changeButton.topAnchor.constraint(equalTo: centerView.bottomAnchor, constant: 10).isActive = true
        changeButton.centerXAnchor.constraint(equalTo: self.view.centerXAnchor, constant: 0).isActive = true
        changeButton.widthAnchor.constraint(equalTo: centerView.widthAnchor, multiplier: 1.2).isActive = true
        changeButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
    }
    func textFieldDidBeginEditing(_ textField: UITextField) {
        UIView.animate(withDuration: 3) {
            self.centerViewTopConstraint?.constant = -100
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        UIView.animate(withDuration: 3) {
            self.centerViewTopConstraint?.constant = -20
        }
    }
    
    func moveCenterViewUp(){
        self.centerView.frame.origin.y -= 120
        self.usernameTextField.frame.origin.y -= 120
        self.emailTextField.frame.origin.y -= 120
        self.passwordTextField.frame.origin.y -= 120
        self.actionButton.frame.origin.y -= 120
    }
    
    func moveCenterViewDown(){
        self.centerView.frame.origin.y += 120
        self.usernameTextField.frame.origin.y += 120
        self.emailTextField.frame.origin.y += 120
        self.passwordTextField.frame.origin.y += 120
        self.actionButton.frame.origin.y += 120
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == usernameTextField {
            emailTextField.becomeFirstResponder()
        } else if textField == emailTextField {
            passwordTextField.becomeFirstResponder()
        } else {
            passwordTextField.resignFirstResponder()
            signUp()
        }
        return false
    }
    
    func signUp(){
        switch action {
        case "signup":
            guard let username = usernameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) else { return }
            guard let email = emailTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) else { return }
            guard let password = passwordTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) else { return }
            print(username)
            print(email)
            print(password)
            if username == "" {
                let alertController = UIAlertController(title: "Error", message: "Please enter a username", preferredStyle: .alert)
                
                let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                alertController.addAction(defaultAction)
                
                present(alertController, animated: true, completion: nil)
                
            } else if email == "" {
                let alertController = UIAlertController(title: "Error", message: "Please enter a email", preferredStyle: .alert)
                
                let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                alertController.addAction(defaultAction)
                
                present(alertController, animated: true, completion: nil)
                
            } else if password == "" {
                let alertController = UIAlertController(title: "Error", message: "Please enter a password", preferredStyle: .alert)
                
                let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                alertController.addAction(defaultAction)
                
                present(alertController, animated: true, completion: nil)
                
            } else {
                Auth.auth().createUser(withEmail: email, password: password) { (user, error) in
                    
                    if error == nil {
                        print("You have successfully signed up")
                        guard let userUId = user?.uid else {
                            return
                        }
                        let ref = Database.database().reference(fromURL: "https://foodies-19e91.firebaseio.com/")
                        
                        let usersRef = ref.child("Users").child(userUId)
                        usersRef.updateChildValues(["username" : username, "email": email, "uid": userUId, "bio": "", "dishes": [], "restaurants": []])
                        let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
                        changeRequest?.displayName = username
                        changeRequest?.commitChanges { (error) in
                            if error == nil {
                                self.present(FoodiesTabBarController(), animated: false, completion: nil)
                            } else {
                                print("Error while changing users username with error code:")
                                print(error!)
                                self.present(FoodiesTabBarController(), animated: false, completion: nil)
                            }
                        }
                        
                        
                        
                    } else {
                        let alertController = UIAlertController(title: "Error", message: error?.localizedDescription, preferredStyle: .alert)
                        
                        let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                        alertController.addAction(defaultAction)
                        
                        self.present(alertController, animated: true, completion: nil)
                    }
                }
            }
            print("sign up")
        case "login":
            guard let email = emailTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) else { return }
            guard let password = passwordTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) else { return }
            Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
                
                if error == nil {
                    
                    //Print into the console if successfully logged in
                    print("You have successfully logged in")
                    
                    //Go to the HomeViewController if the login is sucessful
                    self.present(FoodiesTabBarController(), animated: false, completion: nil)
                    
                } else {
                    
                    //Tells the user that there is an error and then gets firebase to tell them the error
                    let alertController = UIAlertController(title: "Error", message: error?.localizedDescription, preferredStyle: .alert)
                    
                    let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                    alertController.addAction(defaultAction)
                    
                    self.present(alertController, animated: true, completion: nil)
                }
            }
            print("login")
        default:
            break
        }
        
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
