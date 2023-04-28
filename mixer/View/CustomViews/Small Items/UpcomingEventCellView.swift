//
//  UpcomingEventCellView.swift
//  mixer
//
//  Created by Jose Martinez on 3/14/23.
//

import SwiftUI

struct UpcomingEventCellView: View {
    var title: String
    var duration: String
    var visibility: String
    var dateMonth: String
    var dateNumber: String
    var dateDay: String
    
    var body: some View {
        HStack(spacing: 20) {
            dateCell
            
            cellInfo
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .preferredColorScheme(.dark)
    }
    
    var dateCell: some View {
        VStack {
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.mixerSecondaryBackground)
                .frame(width: 60, height: 75)
                .overlay(alignment: .bottom) {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.gray.opacity(0.1))
                        .frame(width: 65, height: 20)
                        .overlay {
                            Text(dateDay)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                }
                .overlay {
                    Text(dateNumber)
                        .font(.title3.weight(.bold))
                }
                .overlay(alignment: .top) {
                    Text(dateMonth)
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundColor(.secondary)
                        .padding(.top, 4)
                }
        }
    }
    
    var cellInfo: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.title3)
                .fontWeight(.regular)
                .foregroundColor(.DesignCodeWhite)
            
            Text(duration)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Text("\(Image(systemName: "globe")) \(visibility)")
                .font(.subheadline)
                .foregroundColor(Color.mixerIndigo)
            
        }
    }
}

struct UpcomingEventCellView_Previews: PreviewProvider {
    static var previews: some View {
        UpcomingEventCellView(title: "Neon Party", duration: "10:00 PM - 1:00 PM", visibility: "Open Event", dateMonth: "Mar", dateNumber: "15", dateDay: "Fri")
    }
}

//private struct DateCell: View {
//    var body: some View {
//        VStack {
//            RoundedRectangle(cornerRadius: 12)
//                .fill(Color.mixerSecondaryBackground)
//                .frame(width: 80, height: 90)
//                .overlay(alignment: .bottom) {
//                    RoundedRectangle(cornerRadius: 12)
//                        .fill(Color.gray.opacity(0.1))
//                        .frame(width: 80, height: 25)
//                        .overlay {
//                            Text("Fri")
//                                .foregroundColor(.secondary)
//                        }
//                }
//                .overlay {
//
//                        Text("15")
//                            .font(.title.weight(.bold))
//                }
//                .overlay(alignment: .top) {
//
//                        Text("MAR")
//                        .fontWeight(.bold)
//                        .foregroundColor(.secondary)
//                        .padding(.top, 5)
//                }
//        }
//    }
//}

//private struct CellInfo: View {
//    var body: some View {
//        VStack(alignment: .leading, spacing: 4) {
//            Text("Neon Party")
//                .font(.title2.weight(.medium))
//
//            Text("10:00 PM - 1:00 AM")
//
//                .foregroundColor(.secondary)
//            Text("\(Image(systemName: "globe")) Open Event")
//                .foregroundColor(Color.mixerIndigo)
//
//        }
//    }
//}
