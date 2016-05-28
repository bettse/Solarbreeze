//
//  FirstViewController.swift
//  Solarbreeze
//
//  Created by Eric Betts on 5/27/16.
//  Copyright © 2016 Eric Betts. All rights reserved.
//

import UIKit

class FirstViewController: UIViewController {
    @IBOutlet weak var onSwitch: UISwitch!

    let fakeBase = FakeBase.singleton
    
    override func viewDidLoad() {
        super.viewDidLoad()
        onSwitch.addTarget(self, action: #selector(self.firmwareSwitch), forControlEvents: .ValueChanged)
        // Do any additional setup after loading the view, typically from a nib.
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
}

