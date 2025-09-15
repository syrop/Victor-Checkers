//
//  Checkerboard.swift
//  Victor Checkers
//
//  Created by Wiktor Nizio on 15/09/2025.
//

import SwiftUI

struct Pieces: Shape {
  let position: [PiecesModel.Point]
  
  func path (in rect: CGRect) -> Path {
    var path = Path()
    
    let rowSize = rect.height / 8.0
    let columnSize = rect.width / 8.0
    let diameter = min(rowSize, columnSize)
    let dx = (columnSize - diameter) / 2.0
    let dy = (rowSize - diameter) / 2.0
    
    for piece in position {
      let startX = columnSize * Double(piece.x)
      let startY = rowSize * Double(7 - piece.y)
      let circle = CGRect(x: startX, y: startY, width: diameter, height: diameter)
      path.addEllipse(in: circle, transform: CGAffineTransform(translationX: dx, y: dy))
    }
    
    return path
  }
}

