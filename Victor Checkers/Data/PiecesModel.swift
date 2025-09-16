//
//  PiecesModel.swift
//  Victor Checkers
//
//  Created by Wiktor Nizio on 15/09/2025.
//

import Foundation

struct PiecesModel {
  var id: String = UUID().uuidString
  var parent: String = ""
  var whiteMen: [Point] = []
  var blackMen: [Point] = []
  var whiteKings: [Point] = []
  var blackKings: [Point] = []
  var heuristics: Int? = nil
  var level: Int = 0
  var children: [PiecesModel] = []
  
  struct Point : Equatable {
    var x: Int
    var y: Int
  }
}
