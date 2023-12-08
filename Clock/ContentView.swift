//
//  ContentView.swift
//  Clock
//
//  Created by Brett Moxey on 8/12/2023.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        TimelineView(.animation(minimumInterval: 1/20)) { timeline in
            Canvas { ctx, size in
                let angles = getAngles(for: timeline.date)
                let rect = CGRect(origin: .zero, size: size)
                let radius = min(size.width, size.height) / 2
                let border = radius / 25
                let hourLength = radius / 2.5
                let minuteLength = radius / 1.5
                let secondLength = radius * 1.1
                ctx.stroke(Circle()
                    .inset(by: border / 2)
                    .path(in: rect), with: .color(.primary), lineWidth: border)
                ctx.translateBy(x: rect.midX, y: rect.midY)
                drawHours(in: ctx, radius: radius)
                drawHand(in: ctx, radius: radius, length: minuteLength, angle: angles.minute)
                drawHand(in: ctx, radius: radius, length: hourLength, angle: angles.hour)
                let innerRing = radius / 6
                let ringWidth = radius / 40
                let inner = CGRect(x: -innerRing / 2, y: -innerRing / 2, width: innerRing, height: innerRing)
                ctx.stroke(
                    Circle()
                        .path(in: inner), with: .color(.primary), lineWidth: ringWidth)
                let secondLine = Capsule()
                    .offset(x: 0, y: -radius / 6)
                    .rotation(angles.second, anchor: .top)
                    .path(in: CGRect(x: -border / 2, y: 0, width: border, height: secondLength))
                ctx.fill(secondLine, with: .color(.orange))
                let centerPiece = Circle()
                    .path(in: inner.insetBy(dx: ringWidth, dy: ringWidth))
                ctx.blendMode = .clear
                ctx.fill(centerPiece, with: .color(.white))
                ctx.blendMode = .normal
                ctx.stroke(centerPiece, with: .color(.orange), lineWidth: ringWidth)
            }
        }
    }
}

#Preview {
    ContentView()
}

func getAngles(for date: Date) -> (hour: Angle, minute: Angle, second: Angle) {
    let parts = Calendar.current.dateComponents([.hour, .minute, .second, .nanosecond], from: .now)
    let hour = Double(parts.hour ?? 0)
    let minute = Double(parts.minute ?? 0)
    let second = Double(parts.second ?? 0)
    let nanosecond = Double(parts.nanosecond ?? 0)
    let hourAngle = Angle.degrees(30 * (hour + minute / 60) + 180)
    let minuteAngle = Angle.degrees(6 * (minute + second / 60) + 180)
    let secondAngle = Angle.degrees(6 * (second + nanosecond / 1_000_000_000) + 180)
    return (hourAngle, minuteAngle, secondAngle)
}

func drawHand(in context: GraphicsContext, radius: Double, length: Double, angle: Angle) {
    let width = radius / 30
    
    let stalk = Rectangle().rotation(angle, anchor: .top)
        .path(in: CGRect(x: -width / 2, y: 0, width: width, height: length))
    context.fill(stalk, with: .color(.primary))
    
    let hand = Capsule()
        .offset(x: 0, y: radius / 5)
        .rotation(angle, anchor: .top)
        .path(in: CGRect(x: -width, y: 0, width: width*2, height: length))
    context.fill(hand, with: .color(.primary))
}

func drawHours(in context: GraphicsContext, radius: Double) {
    let textSize = radius / 4
    let textOffset = radius * 0.75
    for i in 1 ... 12 {
        let text = Text(String(i)).font(.system(size: textSize)).bold()
        let point = CGPoint(x: 0, y: -textOffset).applying(CGAffineTransform(rotationAngle: Double(i) * .pi / 6))
        context.draw(text, at: point)
    }
}
