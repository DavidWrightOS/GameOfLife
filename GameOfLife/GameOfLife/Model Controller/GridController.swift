//
//  GridController.swift
//  GameOfLife
//
//  Created by David Wright on 8/19/20.
//  Copyright © 2020 David Wright. All rights reserved.
//

import Foundation

class GridController {
    
    // MARK: - Properties
    
    var grid: Grid {
        didSet {
            updateNextGenerationGridBuffer { nextGenCells in
                self.nextGenerationGridBuffer = Grid(width: self.grid.width,
                                                     height: self.grid.height,
                                                     cells: nextGenCells)
            }
        }
    }
    
    var nextGenerationGridBuffer: Grid? {
        didSet {
            guard shouldUpdateGrid else { return }
            shouldUpdateGrid = false
            updateGrid()
        }
    }
    
    var generationCount = 0
    var shouldUpdateGrid = false
        
    // MARK: - Initializers
    
    init(grid: Grid? = nil) {
        if let grid = grid {
            self.grid = grid
        } else {
            self.grid = Grid(width: 25, height: 25)
        }
    }
    
    init(width: Int, height: Int) {
        self.grid = Grid(width: width, height: height)
    }
    
    // MARK: - Methods
    
    func loadNextGeneration() {
        updateGrid()
    }
    
    func updateGrid() {
        guard let nextGenerationGrid = nextGenerationGridBuffer else {
            shouldUpdateGrid = true
            return
        }
        
        grid = nextGenerationGrid
        generationCount += 1
        
        updateNextGenerationGridBuffer { nextGenCells in
            self.nextGenerationGridBuffer = Grid(width: self.grid.width,
                                                 height: self.grid.height,
                                                 cells: nextGenCells)
        }
    }
    
    func neighbors(for cell: Cell) -> [Cell] {
        var neighbors = [Cell?]()
        
        for dy in -1...1 {
            for dx in -1...1 {
                guard !(dx == 0 && dy == 0) else { continue }
                let neighbor = grid.cellAt(x: cell.x + dx, y: cell.y + dy)
                neighbors.append(neighbor)
            }
        }
        
        return neighbors.compactMap { $0 }
    }
    
    func numberOfAliveNeighbors(for cell: Cell) -> Int {
        neighbors(for: cell).filter { $0.state == .alive }.count
    }
    
    // Rules for determining the next generation:
    // 1. Any live cell with fewer than two live neighbors will die.
    // 2. Any live cell with two or three live neighbors will live on to the next generation.
    // 3. Any live cell with more than three live neighbors will die.
    // 4. Any dead cell with exactly three live neighbors will become a live cell.
    
    func updateNextGenerationGridBuffer(completion: @escaping ([Cell]) -> Void) {
        let currentGenerationCells = grid.cells
        var nextGenerationCells = currentGenerationCells
        nextGenerationGridBuffer = nil
        
        DispatchQueue.global(qos: .background).async {
            for (index, currentCell) in currentGenerationCells.enumerated() {
                switch self.numberOfAliveNeighbors(for: currentCell) {
                    
                // Rule 2
                case 2...3 where currentCell.state == .alive:
                    break
                    
                // Rule 4
                case 3 where currentCell.state == .dead:
                    nextGenerationCells[index].state = .alive
                    
                // Rules 1 & 3
                default:
                    nextGenerationCells[index].state = .dead
                }
            }
            DispatchQueue.main.async {
                completion(nextGenerationCells)
    
    func setRandomInitialState() {
        var randomCells = [Cell]()
        for y in 0..<grid.width {
            for x in 0..<grid.height {
                let randomState = Int.random(in: 0...5)
                let cell = Cell(x: x, y: y, state: randomState == 0 ? .alive : .dead)
                randomCells.append(cell)
            }
        }
        grid.cells = randomCells
        generationCount = 0
    }
}
