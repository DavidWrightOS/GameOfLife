//
//  Grid.swift
//  GameOfLife
//
//  Created by David Wright on 8/19/20.
//  Copyright © 2020 David Wright. All rights reserved.
//

import Foundation

class Grid {
    
    // MARK: - Properties
    
    var cells = [Cell]()
    let width: Int
    let height: Int
    
    // MARK: - Initializer
    
    public init(width: Int = 25, height: Int = 25) {
        self.width = width
        self.height = height
        
        var newCells = [Cell]()
        newCells.reserveCapacity(width * height)
        
        for _ in 0..<(width * height) {
            newCells.append(Cell())
        }
        
        for index in 0..<(width * height) {
            var neighborIndices = [Int]()
            let indexAbove = index - width
            let indexBelow = index + width
            
            if (index + 1) % width == 0 {
                // right column
                switch index {
                case width - 1:
                    // top right corner
                    neighborIndices = [index - 1, indexBelow - 1, indexBelow]
                case (width * height) - 1:
                    // bottom right corner
                    neighborIndices = [indexAbove - 1, indexAbove, index - 1]
                default:
                    // right column, non-corner
                    neighborIndices = [indexAbove - 1, indexAbove, index - 1, indexBelow - 1, indexBelow]
                }
            } else if index % width == 0 {
                // left column
                switch index {
                case 0:
                    // top left corner
                    neighborIndices = [index + 1, indexBelow, indexBelow + 1]
                case width * (height - 1):
                    // bottom left corner
                    neighborIndices = [indexAbove, indexAbove + 1, index + 1]
                default:
                    // left column, non-corner
                    neighborIndices = [indexAbove, indexAbove + 1, index + 1, indexBelow, indexBelow + 1]
                }
            } else if index < width {
                // top row, non-corner
                neighborIndices = [index - 1, index + 1, indexBelow - 1, indexBelow, indexBelow + 1]
            } else if index >= (width * height) - width {
                // bottom row, non-corner
                neighborIndices = [indexAbove - 1, indexAbove, indexAbove + 1, index - 1, index + 1]
            } else {
                neighborIndices = [indexAbove - 1, indexAbove, indexAbove + 1,
                                   index - 1, index + 1,
                                   indexBelow - 1, indexBelow, indexBelow + 1]
            }
            
            var neighbors = [Cell]()
            
            for i in neighborIndices {
                neighbors.append(newCells[i])
            }
            
            newCells[index].neighbors = neighbors
        }
        self.cells = newCells
    }
    
    // MARK: - Methods
    
    func indexIsValidAt(_ index: Int) -> Bool {
        index >= 0 && index < width * height
    }
    
    func indexIsValidAt(x: Int, y: Int) -> Bool {
        x >= 0 && x < width && y >= 0 && y < height
    }
    
    // Uncomment the following code to enable subscript access, Ex: grid[1][3]
    subscript(row: Int, column: Int) -> Cell {
        get {
            assert(indexIsValidAt(x: column, y: row), "Index out of range")
            return cells[(row * column) + column]
        }
        set {
            assert(indexIsValidAt(x: column, y: row), "Index out of range")
            cells[(row * column) + column] = newValue
        }
    }
    
    func copy() -> Grid {
        let copiedGrid = Grid(width: width, height: height)
        for index in cells.indices {
            copiedGrid.cells[index].state = cells[index].state
        }
        return copiedGrid
    }
    
    /// Returns a new grid with the same width and height, but all cells are in the 'dead' state
    /// This is faster than the copy() method. Use similarGrid() when initializing a new grid with the same
    /// width and height as the receiver, and you do not need to copy all of the cell states to the new grid.
    func similarGrid() -> Grid {
        Grid(width: width, height: height)
    }
    
    func copyCellStates(from grid: Grid) {
        guard width == grid.width, height == grid.height else { return }
        
        for i in cells.indices {
            cells[i].state = grid.cells[i].state
        }
    }
}

extension Grid: CustomStringConvertible {
    var description: String {
        var description: String = ""
        for x in 0..<height {
            description += cells[x*width..<(x*width + width)].compactMap { $0.state == .alive ? " ◼︎ " : " . " }.joined() + "\n"
        }
        return description + "\n"
    }
}

extension Grid: Equatable {
    static func == (lhs: Grid, rhs: Grid) -> Bool {
        guard lhs.width == rhs.width, lhs.height == rhs.height else { return false }
        
        for i in lhs.cells.indices {
            guard lhs.cells[i].state == rhs.cells[i].state else { return false }
        }
        
        return true
    }
}
