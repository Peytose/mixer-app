//
//  TravelTimeView.swift
//  mixer
//
//  Created by Jose Martinez on 2/9/24.
//

import SwiftUI

struct TravelTimeView: View {
    var userAddress: String
    var destinationTitle: String
    var destinationAddress: String
    
    
    var body: some View {
        VStack(spacing: 20) {
            LocationCell(address: userAddress, isDestination: false)
            LocationCell(address: destinationAddress, title: destinationTitle, isDestination: true)
        }
        .padding()
        .background(Color.theme.secondaryBackgroundColor)
        .cornerRadius(12)
    }
}

fileprivate struct LocationCell: View {
    var address: String
    var title: String?
    var isDestination: Bool
    
    var body: some View {
        HStack(spacing: 20) {
            Image(systemName: isDestination ? "mappin.and.ellipse" : "location")
            
            VStack(alignment: .leading) {
                if let title {
                    Text(title)
                        .font(.headline)
                } else {
                    Text("My Location")
                        .font(.headline)
                }
                
                Text(isDestination ? address : "Near \(address)")
                    .font(.footnote)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Image(systemName: "ellipsis")
                .rotationEffect(Angle(degrees: 90))
        }
    }
}

#Preview {
    TravelTimeView(userAddress: "77 Mass Ave, Boston MA", destinationTitle: "MIT Theta Chi", destinationAddress: "528 Beacon St, Boston MA")
}
