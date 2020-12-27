//
//  BatchProgramViewController.swift
//  bt710-programmer
//
//  Created by Michael Vartanian on 12/23/20.
//

import UIKit
import CoreBluetooth
import Firebase

class BatchProgramViewController: UIViewController, UITableViewDelegate,  UITableViewDataSource {
    
    @IBOutlet var programListTableView: UITableView!

    var ref: DatabaseReference!

    let cellReuseIdentifier = "ProgramListCell"
    
    var programLists : [String] = ["Kiewet Settings", "MacArthur Settings", "V2Soft Settings", "Default Settings"]
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return programLists.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.programListTableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier, for: indexPath)

        let programList = programLists[indexPath.row]
        cell.textLabel?.text = programList
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
        self.programListTableView.register(UITableViewCell.self, forCellReuseIdentifier: cellReuseIdentifier)

        programListTableView.delegate = self
        programListTableView.dataSource = self
    }

    override func viewWillAppear(_ animated: Bool) {
        // Grab the company information to register tags
        ref = Database.database().reference()

        ref.child("BatchProgram").observeSingleEvent(of: .value, with: { (snapshot) in
            // Get user value
            let value = snapshot.value as? NSDictionary
            let cloudProgramLists = value?.allKeys as! [String]

            // Assuming if the code got to this section, cloudCustomerLists exists and has some members
            self.programLists = cloudProgramLists
            self.programListTableView.reloadData()

            // ...
        }) { (error) in
            print(error.localizedDescription)
        }
    }
}
