//
//  ViewController.swift
//  OpenPassDevelopmentApp
//
//  Created by Brad Leege on 10/14/22.
//

import OpenPass
import UIKit

class ViewController: UIViewController {

    private let openPassManager = OpenPassManager()
    
    private let displayLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 28, weight: .bold)
        label.numberOfLines = 0
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        buildViewHierarchy()
    }
    
    private func buildViewHierarchy() {
        
        self.view.backgroundColor = .green

        displayLabel.text = openPassManager.text
        
        view.addSubview(displayLabel)
        
        NSLayoutConstraint.activate([
            displayLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            displayLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            displayLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])
                
    }

}
