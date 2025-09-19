//
//  Checkerboard.swift
//  Victor Checkers
//
//  Created by Wiktor Nizio on 15/09/2025.
//

import SwiftUI

struct Pieces: Shape {
  var position: [PiecesModel.Point]
  var kings: Bool = false
  var invisible: PiecesModel.Point = PiecesModel.Point(x: -1, y: -1)
  var offset: CGSize = CGSize.zero
  var movingKing: Bool = false
  
  
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
      let center = CGPoint(x: startX + diameter / 2, y: startY + diameter / 2)
      path.move(to: center)
      path.addArc(center: center, radius: diameter / 2, startAngle: .degrees(0), endAngle: .degrees(360), clockwise: true, transform: CGAffineTransform(translationX: dx, y: dy))
      if (kings) {
        path.move(to: center)
        path.addArc(center: center, radius: diameter / 4, startAngle: .degrees(360), endAngle: .degrees(0), clockwise: false, transform: CGAffineTransform(translationX: dx, y: dy))
      }
    }
    if (kings == movingKing) && hasInvisiblePiece && invisible.x >= 0 && invisible.y >= 0 {
      let x = columnSize * Double(invisible.x) + offset.width
      let y = rowSize * Double(7 - invisible.y) + offset.height
      let center = CGPoint(x: x + diameter / 2, y: y + diameter / 2)
      path.move(to: center)
      path.addArc(center: center, radius: diameter / 2, startAngle: .degrees(0), endAngle: .degrees(360), clockwise: true, transform: CGAffineTransform(translationX: dx, y: dy))
      if (kings) {
        path.move(to: center)
        path.addArc(center: center, radius: diameter / 4, startAngle: .degrees(360), endAngle: .degrees(0), clockwise: false, transform: CGAffineTransform(translationX: dx, y: dy))
      }
    }
    return path
  }
}

