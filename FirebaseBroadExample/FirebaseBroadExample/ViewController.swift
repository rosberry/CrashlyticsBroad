//
//  ViewController.swift
//
//  Copyright © 2019 Rosberry. All rights reserved.
//

import UIKit
import ButterBroad

class ViewController: UIViewController {

    @IBOutlet weak var textField: UITextField!

    @IBAction func logButtonPressed(_ sender: Any) {
        if let text = textField.text, text.isEmpty == false {
            Butter.common.logEvent(with: text)
            textField.text = ""
        }
    }
}
