//
//  ContentView.swift
//  Victor Checkers
//
//  Created by Wiktor Nizio on 15/09/2025.
//

import SwiftUI

struct ContentView: View {
  
  @State private var viewModel = CheckersViewModel()
  
  var body: some View {
    ZStack {
      Checkerboard(inverted: false)
        .fill(.white)
        .padding()
      Checkerboard(inverted: true)
        .fill(.black)
        .padding()
      Pieces(position: viewModel.position.whiteMen)
        .fill(.green)
        .padding()
      Pieces(position: viewModel.position.blackMen)
        .fill(.red)
        .padding()
    }
  }
}

#Preview {
  ContentView()
}
