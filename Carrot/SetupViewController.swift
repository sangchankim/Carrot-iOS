//
//  SetupViewController.swift
//  Carrot
//
//  Created by Kevin Kim on 1/7/16.
//  Copyright © 2016 Kevin Kim. All rights reserved.
//

import UIKit
import Parse

class SetupViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var carrotView: UIView!
    @IBOutlet weak var sliderView: UIView!

    @IBOutlet weak var priceSlider: UISlider!
    
    @IBOutlet weak var currentPrice: UILabel!
    @IBOutlet weak var maxPrice: UILabel!
    

    var items : Item = Item()
    var index: Int = 0
    var tag: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Hard coded account and customer id
        let accountId = "56241a14de4bf40b17112f02"
        let customerId = "56241a13de4bf40b1711224d"
        PFUser.currentUser()?.setObject(accountId, forKey: "account_id")
        PFUser.currentUser()?.setObject(customerId, forKey: "customer_id")
        PFUser.currentUser()!.saveInBackgroundWithBlock {
            (success: Bool, error: NSError?) -> Void in
            if (success) {
                let currentUserID = PFUser.currentUser()?.objectId!
                PFCloud.callFunctionInBackground("processPurchases", withParameters: ["object_id" : currentUserID!]) { (returnData: AnyObject?, error: NSError?) -> Void in
                    if (error == nil) {
                        if let data = returnData {
                            self.items = Item()
                            let results = Utilities.convertStringToDictionary(data as! String)
                            
                            for (key,value) in results! {
                                var item_name: String = key
                                item_name = item_name.capitalizedString
                                let item_price: Double = value as! Double
                                
                                self.items.itemName.append(item_name)
                                self.items.price.append(item_price)
                            }
                            
                            self.tableView.reloadData()
                            
                        }
                    } else {
                        print("Totals Error = \(error)")
                    }
                }
            } else {
                print("failed posting account and customer id")
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    // MARK: - Table View
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.itemName.count
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("topThreeCell", forIndexPath: indexPath) as! topThreeTableViewCell
        cell.descripLabel.text = items.itemName[indexPath.row]
        cell.priceLabel.text = Utilities.getCurrencyValue(items.price[indexPath.row])
        cell.priceButton.tag = indexPath.row
        return cell
    }

    func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        let cell = tableView.cellForRowAtIndexPath(indexPath) as! topThreeTableViewCell
        cell.backgroundColor = UIColor(netHex: 0xF8f7F3)
        return indexPath
        
    }
    
    @IBAction func priceChangePushed(sender: UIButton) {
        sliderView.hidden = false
        carrotView.hidden = true
        
        self.tag = sender.tag
        
        priceSlider.maximumValue = Float(2.0 * items.price[tag])
        priceSlider.minimumValue = 0.0
        priceSlider.value = Float(items.price[tag])
        
        let price = items.price[tag]
        currentPrice.text = "$\(Utilities.getCurrencyValue(price))"
        maxPrice.text = "$\(Utilities.getCurrencyValue(price * 2))"
        
    }
    
    @IBAction func changeValue(sender: UISlider) {
            let currencyValue = "$\(Utilities.getCurrencyValue(Double(sender.value)))"
            currentPrice.text = currencyValue
            //items.price[tag] = Double(currencyValue)!
            //let indexPath = NSIndexPath(forRow: tag, inSection: 1)
            //let cell = tableView.cellForRowAtIndexPath(indexPath) as! topThreeTableViewCell
            //cell.priceLabel.text = "$\(currentValue)"
    }

    @IBAction func seeProfilePushed(sender: UIButton) {
        if let indexPath = tableView.indexPathForSelectedRow {
            index = indexPath.row
            performSegueWithIdentifier("makeGoal", sender: self)
        }
    }
    
    
    // MARK: - Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "makeGoal") {
            let destVC = segue.destinationViewController as! GoalViewController
            destVC.carrotName = items.itemName[index]
            destVC.carrotPrice = items.price[index]
        }
    }
    
}

struct Item {
    var itemName: [String] = []
    var price: [Double] = []
}
