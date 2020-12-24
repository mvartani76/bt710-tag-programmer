//
//  BatchProgramViewController.swift
//  bt710-programmer
//
//  Created by Michael Vartanian on 12/23/20.
//

import UIKit
import CoreBluetooth

class BatchProgramViewController: UIViewController, UITableViewDelegate,  UITableViewDataSource {
    
    @IBOutlet var programListTableView: UITableView!
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        // Register the table view cell class and its reuse id
        self.programListTableView.register(UITableViewCell.self, forCellReuseIdentifier: cellReuseIdentifier)

        programListTableView.delegate = self
        programListTableView.dataSource = self
    }
}
