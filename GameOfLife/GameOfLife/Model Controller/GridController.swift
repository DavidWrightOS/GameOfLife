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
    
    // MARK: - Public Properties
    
    var grid: Grid
    var generationCount = 0
    var isCalculatingNextGeneration = false
    weak var delegate: GridControllerDelegate?
    
    var gridHasOnlyDeadCells: Bool {
        // Start checking from the middle of the grid first because it is more likely to contain live cells
        let middleIndex = cellCount / 2
        for offset in 0..<middleIndex - 1 {
            guard grid.cells[middleIndex - offset].state == .dead else { return false }
            guard grid.cells[middleIndex + offset].state == .dead else { return false }
        }
        guard grid.cells.first?.state == .dead, grid.cells.last?.state == .dead else { return false }
        return true
    }
    
    // MARK: - Private Properties
    
    private var buffer: Grid
    private var shouldUpdateBuffer = false
    private var initialState: InitialState?
    private var initialGrid: Grid
    private var width: Int { grid.width }
    private var height: Int { grid.height }
    private var cellCount: Int { width * height }
    
    // MARK: - Initializers
    
    init(width: Int, height: Int) {
        self.grid = Grid(width: width, height: height)
        self.buffer = Grid(width: width, height: height)
        self.initialGrid = Grid(width: width, height: height)
    }
    
    // MARK: - Public Methods
    
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
        guard !isCalculatingNextGeneration else {
            shouldUpdateBuffer = true
            return
        }
        
        isCalculatingNextGeneration = true
        shouldUpdateBuffer = false
        
        if !self.buffer.isSameSize(as: self.grid) {
            self.buffer = self.grid.newGridWithSameSize()
        }
        
        let dispatchGroup = DispatchGroup()
        let groupSize = 500 // number of cells that will be updated in each dispatchGroup
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
    
    func toggleStateForCellAt(x: Int, y: Int) {
        grid[x, y].state = grid[x, y].state == .dead ? .alive : .dead
    }
    
    func setStateForCellAt(x: Int, y: Int, state: State) {
        grid[x, y].state = state
    }
    
    // MARK: - Private Methods
    
    private func finishedCalculatingNextGeneration() {
        isCalculatingNextGeneration = false
        guard buffer.isSameSize(as: grid), !shouldUpdateBuffer else { updateBuffer(); return }
        delegate?.didFinishLoadingNextGeneration()
    }
    
    private func setRandomInitialState() {
        grid.cells.forEach { $0.state = randomState() }
        updateBuffer()
    }
    
    private func randomState() -> State {
        Int.random(in: 0...5) == 0 ? .alive : .dead
    }
    
    private func expandedGridNewCellState() -> State {
        initialState == .random ? randomState() : .dead
    }
    
    private func updateGridSize(width newWidth: Int, height newHeight: Int) {
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
}
