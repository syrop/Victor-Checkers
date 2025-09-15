//
//  Checkerboard.swift
//  Victor Checkers
//
//  Created by Wiktor Nizio on 15/09/2025.
//

import SwiftUI

struct Checkerboard: Shape {
  let inverted: Bool
  
  func path (in rect: CGRect) -> Path {
    var path = Path()
    
    let rowSize = rect.height / 8.0
    let columnSize = rect.width / 8.0
    
    for row in 0...7 {
      for column in 0...7 {
        if (row + column).isMultiple(of: 2) != inverted {
          let startX = columnSize * Double(column)
          let startY = rowSize * Double(row)
                               
          let rect = CGRect(x: startX, y: startY, width: columnSize, height: rowSize)
          path.addRect(rect)
        }
      }
    }
    
    return path
  }
}

