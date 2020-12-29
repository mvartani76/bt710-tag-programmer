//
//  SingleTagFileUploadViewController.swift
//  bt710-programmer
//
//  Created by Michael Vartanian on 12/28/20.
//

import UIKit
import CoreBluetooth
import Firebase

class SingleTagFileUploadViewController: UIViewController, UITableViewDelegate,  UITableViewDataSource {
    
    // cell reuse id (cells that scroll out of view can be reused)
    let cellReuseIdentifier = "FileCell"

    var fileLists : [String] = ["Param 1", "Param 2", "Param 3", "Param 4"]
    
    @IBOutlet var fileListTableView: UITableView!

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fileLists.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.fileListTableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier, for: indexPath)

        let fileList = fileLists[indexPath.row]
        cell.textLabel?.text = fileList
        cell.textLabel?.textAlignment = .center
        
        // Create destination URL
        let documentsUrl:URL =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first! as URL
           let destinationFileUrl = documentsUrl.appendingPathComponent("params.txt")

        return cell
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Register the table view cell class and its reuse id
        self.fileListTableView.register(UITableViewCell.self, forCellReuseIdentifier: cellReuseIdentifier)

        fileListTableView.delegate = self
        fileListTableView.dataSource = self
    }
    override func viewWillAppear(_ animated: Bool) {
        var cloudFileLists : [String] = []
        let storage = Storage.storage()
        let storageReference = storage.reference().child("parameter-files")
        storageReference.listAll { [self] (result,error) in
            if let error = error {
                print(error)
            }
            for prefix in result.prefixes {
                print("prefix = \(prefix)")
            }
            for item in result.items {
                print("item = \(item.name)")
                cloudFileLists.append(item.name)
                print(cloudFileLists)
            }
            print("cfl = \(cloudFileLists)")
            fileLists = cloudFileLists
            self.fileListTableView.reloadData()
        }
    }
    
}
