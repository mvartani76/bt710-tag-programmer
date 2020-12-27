//
//  SingleTagViewController.swift
//  bt710-programmer
//
//  Created by Michael Vartanian on 12/23/20.
//

import UIKit
import CoreBluetooth

class SingleTagViewController: UIViewController {
    var device : UInt = 0
    @IBOutlet var singleTagTitle: UILabel!
    @IBOutlet var downloadButton: UIButton!
    @IBOutlet var uploadButton: UIButton!
    @IBOutlet var registerButton: UIButton!

    @IBAction func downloadParams(_ sender: UIButton) {
    }

    @IBAction func uploadParams(_ sender: UIButton) {
    }

    @IBAction func registerDevice(_ sender: UIButton) {
    }

    override func viewWillAppear(_ animated: Bool) {
        singleTagTitle.text = String(format: "Tag %llX Details", device)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
}
