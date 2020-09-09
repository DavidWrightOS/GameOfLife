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

    var gridController = GridController(width: 0, height: 0)
    var shouldLoadNextGeneration = false
    var isUpdatingGridView = false
    var timer: Timer?
    let presetStates: [InitialState] = [.random, .acorn, .pulsar, .gliderGun]
    let defaults = UserDefaults.standard
    
    var gameSpeed = 20.0 {
        didSet { defaults.set(gameSpeed, forKey: UserDefaultsKey.gameSpeed) }
    }
    
    var gridSize = 45 {
        didSet { defaults.set(gridSize, forKey: UserDefaultsKey.gridSize) }
    }
    
    var isRunning = false {
        didSet { advance1StepButton.isEnabled = !isRunning }
    }
    
    var gameIsInInitialState = true {
        didSet {
            hideSizeStepperView.isHidden = gameIsInInitialState
            stopButton.isEnabled = !gameIsInInitialState
            stopButton.tintColor = stopButton.isEnabled ? .enabledButtonColor : .disabledButtonColor
            clearGridButton.isHidden = gameIsInInitialState ? !gridIsEmpty : true
        }
    }
    
    var gridIsEmpty = false {
        didSet {
            clearGridButton.isHidden = gridIsEmpty
            advance1StepButton.isEnabled = !gridIsEmpty
            playPauseButton.isEnabled = !gridIsEmpty
            playPauseButton.tintColor = playPauseButton.isEnabled ? .enabledButtonColor : .disabledButtonColor
        }
    }
    
    // MARK: - IBOutlets
    
    @IBOutlet var gridView: GridView!
    @IBOutlet var generationCountLabel: UILabel!
    @IBOutlet var playPauseButton: UIButton!
    @IBOutlet var advance1StepButton: UIButton!
    @IBOutlet var stopButton: UIButton!
    @IBOutlet var speedLabel: UILabel!
    @IBOutlet var gridSizeHeaderLabel: UILabel!
    @IBOutlet var gridSizeLabel: UILabel!
    @IBOutlet var presetButtons: [UIButton]!
    @IBOutlet var gameSpeedStepper: UIStepper!
    @IBOutlet var gridSizeStepper: UIStepper!
    @IBOutlet var clearGridButton: UIButton!
    @IBOutlet var hideSizeStepperView: UIView!
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadUserSettings()
        setupGame()
    }
    
    // MARK: - Methods
    
    func loadUserSettings() {
        let gameSpeedSetting = defaults.double(forKey: UserDefaultsKey.gameSpeed)
        gameSpeed = (gameSpeedSetting != 0.0) ? gameSpeedSetting : gameSpeed
        
        let gridSizeSetting = defaults.integer(forKey: UserDefaultsKey.gridSize)
        gridSize = (gridSizeSetting != 0) ? gridSizeSetting : gridSize
    }
    
    func setupGame() {
        
        // Set initial game state
        gridController.setInitialState(.random)
        gridSizeStepper.minimumValue = 10
        gridSizeStepper.maximumValue = 150
        gridSizeStepper.stepValue = 10
        gridSizeStepper.value = Double(gridSize)
        updateGridSize()
        gameSpeedStepper.minimumValue = 5
        gameSpeedStepper.maximumValue = 100
        gameSpeedStepper.stepValue = 5
        gameSpeedStepper.value = gameSpeed
        updateGameSpeed()
        
        // Set initial UI state
        hideSizeStepperView.isHidden = true
        hideSizeStepperView.backgroundColor = UIColor.systemBackground
        advance1StepButton.setTitleColor(.disabledButtonColor, for: .disabled)
        stopButton.isEnabled = false
        stopButton.tintColor = .disabledButtonColor
        updatePresetButtonTitles()
    }
    
    func updateViews() {
        isUpdatingGridView = true
        gridView.grid = gridController.grid
        isUpdatingGridView = false
        if shouldLoadNextGeneration {
            advanceOneGeneration()
        }
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
        shouldLoadNextGeneration = gridController.isCalculatingNextGeneration
        guard !gridController.isCalculatingNextGeneration && !isUpdatingGridView else {
            shouldLoadNextGeneration = true
            return
        }
        
        // Main thread: swap the grid and buffer properties
        // Background thread: calculate next generation and store in buffer
        gridController.loadNextGeneration()
        
        // Main thread: update the screen with the current grid
        updateViews()
    }
    
    // Touch Gestures
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard gameIsInInitialState else { return }
        guard let point = touches.first?.location(in: gridView),
            gridView.bounds.contains(point) else { return }

        let x = Int(point.x / gridView.cellSize)
        let y = Int(point.y / gridView.cellSize)
        
        gridController.grid.toggleStateForCellAt(x: x, y: y)
        gridView.setNeedsDisplay()
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard gameIsInInitialState else { return }
        guard let point = touches.first?.location(in: gridView),
            gridView.bounds.contains(point) else { return }
        
        let x = Int(point.x / gridView.cellSize)
        let y = Int(point.y / gridView.cellSize)
        
        gridController.grid.setStateForCellAt(x: x, y: y, state: .alive)
        gridView.setNeedsDisplay()
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard gameIsInInitialState else { return }
        gridIsEmpty = gridController.gridHasOnlyDeadCells
        gridController.updateBuffer()
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
        gameIsInInitialState = false
        advanceOneGeneration()
    }
    
    @IBAction func stopButtonTapped(_ sender: UIButton) {
        stopTimer()
        gridController.resetInitialGrid()
        gameIsInInitialState = true
        gridIsEmpty = gridController.gridHasOnlyDeadCells
        updateViews()
    }
    
    @IBAction func clearGridButtonTapped(_ sender: UIButton) {
        gridController.clearGrid()
        gridIsEmpty = true
        updateViews()
    }
    
    // Steppers
    
    @IBAction func gridSizeStepperValueChanged(_ sender: UIStepper) {
        let oldGridSize = gridSize
        gridSize = Int(sender.value)
        updateGridSize()
        if gridSize < oldGridSize {
            gridIsEmpty = gridController.gridHasOnlyDeadCells
        }
    }
    
    @IBAction func gameSpeedStepperValueChanged(_ sender: UIStepper) {
        gameSpeed = sender.value
        updateGameSpeed()
    }
    
    // Preset Buttons
    
    @IBAction func presetButtonTapped(_ sender: UIButton) {
        stopTimer()
        gridController.setInitialState(presetStates[sender.tag])
        gameIsInInitialState = true
        gridIsEmpty = false
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

// MARK: - GridControllerDelegate

extension GameViewController: GridControllerDelegate {
    func didFinishLoadingNextGeneration() {
        if shouldLoadNextGeneration {
            advanceOneGeneration()
        }
    }
}
