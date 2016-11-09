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
    let appDelegate = UIApplication.shared.delegate as! AppDelegate

    let fakeBase = FakeBase.singleton
    var library : [Token] = {
        return Token.all()
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        onSwitch.addTarget(self, action: #selector(self.firmwareSwitch), for: .valueChanged)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func firmwareSwitch() {
        //Disable idle timer when fakebase is on
        UIApplication.shared.isIdleTimerDisabled = onSwitch.isOn
        if onSwitch.isOn {
            fakeBase.start()
        } else {            
            fakeBase.stop()
            fakeBase.clearAllTokens()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let count = library.count
        if (count > 0) {
            collectionView.allowsMultipleSelection = true
        }
        return count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let token = library[indexPath.row]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cellView", for: indexPath)
        
        if let background = cell.backgroundView {
            background.backgroundColor = token.color.withAlphaComponent(0.25)
        }
        
        if let selectedBackground = cell.selectedBackgroundView {
            selectedBackground.backgroundColor = token.color.withAlphaComponent(0.80)
        }
        
        for (index, subview) in cell.contentView.subviews.enumerated() {
            if let label = subview as? UILabel {
                label.textAlignment = NSTextAlignment.center
                switch (index) {
                case 0: //Name
                    label.text = token.name
                    break
                case 1: //Role
                    label.text = "\(token.symbol) \(token.role.description)"
                    break
                default:
                    print("unknown subview \(index)")
                }
            }
        }        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        let token = library[indexPath.row]
        fakeBase.removeToken(token)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let token = library[indexPath.row]
        print("\(token) selected")
        fakeBase.placeToken(token)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return true
    }
    
    func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
        let token = library[indexPath.row]
        switch(action.description) {
        case "cut:":
            print("Delete")
        case "copy:":
            if token is SkylanderToken {
                let st = (token as! SkylanderToken)
                st.gold += 1000
                //Not saved to disk, requires loading the character to save the values
                print("Gold: \(st.gold)")
            }
        case "paste:":
            let contents = NSMutableData(capacity: MifareClassic.tokenSize)!
            for i in 0..<MifareClassic.blockCount { contents.append(token.decryptedBlock(i)) }
            let filename = "\(token.name)-unencrypted-\(Date()).bak"
            contents.write(to: appDelegate.applicationDocumentsDirectory.appendingPathComponent(filename), atomically: true)
            print("Saved \(filename)")
        default:
            break
        }
    }
}

