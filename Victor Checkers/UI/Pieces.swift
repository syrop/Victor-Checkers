//
//  Checkerboard.swift
//  Victor Checkers
//
//  Created by Wiktor Nizio on 15/09/2025.
//

import SwiftUI

struct Pieces: Shape {
  var position: [PiecesModel.Point]
  var invisible: PiecesModel.Point = PiecesModel.Point(x: -1, y: -1)
  var offset: CGSize = CGSize.zero
  func path (in rect: CGRect) -> Path {
    var path = Path()
    
    let rowSize = rect.height / 8.0
    let columnSize = rect.width / 8.0
    let diameter = min(rowSize, columnSize)
    let dx = (columnSize - diameter) / 2.0
    let dy = (rowSize - diameter) / 2.0
    var hasInvisiblePiece = false
    for piece in position {
      if piece.x == invisible.x && piece.y == invisible.y {
        hasInvisiblePiece = true
        continue
      }
      let startX = columnSize * Double(piece.x)
      let startY = rowSize * Double(7 - piece.y)
      let circle = CGRect(x: startX, y: startY, width: diameter, height: diameter)
      path.addEllipse(in: circle, transform: CGAffineTransform(translationX: dx, y: dy))
    }
    if hasInvisiblePiece && invisible.x >= 0 && invisible.y >= 0 {
      let movingCircle = CGRect(
        x: columnSize * Double(invisible.x) + offset.width,
        y: rowSize * Double(7 - invisible.y) + offset.height,
        width: diameter,
        height: diameter,
      )
      path.addEllipse(in: movingCircle)
    }
    return path
  }
}

