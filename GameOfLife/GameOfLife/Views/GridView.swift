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
        
        for cell in grid.cells where cell.state == .alive {
            let rect = CGRect(x: CGFloat(cell.x) * cellSize, y: CGFloat(cell.y) * cellSize, width: cellSize, height: cellSize)
            context?.addRect(rect)
            context?.setFillColor(UIColor.black.cgColor)
            context?.fill(rect)
        }
        
        context?.restoreGState()
    }
}
