//
//  ViewController.swift
//  OpenPassTestApp
//
//  Created by Brad Leege on 10/10/22.
//

import OpenPass
import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var detailLabel: UILabel!
    private let openPassManager = OpenPassManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        detailLabel.text = openPassManager.text
    }

}
