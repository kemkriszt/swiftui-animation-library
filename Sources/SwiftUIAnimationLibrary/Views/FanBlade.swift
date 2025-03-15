//
//  File.swift
//  SwiftUIAnimationLibrary
//
//  Created by Krisztián Kemenes on 15.03.2025.
//

import SwiftUI

/// Draws a capsule that works as a fan blade.
struct FanBlade: Shape {
    /// The center point of the 'fan' to draw the blade around
    let pivot: CGPoint
    /// Current angle of the blade
    let angle: Angle
    /// Width of the capsule
    let bladeWidth: Double
    /// Height of the capsule
    let bladeHeight: Double
    /// A gap in the middle of the 'fan'. The blade will not go right to the center point
    var centerGap: Double  = 5
    /// Scale the blade. It scales towards the center point
    var scale: Double = 1.0
    
    /// Radius of the capsules end arcs
    var arcRadius: Double {
        bladeWidth / 2
    }
    
    /// Width of the straight line in the side of the capsule
    var bladeSideWidth: Double {
        bladeHeight - centerGap - arcRadius * 2
    }
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        // Create a capsule shape. We need to construct it from building blocks
        // as we would not be able to rotate a rounded rectangle
        
        // 1. Calculate scaled values
        let scaledArcRadius = scale * arcRadius
        let scaledSideWidth = scale * bladeSideWidth
        // Make sure to scale towards the middle not the outer radius
        let yOffset = (arcRadius + bladeSideWidth) * (1 - scale)
        
        // 2. Transformation for the rotation effect
        let transform = CGAffineTransform(translationX: pivot.x, y: pivot.y)
            .rotated(by: angle.radians)
            .translatedBy(x: -pivot.x, y: -pivot.y)
        
        // 3. Positions of the arcs
        let topArcCenter = CGPoint(x: Int(rect.midX),
                                   y: Int(scaledArcRadius + yOffset + rect.origin.y))
                            .applying(transform)
        let bottomArcCenter = CGPoint(x: Int(rect.midX),
                                      y: Int(scaledArcRadius + scaledSideWidth + yOffset + rect.origin.y))
                            .applying(transform)
        
        let offsetAngle = angle.degrees
        let topArcStartAngle = Angle.degrees(Double(0 + offsetAngle))
        let topArcEndAngle = Angle.degrees(Double(180 + offsetAngle))
        
        let bottomArcStartAngle = Angle.degrees(Double(180 + offsetAngle))
        let bottomArcEndAngle = Angle.degrees(Double(0 + offsetAngle))
        
        // 4. Draw
        path.addArc(center: topArcCenter,
                    radius: scaledArcRadius,
                    startAngle: topArcStartAngle,
                    endAngle: topArcEndAngle,
                    clockwise: true)
        path.addArc(center: bottomArcCenter,
                    radius: scaledArcRadius,
                    startAngle: bottomArcStartAngle,
                    endAngle: bottomArcEndAngle,
                    clockwise: true)
        path.closeSubpath()
        
        return path
    }
}

#Preview {
    @Previewable @State var scale: Double = 1.0
    
    FanBlade(pivot: .init(x: 200, y: 200),
             angle: .zero,
             bladeWidth: 50,
             bladeHeight: 200,
             scale: scale)
        .stroke(.blue)
        .frame(width: 400, height: 400)
    Slider(value: $scale, in: 0.1...1)
}
