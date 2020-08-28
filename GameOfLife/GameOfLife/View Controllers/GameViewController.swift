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
    var gridSize = 45
    var isRunning = false
    var timer: Timer?
    let presetStates: [InitialState] = [.random, .acorn, .pulsar, .gliderGun]
    
    var gameIsInInitialState = true {
        didSet {
            gridSizeStepper.isEnabled = gameIsInInitialState
            gridSizeLabel.textColor = gameIsInInitialState ? .label : .systemGray
        }
    }
    
    var tempGenCounter = 0 {
        didSet {
            if tempGenCounter >= Int(gameSpeed) * 5 {
                tempGenCounter = 0
                print(String(format: "Drawing: %.4f seconds", gridView.averageSecondsToDraw))
                print(String(format: "Loading: %.4f seconds\n", gridController.averageSecondsToCalculateNextGeneration))
            }
        }
    }
    
    // MARK: - IBOutlets
    
    @IBOutlet var gridView: GridView!
    @IBOutlet var generationCountLabel: UILabel!
    @IBOutlet var playPauseButton: UIButton!
    @IBOutlet var speedLabel: UILabel!
    @IBOutlet var gridSizeLabel: UILabel!
    @IBOutlet var presetButtons: [UIButton]!
    @IBOutlet var gameSpeedStepper: UIStepper!
    @IBOutlet var gridSizeStepper: UIStepper!
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        gridController.setInitialState(.random)
        updatePresetButtonTitles()
        gameSpeedStepper.value = gameSpeed
        updateGameSpeed()
        gridSizeStepper.value = Double(gridSize)
        updateGridSize()
        gridController.setInitialState(.random)
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
    
    func updatePresetButtonTitles() {
        for button in presetButtons {
            let presetDisplayName = presetStates[button.tag].info?.displayName ?? "Random"
            button.setTitle(presetDisplayName, for: .normal)
        }
    }
    
    func advanceOneGeneration() {
        if !gridController.isCalculatingNextGeneration {
            // Main thread: swap the grid and buffer properties
            // Background thread: calculate next generation and store in buffer
            gridController.loadNextGeneration()
            
            // Main thread: update the screen with the current grid
            updateViews()
            
            tempGenCounter += 1
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.03) {
                if !self.gameIsInInitialState {
                    self.advanceOneGeneration()
                }
            }
        }
    }
    
    // Touch Gestures
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard gameIsInInitialState else { return }
        guard let point = touches.first?.location(in: gridView),
            gridView.bounds.contains(point) else { return }
        
        let x = Int(point.x / gridView.cellSize)
        let y = Int(point.y / gridView.cellSize)
        
        gridController.grid.toggleStateForCellAt(x: x, y: y)
        gridView.grid?.toggleStateForCellAt(x: x, y: y)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard gameIsInInitialState else { return }
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
            gameIsInInitialState = false
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
        gameIsInInitialState = true
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
        gridController.setInitialState(presetStates[sender.tag])
        updateViews()
    }
}


// MARK: - InfoViewControllerDelegate

extension GameViewController: InfoViewControllerDelegate {
    func didDismissInfoViewController() {
        if isRunning {
            startTimer()
        }
    }
}
