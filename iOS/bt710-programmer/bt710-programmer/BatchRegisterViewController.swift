//
//  BatchRegisterViewController.swift
//  bt710-programmer
//
//  Created by Michael Vartanian on 12/23/20.
//

import UIKit
import CoreBluetooth

class BatchRegisterViewController: UIViewController, UITableViewDelegate,  UITableViewDataSource {
    
    @IBOutlet var customerListTableView: UITableView!
    
    let cellReuseIdentifier = "RegisterListCell"
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        // Register the table view cell class and its reuse id
        self.customerListTableView.register(UITableViewCell.self, forCellReuseIdentifier: cellReuseIdentifier)

        customerListTableView.delegate = self
        customerListTableView.dataSource = self
    }
}
