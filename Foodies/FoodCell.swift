//
//  FoodCell.swift
//  Foodies
//
//  Created by Roberto Pirck Valdés on 15/9/17.
//  Copyright © 2017 Roberto Pirck Valdés. All rights reserved.
//

import UIKit

class FoodCell: UICollectionViewCell {
    
    let foodImage : UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        return imageView
        
    }()
    
    let foodLabel : UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
        
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .black
        layer.cornerRadius = frame.height/2
        clipsToBounds = true
        addSubview(foodImage)
        
        foodImage.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 0).isActive = true
        foodImage.rightAnchor.constraint(equalTo: self.rightAnchor, constant: 0).isActive = true
        foodImage.topAnchor.constraint(equalTo: self.topAnchor, constant: 0).isActive = true
        foodImage.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 0).isActive = true
        
        addSubview(foodLabel)
        
        foodLabel.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 5).isActive = true
        foodLabel.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -5).isActive = true
        foodLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor, constant: 0).isActive = true
        foodLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor, constant: 0).isActive = true
        
        
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    
}

