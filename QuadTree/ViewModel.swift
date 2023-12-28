//
//  ViewModel.swift
//  QuadTree
//
//  Created by Andrew Zheng (github.com/aheze) on 12/27/23.
//  Copyright © 2023 Andrew Zheng. All rights reserved.
//

import SwiftUI

class ViewModel: ObservableObject {
    // MARK: - Configuration

    @Published var viewportSize = CGSize(width: 500, height: 300)
    let xDomain = Double(-10) ... Double(10)
    let yDomain = Double(-3) ... Double(3)
    var domainWidth: Double { xDomain.upperBound - xDomain.lowerBound }
    var domainHeight: Double { yDomain.upperBound - yDomain.lowerBound }

    // function to render
    func function(point: Point) -> Double {
        let x = point.x
        let y = point.y

//        return y * pow((x - y), 2) - (4 * x) - 8
//        return pow(x, 2) + pow(y, 2) - 5
        return tan(pow(x, 2) + pow(y, 2)) - 1
    }

    // MARK: - Rendering

    @Published var displayedCells = [DisplayedCell]()

    init() {
        let timer = TimeElapsed()

        let root = Global.buildTree(
            function: function,
            xMin: xDomain.lowerBound,
            xMax: xDomain.upperBound,
            yMin: yDomain.lowerBound,
            yMax: yDomain.upperBound,
            minDepth: 6,
            maxCells: 15000,
            tolerance: domainWidth / 1000
        )

        var displayedCells = [DisplayedCell]()
        root.levelOrderTraversal { cell in

            let frame = CGRect(
                x: cell.frame.bL.point.x,
                y: cell.frame.bL.point.y,
                width: cell.frame.bR.point.x - cell.frame.bL.point.x,
                height: cell.frame.tL.point.y - cell.frame.bL.point.y
            )

            var adjustedFrame = CGRect(
                x: viewportSize.width / 2 + (frame.minX / domainWidth) * viewportSize.width,
                y: viewportSize.height / 2 + (frame.minY / domainHeight) * viewportSize.height,
                width: (frame.width / domainWidth) * viewportSize.width,
                height: (frame.height / domainHeight) * viewportSize.height
            )

            adjustedFrame.origin.y = viewportSize.height - adjustedFrame.origin.y
            adjustedFrame.origin.y -= adjustedFrame.height

            let displayedCell = DisplayedCell(cell: cell, frame: adjustedFrame)
            displayedCells.append(displayedCell)
        }

        print("root: \(root), count: \(displayedCells.count), time: \(timer)")

        self.displayedCells = displayedCells
    }
}
