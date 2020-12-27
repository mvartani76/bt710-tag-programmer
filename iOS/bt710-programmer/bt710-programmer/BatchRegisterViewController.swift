//
//  BatchRegisterViewController.swift
//  bt710-programmer
//
//  Created by Michael Vartanian on 12/23/20.
//

import UIKit
import CoreBluetooth
import Firebase

class BatchRegisterViewController: UIViewController, UITableViewDelegate,  UITableViewDataSource {
    
    @IBOutlet var customerListTableView: UITableView!
    
    var ref: DatabaseReference!

    let cellReuseIdentifier = "RegisterListCell"
    
    // This will be configured via cloud
    var customerLists : [String] = ["Kiewet", "MacArthur", "Stepan", "V2Soft"]
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return customerLists.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.customerListTableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier, for: indexPath)

        let customerList = customerLists[indexPath.row]
        cell.textLabel?.text = customerList
        cell.textLabel?.textAlignment = .center

        return cell
    }
    
    @IBAction func chooseButtonPressed(_ sender: Any) {
    }
    
    @IBAction func cancelButtonPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.

        // Register the table view cell class and its reuse id
        self.customerListTableView.register(UITableViewCell.self, forCellReuseIdentifier: cellReuseIdentifier)

        customerListTableView.delegate = self
        customerListTableView.dataSource = self
    }

    override func viewWillAppear(_ animated: Bool) {
        // Grab the company information to register tags
        ref = Database.database().reference()

        ref.child("BatchRegister").observeSingleEvent(of: .value, with: { (snapshot) in
            // Get user value
            let value = snapshot.value as? NSDictionary
            let cloudCustomerLists = value?.allKeys as! [String]

            // Assuming if the code got to this section, cloudCustomerLists exists and has some members
            self.customerLists = cloudCustomerLists
            self.customerListTableView.reloadData()

            // ...
        }) { (error) in
            print(error.localizedDescription)
        }
    }
}
