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
            updateNextGenerationGridBuffer()
        }
    }
    
    var nextGenerationGridBuffer: Grid!
    var generationCount = 0
    var width: Int { grid.width }
    var height: Int { grid.height }
    var cellCount: Int { width * height }
    
    // MARK: - Initializers
    
    init(grid: Grid? = nil) {
        if let grid = grid {
            self.grid = grid
        } else {
            self.grid = Grid(width: 25, height: 25)
        }
        
        updateNextGenerationGridBuffer()
    }
    
    init(width: Int, height: Int) {
        self.grid = Grid(width: width, height: height)
        updateNextGenerationGridBuffer()
    }
    
    // MARK: - Methods
    
    func loadNextGeneration() {
        grid = nextGenerationGridBuffer
        generationCount += 1
    }
    
    func neighborsForCell(at index: Int) -> [Cell] {
        let cellCoordinate = grid.coordinateForCell(at: index)
        var neighbors = [Cell]()
        
        for dy in -1...1 {
            for dx in -1...1 {
                guard !(dx == 0 && dy == 0) else { continue }
                guard let neighbor = grid.cellAt(x: cellCoordinate.x + dx, y: cellCoordinate.y + dy) else { continue }
                neighbors.append(neighbor)
            }
        }
        
        return neighbors
    }
    
    func numberOfAliveNeighborsForCell(at index: Int) -> Int {
        neighborsForCell(at: index).filter { $0.state == .alive }.count
    }
    
    func updateNextGenerationGridBuffer() {
        let currentGenerationCells = grid.cells
        var nextGenerationCells = currentGenerationCells
        
        for (index, currentCell) in currentGenerationCells.enumerated() {
            switch self.numberOfAliveNeighborsForCell(at: index) {
            case 2...3 where currentCell.state == .alive:
                // Rule 2: Any live cell with two or three live neighbors will live on to the next generation.
                break
            case 3 where currentCell.state == .dead:
                // Rule 4: Any dead cell with exactly three live neighbors will become a live cell.
                nextGenerationCells[index].state = .alive
            default:
                // Rules 1 & 3: Any live cell with fewer than two or more than three live neighbors will die.
                nextGenerationCells[index].state = .dead
            }
        }
        
        self.nextGenerationGridBuffer = Grid(width: width, height: height, cells: nextGenerationCells)
    }
    
    func setRandomInitialState() {
        var randomCells = [Cell]()
        randomCells.reserveCapacity(cellCount)
        
        for _ in 0..<cellCount {
            let randomState: State = Int.random(in: 0...5) == 0 ? .alive : .dead
            randomCells.append(Cell(state: randomState))
        }
        grid.cells = randomCells
        generationCount = 0
    }
    
    func setInitialState(_ initialState: InitialState) {
        guard let stateInfo = initialState.info else {
            setRandomInitialState()
            return
        }
        
        var newGrid = Grid(width: width, height: height)
        let dx = (width - stateInfo.width) / 2
        let dy = (height - stateInfo.height) / 2
        
        let centeredCoordinates = stateInfo.aliveCellsCoordinates
            .map { Coordinate(x: $0.x + dx, y: $0.y + dy) }
        
        for coordinate in centeredCoordinates {
            newGrid.setStateForCellAt(x: coordinate.x, y: coordinate.y, state: .alive)
        }
        
        grid = newGrid
        generationCount = 0
    }
    
    func resetGrid() {
        grid = Grid(width: width, height: height)
        generationCount = 0
    }
    
    func updateGridSize(to newSize: Int) {
        let currentGrid = grid
        let dx = (newSize - currentGrid.width) / 2
        let dy = (newSize - currentGrid.height) / 2
        
        var newCells = [Cell]()
        newCells.reserveCapacity(newSize * newSize)
        
        for y in 0..<newSize {
            for x in 0..<newSize {
                let cellState = currentGrid.cellAt(x: x - dx, y: y - dy)?.state ?? .dead
                newCells.append(Cell(state: cellState))
            }
        }
        
        grid = Grid(width: newSize, height: newSize, cells: newCells)
    }
}
