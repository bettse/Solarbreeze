//
//  SecondViewController.swift
//  Solarbreeze
//
//  Created by Eric Betts on 5/27/16.
//  Copyright © 2016 Eric Betts. All rights reserved.
//

import UIKit

class SecondViewController : UIViewController, PortalUIProtocol {
    @IBOutlet weak var discover : UIButton!
    @IBOutlet weak var progress : UIProgressView!
    @IBOutlet weak var log : UITextView!
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var portalDriver : PortalDriver?

    override func viewDidLoad() {
        super.viewDidLoad()

        log.text = ""
        portalDriver = PortalDriver(ui: self)
        discover.addTarget(self, action: #selector(startDriver), for: .touchUpInside)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func startDriver() {
        portalDriver?.discover()
        discover.setTitle("Connecting...", for: .normal)
        progress.setProgress(0.0, animated: false)
        log((discover.titleLabel?.text)!)
    }
    
    func log(_ msg : String) {
        log.insertText("\(Date().customTime) \(msg)\n")
    }
    
    func connected() {
        discover.setTitle("Connected", for: .normal)
        log((discover.titleLabel?.text)!)
    }
    
    func disconnected() {
        discover.setTitle("Discover", for: .normal)
        log((discover.titleLabel?.text)!)
    }
    
    func newToken() {
        progress.setProgress(0.0, animated: false)
        log("New token")
    }
    
    func readBlock(number : Int) {
        progress.setProgress(Float(number + 1)/Float(MifareClassic.blockCount), animated: true)
    }
    
    func tokenSave(model: Model) {
        log("\(model.series) \(model.id) \(model.name)")
        progress.setProgress(1.0, animated: true)
    }
}
