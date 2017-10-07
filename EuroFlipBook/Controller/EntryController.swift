//
//  EntryController.swift
//  EuroFlipBook
//
//  Created by Stephen Martinez on 10/6/17.
//  Copyright © 2017 Stephen Martinez. All rights reserved.
//

import UIKit

class EntryController: UIViewController{
    
    @IBOutlet var activityViewPlacard: UIView!
    @IBOutlet weak var activitySpinner: UIActivityIndicatorView!
    @IBOutlet weak var enterFlipBookButton: UIButton!
    @IBOutlet weak var centerArea: UIView!
    
    let imageStack = Stack<UIImage>()
    
    override func viewDidLoad() { super.viewDidLoad()
        EuroFlipBook.shared.navCon = navigationController
    }
    
    @IBAction func enter(_ sender: AnyObject) {
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
    }
    
    
}
