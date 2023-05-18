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
    @State var university: UniversityExamples = .mit
    @State var universityName: String = "" // New state variable to hold the user's input for the university name
    @State var status: GuestStatus = .invited
    @State var gender: Gender      = .preferNot
    @State var age: Int            = 17
    @Environment(\.presentationMode) var mode


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
        
        var icon: String {
            switch(self) {
                case .male: return "human-male"
                case .female: return "human-female"
                default: return ""
            }
        }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                List {
                    Section {
                        TextField("Name", text: $name)
                            .foregroundColor(Color.mainFont)
                            .autocorrectionDisabled()
                        
                        HStack {
                            Text(university == UniversityExamples.other ? universityName : university.rawValue)

                            Spacer()

                            Menu("Select School") {
                                ForEach(UniversityExamples.allCases, id: \.self) { university in
                                    Button(university.rawValue) {
                                        self.university = university
                                    }
                                }
                            }
                            .accentColor(.mixerIndigo)
                        }
                        .listRowBackground(Color.mixerSecondaryBackground)
                        
                        if university == .other {
                            TextField("School Name", text: $universityName, axis: .vertical)
                                .foregroundColor(Color.mainFont)
                                .autocorrectionDisabled()
                        }
                        
                        HStack {
                            Text(gender.rawValue)
                            
                            Spacer()
                            
                            Menu("Select Gender") {
                                ForEach(Gender.allCases, id: \.self) { gender in
                                    Button(gender.rawValue) {
                                        self.gender = gender
                                    }
                                }
                            }
                            .accentColor(.mixerIndigo)
                        }
                    } header: {
                        Text("Guest Details")
                            .fontWeight(.semibold)
                    }
                    .listRowBackground(Color.mixerSecondaryBackground)
                    
                    Section {
                        Stepper("Age: \(age == 17 ? "N/A" : String(age))", value: $age, in: 17...100)
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
            .navigationTitle("Add Guest")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        viewModel.createGuest(name: name,
                                              university: university == .other ? universityName : university.rawValue, // Update university based on user input
                                              status: status,
                                              age: age,
                                              gender: gender.rawValue)
                        
                        showAddGuestView.toggle()
                    }, label: {
                        Text("Submit")
                            .foregroundColor(.blue)
                            .bold()
                    })
                }
                
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(role: .cancel, action: {
                        withAnimation() {
                            mode.wrappedValue.dismiss()
                        }
                    }, label: {
                        Text("Cancel")
                            .foregroundColor(.secondary)
                    })
                }
            }
            .preferredColorScheme(.dark)
        }
    }
}
