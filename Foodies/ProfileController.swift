//
//  profileController.swift
//  Foodies
//
//  Created by Roberto Pirck Valdés on 12/9/17.
//  Copyright © 2017 Roberto Pirck Valdés. All rights reserved.
//

import UIKit

class profileController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Profile"
        self.view.backgroundColor = .red
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white, NSFontAttributeName: UIFont(name: "HelveticaNeue-Bold", size: 22)!]
        navigationController?.navigationBar.barTintColor = UIColor(red: 241/155, green: 196/255, blue: 15/255, alpha: 1)
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

