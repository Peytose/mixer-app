//
//  ReviewCreatedEventView.swift
//  mixer
//
//  Created by Jose Martinez on 12/22/22.
//


import SwiftUI

struct ReviewCreatedEventView: View {
    @ObservedObject var viewModel: CreateEventViewModel
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 18) {
                Text(viewModel.title)
                    .font(.body)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Text(viewModel.privacy.rawValue)
                    .font(.body)
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)
                
                Divider().foregroundColor(.secondary)
                
//                Text(viewModel.startDate.getTimestampString(format: <#T##String#>))
//                Text("\(viewModel.isPrivate.stringVersion) Event \(Image(systemName: viewModel.isPrivate == .yes ? "lock.fill": "globe"))")
//                    .font(.title3).fontWeight(.medium)
//                    .foregroundColor(.secondary)
//                    .padding(.bottom, 5)
                
                
                
                VStack(alignment: .leading, spacing: 18) {
                    reviewDetailRow(title: "Starts", value: "Friday, Jan 20 at 9:00 PM")
                    reviewDetailRow(title: "Ends", value: "Saturday, Jan 21 at 1:00 AM")
                    reviewDetailRow(title: "Location", value: "528 Beacon St, Boston MA 02215")
                    reviewDetailRow(title: "Ends", value: "Saturday, Jan 21 at 1:00 AM")
                    reviewDetailRow(title: "Type", value: "Wet")
                    reviewDetailRow(title: "Theme", value: "Neon")
                }
                
                VStack(alignment: .leading) {
                    Text("Event Description:")
                        .font(.title3).fontWeight(.medium)
                    
                    Text("Neon party at Theta Chi, need we say more?")
                        .font(.headline)
                        .foregroundColor(.secondary)
                        .lineLimit(4)
                }
                
                VStack(alignment: .leading) {
                    Text("Attire Description:")
                        .font(.title3).fontWeight(.medium)
                    
                    Text("Normal party clothes, neon if possible")
                        .font(.headline)
                        .foregroundColor(.secondary)
                        .lineLimit(4)
                }
                
                VStack(alignment: .leading) {
                    Text("Note for guest:")
                        .font(.title3).fontWeight(.medium)
                    
                    Text("N/A")
                        .font(.headline)
                        .foregroundColor(.secondary)
                        .lineLimit(4)
                }
                
                
                VStack(alignment: .leading, spacing: 10) {
                    Text("Event Flyer:")
                        .font(.title3).fontWeight(.medium)
                    
//                    Image(uiImage: $viewModel.flyer)
//                        .resizable()
//                        .aspectRatio(contentMode: .fit)
//                        .cornerRadius(20)
//                        .frame(width: 208, height: 250, alignment: .center)
//                        .frame(maxWidth: .infinity, alignment: .center)
//                        .padding()
                }
                
                VStack(alignment: .center) { NextButton(text: "Create Event", action: viewModel.createEvent) }
            }
            .padding()
        }
        .background(Color.mixerBackground.ignoresSafeArea())
    }
}

struct ReviewCreatedEventView_Previews: PreviewProvider {
    static var previews: some View {
        ReviewCreatedEventView(viewModel: CreateEventViewModel())
            .preferredColorScheme(.dark)
    }
}

struct reviewDetailRow: View {
    var title: String
    var value: String
    var body: some View {
        HStack {
            Text("\(title):")
                .font(.title3).fontWeight(.medium)
            
            Text(value)
                .font(.headline)
                .foregroundColor(.secondary)
        }
    }
}
