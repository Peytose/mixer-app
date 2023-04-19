//
//  AddToGuestlistView.swift
//  mixer
//
//  Created by Jose Martinez on 10/10/22.
//

import SwiftUI

struct AddToGuestlistView: View {
    @ObservedObject var viewModel: GuestlistViewModel
    @Binding var showAddGuestView: Bool
    @State var name: String = ""
    @State var email: String = ""
    @State var university: UniversityExamples = .mit
    @State var universityName: String = "" // New state variable to hold the user's input for the university name
    @State var status: GuestStatus = .invited
    @State var gender: Gender      = .preferNot
    @State var age: Int            = 19
    
    enum UniversityExamples: String, CaseIterable {
        case mit = "MIT"
        case neu = "NEU"
        case bu = "BU"
        case harvard = "Harvard"
        case bc = "BC"
        case tufts = "Tufts"
        case simmons = "Simmons"
        case wellesley = "Wellesley"
        case berklee = "Berklee College of Music"
        case other = "Other"
    }
    
    enum Gender: String, CaseIterable {
        case male      = "Male"
        case female    = "Female"
        case other     = "Other"
        case preferNot = "Prefer not to say"
    }
    
    var body: some View {
        ZStack {
            List {
                Section {
                    TextField("Guest name", text: $name)
                        .foregroundColor(Color.mainFont)
                    
                    TextField("Guest email", text: $email)
                        .foregroundColor(Color.mainFont)
                } header: {
                    Text("Guest Details")
                        .fontWeight(.semibold)
                }
                .listRowBackground(Color.mixerSecondaryBackground)
                
                Section {
                    Picker("University", selection: $university) {
                        ForEach(UniversityExamples.allCases, id: \.self) { university in
                            Text(university.rawValue)
                                .tag(university)
                        }
                    }
                    .pickerStyle(.menu)
                    
                    if university == .other {
                        TextField("School Name", text: $universityName, axis: .vertical) // Bind to the new variable
                            .foregroundColor(Color.mainFont)
                    }
                } header: {
                    Text("Extra Details")
                        .fontWeight(.semibold)
                }
                .listRowBackground(Color.mixerSecondaryBackground)
                
                Section {
                    Stepper("Age: \(age)", value: $age, in: 16...100)
                    
                    Picker("Gender", selection: $gender) {
                        ForEach(Gender.allCases, id: \.self) { gender in
                            Text(gender.rawValue)
                                .tag(gender)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                } header: {
                    Text("Optional Details")
                        .fontWeight(.semibold)
                }
                .listRowBackground(Color.mixerSecondaryBackground)
                
                Section {
                    Picker("Are you adding the guest to the guestlist or checking them in?", selection: $status) {
                        ForEach(GuestStatus.allCases, id: \.self) { option in
                            Text(option == GuestStatus.invited ? "Guestlist" : "Check-in")
                                .tag(option)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                } header: {
                    Text("Optional Details")
                        .fontWeight(.semibold)
                }
                .listRowBackground(Color.mixerSecondaryBackground)
                
                Section {
                    // Section to separate button
                    Section{}.listRowBackground(Color.clear)
                }
            }
            .scrollContentBackground(.hidden)
        }
        .background(Color.mixerBackground.edgesIgnoringSafeArea(.all))
        .overlay(alignment: .bottom) {
            CreateEventNextButton(text: "Add", action: {
                viewModel.createGuest(name: name,
                                      email: email,
                                      university: university == .other ? universityName : university.rawValue, // Update university based on user input
                                      status: status,
                                      age: age,
                                      gender: gender.rawValue)
                
                showAddGuestView.toggle()
            }, isActive: true)
        }
        .preferredColorScheme(.dark)
    }
}
