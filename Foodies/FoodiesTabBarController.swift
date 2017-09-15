//
//  FoodiesTabBarController.swift
//  Foodies
//
//  Created by Roberto Pirck Valdés on 12/9/17.
//  Copyright © 2017 Roberto Pirck Valdés. All rights reserved.
//

import UIKit

class FoodiesTabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpTabBar()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setUpTabBar(){
        let foodiesController = lightStatusBarNavigation(rootViewController: FoodiesTable())
        let restaurantsController = lightStatusBarNavigation(rootViewController: RestaurantsTable())
        let profileController = lightStatusBarNavigation(rootViewController: ProfileController())
        
        foodiesController.tabBarItem = UITabBarItem(title: "Foodies", image: #imageLiteral(resourceName: "foodieTab"), tag: 0)
        restaurantsController.tabBarItem = UITabBarItem(title: "Restaurants", image: #imageLiteral(resourceName: "restaurantTab"), tag: 1)
        profileController.tabBarItem = UITabBarItem(title: "Profile", image: #imageLiteral(resourceName: "profileTab"), tag: 2)
        setViewControllers([foodiesController,restaurantsController,profileController], animated: true)
        selectedIndex = 1
        
        tabBar.barTintColor =   UIColor(red: 241/155, green: 196/255, blue: 15/255, alpha: 1)
        
        let normalColor = UIColor(red: 164/255, green: 170/255, blue: 179/255, alpha: 1)
        let selectedColor = UIColor.white
        
        
        tabBar.items![0].setTitleTextAttributes([NSForegroundColorAttributeName: selectedColor, NSFontAttributeName: UIFont(name: "HelveticaNeue-Medium", size: 11)!], for: .selected)
        tabBar.items![0].setTitleTextAttributes([NSForegroundColorAttributeName: normalColor, NSFontAttributeName: UIFont(name: "HelveticaNeue-Medium", size: 11)!], for: .normal)
        tabBar.items![0].image = self.tabBar.items![0].image?.tabBarImageWithCustomTint(tintColor: normalColor)
        tabBar.items![0].selectedImage = self.tabBar.items![0].selectedImage?.tabBarImageWithCustomTint(tintColor: selectedColor)
        
        
        tabBar.items![1].setTitleTextAttributes([NSForegroundColorAttributeName: selectedColor, NSFontAttributeName: UIFont(name: "HelveticaNeue-Medium", size: 11)!], for: .selected)
        tabBar.items![1].setTitleTextAttributes([NSForegroundColorAttributeName: normalColor, NSFontAttributeName: UIFont(name: "HelveticaNeue-Medium", size: 11)!], for: .normal)
        tabBar.items![1].image = self.tabBar.items![1].image?.tabBarImageWithCustomTint(tintColor: normalColor)
        tabBar.items![1].selectedImage = self.tabBar.items![1].selectedImage?.tabBarImageWithCustomTint(tintColor: selectedColor)
        
        
        tabBar.items![2].setTitleTextAttributes([NSForegroundColorAttributeName: selectedColor, NSFontAttributeName: UIFont(name: "HelveticaNeue-Medium", size: 11)!], for: .selected)
        tabBar.items![2].setTitleTextAttributes([NSForegroundColorAttributeName: normalColor, NSFontAttributeName: UIFont(name: "HelveticaNeue-Medium", size: 11)!], for: .normal)
        tabBar.items![2].image = self.tabBar.items![2].image?.tabBarImageWithCustomTint(tintColor: normalColor)
        tabBar.items![2].selectedImage = self.tabBar.items![2].selectedImage?.tabBarImageWithCustomTint(tintColor: selectedColor)
        
    }
}

extension UIImage {
    func tabBarImageWithCustomTint(tintColor: UIColor) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(self.size, false, self.scale)
        let context: CGContext = UIGraphicsGetCurrentContext()!
        
        context.translateBy(x: 0, y: self.size.height)
        context.scaleBy(x: 1.0, y: -1.0)
        context.setBlendMode(CGBlendMode.normal)
        let rect: CGRect = CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height)
        
        context.clip(to: rect, mask: self.cgImage!)
        
        tintColor.setFill()
        context.fill(rect)
        
        var newImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        newImage = newImage.withRenderingMode(UIImageRenderingMode.alwaysOriginal)
        return newImage
    }
}
