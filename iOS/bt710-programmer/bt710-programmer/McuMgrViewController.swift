//
//  McuMgrViewController.swift
//  bt710-programmer
//
//  Created by Michael Vartanian on 12/27/20.
//

/*
 * Copyright (c) 2018 Nordic Semiconductor ASA.
 *
 * SPDX-License-Identifier: Apache-2.0
 */

import UIKit
import McuManager

protocol McuMgrViewController {

    var transporter: McuMgrTransport! { get set }
}

