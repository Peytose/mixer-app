//
//  GuestlistPDF.swift
//  mixer
//
//  Created by Peyton Lyons on 8/29/23.
//

import SwiftUI

struct GuestlistPDF: View {
    let event: Event
    let guests: [EventGuest]
    
    var body: some View {
        VStack {
            headerView
            guestListView
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.theme.backgroundColor)
    }
    
    private var headerView: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Guestlist for \(event.title)")
                .font(.title)
                .fontWeight(.bold)
            
            Text("Hosted by \(event.hostNames.joined(separator: ", "))")
                .fontWeight(.semibold)
            
            HStack {
                Text("Started: \(event.startDate.getTimestampString(format: "MM-dd-yyyy h:mm a"))")
                Spacer()
                Text("Ended: \(event.endDate.getTimestampString(format: "MM-dd-yyyy h:mm a"))")
            }
            .font(.caption)
        }
        .foregroundStyle(.white)

    }
    
    private var guestListView: some View {
        VStack {
            ForEach(guests) { guest in
                if let index = guests.firstIndex(where: { $0.id == guest.id }) {
                    guestRow(for: guest, at: index)
                }
            }
            .foregroundStyle(.white)
        }
        .listStyle(.grouped)
        .scrollContentBackground(.hidden)

    }
    
    
    private func guestRow(for guest: EventGuest, at index: Int) -> some View {
        HStack(alignment: .top) {
            Text("\(index + 1).")
                .fontWeight(.bold)
            
            VStack(alignment: .leading) {
                HStack(alignment: .top) {
                    Text(guest.name)
                        .fontWeight(.semibold)
                    
                    Spacer()
                    
                    if let timestamp = guest.timestamp {
                        if timestamp > event.endDate {
                            Text("(\(timestamp.getTimestampString(format: "MM-dd")))")
                                .foregroundColor(.red)
                            
                                .font(.footnote)
                        }
                        
                        Text("Check in: \(timestamp.getTimestampString(format: "h:mm a"))")
                            .foregroundColor(timestamp > event.endDate ? .red : .white)
                            .font(.footnote)
                        
                    }
                }
                
                HStack {
                    if let age = guest.age {
                        Text("Age: \(age)")
                            .font(.caption)
                    }
                    
                    if let email = guest.email {
                        Text("Email: \(email)")
                            .font(.caption)
                    }
                    
                    if let university = guest.university {
                        Text("University: \(university.name)")
                            .font(.caption)
                    }
                }
            }
        }
        .padding()
        .background {
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.theme.secondaryBackgroundColor)
        }
        .lineLimit(1)
        .minimumScaleFactor(0.9)
    }
    
    private func attendanceStatus(for timestamp: Date, comparedTo eventEndDate: Date) -> some View {
        Text(timestamp > eventEndDate ? "Late" : "On Time")
            .foregroundColor(timestamp > eventEndDate ? .red : .green)
            .font(.caption)
            .padding(4)
            .background(timestamp > eventEndDate ? Color.red.opacity(0.1) : Color.green.opacity(0.1))
            .cornerRadius(4)
    }
}


struct GuestlistPDF_Previews: PreviewProvider {
    static var previews: some View {
        GuestlistPDF(event: dev.mockEvent, guests: [EventGuest(name: "Jose Martinez", universityId: "com", email: "jose.martinez", age: 1, gender: .man),EventGuest(name: "Peyton Lyons", universityId: "com", age: 1, gender: .man)])
    }
}
