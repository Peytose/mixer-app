//
//  ImageRenderer.swift
//  mixer
//
//  Created by Peyton Lyons on 8/29/23.
//

import SwiftUI
import CoreGraphics

struct ContentView: View {
    var body: some View {
        ShareLink("Export PDF", item: render(content: testView(), title: "MyTitle"))
    }

    @MainActor
    func render<Content: View>(content: Content, title: String) -> URL {
        let renderer = ImageRenderer(content: content)
        let url = URL.documentsDirectory.appending(path: "\(title).pdf")
        
        renderer.render { size, context in
            var box = CGRect(x: 0, y: 0, width: size.width, height: size.height)
            guard let pdf = CGContext(url as CFURL, mediaBox: &box, nil) else {
                return
            }
            pdf.beginPDFPage(nil)
            context(pdf)
            pdf.endPDFPage()
            pdf.closePDF()
        }
        return url
    }
}

struct testView: View {
    var body: some View {
        Text("Hello, world!")
            .font(.largeTitle)
            .foregroundStyle(.white)
            .padding()
            .background(.blue)
            .clipShape(Capsule())
    }
}
