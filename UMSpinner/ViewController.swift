//
//  ViewController.swift
//  UMSpinner
//
//  Created by Uros Mihailovic on 10/28/15.
//  Copyright © 2015 UMI. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var iOSSpinner: UIActivityIndicatorView!
    @IBOutlet weak var spinner: UMSpinner!
    @IBOutlet weak var spinnerII: UMSpinner!
    @IBOutlet weak var spinnerIII: UMSpinner!
    override func viewDidLoad() {
        super.viewDidLoad()
        spinner.configureSpinner(withStyle: .NativePetals)
        
        let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(2 * Double(NSEC_PER_SEC)))
        dispatch_after(delayTime, dispatch_get_main_queue()) {
            self.spinner.startSpinning()
        }

        spinnerII.configureSpinner(withStyle: .FadingBeads)
        spinnerII.startSpinning()
        spinnerIII.configureSpinner(withStyle: .FadingHexagons)
        spinnerIII.startSpinning()
    }
}

