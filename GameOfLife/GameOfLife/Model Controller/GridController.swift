//
//  GridController.swift
//  GameOfLife
//
//  Created by David Wright on 8/19/20.
//  Copyright © 2020 David Wright. All rights reserved.
//

import Foundation

protocol GridControllerDelegate: class {
    func didFinishLoadingNextGeneration()
}

class GridController {
    
    // MARK: - Properties
    
    var grid: Grid
    var buffer: Grid
    var isCalculatingNextGeneration = false
    var generationCount = 0
    var width: Int { grid.width }
    var height: Int { grid.height }
    var cellCount: Int { width * height }
    var initialState: InitialState?
    var initialGrid: Grid
    var delegate: GridControllerDelegate?
    
    var gridHasOnlyDeadCells: Bool {
        // Start checking from the middle of the grid first because it is more likely to contain live cells
        let middleIndex = cellCount / 2
        for offset in 0..<middleIndex - 1 {
            guard grid.cells[middleIndex - offset].state == .dead else { return false }
            guard grid.cells[middleIndex + offset].state == .dead else { return false }
        }
        guard grid.cells.first?.state == .dead,
            grid.cells.last?.state == .dead else { return false }
        
        return true
    }
    
    // MARK: - Initializers
    
    init(grid: Grid? = nil) {
        if let grid = grid {
            self.grid = grid
            self.buffer = grid.similarGrid()
        } else {
            self.grid = Grid(width: 25, height: 25)
            self.buffer = self.grid.similarGrid()
        }
        self.initialGrid = self.grid.similarGrid()
        updateBuffer()
    }
    
    init(width: Int, height: Int) {
        self.grid = Grid(width: width, height: height)
        self.buffer = self.grid.similarGrid()
        self.initialGrid = self.grid.similarGrid()
        updateBuffer()
    }
    
    // MARK: - Methods
    
    func loadNextGeneration() {
        if generationCount == 0 {
            if initialGrid.isSameSize(as: grid) {
                initialGrid.copyCellStates(from: grid)
            } else {
                initialGrid = grid.copy()
            }
        }
        swap(&grid, &buffer)
        generationCount += 1
        updateBuffer()
    }
    
    func updateBuffer() {
        guard !isCalculatingNextGeneration else { return }
        
        isCalculatingNextGeneration = true
        
        DispatchQueue.global(qos: .userInteractive).async {
            if !self.buffer.isSameSize(as: self.grid) {
                self.buffer = self.grid.similarGrid()
            }
            
            for i in self.grid.cells.indices {
                self.buffer.cells[i].state = self.grid.cells[i].nextState
            }
            
            DispatchQueue.main.async {
                self.finishedCalculatingNextGeneration()
            }
        }
    }
    
    func finishedCalculatingNextGeneration() {
        guard buffer.isSameSize(as: grid) else {
            updateBuffer()
            return
        }
        
        isCalculatingNextGeneration = false
        delegate?.didFinishLoadingNextGeneration()
    }
    
    func setRandomInitialState() {
        for cell in grid.cells {
            cell.state = randomState()
        }
        updateBuffer()
    }
    
    func newGridWithCurrentInitialState(width: Int, height: Int) -> Grid? {
        guard let stateInfo = initialState?.info else { return nil }
        
        let newGrid = Grid(width: width, height: height)
        let dx = (width - stateInfo.width) / 2
        let dy = (height - stateInfo.height) / 2
        
        let centeredCoordinates = stateInfo.aliveCellsCoordinates
            .map { Coordinate(x: $0.x + dx, y: $0.y + dy) }
        
        for coordinate in centeredCoordinates {
            newGrid.setStateForCellAt(x: coordinate.x, y: coordinate.y, state: .alive)
        }
        
        return newGrid
    }
    
    func setInitialState(_ initialState: InitialState) {
        self.initialState = initialState
        generationCount = 0
        
        guard let newGrid = newGridWithCurrentInitialState(width: width, height: height) else {
            setRandomInitialState()
            return
        }

        grid = newGrid
    }
    
    func clearGrid() {
        for cell in grid.cells {
            cell.state = .dead
        }
        generationCount = 0
        initialState = nil
        updateBuffer()
    }
    
    func resetInitialGrid() {
        swap(&grid, &initialGrid)
        generationCount = 0
        updateBuffer()
    }
    
    func updateGridSize(to newSize: Int) {
        guard generationCount == 0 else { return }

        if let initialStateWidth = self.initialState?.info?.width,
            let initialStateHeight = self.initialState?.info?.height,
            width < initialStateWidth || height < initialStateHeight,
            let newGrid = newGridWithCurrentInitialState(width: newSize, height: newSize) {
            grid = newGrid
            updateBuffer()
            return
        }

        let dx = (newSize - width) / 2
        let dy = (newSize - height) / 2

        let newGrid = Grid(width: newSize, height: newSize)

        for y in 0..<newSize {
            for x in 0..<newSize {
                let index = indexAt(x: x - dx, y: y - dy)
                let cellState = grid.indexIsValidAt(index) ? grid.cells[index].state : expandedGridNewCellState()
                if cellState == .alive {
                    newGrid[y, x].state = .alive
                }
            }
        }
        
        grid = newGrid
        updateBuffer()
    }
    
    func indexAt(x: Int, y: Int) -> Int {
        y * width + x
    }
    
    func randomState() -> State {
        Int.random(in: 0...5) == 0 ? .alive : .dead
    }
    
    func expandedGridNewCellState() -> State {
        initialState == .random ? randomState() : .dead
    }
}
