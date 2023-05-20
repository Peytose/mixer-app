//
//  ImageLoader.swift
//  mixer
//
//  Created by Peyton Lyons on 5/19/23.
//

import SwiftUI

class ImageLoader: ObservableObject {
    @Published var image: Image? = nil
    
    init(url: String) {
        loadImage(from: url)
    }
    
    private func loadImage(from url: String) {
        guard let url = URL(string: url) else { return }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let data = data, let uiImage = UIImage(data: data) {
                DispatchQueue.main.async {
                    self.image = Image(uiImage: uiImage)
                    print("DEBUG: Updated image!")
                }
            }
        }.resume()
    }
}
