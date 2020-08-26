//
//  GridView.swift
//  GameOfLife
//
//  Created by David Wright on 8/19/20.
//  Copyright © 2020 David Wright. All rights reserved.
//

import UIKit

class GridView: UIView {
    
    // MARK: - Properties
    
    var grid: Grid? {
        didSet {
            setNeedsDisplay()
        }
    }
    
    var cellSize: CGFloat {
        guard let grid = grid else { return 0 }
        return frame.width / CGFloat(grid.width)
    }
    
    // MARK: - Initializers
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    // MARK: - Drawing
    
    public override func draw(_ rect: CGRect) {
        guard let grid = grid else { return }
        let context = UIGraphicsGetCurrentContext()
        
        context?.saveGState()
        
        for (index, cell) in grid.cells.enumerated() where cell.state == .alive {
            let cellCoordinate = grid.coordinateForCell(at: index)
            
            let rect = CGRect(x: CGFloat(cellCoordinate.x) * cellSize,
                              y: CGFloat(cellCoordinate.y) * cellSize,
                              width: cellSize,
                              height: cellSize)
            
            context?.addRect(rect)
            context?.setFillColor(UIColor.black.cgColor)
            context?.fill(rect)
        }
        
        context?.restoreGState()
    }
}
