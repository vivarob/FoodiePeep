//
//  FoodieCell.swift
//  Foodies
//
//  Created by Roberto Pirck Valdés on 13/9/17.
//  Copyright © 2017 Roberto Pirck Valdés. All rights reserved.
//

import UIKit

class FoodieCell: UITableViewCell {
    
    var imagesCollectionHeightConstraint: NSLayoutConstraint?
 
    var foodieNameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "HelveticaNeue-Medium", size: 18)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var foodieAddressLabel: UILabel = {
        let label = UILabel()
        label.textColor = .lightGray
        label.font = UIFont(name: "HelveticaNeue-Medium", size: 14)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var foodieDateLabel: UILabel = {
        let label = UILabel()
        label.textColor = .red
        label.font = UIFont(name: "HelveticaNeue-Medium", size: 14)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var imagesCollection: UICollectionView = {
        var layout = UICollectionViewFlowLayout()
        var collection = UICollectionView(frame: .zero, collectionViewLayout: layout)
        layout.scrollDirection = .horizontal
        layout.headerReferenceSize = CGSize(width: 5, height: 5)
        layout.footerReferenceSize = CGSize(width: 5, height: 5)
        collection.register(FoodCell.self, forCellWithReuseIdentifier: "CellId")
        collection.backgroundColor = .clear
        collection.showsHorizontalScrollIndicator = false
        collection.translatesAutoresizingMaskIntoConstraints = false
        return collection
        
    }()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        addSubview(foodieNameLabel)
        foodieNameLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 8).isActive = true
        foodieNameLabel.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 16).isActive = true
        foodieNameLabel.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -16).isActive = true
        foodieNameLabel.heightAnchor.constraint(equalToConstant: 30).isActive = true
        
        addSubview(foodieAddressLabel)
        foodieAddressLabel.topAnchor.constraint(equalTo: self.foodieNameLabel.bottomAnchor, constant: 8).isActive = true
        foodieAddressLabel.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 16).isActive = true
        foodieAddressLabel.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -16).isActive = true
        foodieAddressLabel.heightAnchor.constraint(equalToConstant: 20).isActive = true
        
        addSubview(foodieDateLabel)
        foodieDateLabel.topAnchor.constraint(equalTo: self.foodieAddressLabel.bottomAnchor, constant: 8).isActive = true
        foodieDateLabel.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 16).isActive = true
        foodieDateLabel.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -16).isActive = true
        foodieDateLabel.heightAnchor.constraint(equalToConstant: 20).isActive = true

        addSubview(imagesCollection)
        imagesCollection.topAnchor.constraint(equalTo: self.foodieDateLabel.bottomAnchor, constant: 8).isActive = true
        imagesCollection.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 16).isActive = true
        imagesCollection.rightAnchor.constraint(equalTo: self.rightAnchor, constant: 0).isActive = true
        imagesCollectionHeightConstraint = imagesCollection.heightAnchor.constraint(equalToConstant: 100)
        imagesCollectionHeightConstraint?.isActive = true
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

extension FoodieCell {
    
    func setCollectionViewDataSourceDelegate<D: UICollectionViewDataSource & UICollectionViewDelegate>(_ dataSourceDelegate: D, forRow row: Int, forSection section:Int) {
        imagesCollection.delegate = dataSourceDelegate
        imagesCollection.dataSource = dataSourceDelegate
        imagesCollection.tag = row
        imagesCollection.setContentOffset(imagesCollection.contentOffset, animated:false) // Stops collection view if it was scrolling.
        imagesCollection.reloadData()
    }
    
    var collectionViewOffset: CGFloat {
        set { imagesCollection.contentOffset.x = newValue }
        get { return imagesCollection.contentOffset.x }
    }
    
}

