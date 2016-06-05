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
    @IBOutlet weak var libraryView : UICollectionView!

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
            fakeBase.clearAllTokens()
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
        
        if let selectedBackground = cell.selectedBackgroundView {
            selectedBackground.backgroundColor = token.color
        }
        
        for (index, subview) in cell.contentView.subviews.enumerate() {
            if let label = subview as? UILabel {
                label.textAlignment = NSTextAlignment.Center
                switch (index) {
                case 0: //Name
                    label.text = token.name
                    break
                case 1: //Role
                    label.text = token.role.description
                    break
                default:
                    print("unknown subview \(index)")
                }
            }
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

