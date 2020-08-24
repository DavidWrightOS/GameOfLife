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
        resetGrid()
        let xOffset = (gridController.grid.width - 15) / 2
        let yOffset = (gridController.grid.height - 15) / 2
        
        let pulsarCoordinates: [(x: Int, y: Int)] = [
            (3, 1), (4, 1), (5, 1), (9, 1), (10, 1), (11, 1),
            (1, 3), (6, 3), (8, 3), (13, 3),
            (1, 4), (6, 4), (8, 4), (13, 4),
            (1, 5), (6, 5), (8, 5), (13, 5),
            (3, 6), (4, 6), (5, 6), (9, 6), (10, 6), (11, 6),
            (3, 8), (4, 8), (5, 8), (9, 8), (10, 8), (11, 8),
            (1, 9), (6, 9), (8, 9), (13, 9),
            (1, 10), (6, 10), (8, 10), (13, 10),
            (1, 11), (6, 11), (8, 11), (13, 11),
            (3, 13), (4, 13), (5, 13), (9, 13), (10, 13), (11, 13),
        ]
        
        let centeredPulsarCoordinates = pulsarCoordinates.map { (x: $0.x + xOffset, y: $0.y + yOffset) }
                
        for coordinate in centeredPulsarCoordinates {
            gridController.grid.setStateForCellAt(x: coordinate.x,
                                                  y: coordinate.y,
                                                  state: .alive)
        }
        
        updateViews()
    }
    
    @IBAction func preset3ButtonTapped(_ sender: UIButton) {
        resetGrid()
        let xOffset = (gridController.grid.width - 16) / 2
        let yOffset = (gridController.grid.height - 9) / 2
        
        let pentadecathlonCoordinates: [(x: Int, y: Int)] = [
            (5, 3), (10, 3),
            (3, 4), (4, 4), (6, 4), (7, 4), (8, 4), (9, 4), (11, 4), (12, 4),
            (5, 5), (10, 5),
        ]
        
        let centeredPentadecathlonCoordinates = pentadecathlonCoordinates.map { (x: $0.x + xOffset, y: $0.y + yOffset) }
                
        for coordinate in centeredPentadecathlonCoordinates {
            gridController.grid.setStateForCellAt(x: coordinate.x,
                                                  y: coordinate.y,
                                                  state: .alive)
        }
        
        updateViews()
    }
    
    @IBAction func preset4ButtonTapped(_ sender: UIButton) {
        resetGrid()
        let xOffset = (gridController.grid.width - 15) / 2
        let yOffset = (gridController.grid.height - 15) / 2
        
        let exploderCoordinates: [(x: Int, y: Int)] = [
            (7, 6),
            (6, 7), (7, 7), (8, 7),
            (6, 8), (8, 8),
            (7, 9),
        ]
        
        let centeredExploderCoordinates = exploderCoordinates.map { (x: $0.x + xOffset, y: $0.y + yOffset) }
                
        for coordinate in centeredExploderCoordinates {
            gridController.grid.setStateForCellAt(x: coordinate.x,
                                                  y: coordinate.y,
                                                  state: .alive)
        }
        
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
