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
  
  var body: some View {
    GeometryReader { geometry in
      ZStack {
        Checkerboard(inverted: false)
          .fill(.white)
        Checkerboard(inverted: true)
          .fill(.black)
        Pieces(
          position: viewModel.position.blackMen
        )
          .fill(.red)
        Pieces(
          position: viewModel.position.whiteMen,
          invisible: invisible,
          offset: dragOffset,
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
              }
              .onEnded { gesture in
                let index = viewModel.position.whiteMen.firstIndex(of: invisible)
                let indexKing = viewModel.position.whiteKings.firstIndex(of: invisible)
                if index != nil || indexKing != nil {
                  let end = gesture.location
                  let endX = Int(end.x) / Int(geometry.size.width / 8.0)
                  let endY = 7 - Int(end.y) / Int(geometry.size.height / 8.0)
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
                    let interimX = invisible.x + sign(dX)
                    let interimY = invisible.y + sign(dY)
                    let interim = PiecesModel.Point(x: interimX, y: interimY)
                    let indexBlackMan = viewModel.position.blackMen.firstIndex(of: interim)
                    let indexBlackKing = viewModel.position.blackKings.firstIndex(of: interim)
                    if dY == 1 || dY == 2 && (indexBlackMan != nil || indexBlackKing != nil) ||
                        indexKing != nil && (indexBlackMan != nil || indexBlackKing != nil) {
                      if let index = indexBlackMan {
                        viewModel.position.blackMen.remove(at: index)
                      }
                      if let index = indexBlackKing {
                        viewModel.position.blackKings.remove(at: index)
                      }
                      if let index = index {
                        viewModel.position.whiteMen.remove(at: index)
                        viewModel.position.whiteMen.append(destination)
                      }
                      if let index = indexKing {
                        viewModel.position.whiteKings.remove(at: index)
                        viewModel.position.whiteKings.append(destination)
                      }
                    }
                  }
                }
                
                invisible = PiecesModel.Point(x: -1, y: -1)
                dragOffset = CGSize.zero
              }
          )
        
      }
    }.padding()
  }
}

#Preview {
  ContentView()
}
