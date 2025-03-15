//
//  File.swift
//  SwiftUIAnimationLibrary
//
//  Created by Krisztián Kemenes on 15.03.2025.
//

import SwiftUI

/// A colored fan that adds and removes blades with animation
/// Article detailing it: https://yenovi.com/blog/animate-your-drawings-with-swiftui
struct AnimatedFan: View, @preconcurrency Animatable {
    /// Total number of blades
    var blades: Int
    /// Progress of the current animation.
    /// For example when going from 2 blades to 4, this will go from 0 to 1 two times
    private var progress: Double
    private let colors: [Color] = [.red, .blue, .green, .yellow, .orange, .purple, .pink, .gray, .cyan, .brown]
    
    /// SwiftUI interpolates the number of blades as a single double.
    /// For example going from 2 to 4 blades will result in the ``animatableData`` being set to 2, 2.1, 2.2...3, 3.1, 3.2,... 4
    /// The resolution of the values is determined by the system
    var animatableData: Double {
        get {
            Double(blades) + progress
        }
        set {
            self.blades = Int(newValue)
            self.progress = newValue - Double(self.blades)
        }
    }
    
    init(blades: Int) {
        self.blades = blades
        self.progress = 0
    }
    
    var body: some View {
        Canvas { context, size in
            // Create a rectangle to draw in with padding
            let rectanglePadding = 30.0
            let rect = CGRect(origin: .init(x: rectanglePadding, y: rectanglePadding),
                              size: .init(width: size.width - 2.0 * rectanglePadding, height: size.height - 2.0 * rectanglePadding))
            let pivot = CGPoint(x: rect.midX, y: rect.midY)
            // If progress is grater than 0, it means a new blade is being added
            // so we have +1 blade
            let blades = blades + (progress == 0 ? 0 : 1)
            
            let bladeWidth = rect.width / 3
            let bladeHeight = rect.height / 2
            // Progress 0 should be threated as 1
            let finalProgress = (progress == 0.0 ? 1.0 : progress)
            
            for i in 0..<blades {
                let angle = angleWithProgress(blade: i,
                                              totalBlades: blades,
                                              progress: finalProgress)
                let scale = scale(for: i, of: blades, progress: finalProgress)
                let color = colors[i % colors.count]
                let blade = FanBlade(pivot: pivot,
                                     angle: angle,
                                     bladeWidth: bladeWidth,
                                     bladeHeight: bladeHeight,
                                     scale: scale).path(in: rect)
                context.stroke(blade, with: .color(color.opacity(scale)))
                context.fill(blade, with: .color(color.opacity(0.6 * scale)))
            }
        }
    }
    
    /// Calculate the scale factor for a single blade.
    /// - It will always be 1 for blades that are not the last
    /// - For the last blade, it will grow from 0 to 1 while the progress is going from 0 to 0.4,
    /// then while the progress is growing to 0.8, it will overshoot a bit than come back.
    /// This creates a bounce effect
    private func scale(for blade: Int,
                       of blades: Int,
                       progress: Double) -> Double {
        if blade == blades - 1 {
            if progress <= 0.4 {
                return min(progress / 0.4, 1)
            } else if progress <= 0.8 {
                let overshoot = 1.2// Overshoot factor
                let t = (progress - 0.4) / 0.4 // Normalize between 0 and 1
                return 1 + (overshoot - 1) * sin(t * .pi)
            } else {
                return 1
            }
        } else {
            return 1
        }
    }
    
    /// Calculate the angle for a blade in it's context
    private func angleWithProgress(blade: Int,
                                   totalBlades: Int,
                                   progress: Double) -> Angle {
        if blade == 0 && blades > 1 {
            return .zero
        } else if blade == totalBlades - 1 {
            return angleFor(line: blade,
                            outOf: totalBlades,
                            withProgress: progress)
        } else {
            let previous = angleFor(line: blade, outOf: totalBlades - 1)
            let next = angleFor(line: blade, outOf: totalBlades)
            
            return previous + (next - previous) * progress
        }
    }
    
    /// Calcualte the angle for a blade as if it was the last one
    private func angleFor(line: Int,
                          outOf lines: Int,
                          withProgress progress: Double = 1) -> Angle {
        let sideOffsetAngle = 360 / lines
        return Angle.degrees(Double((lines - line) * sideOffsetAngle) * progress)
    }
}

#Preview {
    @Previewable @State var numberOfBlades: Int = 1
    
    VStack {
        AnimatedFan(blades: numberOfBlades)
            .frame(width: 300, height: 300)
        HStack {
            ForEach(1..<10) { index in
                Button("\(index)") {
                    withAnimation(.bouncy(duration: 1, extraBounce: -0.1)) {
                        numberOfBlades = index
                    }
                }
            }
        }
        .buttonStyle(.borderedProminent)
        .offset(y: 40)
    }
}
