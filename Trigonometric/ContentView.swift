//
//  ContentView.swift
//  Trigonometric
//
//  Created by MC on 2020/5/12.
//  Copyright © 2020 MC. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    @State private var maxH: CGFloat = 1
    var body: some View {
        VStack {
            ProgressiveText(text: "AAAAAAAAA", maxH: $maxH)
            
            Slider(value: $maxH, in: 0...6)
                .padding(.top, 150)
                .padding(.horizontal, 30)
        }
        
    }
}

struct ProgressiveText: View {
    let text: String
    @Binding var maxH: CGFloat
    
    var body: some View {
        HStack(spacing: 10) {
            ForEach(0..<10, id: \.self) { index in
                Circle()
                    .fill(Color.green)
                    .frame(width: 10, height: 10)
                    .scaleEffect(self.scaleValue(index, totalCharacters: 10, maxH: self.maxH))
                    .animation(Animation.easeInOut.delay(Double(index) * 0.1))
            }
        }
    }
    
    func scaleValue(_ idx: Int, totalCharacters: Int, maxH: CGFloat) -> CGFloat {
        let x = Double(idx) / Double(totalCharacters)
        let y = (sin(2 * .pi * x - (.pi / 2)) + 1) / 2.0
        return maxH + 2 * CGFloat(y)
    }
}

struct Line: Shape {
    let pt1: CGPoint
    let direction: Angle
    let length: CGFloat
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        let pt2y = pt1.y - sin(CGFloat(direction.radians)) * length
        let pt2x = cos(CGFloat(direction.radians)) * length + pt1.x
        
        let pt2 = CGPoint(x: pt2x, y: pt2y)
        
        path.move(to: pt1)
        path.addLine(to: pt2)
        
        return path
    }
}

struct PolygonShape: Shape {
    var siders: Int
    
    func path(in rect: CGRect) -> Path {
        let h = Double(min(rect.size.width, rect.size.height) / 2.0)
        let c = CGPoint(x: rect.size.width / 2.0, y: rect.size.height / 2.0)
        
        var path = Path()
        
        for i in 0..<siders {
            let angle = (360.0 / Double(siders)) * Double.pi / 180.0 * Double(i)
            let pt = CGPoint(x: c.x + CGFloat(h * cos(angle)),
                             y: c.y - CGFloat(h * sin(angle)))
            
            if i == 0 {
                path.move(to: pt)
            } else {
                path.addLine(to: pt)
            }
        }
        
        path.closeSubpath()
        return path
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
