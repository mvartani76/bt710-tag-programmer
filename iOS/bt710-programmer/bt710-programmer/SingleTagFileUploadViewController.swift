//
//  SingleTagFileUploadViewController.swift
//  bt710-programmer
//
//  Created by Michael Vartanian on 12/28/20.
//

import UIKit
import CoreBluetooth
import Firebase
import McuManager

class SingleTagFileUploadViewController: UIViewController, CBCentralManagerDelegate, CBPeripheralDelegate, UITableViewDelegate,  UITableViewDataSource, FileUploadDelegate {
    
    // cell reuse id (cells that scroll out of view can be reused)
    let cellReuseIdentifier = "FileCell"

    var fileLists : [String] = ["Param 1", "Param 2", "Param 3", "Param 4"]
    var storage : Storage?
    var storageReference : StorageReference?
    var actualFile : StorageReference?

    var transporter: McuMgrTransport! {
        didSet {
            fsManager = FileSystemManager(transporter: transporter)
            fsManager.logDelegate = UIApplication.shared.delegate as? McuMgrLogDelegate
        }
    }

    var fsManager: FileSystemManager!
    var fileData: Data?

    var myPeripheral:CBPeripheral? = nil
    var peripherals:[CBPeripheral] = []
    var manager:CBCentralManager? = nil
    var parentView:SingleTagViewController? = nil

    @IBOutlet var fileListTableView: UITableView!
    @IBOutlet var chooseButton: UIButton!
    @IBOutlet var cancelButton: UIButton!

    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        print("updatestate")
    }

    func uploadProgressDidChange(bytesSent: Int, fileSize: Int, timestamp: Date) {
        print("Upload progress changed...")
    }

    func uploadDidFail(with error: Error) {
        print("Upload Failed")
    }

    func uploadDidCancel() {
        print("Upload Cancelled")
    }

    func uploadDidFinish() {
        print("Upload finished")
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fileLists.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.fileListTableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier, for: indexPath)

        let fileList = fileLists[indexPath.row]
        cell.textLabel?.text = fileList
        cell.textLabel?.textAlignment = .center
        
        // Create destination URL
        //let documentsUrl:URL =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first! as URL
        //let destinationFileUrl = documentsUrl.appendingPathComponent("params.txt")
        actualFile = storageReference?.child(fileList)
        return cell
    }
    
    @IBAction func chooseButtonPressed(_ sender: UIButton) {
        actualFile?.getData(maxSize: 10 * 1024) { data, error in
            if let error = error {
                print("error = \(error)")
            } else {
                _ = self.fsManager.upload(name: "/lfs/params.txt", data: data!, delegate: self)
            }
        }
    }

    @IBAction func cancelButtonPressed(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
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
        var cloudFullPathLists : [Any] = []
        storage = Storage.storage()
        storageReference = storage?.reference().child("parameter-files")
        storageReference?.listAll { [self] (result,error) in
            if let error = error {
                print(error)
            }
            for prefix in result.prefixes {
                print("prefix = \(prefix)")
            }
            for item in result.items {
                print("item = \(item.name)")
                cloudFileLists.append(item.name)
                cloudFullPathLists.append(item.fullPath)
            }
            fileLists = cloudFileLists
            self.fileListTableView.reloadData()
        }

        let bleTransporter = McuMgrBleTransport(self.myPeripheral!)
        bleTransporter.logDelegate = UIApplication.shared.delegate as? McuMgrLogDelegate
        transporter = bleTransporter
    }
}
