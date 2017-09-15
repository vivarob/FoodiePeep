//
//  FoodiesTable.swift
//  Foodies
//
//  Created by Roberto Pirck Valdés on 12/9/17.
//  Copyright © 2017 Roberto Pirck Valdés. All rights reserved.
//

import UIKit
import Firebase

class FoodiesTable: UITableViewController , UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    
    var storedOffsets = [Int: CGFloat]()
    let names = ["Primer Foodie","Segundo Foodie","Tercer Foodie"]
    let address = ["Avenida Papa Negro 45","Calle Machupichu 22","Rue de Marinie 13"]
    let dates = ["22/12/2017","12/10/2018","05/05/2018"]
    var foodies = [Foodie]()
    var foodiesIds = [String]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Foodies"
        self.view.backgroundColor = .white
        setUpNavigationBar()
        setUpTableView()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        getFoodies()
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
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(goToCreateFoodie))
    }
    
    func getFoodies(){
        let userID = Auth.auth().currentUser?.uid
        let ref = Database.database().reference()
        self.foodies.removeAll()
        self.foodiesIds.removeAll()
        self.tableView.reloadData()
        ref.child("Foodies").observe(.childAdded , with: { (snapshot) in
            // Get user value
            guard  let value = snapshot.value as? NSDictionary else {
                print("Couldn't take value for foodie")
                self.tableView.reloadData()
                self.refreshControl?.endRefreshing()
                return
            }
            if !self.foodiesIds.contains((value["id"] as? String)!) && value["userId"] as! String == userID!{
                self.foodiesIds.append((value["id"] as? String)!)
                self.foodies.append(Foodie(dictionary: value as! [String : Any]))
                
            }
            
            if let invitedIds = (value["invitedIds"] as? [String]), invitedIds.contains(userID!) {
                self.foodiesIds.append((value["id"] as? String)!)
                self.foodies.append(Foodie(dictionary: value as! [String : Any]))
            }
            self.tableView.reloadData()
            self.refreshControl?.endRefreshing()
        }) { (error) in
            print(error.localizedDescription)
            self.tableView.reloadData()
            self.refreshControl?.endRefreshing()
        }
        
        self.tableView.reloadData()
        self.refreshControl?.endRefreshing()
        
        
    }
    
    func goToCreateFoodie(){
        self.navigationController?.pushViewController(FoodieMap(), animated: true)
    }
    
    func setUpTableView(){
        tableView.register(FoodieCell.self, forCellReuseIdentifier: "CellId")
        tableView.tableFooterView = UIView()
        tableView.allowsSelection = true
        tableView.showsVerticalScrollIndicator = false
        refreshControl = UIRefreshControl()
        refreshControl?.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl?.addTarget(self, action: #selector(getFoodies), for: .valueChanged)
        tableView.addSubview(refreshControl!)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 80, height: 80)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.foodies[collectionView.tag].images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CellId", for: indexPath) as! FoodCell
        cell.backgroundColor = .white
        guard let url = URL.init(string: self.foodies[collectionView.tag].images[indexPath.row]) else {
            print("Couldn't get url from restaurant object")
            cell.foodImage.image = #imageLiteral(resourceName: "logInImage")
            return cell
        }
        
        cell.foodImage.sd_setImage(with: url, placeholderImage: #imageLiteral(resourceName: "logInImage"))
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if self.foodies[indexPath.row].images.count == 0 {
            return 106
        } else {
            return 212
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.foodies.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CellId", for: indexPath) as! FoodieCell
        cell.preservesSuperviewLayoutMargins = false
        cell.separatorInset = .zero
        cell.layoutMargins = .zero
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM dd, yyyy' at 'h:mm a"
        cell.foodieNameLabel.text = self.foodies[indexPath.row].name
        cell.foodieAddressLabel.text = self.foodies[indexPath.row].address
        cell.foodieDateLabel.text = formatter.string(from: self.foodies[indexPath.row].date)
        if self.foodies[indexPath.row].images.count == 0 {
            cell.imagesCollectionHeightConstraint?.constant = 0
        } else {
            cell.imagesCollectionHeightConstraint?.constant = 100
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let foodieMaxView = FoodieMaxView()
        foodieMaxView.foodie = self.foodies [indexPath.row]
        navigationController?.pushViewController(foodieMaxView, animated: true)
        
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let tableViewCell = cell as? FoodieCell else { return }
        
        tableViewCell.setCollectionViewDataSourceDelegate(self, forRow: indexPath.row, forSection: indexPath.section)
        tableViewCell.collectionViewOffset = storedOffsets[indexPath.row] ?? 0
    }

}
