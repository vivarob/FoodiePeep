//
//  RestaurantsTable.swift
//  Foodies
//
//  Created by Roberto Pirck Valdés on 12/9/17.
//  Copyright © 2017 Roberto Pirck Valdés. All rights reserved.
//

import UIKit
import Firebase
import SDWebImage


class RestaurantsTable: UITableViewController {
    
    
    var restaurantsIds = [String]()
    var restaurants = [Restaurant]()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Restaurants"
        self.view.backgroundColor = .white
        setUpNavigationBar()
        setUpTableView()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        getRestaurants()
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
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(goToCreateRestaurant))
    }
    
    func goToCreateRestaurant(){
        self.navigationController?.pushViewController(RestaurantMap(), animated: true)
    }
    
    func setUpTableView(){
        tableView.tableFooterView = UIView()
        tableView.allowsSelection = true
        refreshControl = UIRefreshControl()
        refreshControl?.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl?.addTarget(self, action: #selector(getRestaurants), for: .valueChanged)
        tableView.addSubview(refreshControl!)
        tableView.register(RestaurantCell.self, forCellReuseIdentifier: "CellId")
    }
    
    func getRestaurants(){
        print("getting restaurants")
        //        let userID = Auth.auth().currentUser?.uid
        let ref = Database.database().reference()
        self.restaurants.removeAll()
        self.restaurantsIds.removeAll()
        self.tableView.reloadData()
        ref.child("Restaurants").observe(.childAdded , with: { (snapshot) in
            // Get user value
            print("entered")
            guard let value = snapshot.value as? NSDictionary else {
                print("Couldn't take value for Restaurant")
                return
            }
            if !self.restaurantsIds.contains((value["id"] as? String)!) {
                self.restaurantsIds.append((value["id"] as? String)!)
                self.restaurants.append(Restaurant(dictionary: value as! [String : Any]))
            }
            self.refreshControl?.endRefreshing()
            self.tableView.reloadData()
        }) { (error) in
            self.refreshControl?.endRefreshing()
            self.tableView.reloadData()
            print(error.localizedDescription)
        }
        self.refreshControl?.endRefreshing()
        self.tableView.reloadData()
        
    }

    
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return restaurants.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CellId", for: indexPath) as! RestaurantCell
        cell.restaurantNameLabel.text = self.restaurants[indexPath.row].name
        cell.restaurantAddressLabel.text = self.restaurants[indexPath.row].address
        guard let url = URL.init(string: self.restaurants[indexPath.row].imageUrl) else {
            print("Couldn't get url from restaurant object")
            cell.restaurantImage.image = #imageLiteral(resourceName: "logInImage")
            return cell
        }
        cell.restaurantImage.sd_setImage(with: url, placeholderImage: #imageLiteral(resourceName: "logInImage"))
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let restaurantMaxView = RestaurantMaxView()
        restaurantMaxView.restaurant = self.restaurants[indexPath.row]
        navigationController?.pushViewController(restaurantMaxView, animated: true)
        
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
