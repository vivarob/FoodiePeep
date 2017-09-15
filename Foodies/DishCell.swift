//
//  DishCell.swift
//  Foodies
//
//  Created by Roberto Pirck Valdés on 12/9/17.
//  Copyright © 2017 Roberto Pirck Valdés. All rights reserved.
//

import UIKit

class DishCell: UICollectionViewCell {
    
    var dishLabel: UILabel =  {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = .white
        label.font = UIFont(name: "HelveticaNeue-Medium", size: 20)!
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(dishLabel)
        dishLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 5).isActive = true
        dishLabel.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -5).isActive = true
        dishLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -5).isActive = true
        dishLabel.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 5).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
