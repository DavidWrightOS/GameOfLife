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
        
        if let cells = cells {
            self.cells = cells
        } else {
            for y in 0..<width {
                for x in 0..<height {
                    let randomState = Int.random(in: 0...5)
                    let cell = Cell(x: x, y: y, state: randomState == 0 ? .alive : .dead)
                    self.cells.append(cell)
                }
            }
        }
    }
    
    // MARK: - Methods
    
    func cellAt(x: Int, y: Int) -> Cell? {
        guard x >= 0, x < width,
            y >= 0, y < height else { return nil }
        
        return cells[y * width + x]
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
