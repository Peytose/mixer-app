//
//  GuestlistEntryForm.swift
//  mixer
//
//  Created by Jose Martinez on 10/10/22.
//

import SwiftUI

struct GuestlistEntryForm: View {
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
            }
            .scrollContentBackground(.hidden)
        }
        .navigationBar(title: "Add Guest", displayMode: .inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                PresentationBackArrowButton()
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

    private var statusPicker: some View {
        Section(header: Text("Status").fontWeight(.semibold)) {
            Picker("", selection: $viewModel.status) {
                ForEach(GuestStatus.allCases, id: \.self) { status in
                    Text(status.description)
                }
            }
            .pickerStyle(.segmented)
        }
        .listRowBackground(Color.theme.secondaryBackgroundColor)
    }

    private var userSearchSection: some View {
        Section(header: Text("Username").fontWeight(.semibold),
                footer: Text("If user doesn't have a mixer account, continue below")) {
            TextField("Enter a user's username ...", text: $viewModel.username)
                .foregroundColor(.white)
                .autocorrectionDisabled()
                .disabled(viewModel.name != "")
        }
        .listRowBackground(Color.theme.secondaryBackgroundColor)
    }

    private var guestDetailsSection: some View {
        Section(header: Text("Guest Details").fontWeight(.semibold)) {
            TextField("Name", text: $viewModel.name)
                .disabled(viewModel.username != "")
            
//            HStack {
//                Text(viewModel.university == .other ? viewModel.customUniversity : viewModel.university.rawValue)
//                Spacer()
//                universityMenu
//            }
//            
//            if viewModel.university == .other {
//                TextField("School Name", text: $viewModel.customUniversity)
//                    .disabled(viewModel.username != "")
//            }
            
            genderField
        }
        .listRowBackground(Color.theme.secondaryBackgroundColor)
    }

    private var optionalDetailsSection: some View {
        Section(header: Text("Optional Details").fontWeight(.semibold)) {
            Stepper("Age: \(viewModel.age)", value: $viewModel.age, in: 17...100)
                .disabled(viewModel.username != "")
        }
        .listRowBackground(Color.theme.secondaryBackgroundColor)
    }

    private var universityMenu: some View {
        Menu("Select School") {
//            ForEach(UniversityExamples.allCases, id: \.self) { university in
//                Button(university.rawValue) {
//                    viewModel.university = university
//                }
//            }
        }
        .menuTextStyle()
        .disabled(viewModel.username != "")
    }

    private var genderField: some View {
        HStack {
            Text(viewModel.gender.description)
            Spacer()
            Menu("Select Gender") {
                ForEach(Gender.allCases, id: \.self) { gender in
                    Button(gender.description) {
                        viewModel.gender = gender
                    }
                }
            }
            .accentColor(Color.theme.mixerIndigo)
            .disabled(viewModel.username != "")
        }
    }
}