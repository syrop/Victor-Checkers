//
//  ContentView.swift
//  Victor Checkers
//
//  Created by Wiktor Nizio on 15/09/2025.
//

import SwiftUI

struct ContentView: View {
  
  @State private var viewModel = CheckersViewModel()
  @State private var dragOffset = CGSize.zero
  @State private var invisible = PiecesModel.Point(x: -1, y: -1)
  @State private var movingKing = false
  @State private var refreshID = UUID()
  
  var body: some View {
    NavigationStack {
      GeometryReader { geometry in
        ZStack {
          Checkerboard(inverted: false)
            .fill(.white)
          Checkerboard(inverted: true)
            .fill(.black)
          Pieces(
            position: viewModel.position.blackMen,
          )
          .fill(.red)
          Pieces(
            position: viewModel.position.whiteMen,
            invisible: invisible,
            offset: dragOffset,
            movingKing: movingKing,
          )
          .fill(.green)
          .gesture(
            DragGesture()
              .onChanged { gesture in
                dragOffset = gesture.translation
                let start = gesture.startLocation
                let startX = Int(start.x) / Int(geometry.size.width / 8.0)
                let startY = 7 - Int(start.y) / Int(geometry.size.height / 8.0)
                invisible = PiecesModel.Point(x: startX, y: startY)
                movingKing = false
              }
              .onEnded { gesture in
                makeAMove(size: geometry.size, location: gesture.location)
              }
          )
          Pieces(
            position: viewModel.position.blackKings,
            kings: true,
          )
          .fill(.red)
          Pieces(
            position: viewModel.position.whiteKings,
            kings: true,
            invisible: invisible,
            offset: dragOffset,
            movingKing: movingKing,
          )
          .fill(.green)
          .gesture(
            DragGesture()
              .onChanged { gesture in
                dragOffset = gesture.translation
                let start = gesture.startLocation
                let startX = Int(start.x) / Int(geometry.size.width / 8.0)
                let startY = 7 - Int(start.y) / Int(geometry.size.height / 8.0)
                invisible = PiecesModel.Point(x: startX, y: startY)
                movingKing = true
              }
              .onEnded { gesture in
                makeAMove(size: geometry.size, location: gesture.location)
              }
          )
          if (viewModel.whiteWon) {
            Text("White won")
              .foregroundStyle(.black)
              .background(.white)
          }
          if (viewModel.blackWon) {
            Text("Black won")
              .foregroundStyle(.black)
              .background(.white)
          }
        }
      }
      .padding()
      .task {
        var position = viewModel.position
        await CheckersViewModel.populateChildren(position: &position)
        viewModel.position = position
      }
      .id(refreshID)
      .toolbar {
        ToolbarItem(placement: .topBarTrailing) {
          Button("Reset") {
            viewModel.position = CheckersViewModel.INITIAL_POSITION
            viewModel.blackWon = false
            viewModel.whiteWon = false
            viewModel.noMoves = false
            refreshID = UUID()
          }
        }
      }
    }
  }
  
  func makeAMove(size: CGSize, location: CGPoint) {
    let index = viewModel.position.whiteMen.firstIndex(of: invisible)  // the man that is moving
    let indexKing = viewModel.position.whiteKings.firstIndex(of: invisible)  // the king that is moving
    if index != nil || indexKing != nil {
      let end = location
      let endX = Int(end.x) / Int(size.width / 8.0)
      let endY = 7 - Int(end.y) / Int(size.height / 8.0)
      let destination = PiecesModel.Point(x: endX, y: endY)
      if !viewModel.position.whiteMen.contains(destination) &&
          !viewModel.position.whiteKings.contains(destination) &&
          !viewModel.position.blackMen.contains(destination) &&
          !viewModel.position.blackMen.contains(destination) &&
          endY <= 7 &&
          endY >= 0 &&
          endX >= 0 &&
          endX <= 7 {
        let dX = endX - invisible.x
        let dY = endY - invisible.y
        let interimX = endX - sign(dX)
        let interimY = endY - sign(dY)
        let interim = PiecesModel.Point(x: interimX, y: interimY)  // the captured piece, if any
        let indexBlackMan = viewModel.position.blackMen.firstIndex(of: interim)
        let indexBlackKing = viewModel.position.blackKings.firstIndex(of: interim)
        
        var newPosition = viewModel.position
        
        if dX != 0 && abs(dX) == abs(dY) && (dY == 1 || dY == 2 && (indexBlackMan != nil || indexBlackKing != nil) || indexKing != nil) {
          
          if (indexKing != nil) {
              var x = invisible.x
              var y = invisible.y
            while true {
              x += sign(dX)
              y += sign(dY)
              if (x == endX || y == endY) {
                break
              }
              if (viewModel.position.whiteMen.contains(destination) ||
                  viewModel.position.whiteKings.contains(destination) ||
                  viewModel.position.blackMen.contains(destination) ||
                  viewModel.position.blackMen.contains(destination)) &&
                  !(x == interimX && y == interimY && (indexBlackMan != nil || indexBlackKing != nil)) {
                return
              }
            }
          }
          
          if let index = indexBlackMan {
            newPosition.blackMen.remove(at: index)
          }
          if let index = indexBlackKing {
            newPosition.blackKings.remove(at: index)
          }
          if let index = index {  // the white man has moved
            newPosition.whiteMen.remove(at: index)
            if endY < 7 {
              newPosition.whiteMen.append(destination)
            } else {
              newPosition.whiteKings.append(destination)
            }
          }
          if let index = indexKing {  // the white king has moved
            newPosition.whiteKings.remove(at: index)
            newPosition.whiteKings.append(destination)
          }
          if (viewModel.position != newPosition) {
            let index = viewModel.position.children.firstIndex(of: newPosition)
            viewModel.position = viewModel.position.children[index!]
            Task {
              await viewModel.nextPosition()
              viewModel.position.reduceLevel()
              viewModel.position.reduceLevel()
              refreshID = UUID()
            }
          }
        }
      }
    }
    
    invisible = PiecesModel.Point(x: -1, y: -1)
    dragOffset = CGSize.zero
  }
}

#Preview {
  ContentView()
}
