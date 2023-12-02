//
//  String+Ext.swift
//  mixer
//
//  Created by Peyton Lyons on 11/24/22.
//

import SwiftUI
import CoreLocation

extension String {
    func applyPattern(pattern: String = "##  ##  ####", replacmentCharacter: Character = "#") -> String {
        var pureNumber = self.replacingOccurrences( of: "[^0-9]", with: "", options: .regularExpression)
        for index in 0 ..< pattern.count {
            guard index < pureNumber.count else { return pureNumber }
            let stringIndex = String.Index(utf16Offset: index, in: self)
            let patternCharacter = pattern[stringIndex]
            guard patternCharacter != replacmentCharacter else { continue }
            pureNumber.insert(patternCharacter, at: stringIndex)
        }
        return pureNumber
    }

    
    func getLocation(completion: @escaping(CLLocation?, Error?) -> Void) {
        CLGeocoder().geocodeAddressString(self) { placemarks, error in
            if let error = error {
                completion(nil, error)
                return
            }
            
            guard let location = placemarks?.first?.location else { return }
            completion(location, nil)
        }
    }
    
    
    func generateQRCode() -> UIImage? {
        let data = self.data(using: String.Encoding.ascii)

        if let filter = CIFilter(name: "CIQRCodeGenerator") {
            filter.setValue(data, forKey: "inputMessage")
            let transform = CGAffineTransform(scaleX: 9, y: 9)

            if let output = filter.outputImage?.transformed(by: transform),
               let cgImage = CIContext().createCGImage(output, from: output.extent) {
                return UIImage(cgImage: cgImage)
            }
        }

        return nil
    }
    
    
    func loadImage(completion: @escaping (Image?) -> Void) {
        guard let url = URL(string: self) else { return }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let data = data, let uiImage = UIImage(data: data) {
                DispatchQueue.main.async {
                    completion(Image(uiImage: uiImage))
                    print("DEBUG: Updated image!")
                }
            } else {
                completion(nil)
            }
        }
        .resume()
    }
    
    
    var formattedAsCurrency: String {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .currency
        numberFormatter.currencySymbol = "$"
        numberFormatter.minimumFractionDigits = 2
        numberFormatter.maximumFractionDigits = 2

        // Remove all non-numeric characters
        let filteredString = self.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()

        // Convert to a decimal number
        guard let decimalNumber = Decimal(string: filteredString) else {
            return ""
        }

        // Divide by 100 to get the correct decimal value
        let amount = decimalNumber / Decimal(100)

        // Format the number as currency
        return numberFormatter.string(from: NSDecimalNumber(decimal: amount)) ?? ""
    }
    
    var isValidEmail: Bool {
        let emailPattern = "[A-Z0-9a-z._%+-]+(\\.[A-Z0-9a-z._%+-]+)*@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailPattern)
        return emailPredicate.evaluate(with: self)
    }
    
    var plannerId: String? {
        let components = self.split(separator: "-")
        print("DEBUG: components of path \(components)")
        return components.count == 2 ? String(components[0]) : nil
    }
    
    var hostId: String? {
        let components = self.split(separator: "-")
        return components.count == 2 ? String(components[1]) : nil
    }
    
    
    func replacingPlannerId(with newPlannerId: String) -> String {
        guard let hostId = self.hostId else { return self }
        return "\(newPlannerId)-\(hostId)"
    }
    
    
    func replacingHostId(with newHostId: String) -> String {
        guard let plannerId = self.plannerId else { return self }
        return "\(plannerId)-\(newHostId)"
    }
}
