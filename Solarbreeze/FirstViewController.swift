//
//  FirstViewController.swift
//  Solarbreeze
//
//  Created by Eric Betts on 5/27/16.
//  Copyright © 2016 Eric Betts. All rights reserved.
//

import UIKit

class FirstViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    @IBOutlet weak var onSwitch: UISwitch!

    let fakeBase = FakeBase.singleton
    var library : [Token] = {
        return Token.all()
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        onSwitch.addTarget(self, action: #selector(self.firmwareSwitch), forControlEvents: .ValueChanged)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func firmwareSwitch() {
        //Disable idle timer when fakebase is on
        UIApplication.sharedApplication().idleTimerDisabled = onSwitch.on
        if onSwitch.on {
            fakeBase.start()
        } else {
            fakeBase.stop()
        }
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let count = library.count
        if (count > 0) {
            collectionView.allowsMultipleSelection = true
        }
        return count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let token = library[indexPath.row]
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("cellView", forIndexPath: indexPath)
        
        if let background = cell.backgroundView {
            background.layer.borderColor = token.color.CGColor
            background.layer.borderWidth = 1
        }
        
        if let selectedBackground = cell.selectedBackgroundView {
            selectedBackground.layer.borderColor = token.color.CGColor
            selectedBackground.layer.borderWidth = 3
        }        
        
        if let label = cell.contentView.subviews.first as? UILabel {
            label.text = token.name
            label.textColor = UIColor.whiteColor()
            label.textAlignment = NSTextAlignment.Center
        }
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didDeselectItemAtIndexPath indexPath: NSIndexPath) {
        let token = library[indexPath.row]
        fakeBase.removeToken(token)
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let token = library[indexPath.row]
        fakeBase.placeToken(token)
    }
}

