//
//  InfoViewController.swift
//  GameOfLife
//
//  Created by David Wright on 8/19/20.
//  Copyright © 2020 David Wright. All rights reserved.
//

import UIKit

protocol InfoViewControllerDelegate: class {
    func didDismissInfoViewController()
}

class InfoViewController: UIViewController, UIAdaptivePresentationControllerDelegate {
    
    weak var delegate: InfoViewControllerDelegate?
    
    @IBAction func doneButtonTapped(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true) {
            self.delegate?.didDismissInfoViewController()
        }
    }
}
