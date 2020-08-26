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

    var gridController = GridController(width: 25, height: 25)
    var gameSpeed = 10.0
    var gridSize = 25
    var isRunning = false
    var timer: Timer?
    
    // MARK: - IBOutlets
    
    @IBOutlet var gridView: GridView!
    @IBOutlet var generationCountLabel: UILabel!
    @IBOutlet var playPauseButton: UIButton!
    @IBOutlet var speedLabel: UILabel!
    @IBOutlet var gridSizeLabel: UILabel!
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        gridController.setInitialState(.random)
        updateGameSpeed()
        updateGridSize()
        gridView.grid = gridController.grid
    }
    
    // MARK: - Methods
    
    func updateViews() {
        gridView.grid = gridController.grid
        generationCountLabel.text = "Generation: \(gridController.generationCount)"
    }
    
    func updateGameSpeed() {
        speedLabel.text = "\(Int(gameSpeed))"
        guard isRunning else { return }
        cancelTimer()
        startTimer()
    }
    
    func updateGridSize() {
        gridSizeLabel.text = "\(gridSize) x \(gridSize)"
        gridController.updateGridSize(to: gridSize)
        updateViews()
    }
    
    func advanceOneGeneration() {
        gridController.loadNextGeneration()
        updateViews()
    }
    
    // Touch Gestures
    
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
        
        timer = Timer.scheduledTimer(withTimeInterval: 1.0 / gameSpeed, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            self.advanceOneGeneration()
        }
    }
    
    func cancelTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    func stopTimer() {
        cancelTimer()
        isRunning = false
        playPauseButton.isSelected = false
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
        if isRunning {
            advanceOneGeneration()
            startTimer()
        } else {
            cancelTimer()
        }
    }
    
    @IBAction func advance1StepButtonTapped(_ sender: UIButton) {
        advanceOneGeneration()
    }
    
    @IBAction func stopButtonTapped(_ sender: UIButton) {
        stopTimer()
        gridController.resetGrid()
        updateViews()
    }
    
    // Steppers
    
    @IBAction func gridSizeStepperValueChanged(_ sender: UIStepper) {
        gridSize = Int(sender.value)
        updateGridSize()
    }
    
    @IBAction func gameSpeedStepperValueChanged(_ sender: UIStepper) {
        gameSpeed = sender.value
        updateGameSpeed()
    }
    
    // Preset Buttons
    
    @IBAction func presetButtonTapped(_ sender: UIButton) {
        stopTimer()
        gridController.setInitialState(stateIndex: sender.tag)
        updateViews()
    }
}

extension GameViewController: InfoViewControllerDelegate {
    func didDismissInfoViewController() {
        if isRunning {
            startTimer()
        }
    }
}
