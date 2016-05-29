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
        print("\(library.count) tokens")
        return library.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let token = library[indexPath.row]
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("cellView", forIndexPath: indexPath)
        
        if let subview = cell.subviews.first {
            subview.layer.borderWidth = 1
            subview.layer.borderColor = token.color.CGColor            
            if let label = subview.subviews.first as? UILabel {
                label.text = token.name
                label.textColor = UIColor.whiteColor()
                label.textAlignment = NSTextAlignment.Center
            }
        }        
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let token = library[indexPath.row]
        if let cell = collectionView.cellForItemAtIndexPath(indexPath) {
            if (cell.selected) {
                fakeBase.removeToken(token)
                cell.selected = false
            } else {
                fakeBase.placeToken(token)
                cell.selected = true
            }
        }
        
    }
}

