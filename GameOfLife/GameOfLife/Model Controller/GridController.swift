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
            self.initialGrid = grid.similarGrid()
            self.updateBuffer()
        } else {
            self.grid = Grid(width: 25, height: 25)
            self.buffer = self.grid.similarGrid()
            self.initialGrid = self.grid.similarGrid()
        }
    }
    
    init(width: Int, height: Int) {
        self.grid = Grid(width: width, height: height)
        self.buffer = self.grid.similarGrid()
        self.initialGrid = self.grid.similarGrid()
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
        
        if !self.buffer.isSameSize(as: self.grid) {
            self.buffer = self.grid.similarGrid()
        }
        
        let dispatchGroup = DispatchGroup()
        let groupSize = 500 // number of 'buffer' cells that will be updated in each group
        let cellCount = self.cellCount
        var index = 0
        
        while index < cellCount {
            dispatchGroup.enter()
            let startIndex = index
            DispatchQueue.global(qos: .userInteractive).async(group: dispatchGroup) {
                let endIndex = min(startIndex + groupSize, cellCount)
                
                for i in startIndex..<endIndex {
                    self.buffer.cells[i].state = self.grid.cells[i].nextState
                }
                
                dispatchGroup.leave()
            }
            
            index += groupSize
        }
        
        dispatchGroup.notify(queue: .main) {
            self.finishedCalculatingNextGeneration()
        }
    }
    
    func finishedCalculatingNextGeneration() {
        guard buffer.isSameSize(as: grid) else { updateBuffer(); return }
        isCalculatingNextGeneration = false
        delegate?.didFinishLoadingNextGeneration()
    }
    
    func setRandomInitialState() {
        grid.cells.forEach { $0.state = randomState() }
        updateBuffer()
    }
    
    func setInitialState(_ initialState: InitialState) {
        self.initialState = initialState
        generationCount = 0
        
        guard let stateInfo = initialState.info else { setRandomInitialState(); return }
        
        grid.cells.forEach { $0.state = .dead }
        
        let dx = (width - stateInfo.width) / 2
        let dy = (height - stateInfo.height) / 2
        
        let centeredCoordinates = stateInfo.aliveCellsCoordinates
            .map { Coordinate(x: $0.x + dx, y: $0.y + dy) }
        
        for coordinate in centeredCoordinates {
            guard grid.indexIsValidAt(x: coordinate.x, y: coordinate.y) else { continue }
            grid[coordinate.x, coordinate.y].state = .alive
        }
        
        updateBuffer()
    }
        
    func clearGrid() {
        grid.cells.forEach { $0.state = .dead }
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
        updateGridSize(width: newSize, height: newSize)
    }
    
    func updateGridSize(width newWidth: Int, height newHeight: Int) {
        var newGrid = Grid(width: newWidth, height: newHeight)
        let dx = (newWidth - width) / 2
        let dy = (newHeight - height) / 2
        
        // Copy cell states from existing grid to newGrid
        for newY in 0..<newHeight {
            for newX in 0..<newWidth {
                
                // translate the x and y location of the cell in the existing grid to align the centers of both grids
                let x = newX - dx, y = newY - dy
                
                // If the newGrid cell location falls outside of the existing grid's bounds (because the newGrid is larger)
                // then expandedGridNewCellState will return .dead, or a random state if the initialState property = .random
                let cellState = grid.indexIsValidAt(x: x, y: y) ? grid[x, y].state : expandedGridNewCellState()
                newGrid[newX, newY].state = cellState
            }
        }
        
        // If the newGrid is larger than the existing grid, and a preset initial state contains coordinates that do not
        // fit inside the existing grid's bounds, but do fit inside the new grid's bounds, then update the cells at those locations
        if newWidth > width, let stateInfo = initialState?.info,
            width < stateInfo.width || height < stateInfo.height {
            
            // Coordinate offsets to center the initial state inside the current grid
            let dx0 = (width - stateInfo.width) / 2
            let dy0 = (height - stateInfo.height) / 2
            
            // Coordinate offsets to center the initial state inside the newGrid
            let dx1 = dx0 + dx
            let dy1 = dy0 + dy
            
            let coordinatesToUpdate = stateInfo.aliveCellsCoordinates
                .filter { !grid.indexIsValidAt(x: $0.x + dx0, y: $0.y + dy0) &&
                        newGrid.indexIsValidAt(x: $0.x + dx1, y: $0.y + dy1) }
            
            coordinatesToUpdate.forEach { newGrid[$0.x + dx1, $0.y + dy1].state = .alive }
        }
        
        swap(&grid, &newGrid)
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
