//
//  Cell.swift
//  GameOfLife
//
//  Created by David Wright on 8/19/20.
//  Copyright © 2020 David Wright. All rights reserved.
//

import Foundation

enum State {
    case alive
    case dead
}

class Cell {
    var state: State
    var neighbors: [Cell]!
    
    var aliveNeighborCount: Int {
        neighbors.filter { $0.state == .alive }.count
    }
    
    var nextState: State {
        switch aliveNeighborCount {
        case 3: return .alive
        case 2 where state == .alive: return .alive
        default: return .dead
        }
    }
    
    init(state: State = .dead, neighbors: [Cell]? = nil) {
        self.state = state
        self.neighbors = neighbors
    }
}
