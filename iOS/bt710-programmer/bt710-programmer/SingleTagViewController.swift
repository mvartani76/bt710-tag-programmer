//
//  SingleTagViewController.swift
//  bt710-programmer
//
//  Created by Michael Vartanian on 12/23/20.
//

import UIKit
import CoreBluetooth
import McuManager

class SingleTagViewController: UIViewController, CBCentralManagerDelegate, CBPeripheralDelegate, McuMgrViewController, FileUploadDelegate {
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
    
    
    var device : UInt = 0
    var myPeripheral:CBPeripheral? = nil
    var peripherals:[CBPeripheral] = []
    var manager:CBCentralManager? = nil
    var parentView:ViewController? = nil
    
    @IBOutlet var singleTagTitle: UILabel!
    @IBOutlet var downloadButton: UIButton!
    @IBOutlet var uploadButton: UIButton!
    @IBOutlet var registerButton: UIButton!
    
    var transporter: McuMgrTransport! {
        didSet {
            fsManager = FileSystemManager(transporter: transporter)
            fsManager.logDelegate = UIApplication.shared.delegate as? McuMgrLogDelegate
        }
    }
        
    var fsManager: FileSystemManager!
    var fileData: Data?

    @IBAction func downloadParams(_ sender: UIButton) {
    }

    @IBAction func uploadParams(_ sender: UIButton) {
        print("entered uploadParams")
        if let path = Bundle.main.path(forResource: "params", ofType: "txt")
            {
                print("entered first if let")
                let fm = FileManager()
                let exists = fm.fileExists(atPath: path)
                if(exists){
                    print("enetered exists")
                    let content = fm.contents(atPath: path)
                    let contentAsString = String(data: content!, encoding: String.Encoding.utf8)
                    print(contentAsString)
                }
            }
        
        if let data = NSDataAsset(name: "params")?.data {
            let mytext = String(data: data, encoding: .utf8)
            print(mytext)
        
        _ = fsManager.upload(name: "/lfs/params.txt", data: data, delegate: self)
        }
    }

    @IBAction func registerDevice(_ sender: UIButton) {
    }

    override func viewWillAppear(_ animated: Bool) {
        singleTagTitle.text = String(format: "Tag %llX Details", device)
        print(myPeripheral)
        // Initialize the BLE transporter using a scanned peripheral
        let bleTransporter = McuMgrBleTransport(self.myPeripheral!)
        bleTransporter.logDelegate = UIApplication.shared.delegate as? McuMgrLogDelegate
        transporter = bleTransporter
    }
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
}
