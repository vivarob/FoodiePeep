//
//  RestaurantCell.swift
//  Foodies
//
//  Created by Roberto Pirck Valdés on 13/9/17.
//  Copyright © 2017 Roberto Pirck Valdés. All rights reserved.
//

import UIKit

class RestaurantCell: UITableViewCell {
    
    var restaurantImage: UIImageView = {
        let imageView = UIImageView()
        imageView.image = #imageLiteral(resourceName: "logInImage")
        imageView.layer.cornerRadius = 10
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    var restaurantNameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "HelveticaNeue-Medium", size: 18)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Roberto's Restaurant"
        return label
    }()
    
    var restaurantAddressLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "HelveticaNeue-Medium", size: 14)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.textColor = .lightGray
        label.text = "Avenida Papa Negro 45"
        return label
    }()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        addSubview(restaurantImage)
        restaurantImage.centerYAnchor.constraint(equalTo: self.centerYAnchor, constant: 0).isActive = true
        restaurantImage.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 16).isActive = true
        restaurantImage.heightAnchor.constraint(equalToConstant: 100).isActive = true
        restaurantImage.widthAnchor.constraint(equalToConstant: 100).isActive = true
        
        addSubview(restaurantNameLabel)
        restaurantNameLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 20).isActive = true
        restaurantNameLabel.leftAnchor.constraint(equalTo: restaurantImage.rightAnchor, constant: 8).isActive = true
        restaurantNameLabel.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -8).isActive = true
        restaurantNameLabel.heightAnchor.constraint(equalToConstant: 25).isActive = true
        
        addSubview(restaurantAddressLabel)
        restaurantAddressLabel.topAnchor.constraint(equalTo: restaurantNameLabel.bottomAnchor, constant: 0).isActive = true
        restaurantAddressLabel.leftAnchor.constraint(equalTo: restaurantImage.rightAnchor, constant: 8).isActive = true
        restaurantAddressLabel.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -8).isActive = true
        restaurantAddressLabel.heightAnchor.constraint(equalToConstant: 60).isActive = true
        
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
