//
//  MapBalloon.swift
//  mixer
//
//  Created by Peyton Lyons on 11/29/23.
//

import SwiftUI

struct MapBalloon: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.size.width
        let height = rect.size.height
        path.move(to: CGPoint(x: 0.5*width, y: 0))
        path.addCurve(to: CGPoint(x: width, y: 0.4199999397*height), control1: CGPoint(x: 0.7761423448*width, y: 0), control2: CGPoint(x: width, y: 0.1880403877*height))
        path.addCurve(to: CGPoint(x: 0.6825242136*width, y: 0.8111359542*height), control1: CGPoint(x: width, y: 0.5978534782*height), control2: CGPoint(x: 0.8683950387*width, y: 0.749887094*height))
        path.addLine(to: CGPoint(x: 0.5284730126*width, y: 0.9880128586*height))
        path.addCurve(to: CGPoint(x: 0.5160405028*width, y: 0.9968242425*height), control1: CGPoint(x: 0.5252614863*width, y: 0.9917156366*height), control2: CGPoint(x: 0.5209972157*width, y: 0.9947378996*height))
        path.addCurve(to: CGPoint(x: 0.4999945771*width, y: 0.9999998743*height), control1: CGPoint(x: 0.5110837899*width, y: 0.9989105226*height), control2: CGPoint(x: 0.5055802289*width, y: 0.9999998743*height))
        path.addCurve(to: CGPoint(x: 0.4839485393*width, y: 0.9968242425*height), control1: CGPoint(x: 0.494408888*width, y: 0.9999998743*height), control2: CGPoint(x: 0.4889052522*width, y: 0.9989105226*height))
        path.addCurve(to: CGPoint(x: 0.4715160295*width, y: 0.9880128586*height), control1: CGPoint(x: 0.4789918264*width, y: 0.9947378996*height), control2: CGPoint(x: 0.4747275558*width, y: 0.9917156366*height))
        path.addLine(to: CGPoint(x: 0.3174604154*width, y: 0.811130865*height))
        path.addCurve(to: CGPoint(x: 0, y: 0.4199999397*height), control1: CGPoint(x: 0.1315977246*width, y: 0.7498786747*height), control2: CGPoint(x: 0, y: 0.5978485146*height))
        path.addCurve(to: CGPoint(x: 0.5*width, y: 0), control1: CGPoint(x: 0, y: 0.1880403877*height), control2: CGPoint(x: 0.2238576365*width, y: 0))
        path.closeSubpath()
        return path
    }
}
