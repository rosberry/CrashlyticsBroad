//
//  ViewController.swift
//  CrashlyticsBroadExample
//
//  Created by Nick Tyunin on 22/08/2019.
//  Copyright © 2019 Rosberry. All rights reserved.
//

import UIKit
import ButterBroad

class ViewController: UIViewController {

    @IBOutlet weak var textField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func logEvengtDidTapped(_ sender: Any) {
        if let text = textField.text, text.isEmpty == false {
            Butter.common.logEvent(with: text)
            textField.text = ""
        }
    }
}
