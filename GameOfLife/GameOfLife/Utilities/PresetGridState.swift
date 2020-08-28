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
    case random, acorn, pulsar, gliderGun, pentadecathlon, exploder
    
    static subscript(n: Int) -> InitialState {
        InitialState(rawValue: n)!
    }
    
    var info: PresetGridState? {
        switch self {
        case .acorn: return .acorn
        case .pulsar: return .pulsar
        case .gliderGun: return .gliderGun
        case .pentadecathlon: return .pentadecathlon
        case .exploder: return .exploder
        default: return nil
        }
    }
}

struct PresetGridState {
    let displayName: String
    let width: Int
    let height: Int
    let aliveCellsCoordinates: [Coordinate]
    
    static let acorn =
        PresetGridState(displayName: "Acorn",
                        width: 7,
                        height: 3,
                        aliveCellsCoordinates: [
                            (0, 0), (1, 0), (4, 0), (5, 0), (6, 0),
                            (3, 1),
                            (1, 2),
                            ].map { Coordinate(x: $0.0, y: $0.1) })
    
    static let pulsar =
        PresetGridState(displayName: "Pulsar",
                        width: 15,
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
    
    static let gliderGun =
        PresetGridState(displayName: "Glider Gun",
                        width: 36,
                        height: 9,
                        aliveCellsCoordinates: [
                            (24, 0),
                            (22, 1), (24, 1),
                            (12, 2), (13, 2), (20, 2), (21, 2), (34, 2), (35, 2),
                            (11, 3), (15, 3), (20, 3), (21, 3), (34, 3), (35, 3),
                            (0, 4), (1, 4), (10, 4), (16, 4), (20, 4), (21, 4),
                            (0, 5), (1, 5), (10, 5), (14, 5), (16, 5), (17, 5), (22, 5), (24, 5),
                            (10, 6), (16, 6), (24, 6),
                            (11, 7), (15, 7),
                            (12, 8), (13, 8),
                            ].map { Coordinate(x: $0.0, y: $0.1) })
    
    static let pentadecathlon =
        PresetGridState(displayName: "Penta-D",
                        width: 16,
                        height: 9,
                        aliveCellsCoordinates: [
                            (5, 3), (10, 3),
                            (3, 4), (4, 4), (6, 4), (7, 4), (8, 4), (9, 4), (11, 4), (12, 4),
                            (5, 5), (10, 5),
                            ].map { Coordinate(x: $0.0, y: $0.1) })
    
    static let exploder =
        PresetGridState(displayName: "Exploder",
                        width: 15,
                        height: 15,
                        aliveCellsCoordinates: [
                            (7, 6),
                            (6, 7), (7, 7), (8, 7),
                            (6, 8), (8, 8),
                            (7, 9),
                            ].map { Coordinate(x: $0.0, y: $0.1) })
}
