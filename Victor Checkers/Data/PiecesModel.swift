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
  
  func generateChildren() async -> [PiecesModel] {
    let whiteMove = level % 2 == 0
    let men = (whiteMove) ? whiteMen : blackMen
    let kings = (whiteMove) ? whiteKings : blackKings
    let opponentMen = (whiteMove) ? blackMen : whiteMen
    let opponentKings = (whiteMove) ? blackKings : whiteKings
    let menMovingDirection = (whiteMove) ? 1 : -1
    return await withTaskGroup(of: [PiecesModel].self, returning: [PiecesModel].self) { taskGroup in
      
      func isEmptyAndValid(_ point: Point) -> Bool {
        let isValid = 0...7 ~= point.x && 0...7 ~= point.y
        guard isValid else {
          return false
        }
        return !whiteMen.contains(point) && !whiteKings.contains(point) && !blackMen.contains(point) && !blackKings.contains(point)
      }
      
      func containsWhite(_ point: Point) -> Bool {
        return whiteMen.contains(point) || whiteKings.contains(point)
      }
      
      func containsBlack(_ point: Point) -> Bool {
        return blackMen.contains(point) || blackKings.contains(point)
      }
      
      func capture(position: PiecesModel, at point: Point) -> PiecesModel {
        var result = position
        
        var index = result.whiteMen.firstIndex(of: point)
        if let index = index {
          result.whiteMen.remove(at: index)
        }
        index = result.whiteKings.firstIndex(of: point)
        if let index = index {
          result.whiteKings.remove(at: index)
        }
        index = result.blackMen.firstIndex(of: point)
        if let index = index {
          result.blackMen.remove(at: index)
        }
        index = result.blackKings.firstIndex(of: point)
        if let index = index {
          result.blackKings.remove(at: index)
        }
        return result
      }
        
      func add(position: PiecesModel, at point: Point) -> PiecesModel {
        var result = position
        if (whiteMove) {
          if (point.y == 7) {
            result.whiteKings.append(point)
          } else {
            result.whiteMen.append(point)
          }
        } else {
          if (point.y == 0) {
            result.blackKings.append(point)
          } else {
            result.blackMen.append(point)
          }
        }
        return result
      }
      
      func kingMoves(position: PiecesModel, at point: Point, dirX: Int, dirY: Int) -> [PiecesModel] {
        var result: [PiecesModel] = []
        var x = point.x
        var y = point.y
        while (true) {
          x += dirX
          y += dirY
          var addition = position
          if isEmptyAndValid(Point(x: x + dirX, y: y + dirY)) && whiteMove && containsBlack(Point(x: x, y: y)) {
            addition = capture(position: addition, at: Point(x: x, y: y))
            addition.whiteKings.append(Point(x: x + dirX, y: y + dirY))
            result.append(addition)
          } else if isEmptyAndValid(Point(x: x + dirX, y: y + dirY)) && !whiteMove && containsWhite(Point(x: x, y: y)) {
            addition = capture(position: addition, at: Point(x: x, y: y))
            addition.blackKings.append(Point(x: x + dirX, y: y + dirY))
            result.append(addition)
          } else if isEmptyAndValid(Point(x: y, y: y)) {
            if whiteMove {
              addition.whiteKings.append(Point(x: x, y: y))
            } else {
              addition.blackKings.append(Point(x: x, y: y))
            }
            result.append(addition)
          } else {
            break
          }
        }
        
        return result
      }
      
      for man in men {
        taskGroup.addTask {
          var taskResult: [PiecesModel] = []
          if isEmptyAndValid(Point(x: man.x - 1, y: man.y + menMovingDirection)) { // normal move
            var child = capture(position: self, at: man)
            child = add(position: child, at: Point(x: man.x - 1, y: man.y + menMovingDirection))
            taskResult.append(child)
          }
          if isEmptyAndValid(Point(x: man.x + 1, y: man.y + menMovingDirection)) { // normal move
            var child = capture(position: self, at: man)
            child = add(position: child, at: Point(x: man.x + 1, y: man.y + menMovingDirection))
            taskResult.append(child)
          }
          if isEmptyAndValid(Point(x: man.x - 2, y: man.y + menMovingDirection * 2)) { // man captures a piece
            if (whiteMove && containsBlack(Point(x: man.x - 1, y: man.y + menMovingDirection))) ||
                (!whiteMove && containsWhite(Point(x: man.x - 1, y: man.y + menMovingDirection))) {
              var child = capture(position: self, at: man)
              child = capture(position: child, at: Point(x: man.x - 1, y: man.y + menMovingDirection))
              child = add(position: child, at: Point(x: man.x - 2, y: man.y + menMovingDirection * 2))
              taskResult.append(child)
            }
          }
          return taskResult
        }
      }
      
      for king in kings {
        taskGroup.addTask {
          let removed = capture(position: self, at: king)
          var taskResult: [PiecesModel] = []
          taskResult.append(contentsOf: kingMoves(position: removed, at: king, dirX: -1, dirY: -1))
          taskResult.append(contentsOf: kingMoves(position: removed, at: king, dirX: -1, dirY: +1))
          taskResult.append(contentsOf: kingMoves(position: removed, at: king, dirX: +1, dirY: -1))
          taskResult.append(contentsOf: kingMoves(position: removed, at: king, dirX: +1, dirY: +1))
          return taskResult
        }
      }
      
      return await taskGroup.reduce(into: [PiecesModel]()) { partialResult, pieces in
        partialResult.append(contentsOf: pieces)
      }
    }
  }
  
}
