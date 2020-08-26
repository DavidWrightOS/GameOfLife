//
//  Grid.swift
//  GameOfLife
//
//  Created by David Wright on 8/19/20.
//  Copyright © 2020 David Wright. All rights reserved.
//

import Foundation

struct Grid {
    
    // MARK: - Properties
    
    var cells = [Cell]()
    let width: Int
    let height: Int
    
    // MARK: - Initializer
    
    public init(width: Int = 25, height: Int = 25, cells: [Cell]? = nil) {
        self.width = width
        self.height = height
        self.cells = cells ?? Array(repeating: Cell(), count: width * height)
    }
    
    // MARK: - Methods
    
    func cellAt(x: Int, y: Int) -> Cell? {
        guard x >= 0, x < width,
            y >= 0, y < height else { return nil }
        
        return cells[y * width + x]
    }
    
    func coordinateForCell(at index: Int) -> Coordinate {
        let x = index % width
        let y = (index - x) / width
        return Coordinate(x: x, y: y)
    }
    
    @discardableResult
    mutating func toggleStateForCellAt(x: Int, y: Int) -> Bool {
        guard x >= 0, x < width,
        y >= 0, y < height else { return false }
        let index = y * width + x
        if cells[index].state == .alive {
            cells[index].state = .dead
        } else {
            cells[index].state = .alive
        }
        return true
    }
    
    @discardableResult
    mutating func setStateForCellAt(x: Int, y: Int, state: State) -> Bool {
        guard x >= 0, x < width,
        y >= 0, y < height else { return false }
        let index = y * width + x
        cells[index].state = state
        return true
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
