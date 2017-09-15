//
//  Models.swift
//  Foodies
//
//  Created by Roberto Pirck Valdés on 14/9/17.
//  Copyright © 2017 Roberto Pirck Valdés. All rights reserved.
//

import Foundation
import UIKit

class Foodie {
    let userId: String
    let id: String
    let name: String
    let longitude: Double
    let latitude: Double
    let address: String
    let date: Date
    let images: [String]
    let invitedIds: [String]
    
    init(dictionary: [String: Any]) {
        self.userId = dictionary["userId"] as? String ?? ""
        self.name = dictionary["name"] as? String ?? ""
        self.longitude = dictionary["longitude"] as? Double ?? 0
        self.latitude = dictionary["latitude"] as? Double ?? 0
        self.address = dictionary["address"] as? String ?? "Invalid Address"
        self.invitedIds = dictionary["invitedIds"] as? [String] ?? []
        self.images = dictionary["images"] as? [String] ?? []
        self.id = dictionary["id"] as? String ?? ""
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        guard let dateString = dictionary["date"] as? String else {
            print("Couldn't take date from dictionary")
            self.date = Date()
            return
        }
        self.date = formatter.date(from: dateString)!
    }
    
    init(userId: String,id: String, name: String, longitude: Double, latitude: Double, address: String, date: String ,images: [String], invitedIds: [String]) {
        self.userId = userId
        self.name = name
        self.longitude = longitude
        self.latitude = latitude
        self.address = address
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        self.date = formatter.date(from: date)!
        self.images = images
        self.invitedIds = invitedIds
        self.id = id
    }
}

class Restaurant {
    let userId: String
    let name: String
    let id: String
    let longitude: Double
    let latitude: Double
    let address: String
    let imageUrl: String
    
    init(dictionary: [String: Any]) {
        self.userId = dictionary["userId"] as? String ?? ""
        self.name = dictionary["name"] as? String ?? ""
        self.longitude = dictionary["longitude"] as? Double ?? 0
        self.latitude = dictionary["latitude"] as? Double ?? 0
        self.address = dictionary["address"] as? String ?? "Invalid Address"
        self.id = dictionary["id"] as? String ?? ""
        self.imageUrl = dictionary["imageUrl"] as? String ?? ""
    }
    
    init(userId: String,id: String, name: String, longitude: Double, latitude: Double, address: String, imageUrl: String) {
        self.userId = userId
        self.name = name
        self.longitude = longitude
        self.latitude = latitude
        self.address = address
        self.imageUrl = imageUrl
        self.id = id

    }
}

class User {
    let uid: String
    let username: String
    let email: String
    let bio: String
    let dishes: [String]
    let restaurants: [String]
    let imageUrl: String
    
    init(dictionary: [String: Any]) {
        self.uid = dictionary["uid"] as? String ?? ""
        self.username = dictionary["username"] as? String ?? ""
        self.email = dictionary["email"] as? String ?? "Invalid Address"
        self.bio = dictionary["bio"] as? String ?? ""
        self.dishes = dictionary["dishes"] as? [String] ?? []
        self.restaurants = dictionary["restaurants"] as? [String] ?? []
        self.imageUrl = dictionary["imageUrl"] as? String ?? ""
    }
    
    init(uid: String, username: String, email: String, bio: String, dishes: [String], restaurants: [String], imageUrl: String) {
        self.uid = uid
        self.username = username
        self.email = email
        self.bio = bio
        self.dishes = dishes
        self.restaurants = restaurants
        self.imageUrl = imageUrl

    }
    
    
}
