//
//  CustomDateSelector.swift
//  mixer
//
//  Created by Peyton Lyons on 9/9/23.
//

import SwiftUI

struct CustomDateSelector: View {
    let text: String
    @Binding var date: Date
    let range: ClosedRange<Date>
    
    var body: some View {
        HStack(alignment: .center, spacing: 0) {
            Text(text)
                .font(.title3)
                .fontWeight(.medium)
                .lineLimit(1)
                .minimumScaleFactor(0.95)
            
            Spacer()
            
            DatePicker("", selection: $date,
                       in: range,
                       displayedComponents: [.date, .hourAndMinute])
            .datePickerStyle(.compact)
            .labelsHidden()
        }
        .padding()
        .background(alignment: .center) {
            RoundedRectangle(cornerRadius: 9)
                .stroke(lineWidth: 1)
                .foregroundColor(Color.theme.mixerIndigo)
        }
    }
}
