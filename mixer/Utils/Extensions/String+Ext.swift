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
    
    func coordinates() async throws -> CLLocationCoordinate2D? {
        let geocoder = CLGeocoder()
        do {
            let placemarks = try await geocoder.geocodeAddressString(self)
            if let location = placemarks.first?.location {
                return location.coordinate
            } else {
                return nil
            }
        } catch let error {
            print("Error: \(error)")
            return nil
        }
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
        let emailPattern = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailPattern)
        return emailPredicate.evaluate(with: self)
    }
}
