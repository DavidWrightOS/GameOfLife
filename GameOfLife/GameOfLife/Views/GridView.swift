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
    
    var grid = Grid(width: 25, height: 25) {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    var cellSize: CGFloat {
        self.frame.width / CGFloat(grid.width)
    }
    
    // MARK: - Initializers
    
    public convenience init(viewWidth: CGFloat, gridWidth: Int = 25, gridHeight: Int = 25) {
        let viewHeight = viewWidth * CGFloat(gridHeight) / CGFloat(gridWidth)
        let frame = CGRect(x: 0, y: 0, width: viewWidth, height: viewHeight)
        self.init(frame: frame)
        self.grid = Grid(width: gridWidth, height: gridHeight)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    // MARK: - Drawing
    
    public override func draw(_ rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()
        
        context?.saveGState()
        
        for cell in grid.cells {
            let rect = CGRect(x: CGFloat(cell.x) * cellSize, y: CGFloat(cell.y) * cellSize, width: cellSize, height: cellSize)
            let color = cell.state == .alive ? UIColor.black.cgColor: UIColor.systemGray4.cgColor
            context?.addRect(rect)
            context?.setFillColor(color)
            context?.fill(rect)
        }
        
        context?.restoreGState()
    }
}
