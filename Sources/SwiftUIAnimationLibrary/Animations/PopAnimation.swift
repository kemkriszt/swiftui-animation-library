//
//  File.swift
//  SwiftUIAnimationLibrary
//
//  Created by Krisztian Kemenes on 28.02.2025.
//

import SwiftUI

extension View {
    func popAnimation(animated: Bool, delay: Double = 0, speed: Double = 1.5) -> some View {
        self.opacity(animated ? 1 : 0)
            .scaleEffect(animated ? 1 : 0)
            .animation(.bouncy(extraBounce: 0.3).speed(1.5).delay(delay), value: animated)
    }
}


#Preview {
    @Previewable @State var showing: Bool = false
    
    VStack {
        Button("Show") { showing.toggle() }
        Rectangle()
            .frame(width: 100, height: 100)
            .popAnimation(animated: showing)
    }
}
