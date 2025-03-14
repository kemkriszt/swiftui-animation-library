//
//  SwiftUIView.swift
//  SwiftUIAnimationLibrary
//
//  Created by Krisztián Kemenes on 09.03.2025.
//

import SwiftUI

struct AnimatedLines: Shape {
    var lines: Int
    private var progress: Double
    
    init(lines: Int) {
        self.lines = lines
        self.progress = 0
    }
    
    var animatableData: Double {
        get {
            Double(lines) + progress
        }
        set {
            self.lines = Int(newValue)
            self.progress = newValue - Double(self.lines)
        }
    }

    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        let lines = lines + (progress == 0 ? 0 : 1)
        let pivot = CGPoint(x: rect.midX, y: rect.midY)
        
        for i in 0..<lines {
            // Calculate the transform for the current index
            let finalProgress = (progress == 0.0 ? 1.0 : progress)
            let angle = angleWithProgress(line: i,
                                          totalLines: lines,
                                          progress: finalProgress)
            
            let transform = CGAffineTransform(translationX: pivot.x, y: pivot.y)
                .rotated(by: angle.radians)
                .translatedBy(x: -pivot.x, y: -pivot.y)
            
            // Create the end point of a side then rotate it around the center point based on the current index
            let targetPoint = CGPoint(x: rect.midX, y: rect.midY - rect.height / 4)
                .applying(transform)
            path.move(to: pivot)
            path.addLine(to: targetPoint)
        }
        
        return path
    }
    
    private func angleWithProgress(line: Int, totalLines: Int, progress: Double) -> Angle {
        if line == 0 {
            return .zero
        } else if line == totalLines - 1 {
            return angleFor(line: line,
                            outOf: totalLines,
                            withProgress: progress)
        } else {
            let previous = angleFor(line: line, outOf: totalLines - 1)
            let next = angleFor(line: line, outOf: totalLines)
            
            return previous + (next - previous) * progress
        }
    }
    
    private func angleFor(line: Int, outOf lines: Int, withProgress progress: Double = 1) -> Angle {
        let sideOffsetAngle = 360 / lines
        return Angle.degrees(Double((lines - line) * sideOffsetAngle) * progress)
    }
}

#Preview {
    @Previewable @State var numberOfSides: Int = 1
    
    AnimatedLines(lines: numberOfSides)
        .stroke(.red, lineWidth: 2)
        .frame(width: 400, height: 400)
        .overlay(alignment: .bottom) {
            HStack {
                ForEach(1..<10) { index in
                    Button("\(index)") {
                        withAnimation(.easeInOut(duration: 1)) {
                            numberOfSides = (index)
                        }
                    }
                }
            }
            .buttonStyle(.borderedProminent)
        }
}
