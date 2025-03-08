//
//  File.swift
//  SwiftUIAnimationLibrary
//
//  Created by Krisztian Kemenes on 06.03.2025.
//

import SwiftUI

struct InteractiveSlider: View {
    private static let handleWidth: Double = 5
    private static let cornerRadius: Double = 5
    private static let containerSpacing: Double = 5
    private static let leftTitleName = "left-title"
    private static let rightTitleName = "right-title"
    
    let leftText: String = "Skill"
    let rightText: String = "3.7 Sonett"
    
    @Namespace private var namespace
    
    @State private var percent: Double = 0.46
    
    @State private var leftTitleShowingBelow: Bool = false
    @State private var rightTitleShowingBelow: Bool = false
    
    var body: some View {
        GeometryReader { geometry in
            VStack {
                HStack(spacing: Self.containerSpacing) {
                    HStack {
                        visibilityReportingTextView(leftText,
                                                    $leftTitleShowingBelow,
                                                    geometryId: Self.leftTitleName,
                                                    alignment: .leading)
                        Spacer()
                        Text("\(Int(percent * 100))%")
                            .fixedSize()
                    }
                    .padding()
                    .frame(width: sliderWidth(with: geometry.size))
                    .background(
                        RoundedRectangle(cornerRadius: Self.cornerRadius)
                            .fill(.gray.opacity(0.4))
                    )
                    RoundedRectangle(cornerRadius:  Self.cornerRadius)
                        .fill(.red)
                        .frame(width: Self.handleWidth, height: 53)
                        .gesture(
                            DragGesture()
                                .onChanged { value in
                                    let width = sliderWidth(with: geometry.size)
                                    let newWidth = width + value.translation.width
                                    percent = convertToPercentage(newWidth, of: geometry.size.width)
                                }
                        )
                    HStack {
                        Text("\(100 - Int(percent * 100))%")
                        Spacer()
                        visibilityReportingTextView(rightText,
                                                    $rightTitleShowingBelow,
                                                    geometryId: Self.rightTitleName,
                                                    alignment: .trailing)
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius:  Self.cornerRadius)
                            .fill(.gray)
                    )
                }
                HStack {
                    if leftTitleShowingBelow {
                        Text(leftText)
                            .matchedGeometryEffect(id: Self.leftTitleName, in: namespace)
                    }
                    Spacer()
                    if rightTitleShowingBelow {
                        Text(rightText)
                            .matchedGeometryEffect(id: Self.rightTitleName, in: namespace)
                    }
                }
            }
            .foregroundStyle(.white)
            .font(.body.monospaced())
        }
        .frame(height: 52)
    }
    
    func visibilityReportingTextView(_ text: String,
                                     _ visilibity: Binding<Bool>,
                                     geometryId: String,
                                     alignment: Alignment) -> some View {
        ViewThatFits(in: .horizontal) {
            Text(text)
                .hidden()
                .fixedSize()
                .onAppear { withAnimation(.easeOut(duration: 0.2)) { visilibity.wrappedValue = false } }
            Color.clear
                .onAppear { withAnimation(.easeOut(duration: 0.2)) { visilibity.wrappedValue = true } }
        }
        .overlay(alignment: .leading) {
            if !visilibity.wrappedValue {
                Text(text)
                    .fixedSize()
                    .matchedGeometryEffect(id: geometryId, in: namespace)
            }
        }
    }
    
    func sliderWidth(with size: CGSize) -> Double {
        (size.width * percent) - Self.handleWidth / 2 - Self.containerSpacing / 2
    }
    
    func convertToPercentage(_ width: Double, of fullWidth: Double) -> Double {
        let newPercentage = (width + Self.handleWidth / 2 + Self.containerSpacing / 2) / fullWidth
        return min(max(newPercentage, 0), 1)
    }
}

#Preview {
    VStack {
        InteractiveSlider()
    }
    .padding()
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Color(UIColor(red: 21/255, green: 21/255, blue: 16/255, alpha: 1)))
}
