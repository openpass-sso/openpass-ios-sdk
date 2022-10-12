//
//  ContentView.swift
//  OpenPassDevelopmentApp
//
//  Created by Brad Leege on 10/12/22.
//

import SwiftUI
import OpenPass

struct ContentView: View {
    
    let openPassManager = OpenPassManager()
    
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundColor(.accentColor)
            Text(openPassManager.text)
        }
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
