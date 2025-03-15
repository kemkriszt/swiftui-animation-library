//
//  SwiftUIView.swift
//  SwiftUIAnimationLibrary
//
//  Created by Krisztian Kemenes on 20.02.2025.
//

import SwiftUI

/// SwiftUI animations presenting two dots that merge into each other niceline
struct DropletMerge: View {
    private let mainColor: Color = .blue
    private let secondaryColor: Color = .black
    private let baseSize = 50.0
    private let maxOffset = 50.0
    
    @State private var animated: Bool = false
    
    var canvasWidth: Double {
        maxOffset * 2 + baseSize
    }
    
    var canvasHeight: Double {
        baseSize
    }
    
    var body: some View {
        Canvas { context, size in
            context.addFilter(.alphaThreshold(min: 0.5, color: .black))
            context.addFilter(.blur(radius: 15))
            
            context.drawLayer { ctx in
                // access the passed in symbols using their .tag() id
                let circle0 = ctx.resolveSymbol(id: 0)!
                let circle1 = ctx.resolveSymbol(id: 1)!
                
                ctx.draw(circle0, at: CGPoint(x: baseSize / 2, y: canvasHeight / 2))
                ctx.draw(circle1, at: CGPoint(x: canvasWidth - baseSize / 2, y: canvasHeight / 2))
            }
        } symbols: {
            Circle()
                .fill(mainColor)
                .frame(width: baseSize, height: baseSize)
                .offset(x: animated ? 0 : maxOffset)
                .tag(0)
            Circle()
                .fill(secondaryColor)
                .frame(width: baseSize, height: baseSize)
                .offset(x: animated ? 0 : -maxOffset)
                .tag(1)
        }
        .frame(width: canvasWidth, height: canvasHeight)
        .rotationEffect(.degrees(animated ? 0.0 : 360.0))
        .animation(
            .easeInOut(duration: 2.5)
            .repeatForever(autoreverses: true),
            value: animated
        )
        .task {
            animated = true
        }
    }
}

#Preview {
    DropletMerge()
}
