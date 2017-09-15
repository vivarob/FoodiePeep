//
//  ChooseDishesTable.swift
//  Foodies
//
//  Created by Roberto Pirck Valdés on 15/9/17.
//  Copyright © 2017 Roberto Pirck Valdés. All rights reserved.
//


import UIKit
import Firebase

class ChooseDishesTable: UITableViewController {
    
    var user: User? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Favourite dishes"
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "CellId")
        seUpNavigationController()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func seUpNavigationController() {
        navigationController?.navigationBar.barTintColor = UIColor(red: 241/155, green: 196/255, blue: 15/255, alpha: 1)
        navigationController?.navigationBar.tintColor = UIColor.white
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white, NSFontAttributeName: UIFont(name: "HelveticaNeue-Bold", size: 20)!]
        navigationController?.navigationBar.isTranslucent = false
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(saveDishes))
        navigationItem.rightBarButtonItem?.setTitleTextAttributes([NSForegroundColorAttributeName: UIColor.white], for: .normal)
        
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
    
    func saveDishes(){
        guard let dishes = self.user?.dishes else {
            let savedAlert = UIAlertController(title: "", message: "An error has ocurred while saving favourite dishes for user, please try again later", preferredStyle: .alert)
            savedAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (UIAlertAction) in
                
            }))
            self.present(savedAlert, animated: true, completion: nil)
            return
        }
        Database.database().reference().root.child("Users").child((self.user?.uid)!).updateChildValues(["dishes": dishes])
        let savedAlert = UIAlertController(title: "Saved!", message: "Successfully changed favourite dishes for user", preferredStyle: .alert)
        savedAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (UIAlertAction) in
            self.navigationController?.popViewController(animated: true)
        }))
        self.present(savedAlert, animated: true, completion:  nil)
    }
    
    
    
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return (user?.dishes.count)! + 1
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CellId", for: indexPath)
        if indexPath.row == 0 {
            cell.textLabel?.text = "+ ADD DISH"
            cell.textLabel?.font = UIFont(name: "HelveticaNeue-Bold", size: 18)!
            cell.textLabel?.textColor = UIColor(red: 192/255, green: 57/255, blue: 43/255, alpha: 1)
            cell.selectionStyle = .gray
        } else {
            cell.textLabel?.text = user?.dishes[indexPath.row - 1]
            cell.textLabel?.textColor = .black
            cell.selectionStyle = .none
        }
        
        return cell
    }
    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        if indexPath.row == 0 {
            return false
        } else {
            return true
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            tableView.cellForRow(at: indexPath)?.isSelected = false
            let alertController = UIAlertController(title: "Add New Dish", message: "", preferredStyle: .alert)
            
            let saveAction = UIAlertAction(title: "Add dish", style: .default, handler: {
                alert -> Void in
                print("entered add dish")
                let firstTextField = alertController.textFields![0] as UITextField
                guard let newDish = firstTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines), newDish != ""  else {
                    return
                }
                guard let user = self.user else {
                    print("Couldn't take the user")
                    return
                }
                var dishes = user.dishes
                dishes.append(newDish)
                self.user = User(uid: user.uid, username: user.username, email: user.email, bio: user.bio, dishes: dishes, restaurants: user.restaurants, imageUrl: user.imageUrl)
                self.tableView.reloadData()
            })
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .destructive, handler: {
                (action : UIAlertAction!) -> Void in
                
            })
            
            alertController.addTextField { (textField : UITextField!) -> Void in
                textField.placeholder = "Enter new dishes"
            }
            
            alertController.addAction(saveAction)
            alertController.addAction(cancelAction)
            
            self.present(alertController, animated: true, completion: nil)
        } else {
        }
    }
    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            guard let user = self.user else {
                print("Couldn't take the user")
                return
            }
            var dishes = user.dishes
            dishes.remove(at: indexPath.row - 1)
            Database.database().reference().root.child("Users").child(user.uid).updateChildValues(["dishes": dishes])
            self.user = User(uid: user.uid, username: user.username, email: user.email, bio: user.bio, dishes: dishes, restaurants: user.restaurants, imageUrl: user.imageUrl)
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
    }
    
    
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
