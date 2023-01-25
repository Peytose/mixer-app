//
//  EventRowView.swift
//  mixer
//
//  Created by Jose Martinez on 1/12/23.
//
import SwiftUI

struct EventRow: View {
    var flyer: String
    var title: String
    var date: String
    var attendance: String
    
    var body: some View {
        VStack(alignment: .leading) {
            
            HStack(spacing: 15) {
                Image(flyer)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 50, height: 50)
                    .clipShape(RoundedRectangle(cornerRadius: 4))
                
                VStack(alignment: .leading) {
                        Text(title)
                            .fontWeight(.semibold)

                    
                    HStack {
                        Text(date)
                            .font(.callout.weight(.semibold))
                            .foregroundColor(.secondary)
                        
                        HStack(spacing: 2) {
                            Image(systemName: "person.3.fill")
                                .imageScale(.small)
                                .symbolRenderingMode(.hierarchical)
                            
                            Text(attendance)
                                .font(.callout)
                                .fontWeight(.semibold)
                                .foregroundColor(.secondary)
                        }
                    }
                    Divider()

                }
                .lineLimit(1)
                .minimumScaleFactor(0.75)
                
                Spacer()
            }
        }
        .frame(height: 60)
    }
}
