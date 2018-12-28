//
//  InfoViewController.swift
//  Calc
//
//  Created by Dzmitry Herasiuk on 26.12.2018.
//  Copyright © 2018 Dzmitry Herasiuk. All rights reserved.
//

import UIKit

class InfoViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBOutlet weak var infoLabel: UILabel! {
        didSet {
            infoLabel.text = minYtext
        }
    }
    
    var minYtext: String = "" {
        didSet {
            infoLabel?.text = minYtext
        }
    }

    override var preferredContentSize: CGSize {
        get {
            if presentingViewController != nil && infoLabel != nil {
                return infoLabel.sizeThatFits(presentingViewController!.view.bounds.size)
            }
            return super.preferredContentSize
        }
        set { super.preferredContentSize = newValue }
    }

    override func viewWillAppear(_ animated: Bool) {
        super .viewWillAppear(animated)
        
//        self.infoLabel.sizeToFit()
//        self.preferredContentSize = infoLabel.bounds.size
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super .viewDidAppear(animated)
    }
}
