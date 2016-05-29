//
//  SecondViewController.swift
//  Solarbreeze
//
//  Created by Eric Betts on 5/27/16.
//  Copyright © 2016 Eric Betts. All rights reserved.
//

import UIKit

class SecondViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    let allModels : [Model] = ThePoster.models
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }    

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allModels.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let model = allModels[indexPath.row]
        let cell = tableView.dequeueReusableCellWithIdentifier("tableViewCell")
                
        if let cell = cell {
            if let label = cell.contentView.subviews.first as? UILabel {
                label.text = model.name
                label.textAlignment = NSTextAlignment.Center
            }
            return cell
        }
        return UITableViewCell()
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let model = allModels[indexPath.row]
        print("\(model.name) selected")
        let token = Token.build(model)
        print("Created: \(token)")
        token.dump(appDelegate.applicationDocumentsDirectory)
        //TODO: Reload library in firstviewcontroller
    }
}

