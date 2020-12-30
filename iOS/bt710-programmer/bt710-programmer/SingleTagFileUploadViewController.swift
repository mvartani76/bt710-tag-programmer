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
    let fileDestinationStr: String = "/lfs/params.txt"

    var myPeripheral:CBPeripheral? = nil
    var peripherals:[CBPeripheral] = []
    var manager:CBCentralManager? = nil
    var parentView:SingleTagViewController? = nil

    @IBOutlet var fileListTableView: UITableView!

    @IBOutlet var actionCancelButton: UIButton!

    @IBOutlet var closeButton: UIButton!

    @IBOutlet var actionStartButton: UIButton!
    @IBOutlet var actionPauseButton: UIButton!
    @IBOutlet var actionResumeButton: UIButton!

    @IBOutlet var fileSizeLabel: UILabel!
    @IBOutlet var fileSize: UILabel!
    @IBOutlet var fileDestinationLabel: UILabel!
    @IBOutlet var fileDestination: UILabel!
    @IBOutlet var fileStatus: UILabel!
    @IBOutlet var fileStatusLabel: UILabel!
    @IBOutlet var fileProgress: UIProgressView!

    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        print("updatestate")
    }

    func uploadProgressDidChange(bytesSent: Int, fileSize: Int, timestamp: Date) {
        fileProgress.setProgress(Float(bytesSent) / Float(fileSize), animated: true)
    }

    func uploadDidFail(with error: Error) {
        fileProgress.setProgress(0, animated: true)
        actionPauseButton.isHidden = true
        actionResumeButton.isHidden = true
        actionCancelButton.isHidden = true
        actionStartButton.isHidden = false
        //actionSelect.isEnabled = true
        fileStatus.textColor = .systemRed
        fileStatus.text = "\(error.localizedDescription)"
    }

    func uploadDidCancel() {
        fileProgress.setProgress(0, animated: true)
        actionPauseButton.isHidden = true
        actionResumeButton.isHidden = true
        actionCancelButton.isHidden = true
        actionStartButton.isHidden = false
        //actionSelect.isEnabled = true
        fileStatus.text = "CANCELLED"
    }

    func uploadDidFinish() {
        fileProgress.setProgress(0, animated: false)
        actionPauseButton.isHidden = true
        actionResumeButton.isHidden = true
        actionCancelButton.isHidden = true
        actionStartButton.isHidden = false
        actionStartButton.isEnabled = false
        //actionSelect.isEnabled = true
        fileStatus.text = "UPLOAD COMPLETE"
        fileData = nil
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fileLists.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.fileListTableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier, for: indexPath)

        let fileList = fileLists[indexPath.row]
        cell.textLabel?.text = fileList
        cell.textLabel?.textAlignment = .center

        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let fileList = fileLists[indexPath.row]

        actualFile = storageReference?.child(fileList)
        actualFile?.getData(maxSize: 10 * 1024) { [self] data, error in
            if let error = error {
                print("error = \(error)")
            } else {
                self.fileData = data
                fileDestination.text = fileDestinationStr
                fileSize.text = "\(data!.count) bytes"
                fileStatus.text = "READY"
                self.fileSize.isHidden = false
                self.fileSizeLabel.isHidden = false
                self.fileStatus.isHidden = false
                self.fileStatusLabel.isHidden = false
                self.fileDestination.isHidden = false
                self.fileDestinationLabel.isHidden = false
                actionStartButton.isHidden = false
            }
        }
    }

    @IBAction func closeButtonPressed(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }

    @IBAction func actionStartButtonPressed(_ sender: UIButton) {

        actionStartButton.isHidden = true
        actionPauseButton.isHidden = false
        actionCancelButton.isHidden = false
        //actionSelect.isEnabled = false

        fileStatus.text = "UPLOADING..."
        _ = self.fsManager.upload(name: fileDestinationStr, data: fileData!, delegate: self)
        self.fileProgress.isHidden = false
    }

    @IBAction func actionPauseButtonPressed(_ sender: UIButton) {
        fileStatus.text = "PAUSED"
        actionPauseButton.isHidden = true
        actionResumeButton.isHidden = false
        self.fsManager.pauseTransfer()
    }

    @IBAction func actionResumeButtonPressed(_ sender: UIButton) {
        fileStatus.text = "UPLOADING..."
        actionPauseButton.isHidden = false
        actionResumeButton.isHidden = true
        self.fsManager.continueTransfer()
    }

    @IBAction func actionCancelButtonPressed(_ sender: UIButton) {
        self.fsManager.cancelTransfer()
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

        fileProgress.setProgress(0, animated: true)

        self.fileSize.isHidden = true
        self.fileSizeLabel.isHidden = true
        self.fileStatus.isHidden = true
        self.fileStatusLabel.isHidden = true
        self.fileDestination.isHidden = true
        self.fileDestinationLabel.isHidden = true

        self.actionStartButton.isHidden = true
        self.actionPauseButton.isHidden = true
        self.actionResumeButton.isHidden = true
        self.actionCancelButton.isHidden = true
        self.fileProgress.isHidden = true

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
