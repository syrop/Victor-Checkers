//
//  CheckersViewModel.swift
//  Victor Checkers
//
//  Created by Wiktor Nizio on 15/09/2025.
//

import SwiftUI
import Combine

class CheckersViewModel: ObservableObject {
  
  @Published var whiteWon: Bool = false
  @Published var blackWon: Bool = false
  @Published var noMoves: Bool = false
  @Published var position: PiecesModel = PiecesModel(
    whiteMen: [
      // Zeroth row
      PiecesModel.Point(x: 0, y: 0),
      PiecesModel.Point(x: 2, y: 0),
      PiecesModel.Point(x: 4, y: 0),
      PiecesModel.Point(x: 6, y: 0),
      // First row
      PiecesModel.Point(x: 1, y: 1),
      PiecesModel.Point(x: 3, y: 1),
      PiecesModel.Point(x: 5, y: 1),
      PiecesModel.Point(x: 7, y: 1),
      // Second row
      PiecesModel.Point(x: 0, y: 2),
      PiecesModel.Point(x: 2, y: 2),
      PiecesModel.Point(x: 4, y: 2),
      PiecesModel.Point(x: 6, y: 2),
    ],
    blackMen: [
      // Fiftt row
      PiecesModel.Point(x: 1, y: 5),
      PiecesModel.Point(x: 3, y: 5),
      PiecesModel.Point(x: 5, y: 5),
      PiecesModel.Point(x: 7, y: 5),
      // Sixth row
      PiecesModel.Point(x: 0, y: 6),
      PiecesModel.Point(x: 2, y: 6),
      PiecesModel.Point(x: 4, y: 6),
      PiecesModel.Point(x: 6, y: 6),
      // Seventh row
      PiecesModel.Point(x: 1, y: 7),
      PiecesModel.Point(x: 3, y: 7),
      PiecesModel.Point(x: 5, y: 7),
      PiecesModel.Point(x: 7, y: 7),
    ]
  )
  
  static func populateChildren(position: inout PiecesModel) async {
    position.children = await position.generateChildren()
  }
  
  func nextPosition() async { // gives the most attractive position from black's point of view
    if (position.whiteWon()) {
      whiteWon = true
    } else {
     var result = position
      await CheckersViewModel.populateChildren(position: &result)
      if (result.children.isEmpty) {
        noMoves = true
      } else {
        position = result.children.max(by: { $0.heuristics() < $1.heuristics() })!
        if (position.blackWon()) {
          blackWon = true
        }
      }
    }
  }
}
