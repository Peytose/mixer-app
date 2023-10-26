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
            Text("Hosted by \(event.hostNames.joinedWithCommasAndAnd())")
            
            HStack {
                Text("STARTED: \(event.startDate.getTimestampString(format: "MM-dd-yyyy h:mm a"))")
                
                Spacer()
                
                Text("ENDED: \(event.endDate.getTimestampString(format: "MM-dd-yyyy h:mm a"))")
            }
            
            ForEach(guests) { guest in
                HStack {
                    if let index = guests.firstIndex(where: { guest.id == $0.id }) {
                        Text("(\(index + 1).)")
                    }
                    
                    Text(guest.name)

                    if let age = guest.age {
                        Text("\(age)")
                    }
                    
                    if let email = guest.email {
                        Text(email)
                    }
                    
                    if let university = guest.university {
                        Text(university.name)
                    }
                    
                    if let timestamp = guest.timestamp {
                        if timestamp > event.endDate {
                            Text("(\(timestamp.getTimestampString(format: "MM-dd")))")
                                .foregroundColor(.red)
                        }
                        
                        Text(timestamp.getTimestampString(format: "h:mm a"))
                            .foregroundColor(timestamp > event.endDate ? .red : .black)
                    }
                }
            }
        }
    }
}
