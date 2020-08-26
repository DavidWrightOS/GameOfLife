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

struct Cell {
    var state: State
    
    init(state: State = .dead) {
        self.state = state
    }
}
