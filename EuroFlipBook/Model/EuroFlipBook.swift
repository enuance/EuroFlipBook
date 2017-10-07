//
//  EuroFlipBook.swift
//  EuroFlipBook
//
//  Created by Stephen Martinez on 10/6/17.
//  Copyright © 2017 Stephen Martinez. All rights reserved.
//

import UIKit

//Singleton Class for the app
class EuroFlipBook{
    private init(){}
    static let shared = EuroFlipBook()
    let appDelegate = (UIApplication.shared.delegate as! AppDelegate)
    //passed in by rootController
    var navCon: UINavigationController!
    
}

struct EFBConst{
    struct StoryBoardID{
        let entryVC = "EntryController"
        let flipBookVC = "flipBookController"
        let segueShowFBC = "showFlipBookController"
    }
    
    
    
    
}
