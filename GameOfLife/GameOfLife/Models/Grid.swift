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
    
    public init(width: Int, height: Int, cells: [Cell]? = nil) {
        self.width = width
        self.height = height
        
        if let cells = cells {
            self.cells = cells
        } else {
            for x in 0..<width {
                for y in 0..<height {
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
}
