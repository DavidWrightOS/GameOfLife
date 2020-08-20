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
    
    var gridController = GridController()
    
    var isRunning = false
    
    var timer: Timer?
    
    // MARK: - IBOutlets
    
    @IBOutlet var gridView: GridView!
    @IBOutlet var generationCountLabel: UILabel!
    @IBOutlet var playPauseButton: UIButton!
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        gridView = GridView(viewWidth: view.frame.width)
    }
    
    func updateViews() {
        gridView.grid = gridController.grid
        generationCountLabel.text = "Generation: \(gridController.generationCount)"
        gridController.loadNextGeneration()
    }
    
    // MARK: - Timer
    var t = 0
    func startTimer() {
        timer?.invalidate()
        
        timer = Timer.scheduledTimer(withTimeInterval: 0.10, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            print(self.t); self.t += 1
            self.updateViews()
        }
    }
    
    func cancelTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    // MARK: - IBActions
    
    // Game Controls
    
    @IBAction func playPauseButtonTapped(_ sender: UIButton) {
        isRunning.toggle()
        playPauseButton.isSelected = isRunning
        updateViews()
        if isRunning {
            startTimer()
        } else {
            cancelTimer()
        }
    }
    
    @IBAction func advance1StepButtonTapped(_ sender: UIButton) {
        updateViews()
    }
    
    @IBAction func stopButtonTapped(_ sender: UIButton) {
        guard isRunning else { return }
        cancelTimer()
        playPauseButton.isSelected = false
        gridController = GridController(width: gridController.grid.width,
                                        height: gridController.grid.height)
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
