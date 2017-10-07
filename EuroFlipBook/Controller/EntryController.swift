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
    
    private let imageStack = Stack<UIImage>()
    private var locationName: String!
    
    override func viewWillAppear(_ animated: Bool) {super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = true
        enterFlipBookButton.alpha = 1
    }
    
    override func viewDidDisappear(_ animated: Bool) {super.viewDidDisappear(animated)
        activityViewPlacard.alpha = 0
        activityViewPlacard.removeFromSuperview()
    }
    
    @IBAction func enter(_ sender: AnyObject) {
        imageStack.removeAll()
        showLoading()
        let coordinate = EuroFlipBook.shared.randomLocation
        locationName = coordinate.name
        FlickrClient.photosForLocation(latitude: coordinate.lat, longitude: coordinate.lon){[unowned self] photoList, networkError in
            guard networkError == nil else{
                print("Network Error: \(networkError!.localizedDescription)")
                DispatchQueue.main.async {self.removeLoading()}
                return
            }
            guard let photoList = photoList, photoList.count != 0 else{
                DispatchQueue.main.async {self.removeLoading()}
                return
            }
            var loopCount = 0
            for photoInfo in photoList{
                FlickrClient.getPhotoFor(url: photoInfo.fullSize){ photoData, netError in
                    guard networkError == nil else{
                        print("Network Error: \(networkError!.localizedDescription)")
                        DispatchQueue.main.async {self.removeLoading()}
                        return
                    }
                    guard let photoData = photoData, let photoImage = UIImage(data: photoData) else{
                        self.imageStack.removeAll()
                        DispatchQueue.main.async {self.removeLoading()}
                        return
                    }
                    self.imageStack.push(photoImage)
                    loopCount += 1
                    print("Completed \(loopCount) out of \(photoList.count) stack inserts")
                    if loopCount == photoList.count{DispatchQueue.main.async {self.showFlipBookController()}}
                }
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let identifier = segue.identifier else{return}
        if identifier == EFBConstant.StoryBoardID.segueShowFBC{
            if let FlipBookVC = segue.destination as? FlipBookController{
                FlipBookVC.primaryDeck = imageStack
                FlipBookVC.locationName = locationName
            }
        }
    }
    
}


extension EntryController{
    
    func showLoading(completed: (()->Void)? = nil){
        activityViewPlacard.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(activityViewPlacard)
        NSLayoutConstraint.activate([
            activityViewPlacard.centerYAnchor.constraint(equalTo: centerArea.centerYAnchor, constant: 0),
            activityViewPlacard.centerXAnchor.constraint(equalTo: centerArea.centerXAnchor, constant: 0)
            ])
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseIn, animations: { [unowned self] in
            self.activityViewPlacard.alpha = 1
            self.enterFlipBookButton.alpha = 0
            }, completion: {_ in if let completed = completed{completed()}})
    }
    
    func removeLoading(completed: (()->Void)? = nil){
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseIn, animations: { [unowned self] in
            self.activityViewPlacard.alpha = 0
            self.enterFlipBookButton.alpha = 1
            self.activityViewPlacard.removeFromSuperview()
            }, completion: {_ in if let completed = completed{completed()}})
    }
    
    func showFlipBookController(){performSegue(withIdentifier: EFBConstant.StoryBoardID.segueShowFBC, sender: self)}
    
}
