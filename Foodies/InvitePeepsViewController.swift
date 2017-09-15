//
//  InvitePeepsViewController.swift
//  Foodies
//
//  Created by Roberto Pirck Valdés on 15/9/17.
//  Copyright © 2017 Roberto Pirck Valdés. All rights reserved.
//

import Foundation
import UIKit
import Firebase

class InvitePeepsViewController: UITableViewController {
    
    var foodie: Foodie?
    var users = [User]()
    var usersIds = [String]()
    var invitedIds = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpNavigationBar()
        setUpTableView()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        guard let invitedArray = foodie?.invitedIds else {
            print("Couldn't take invitedIds from foodie")
            return
        }
        invitedIds = invitedArray
        getUsers()
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
        
        let backButton = UIButton.init(type: .custom)
        backButton.setImage(#imageLiteral(resourceName: "backArrow"), for: UIControlState.normal)
        backButton.frame = CGRect.init(x: 0, y: 0, width: 12, height: 20)
        backButton.addTarget(self, action: #selector(dismissVC), for: .touchUpInside)
        
        let leftButtonItem = UIBarButtonItem.init(customView: backButton)
        navigationItem.leftBarButtonItem = leftButtonItem
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(saveFoodie))
        
    }
    
    func dismissVC(){
        navigationController?.popViewController(animated: true)
    }
    
    func setUpTableView() {
        tableView.tableFooterView = UIView()
        tableView.allowsSelection = true
        tableView.allowsMultipleSelection = true
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "CellId")
        
    }
    
    func getUsers(){
        //        let userID = Auth.auth().currentUser?.uid
        let ref = Database.database().reference()
        self.users.removeAll()
        self.usersIds.removeAll()
        self.tableView.reloadData()
        ref.child("Users").observe(.childAdded , with: { (snapshot) in
            // Get user value
            print("entre")
            print(self.usersIds)
            print(self.users)
            if let value = snapshot.value as? NSDictionary {
                if !self.usersIds.contains((value["uid"] as? String)!) && value["uid"] as? String != Auth.auth().currentUser?.uid {
                    
                    //                if value.value(forKey: "userId") as? String == userID {
                    self.usersIds.append((value["uid"] as? String)!)
                    self.users.append(User(dictionary: value as! [String : Any]))
                    //                }
                }
                self.tableView.reloadData()
            }
            // ...
        }) { (error) in
            print(error.localizedDescription)
        }
        
        
    }
    
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.users.count
        
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CellId", for: indexPath)
        print(invitedIds.contains(self.users[indexPath.row].uid))
        if invitedIds.contains(self.users[indexPath.row].uid) {
            self.tableView.selectRow(at: indexPath, animated: true, scrollPosition: .none)
        } else {
        }
        cell.textLabel?.text = self.users[indexPath.row].username
        return cell
    }
    
    func saveFoodie() {
        guard let newFoodie = foodie else {
            print("Couldn't take invitedIds from foodie")
            return
        }
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let ref = Database.database().reference()
        var foodieRef = ref.child("Foodies")
        if newFoodie.id == "" {
            foodieRef = foodieRef.childByAutoId()

        } else {
            foodieRef = foodieRef.child(newFoodie.id)
        }
        let foodieDictionary = ["name" : newFoodie.name,
                                "date": formatter.string(from: newFoodie.date),
                                "id": foodieRef.key,
                                "userId": newFoodie.userId,
                                "longitude": newFoodie.longitude,
                                "latitude": newFoodie.latitude,
                                "images" : [],
                                "invitedIds" : invitedIds,
                                "address" : newFoodie.address
            ] as [String : Any]
        
        foodieRef.updateChildValues(foodieDictionary)
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.invitedIds.append(self.users[indexPath.row].uid)
        print(self.invitedIds)
    }
    
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if let deleteIndex = self.invitedIds.index(of: self.users[indexPath.row].uid) {
            self.invitedIds.remove(at: deleteIndex)
            print(self.invitedIds)
        }
    }
    
    /*
     override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
     let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)
     
     // Configure the cell...
     
     return cell
     }
     */
    
    /*
     // Override to support conditional editing of the table view.
     override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the specified item to be editable.
     return true
     }
     */
    
    /*
     // Override to support editing the table view.
     override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
     if editingStyle == .delete {
     // Delete the row from the data source
     tableView.deleteRows(at: [indexPath], with: .fade)
     } else if editingStyle == .insert {
     // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
     }
     }
     */
    
    /*
     // Override to support rearranging the table view.
     override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
     
     }
     */
    
    /*
     // Override to support conditional rearranging of the table view.
     override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the item to be re-orderable.
     return true
     }
     */
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
