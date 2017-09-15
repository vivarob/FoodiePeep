//
//  FavouriteRestaurantCell.swift
//  Foodies
//
//  Created by Roberto Pirck Valdés on 12/9/17.
//  Copyright © 2017 Roberto Pirck Valdés. All rights reserved.
//

import UIKit

class FavouriteRestaurantCell: UITableViewCell {
    
    var restaurantNameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "HelveticaNeue-Medium", size: 18)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var restaurantAddressLabel: UILabel = {
        let label = UILabel()
        label.textColor = .lightGray
        label.font = UIFont(name: "HelveticaNeue-Medium", size: 14)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        addSubview(restaurantNameLabel)
        restaurantNameLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 8).isActive = true
        restaurantNameLabel.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 16).isActive = true
        restaurantNameLabel.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -16).isActive = true
        restaurantNameLabel.heightAnchor.constraint(equalToConstant: 30).isActive = true
        
        
        addSubview(restaurantAddressLabel)
        restaurantAddressLabel.topAnchor.constraint(equalTo: self.restaurantNameLabel.bottomAnchor, constant: 4).isActive = true
        restaurantAddressLabel.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 16).isActive = true
        restaurantAddressLabel.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -16).isActive = true
        restaurantAddressLabel.heightAnchor.constraint(equalToConstant: 20).isActive = true
        
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
