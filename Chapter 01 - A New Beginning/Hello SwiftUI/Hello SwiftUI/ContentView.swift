//
//  ContentView.swift
//  Hello SwiftUI
//
//  Created by Peter Friese on 11.09.22.
//

import SwiftUI

struct ContentView: View {
    @State var name: String = ""

    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundColor(.accentColor)

            TextField(
                "Enter your name here",
                text: $name
            )
            .frame(height: 40)
            .multilineTextAlignment(.center)
            .border(.blue, width: 1)
            .disableAutocorrection(true)

            // Show the comma if name contains at least one letter
            if name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                Text(
                    "Hello!"
                )
            } else {
                Text(
                    "Hello, \(name)!"
                )
            }
        
            // Add a button to reset the name variable to an empty string
            Button("Reset") {
                name = ""
            }
        }
        .padding()

    }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
  }
}
