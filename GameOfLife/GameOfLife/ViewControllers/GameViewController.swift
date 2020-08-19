//
//  GameViewController.swift
//  GameOfLife
//
//  Created by David Wright on 8/19/20.
//  Copyright © 2020 David Wright. All rights reserved.
//

import UIKit

class GameViewController: UIViewController {
    
    // MARK: - Properties
    
    
    
    // MARK: - Initializers
    
    
    
    // MARK: - IBOutlets
    
    @IBOutlet var gridView: GridView!
    @IBOutlet var generationCountLabel: UILabel!
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    // MARK: - IBActions
    
    // Game Controls
    
    @IBAction func playPauseButtonTapped(_ sender: UIButton) {
        
    }
    
    @IBAction func advance1StepButtonTapped(_ sender: UIButton) {
        
    }
    
    @IBAction func stopButtonTapped(_ sender: UIButton) {
        
    }
    
    // Initial State Presets
    
    @IBAction func preset1ButtonTapped(_ sender: UIButton) {
        
    }
    
    @IBAction func preset2ButtonTapped(_ sender: UIButton) {
        
    }
    
    @IBAction func preset3ButtonTapped(_ sender: UIButton) {
        
    }
    
    @IBAction func preset4ButtonTapped(_ sender: UIButton) {
        
    }
}
