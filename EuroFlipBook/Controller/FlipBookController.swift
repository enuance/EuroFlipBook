//
//  FlipBookController.swift
//  EuroFlipBook
//
//  Created by Stephen Martinez on 10/6/17.
//  Copyright © 2017 Stephen Martinez. All rights reserved.
//

import UIKit

class FlipBookController: UIViewController{
    
    @IBOutlet weak var bottomFlipView: UIImageView!
    @IBOutlet weak var topFlipView: UIImageView!
    private(set) var showingTopView = true
    
    private let upperDeck = Stack<UIImage>()
    var primaryDeck: Stack<UIImage>!
    var locationName: String!
    
    override func viewDidLoad() {
        navigationController?.isNavigationBarHidden = false
        super.viewDidLoad()
        setGestures()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard let imageForTopView = primaryDeck?.showing else{
            print("No Photos in Stack")
            navigationController?.popViewController(animated: false)
            return
        }
        topFlipView?.image = imageForTopView
        title = locationName
    }
    
    @objc private func flipUp(){
        guard !primaryDeck.isEmpty, let imageToSetWith = primaryDeck?.underneath else{print("End of FlipBook");return}
        guard let imageForUpperDeck = primaryDeck?.pop()else{print("Expected an image???");return}
        upperDeck.push(imageForUpperDeck)
        transitionFlipBookTo(
            imageToSetWith,
            topView: topFlipView,
            bottomView: bottomFlipView,
            flipUp: true,
            duration: EFBConstant.flipDuration)
    }
    
    @objc private func flipDown(){
        guard let imageForPrimaryDeck = upperDeck.pop() else{print("Beginning of FlipBook");return}
        primaryDeck?.push(imageForPrimaryDeck)
        guard let imageToSetWith = primaryDeck?.showing else{print("Expected an image???");return}
        transitionFlipBookTo(
            imageToSetWith,
            topView: topFlipView,
            bottomView: bottomFlipView,
            flipUp: false,
            duration: EFBConstant.flipDuration)
    }
    
    deinit {print("The FlipBookController has been Deinitialized")}
}

extension FlipBookController{
    
    //Sets the Swiping Gesture recognitions for the FullView Pop up
    func setGestures(){
        //Recognizers for the Top UIImageView
        let swipeUpRecognizerTop = UISwipeGestureRecognizer(target: self, action: #selector(flipUp))
        swipeUpRecognizerTop.numberOfTouchesRequired = 1
        swipeUpRecognizerTop.direction = UISwipeGestureRecognizerDirection.up
        
        let swipeDownRecognizerTop = UISwipeGestureRecognizer(target: self, action: #selector(flipDown))
        swipeDownRecognizerTop.numberOfTouchesRequired = 1
        swipeDownRecognizerTop.direction = UISwipeGestureRecognizerDirection.down
        
        //Recognizers for the Bottom UIImageView
        let swipeUpRecognizerBottom = UISwipeGestureRecognizer(target: self, action: #selector(flipUp))
        swipeUpRecognizerBottom.numberOfTouchesRequired = 1
        swipeUpRecognizerBottom.direction = UISwipeGestureRecognizerDirection.up
        
        let swipeDownRecognizerBottom = UISwipeGestureRecognizer(target: self, action: #selector(flipDown))
        swipeDownRecognizerBottom.numberOfTouchesRequired = 1
        swipeDownRecognizerBottom.direction = UISwipeGestureRecognizerDirection.down
        
        //Assignments for all the Gestures
        topFlipView?.addGestureRecognizer(swipeUpRecognizerTop)
        topFlipView?.addGestureRecognizer(swipeDownRecognizerTop)
        topFlipView?.isUserInteractionEnabled = true
        bottomFlipView?.addGestureRecognizer(swipeUpRecognizerBottom)
        bottomFlipView?.addGestureRecognizer(swipeDownRecognizerBottom)
        bottomFlipView?.isUserInteractionEnabled = true
    }
    
    //Animates the flipping image of the top/bottom imageView
    func transitionFlipBookTo(_ settingImage: UIImage, topView: UIImageView, bottomView: UIImageView, flipUp: Bool, duration: TimeInterval){
        if showingTopView{ bottomView.image = settingImage}
        else{topView.image = settingImage}
        let up = UIViewAnimationOptions.transitionCurlUp
        let down = UIViewAnimationOptions.transitionCurlDown
        let flipDirection = flipUp ? up : down
        UIView.transition(
            from: showingTopView ? topView : bottomView,
            to: showingTopView ? bottomView : topView,
            duration: duration,
            options: [.showHideTransitionViews, flipDirection],
            completion: {[weak self] transitioned in
                guard let showingTop = self?.showingTopView else{return}
                self?.showingTopView = showingTop ? false : true
        })
    }
    
    
    
}

