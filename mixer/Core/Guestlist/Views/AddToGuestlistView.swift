//
//  AddToGuestlistView.swift
//  mixer
//
//  Created by Jose Martinez on 10/10/22.
//

import SwiftUI

struct AddToGuestlistView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var viewModel: GuestlistViewModel

    var body: some View {
        ZStack {
            Color.theme.backgroundColor
                .ignoresSafeArea()
            
            List {
                statusPicker
                
                userSearchSection
                
                guestDetailsSection
                
                optionalDetailsSection
                
                Section{}.listRowBackground(Color.clear)
            }
            .scrollContentBackground(.hidden)
        }
        .navigationBar(title: "Add Guest", displayMode: .inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                BackArrowButton()
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    viewModel.createGuest()
                    dismiss()
                } label: {
                    Text("Submit")
                        .foregroundColor(Color.theme.mixerIndigo)
                        .bold()
                }
            }
        }
    }
}

private extension AddToGuestlistView {
    var userSearchSection: some View {
        Section {
            TextField("Enter a user's username ...", text: $viewModel.username)
                .foregroundColor(.white)
                .autocorrectionDisabled()
                .disabled(viewModel.name != "")
        } header: {
            Text("Username")
                .fontWeight(.semibold)
        } footer: {
            Text("If user doesn't have a mixer account, continue below")
        }
        .listRowBackground(Color.theme.secondaryBackgroundColor)
    }
    
    var guestDetailsSection: some View {
        Section {
            guestNameField
            
            universityField
            
            if viewModel.university == .other {
                customUniversityField
            }
            
            genderField
        } header: {
            Text("Guest Details")
                .fontWeight(.semibold)
        }
        .listRowBackground(Color.theme.secondaryBackgroundColor)
    }
    
    var optionalDetailsSection: some View {
        Section {
            Stepper("Age: \(viewModel.age)", value: $viewModel.age, in: 17...100)
                .disabled(viewModel.username != "")
        } header: {
            Text("Optional Details")
                .fontWeight(.semibold)
        }
        .listRowBackground(Color.theme.secondaryBackgroundColor)
    }

    var guestNameField: some View {
        TextField("Name", text: $viewModel.name)
            .foregroundColor(.white)
            .autocorrectionDisabled()
            .disabled(viewModel.username != "")
    }
    
    var universityField: some View {
        HStack {
            Text(viewModel.university == UniversityExamples.other ? viewModel.customUniversity : viewModel.university.rawValue)

            Spacer()

            Menu("Select School") {
                ForEach(UniversityExamples.allCases, id: \.self) { university in
                    Button(university.rawValue) {
                        viewModel.university = university
                    }
                }
            }
            .menuTextStyle()
            .disabled(viewModel.username != "")
        }
    }
    
    var customUniversityField: some View {
        TextField("School Name", text: $viewModel.customUniversity)
            .foregroundColor(.white)
            .autocorrectionDisabled()
            .disabled(viewModel.username != "")
    }
    
    var genderField: some View {
        HStack {
            Text(viewModel.gender.stringVal)
            
            Spacer()
            
            Menu("Select Gender") {
                ForEach(Gender.allCases, id: \.self) { gender in
                    Button(gender.stringVal) {
                        viewModel.gender = gender
                    }
                }
            }
            .accentColor(Color.theme.mixerIndigo)
            .disabled(viewModel.username != "")
        }
    }
    
    var statusPicker: some View {
        Section {
            Picker("", selection: $viewModel.status) {
                ForEach(GuestStatus.allCases, id: \.self) { status in
                    Text(status.stringVal)
                        .tag(status)
                }
            }
            .pickerStyle(.segmented)
        } header: {
            Text("Status")
                .fontWeight(.semibold)
        }
        .listRowBackground(Color.theme.secondaryBackgroundColor)
    }
}
