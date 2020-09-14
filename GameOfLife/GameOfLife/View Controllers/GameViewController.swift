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

    private var gridController = GridController(width: 0, height: 0)
    private var shouldLoadNextGeneration = false
    private var isUpdatingGridView = false
    private var timer: Timer?
    private let presetStates: [InitialState] = [.random, .acorn, .pulsar, .gliderGun]
    private let defaults = UserDefaults.standard
    
    private var gameSpeed = 20.0 {
        didSet { defaults.set(gameSpeed, forKey: UserDefaultsKey.gameSpeed) }
    }
    
    private var gridSize = 45 {
        didSet { defaults.set(gridSize, forKey: UserDefaultsKey.gridSize) }
    }
    
    private var isRunning = false {
        didSet { advance1StepButton.isEnabled = !isRunning }
    }
    
    private var gameIsInInitialState = true {
        didSet {
            hideSizeStepperView.isHidden = gameIsInInitialState
            stopButton.isEnabled = !gameIsInInitialState
            stopButton.tintColor = stopButton.isEnabled ? .enabledButtonColor : .disabledButtonColor
            clearGridButton.isHidden = gameIsInInitialState ? !gridIsEmpty : true
        }
    }
    
    private var gridIsEmpty = false {
        didSet {
            clearGridButton.isHidden = gridIsEmpty
            advance1StepButton.isEnabled = !gridIsEmpty
            playPauseButton.isEnabled = !gridIsEmpty
            playPauseButton.tintColor = playPauseButton.isEnabled ? .enabledButtonColor : .disabledButtonColor
        }
    }
    
    private lazy var infoViewController: InfoViewController = {
        let infoVC = UIStoryboard(name: "Main", bundle: nil)
            .instantiateViewController(withIdentifier: "InfoViewController") as! InfoViewController
        infoVC.delegate = self
        return infoVC
    }()
    
    // MARK: - IBOutlets
    
    @IBOutlet private var gridView: GridView!
    @IBOutlet private var generationCountLabel: UILabel!
    @IBOutlet private var playPauseButton: UIButton!
    @IBOutlet private var advance1StepButton: UIButton!
    @IBOutlet private var stopButton: UIButton!
    @IBOutlet private var speedLabel: UILabel!
    @IBOutlet private var gridSizeHeaderLabel: UILabel!
    @IBOutlet private var gridSizeLabel: UILabel!
    @IBOutlet private var presetButtons: [UIButton]!
    @IBOutlet private var gameSpeedStepper: UIStepper!
    @IBOutlet private var gridSizeStepper: UIStepper!
    @IBOutlet private var clearGridButton: UIButton!
    @IBOutlet private var hideSizeStepperView: UIView!
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        gridController.delegate = self
        
        loadUserSettings()
        setupGame()
    }
    
    // MARK: - Methods
    
    private func loadUserSettings() {
        let gameSpeedSetting = defaults.double(forKey: UserDefaultsKey.gameSpeed)
        gameSpeed = (gameSpeedSetting != 0.0) ? gameSpeedSetting : gameSpeed
        
        let gridSizeSetting = defaults.integer(forKey: UserDefaultsKey.gridSize)
        gridSize = (gridSizeSetting != 0) ? gridSizeSetting : gridSize
    }
    
    private func setupGame() {
        
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
    
    private func updateViews() {
        isUpdatingGridView = true
        gridView.grid = gridController.grid
        isUpdatingGridView = false
        if shouldLoadNextGeneration {
            advanceOneGeneration()
        }
        generationCountLabel.text = "Generation: \(gridController.generationCount)"
    }
    
    private func updateGameSpeed() {
        speedLabel.text = "\(Int(gameSpeed))"
        guard isRunning else { return }
        cancelTimer()
        startTimer()
    }
    
    private func updateGridSize() {
        gridSizeLabel.text = "\(gridSize) x \(gridSize)"
        gridController.updateGridSize(to: gridSize)
        updateViews()
    }
    
    private func updatePresetButtonTitles() {
        for button in presetButtons {
            let presetDisplayName = presetStates[button.tag].info?.displayName ?? "Random"
            button.setTitle(presetDisplayName, for: .normal)
        }
    }
    
    private func advanceOneGeneration() {
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
    
    // MARK: - Touch Gestures
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard gameIsInInitialState else { return }
        guard let point = touches.first?.location(in: gridView),
            gridView.bounds.contains(point) else { return }

        let x = Int(point.x / gridView.cellSize)
        let y = Int(point.y / gridView.cellSize)
        
        gridController.toggleStateForCellAt(x: x, y: y)
        gridView.setNeedsDisplay()
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard gameIsInInitialState else { return }
        guard let point = touches.first?.location(in: gridView),
            gridView.bounds.contains(point) else { return }
        
        let x = Int(point.x / gridView.cellSize)
        let y = Int(point.y / gridView.cellSize)
        
        gridController.setStateForCellAt(x: x, y: y, state: .alive)
        gridView.setNeedsDisplay()
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard gameIsInInitialState else { return }
        gridIsEmpty = gridController.gridHasOnlyDeadCells
        gridController.updateBuffer()
    }
    
    // MARK: - Timer
    
    private func startTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0 / gameSpeed, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            self.advanceOneGeneration()
        }
    }
    
    private func cancelTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    private func stopTimer() {
        cancelTimer()
        isRunning = false
        playPauseButton.isSelected = false
    }
    
    // MARK: - IBActions
    
    @IBAction private func infoButtonTapped(_ sender: UIButton) {
        cancelTimer()
        present(infoViewController, animated: true, completion: nil)
    }
    
    // Game Controls
    
    @IBAction private func playPauseButtonTapped(_ sender: UIButton) {
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
    
    @IBAction private func advance1StepButtonTapped(_ sender: UIButton) {
        gameIsInInitialState = false
        advanceOneGeneration()
    }
    
    @IBAction private func stopButtonTapped(_ sender: UIButton) {
        stopTimer()
        gridController.resetInitialGrid()
        gameIsInInitialState = true
        gridIsEmpty = gridController.gridHasOnlyDeadCells
        updateViews()
    }
    
    @IBAction private func clearGridButtonTapped(_ sender: UIButton) {
        gridController.clearGrid()
        gridIsEmpty = true
        updateViews()
    }
    
    // Steppers
    
    @IBAction private func gridSizeStepperValueChanged(_ sender: UIStepper) {
        let oldGridSize = gridSize
        gridSize = Int(sender.value)
        updateGridSize()
        if gridSize < oldGridSize {
            gridIsEmpty = gridController.gridHasOnlyDeadCells
        }
    }
    
    @IBAction private func gameSpeedStepperValueChanged(_ sender: UIStepper) {
        gameSpeed = sender.value
        updateGameSpeed()
    }
    
    // Preset Buttons
    
    @IBAction private func presetButtonTapped(_ sender: UIButton) {
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
        if shouldLoadNextGeneration && !gameIsInInitialState {
            advanceOneGeneration()
        }
    }
}
