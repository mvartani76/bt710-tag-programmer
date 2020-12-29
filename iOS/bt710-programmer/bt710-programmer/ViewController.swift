//
//  ViewController.swift
//  bletest
//
//  Created by Michael Vartanian on 12/20/20.
//

import UIKit
import CoreBluetooth
import Firebase

class DeviceTableCell: UITableViewCell {
    @IBOutlet var deviceIDLabel: UILabel!
}

class deviceInfo {
    var deviceID: UInt?
    var devicePeripheral: CBPeripheral?

    init(deviceID: UInt, devicePeripheral: CBPeripheral) {
        self.deviceID = deviceID
        self.devicePeripheral = devicePeripheral
    }
}

class ViewController: UIViewController, CBCentralManagerDelegate, CBPeripheralDelegate, UITableViewDelegate,  UITableViewDataSource {

    static let shared = ViewController()

    // cell reuse id (cells that scroll out of view can be reused)
    let cellReuseIdentifier = "DeviceCell"
    
    @IBOutlet var scanButton: UIButton!
    @IBOutlet var deviceTableView: UITableView!
    
    var scanning = false
    //var devices : [UInt] = []
    var devices : [deviceInfo] = []
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return devices.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:DeviceTableCell = self.deviceTableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier, for: indexPath) as! DeviceTableCell

        let device = devices[indexPath.row]
        cell.textLabel?.text = String(format:"%llX", device.deviceID!)
        cell.textLabel?.textAlignment = .center

        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedDevice = devices[indexPath.row].deviceID
        let selectedDeviceStr = String(format: "%llX", selectedDevice!)
        print("device at row \(indexPath.row) is \(selectedDeviceStr)")
        scanButton.setTitle("Start Scanning", for: .normal)
        scanning = false
        centralManager.stopScan()
        self.myPeripheral = devices[indexPath.row].devicePeripheral
        /*
        if let viewController = storyboard?.instantiateViewController(identifier: "SingleTagViewController") as? SingleTagViewController {
                viewController.device = selectedDevice
                navigationController?.pushViewController(viewController, animated: true)
        }*/
        performSegue(withIdentifier: "ShowSingleDetail", sender: self)
    }
    
    var centralManager: CBCentralManager!
    var myPeripheral: CBPeripheral!
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == CBManagerState.poweredOn {
            print("BLE powered on")
        }
        else {
            print("Something wrong with BLE")
            // Not on, but can have different issues
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        if let manufacturerData = advertisementData[CBAdvertisementDataManufacturerDataKey] as? Data {
            let manufactureID = UInt16(manufacturerData[0]) + UInt16(manufacturerData[1]) << 8

            if manufactureID == 0x0077 {
                let deviceID1 =  UInt(manufacturerData[8]) + UInt(manufacturerData[9]) << 8
                let deviceID2 = UInt(manufacturerData[10]) << 0 + UInt(manufacturerData[11]) << 8
                let deviceID3 = UInt(manufacturerData[12]) << 0 + UInt(manufacturerData[13]) << 8
                let deviceID = UInt(deviceID1) + UInt(deviceID2) << 16 + UInt(deviceID3) << 32
                
                print(String(format: "%llX", deviceID ))

                //if (!results.contains(deviceID) && (deviceID != 0)) {
                if (!isInObject(devices: devices, deviceID: deviceID) && (deviceID != 0)) { devices.append(deviceInfo(deviceID: deviceID, devicePeripheral: peripheral))
                    self.deviceTableView.reloadData()
                }
            }
        }
    }
        
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        self.myPeripheral = peripheral
        peripheral.delegate = self
        myPeripheral.discoverServices(nil)
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        print("error discovering services?")
        print(error as Any)
    }
    
    @IBAction func scanForPeripherals(_ sender: UIButton) {
        if scanning == false {
            centralManager.scanForPeripherals(withServices: nil, options: nil)
            scanButton.setTitle("Stop Scanning", for: .normal)
            scanning = true
        } else {
            scanButton.setTitle("Start Scanning", for: .normal)
            scanning = false
            centralManager.stopScan()
        }
    }
    
    func isInObject(devices : [deviceInfo], deviceID : UInt) -> Bool {
        for i in 0..<devices.count {
            if devices[i].deviceID == deviceID {
                return true
            }
        }
        return false
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        if segue.identifier == "ShowSingleDetail",
           let destination = segue.destination as? SingleTagViewController,
           let selectedPath = deviceTableView.indexPathForSelectedRow?.row {
            destination.device = devices[selectedPath].deviceID!

            //set the manager's delegate to the scan view so it can call relevant connection methods
            centralManager?.delegate = destination as CBCentralManagerDelegate
            destination.manager = centralManager
            destination.myPeripheral = self.myPeripheral
            destination.parentView = self
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        centralManager = CBCentralManager(delegate: self, queue: nil)
        
        // Register the table view cell class and its reuse id
        self.deviceTableView.register(UITableViewCell.self, forCellReuseIdentifier: cellReuseIdentifier)
                
        // (optional) include this line if you want to remove the extra empty cell divider lines
        // self.tableView.tableFooterView = UIView()

        // This view controller itself will provide the delegate methods and row data for the table view.
        deviceTableView.delegate = self
        deviceTableView.dataSource = self
        deviceTableView.register(DeviceTableCell.self, forCellReuseIdentifier: "DeviceCell")
    }
}

