//
//  EditEventDateView.swift
//  mixer
//
//  Created by Jose Martinez on 11/17/23.
//

import SwiftUI

struct EditEventDateView: View {
    @State private var startDate = Date.now
    @State private var endDate = Date.now

    var body: some View {
        List {
            dateAndTimeSection
            
            selectedDate
        }
        .scrollContentBackground(.hidden)
        .scrollIndicators(.hidden)
        .listStyle(.insetGrouped)
        .background(Color.theme.backgroundColor)
        .navigationBar(title: "Edit Event Date", displayMode: .inline)
    }
}

extension EditEventDateView {
    var dateAndTimeSection: some View {
        SettingsSectionContainer(header: "Date & Time") {
            DatePicker(selection: $startDate, in: ...Date.now, displayedComponents: [.date, .hourAndMinute]) {
                Text("Start Time")
            }
            DatePicker(selection: $endDate, in: ...Date.now, displayedComponents: [.date, .hourAndMinute]) {
                Text("End Time")
            }
        }
    }
    
    var selectedDate: some View {
        SettingsSectionContainer(header: "Start Date") {
            Text("\(Text("Starts: ").fontWeight(.bold)) \(startDate.formatted(date: .long, time: .shortened))")
            Text("\(Text("Ends: ").fontWeight(.bold)) \(endDate.formatted(date: .long, time: .shortened))")
        }
    }
}

#Preview {
    EditEventDateView()
}
