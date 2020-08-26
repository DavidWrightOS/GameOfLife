//
//  PresetGridState.swift
//  GameOfLife
//
//  Created by David Wright on 8/25/20.
//  Copyright © 2020 David Wright. All rights reserved.
//

import Foundation

struct Coordinate: Equatable {
    let x: Int
    let y: Int
}

enum InitialState: Int {
    case random, pulsar, pentadecathlon, exploder
    
    var info: PresetGridState? {
        switch self {
        case .pulsar: return PresetGridState.pulsar
        case .pentadecathlon: return PresetGridState.pentadecathlon
        case .exploder: return .exploder
        default: return nil
        }
    }
}

struct PresetGridState {
    let width: Int
    let height: Int
    let aliveCellsCoordinates: [Coordinate]
    
    static let pulsar =
        PresetGridState(width: 15,
                        height: 15,
                        aliveCellsCoordinates: [
                            (3, 1), (4, 1), (5, 1), (9, 1), (10, 1), (11, 1),
                            (1, 3), (6, 3), (8, 3), (13, 3),
                            (1, 4), (6, 4), (8, 4), (13, 4),
                            (1, 5), (6, 5), (8, 5), (13, 5),
                            (3, 6), (4, 6), (5, 6), (9, 6), (10, 6), (11, 6),
                            (3, 8), (4, 8), (5, 8), (9, 8), (10, 8), (11, 8),
                            (1, 9), (6, 9), (8, 9), (13, 9),
                            (1, 10), (6, 10), (8, 10), (13, 10),
                            (1, 11), (6, 11), (8, 11), (13, 11),
                            (3, 13), (4, 13), (5, 13), (9, 13), (10, 13), (11, 13),
                            ].map { Coordinate(x: $0.0, y: $0.1) })
    
    static let pentadecathlon =
        PresetGridState(width: 16,
                        height: 9,
                        aliveCellsCoordinates: [
                            (5, 3), (10, 3),
                            (3, 4), (4, 4), (6, 4), (7, 4), (8, 4), (9, 4), (11, 4), (12, 4),
                            (5, 5), (10, 5),
                            ].map { Coordinate(x: $0.0, y: $0.1) })
    
    static let exploder =
        PresetGridState(width: 15,
                        height: 15,
                        aliveCellsCoordinates: [
                            (7, 6),
                            (6, 7), (7, 7), (8, 7),
                            (6, 8), (8, 8),
                            (7, 9),
                            ].map { Coordinate(x: $0.0, y: $0.1) })
}
