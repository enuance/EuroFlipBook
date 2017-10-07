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
    let session = URLSession.shared
    
    var randomLocation: (name: String, lat: String , lon: String){
        let index = Int(arc4random_uniform(UInt32(EFBConstant.locations.count)))
        return EFBConstant.locations[index]
    }
    
}

struct EFBConstant{
    
    struct StoryBoardID{
        static let entryVC = "EntryController"
        static let flipBookVC = "flipBookController"
        static let segueShowFBC = "showFlipBookController"
    }
    
    static let locations = [
        (name:"Dublin" , lat: "53.349453", lon: "-6.277983" ),
        (name:"Liverpool" , lat: "53.405234", lon: "-2.984898" ),
        (name:"London" , lat: "51.509576", lon: "-0.127484" ),
        (name:"Paris" , lat: "48.853995", lon: "2.342088" ),
        (name:"Brussels" , lat: "50.868458", lon: "4.355605" ),
        (name:"Amsterdam" , lat: "52.372633", lon: "4.895567" ),
        (name:"Frankfurt" , lat: "50.111423", lon: "8.683500" ),
        (name:"Stockholm" , lat: "59.331145", lon: "18.070405" ),
        (name:"Helsinki" , lat: "60.168777", lon: "24.937469" )
    ]
    
    static let flipDuration: TimeInterval = 0.7
}


