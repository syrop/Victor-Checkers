//
//  PiecesModel.swift
//  Victor Checkers
//
//  Created by Wiktor Nizio on 15/09/2025.
//

import Foundation

struct PiecesModel : Equatable {
  var id: String = UUID().uuidString
  var parent: String = ""
  var whiteMen: [Point] = []
  var blackMen: [Point] = []
  var whiteKings: [Point] = []
  var blackKings: [Point] = []
  var level: Int = 0
  var children: [PiecesModel] = []
  
  static func == (lhs: PiecesModel, rhs: PiecesModel) -> Bool {
    return lhs.whiteMen == rhs.whiteMen &&
    lhs.whiteKings == rhs.whiteKings &&
    lhs.blackMen == rhs.blackMen &&
    lhs.blackKings == rhs.blackKings
  }
  
  struct Point : Equatable {
    var x: Int
    var y: Int
  }
  
  mutating func reduceLevel() {
    level -= 1
    var newChildren = [PiecesModel]()
    for child in children {
      var newChild = child
      newChild.reduceLevel()
      newChildren.append(newChild)
    }
    children = newChildren
  }
  
  func generateChildren() async -> [PiecesModel] {
    if level == DEPTH - 1 {
      return [] 
    }
    var resultChildren = children
    if (resultChildren.isEmpty) {
      let whiteMove = level % 2 == 0
      let men = (whiteMove) ? whiteMen : blackMen
      let kings = (whiteMove) ? whiteKings : blackKings
      let menMovingDirection = (whiteMove) ? 1 : -1
      resultChildren = await withTaskGroup(of: [PiecesModel].self, returning: [PiecesModel].self) { taskGroup in
        
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
            } else if isEmptyAndValid(Point(x: x, y: y)) {
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
            if isEmptyAndValid(Point(x: man.x + 2, y: man.y + menMovingDirection * 2)) { // man captures a piece
              if (whiteMove && containsBlack(Point(x: man.x + 1, y: man.y + menMovingDirection))) ||
                  (!whiteMove && containsWhite(Point(x: man.x + 1, y: man.y + menMovingDirection))) {
                var child = capture(position: self, at: man)
                child = capture(position: child, at: Point(x: man.x + 1, y: man.y + menMovingDirection))
                child = add(position: child, at: Point(x: man.x + 2, y: man.y + menMovingDirection * 2))
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
          for piecesElement in pieces {
            var result = piecesElement
            result.id = UUID().uuidString
            result.parent = id
            result.level = level + 1
            result.children = await result.generateChildren()
            partialResult.append(result)
          }
        }
      }
    }
    var result = [PiecesModel]()
    for resultChild in resultChildren {
      var toAppend = resultChild
      toAppend.children = await toAppend.generateChildren()
      result.append(toAppend)
    }
    return result
  }
  
  func blackWon() -> Bool {
    return whiteMen.isEmpty && whiteKings.isEmpty
  }
  
  func whiteWon() -> Bool {
    return blackMen.isEmpty && blackKings.isEmpty
  }
  
  func heuristics() -> Int {
    func immediateHeuristics() -> Int {
      return blackWon() ? Int.max : whiteWon() ? Int.min : blackMen.count + blackKings.count * KINGS_WEIGHT - whiteMen.count - whiteKings.count * KINGS_WEIGHT
    }
    
    if (level == DEPTH - 1) {
      return immediateHeuristics()
    } else if level % 2 == 0 { // white move
      return children.map { child in return child.heuristics() }.min() ?? immediateHeuristics()
    } else { // black move
      return children.map { child in return child.heuristics() }.max() ?? immediateHeuristics()
    }
  }
  
}
