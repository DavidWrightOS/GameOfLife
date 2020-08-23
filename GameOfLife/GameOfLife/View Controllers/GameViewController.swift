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
        gridView.grid = gridController.grid
    }
    
    // MARK: - Methods
    
    func updateViews() {
        gridView.grid = gridController.grid
        generationCountLabel.text = "Generation: \(gridController.generationCount)"
    }
    
    func advanceOneGeneration() {
        gridController.loadNextGeneration()
        updateViews()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard gridController.generationCount == 0 else { return }
        guard let point = touches.first?.location(in: gridView),
            gridView.bounds.contains(point) else { return }
        
        let x = Int(point.x / gridView.cellSize)
        let y = Int(point.y / gridView.cellSize)

        
        gridController.grid.toggleStateForCellAt(x: x, y: y)
        gridView.grid?.toggleStateForCellAt(x: x, y: y)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard gridController.generationCount == 0 else { return }
        guard let point = touches.first?.location(in: gridView),
            gridView.bounds.contains(point) else { return }
        
        let x = Int(point.x / gridView.cellSize)
        let y = Int(point.y / gridView.cellSize)
        
        gridController.grid.setStateForCellAt(x: x, y: y, state: .alive)
        gridView.grid?.setStateForCellAt(x: x, y: y, state: .alive)
    }
    
    // MARK: - Timer
    
    func startTimer() {
        timer?.invalidate()
        
        timer = Timer.scheduledTimer(withTimeInterval: 0.10, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            self.advanceOneGeneration()
        }
    }
    
    func cancelTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    // MARK: - IBActions
    
    @IBAction func infoButtonTapped(_ sender: UIButton) {
        cancelTimer()
        let infoVC = UIStoryboard(name: "Main", bundle: nil)
            .instantiateViewController(withIdentifier: "InfoViewController") as! InfoViewController
        infoVC.delegate = self
        present(infoVC, animated: true, completion: nil)
    }
    
    // Game Controls
    
    @IBAction func playPauseButtonTapped(_ sender: UIButton) {
        isRunning.toggle()
        playPauseButton.isSelected = isRunning
        advanceOneGeneration()
        if isRunning {
            startTimer()
        } else {
            cancelTimer()
        }
    }
    
    @IBAction func advance1StepButtonTapped(_ sender: UIButton) {
        advanceOneGeneration()
    }
    
    @IBAction func stopButtonTapped(_ sender: UIButton) {
        cancelTimer()
        isRunning = false
        playPauseButton.isSelected = false
        gridController = GridController(width: gridController.grid.width,
                                        height: gridController.grid.height)
        updateViews()
    }
    
    func resetGrid() {
        cancelTimer()
        isRunning = false
        playPauseButton.isSelected = false
        gridController = GridController(width: gridController.grid.width,
                                        height: gridController.grid.height)
        updateViews()
    }
    
    // Initial State Presets
    
    @IBAction func preset1ButtonTapped(_ sender: UIButton) {
        cancelTimer()
        isRunning = false
        playPauseButton.isSelected = false
        gridController.setRandomInitialState()
        updateViews()
    }
    
    @IBAction func preset2ButtonTapped(_ sender: UIButton) {
        
    }
    
    @IBAction func preset3ButtonTapped(_ sender: UIButton) {
        
    }
    
    @IBAction func preset4ButtonTapped(_ sender: UIButton) {
        
    }
}

extension GameViewController: InfoViewControllerDelegate {
    func didDismissInfoViewController() {
        if isRunning {
            startTimer()
        }
    }
}
