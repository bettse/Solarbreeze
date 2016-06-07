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
        
        if let background = cell.backgroundView {
            background.backgroundColor = token.color.colorWithAlphaComponent(0.25)
        }
        
        if let selectedBackground = cell.selectedBackgroundView {
            selectedBackground.backgroundColor = token.color.colorWithAlphaComponent(0.80)
        }
        
        for (index, subview) in cell.contentView.subviews.enumerate() {
            if let label = subview as? UILabel {
                label.textAlignment = NSTextAlignment.Center
                switch (index) {
                case 0: //Name
                    label.text = "\(token.symbol)\(token.name)\(token.symbol)"
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
        print("\(token) selected")
        fakeBase.placeToken(token)
    }
    
    
    func collectionView(collectionView: UICollectionView, shouldShowMenuForItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    func collectionView(collectionView: UICollectionView, canPerformAction action: Selector, forItemAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) -> Bool {
        return true
    }
    
    func collectionView(collectionView: UICollectionView, performAction action: Selector, forItemAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) {
        let token = library[indexPath.row]
        switch(action.description) {
        case "cut:":
            print("Delete")
        case "copy:":
            if token is SkylanderToken {
                let st = (token as! SkylanderToken)
                st.gold += 1000
                //Not saved to disk...could be good, coult be bad
                print("Gold: \(st.gold)")
            }
        case "paste:":
            print("Add XP")
        default:
            break
        }
    }
}

