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
    @State private var isWithoutUniversity: Bool = false
    @StateObject private var universitySearchViewModel = UniversitySearchViewModel()
    @State private var showInviteAlert: Bool = false
    @State private var selectedUser: SearchItem? = nil

    var body: some View {
        ZStack {
            Color.theme.backgroundColor
                .ignoresSafeArea()
            
            List {
                guestTypePicker
                
                if viewModel.guestEntryType != .username {
                    guestDetailsSection
                    universitySection
                    optionalDetailsSection
                } else {
                    userSearchSection
                }
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
        .sheet(isPresented: $viewModel.isShowingUniversityInputSheet) {
            UniversitySearchModalView(viewModel: universitySearchViewModel,
                                      dismissSheet: $viewModel.isShowingUniversityInputSheet, action: viewModel.selectUniversity(_:))
        }
        .fullScreenCover(isPresented: $viewModel.isShowingUsernameInputSheet) {
            NavigationStack {
                ZStack {
                    Color.theme.backgroundColor
                        .ignoresSafeArea()
                    
                    List(viewModel.userResults) { result in
                        if !viewModel.searchText.isEmpty {
                            ItemInfoCell(title: result.title,
                                         subtitle: "@\(result.subtitle)",
                                         imageUrl: result.imageUrl)
                            .onTapGesture {
                                self.selectedUser = result
                                self.showInviteAlert = true
                            }
                            .listRowBackground(Color.theme.secondaryBackgroundColor)
                            .alert(isPresented: $showInviteAlert) {
                                // Safely unwrap selectedMember within the alert
                                if let user = selectedUser {
                                    return Alert(
                                        title: Text("Invite \(user.title) to event"),
                                        primaryButton: .default(Text("Yes"), action: {
//                                            viewModel.inviteMember(with: user.subtitle)
                                            viewModel.isShowingUsernameInputSheet = false
                                        }),
                                        secondaryButton: .cancel()
                                    )
                                } else {
                                    return Alert(title: Text("Error"), message: Text("Something went wrong. Please try again."))
                                }
                            }
                        }
                    }
                    .scrollContentBackground(.hidden)
                    .listStyle(.insetGrouped)
                    .searchable(text: $viewModel.searchText)
                    .navigationTitle("Search Users")
                }
            }
            .overlay(alignment: .topTrailing) {
                XDismissButton { viewModel.isShowingUsernameInputSheet = false }
                    .padding()
            }
        }
    }
    
    private var guestTypePicker: some View {
        Section(header: Text("Entry Type").fontWeight(.semibold)) {
            Picker("", selection: $viewModel.guestEntryType) {
                ForEach(GuestEntryType.allCases, id: \.self) { type in
                        Text(type.pickerTitle)
                            .tag(type.rawValue)
                }
            }
            .pickerStyle(.segmented)
            
            Picker("", selection: $viewModel.status) {
                ForEach(GuestStatus.allCases, id: \.self) { status in
                    if status != .requested {
                        Text(status.pickerTitle)
                            .tag(status.rawValue)
                    }
                }
            }
            .pickerStyle(.segmented)
        }
        .listRowBackground(Color.theme.secondaryBackgroundColor)
    }

    private var userSearchSection: some View {
        Section(header: Text("Username").fontWeight(.semibold),
                footer: Text("If user doesn't have a mixer account, choose manual")) {
            HStack {
                Image(systemName: "text.magnifyingglass")
                    .imageScale(.small)
                    .foregroundColor(Color.secondary)

                Text("Tap to search user")
                    .foregroundColor(.white)
                
                Spacer()
            }
            .contentShape(Rectangle())
            .onTapGesture {
                viewModel.isShowingUsernameInputSheet = true
            }
        }
        .listRowBackground(Color.theme.secondaryBackgroundColor)
    }

    private var guestDetailsSection: some View {
        Section(header: Text("Guest Details").fontWeight(.semibold)) {
            TextField("Name", text: $viewModel.name)
                .disabled(viewModel.username != "")

            genderField
        }
        .listRowBackground(Color.theme.secondaryBackgroundColor)
    }
    
    private var universitySection: some View {
        Section(header: Text("University Details").fontWeight(.semibold)) {
            HStack {
                Toggle("No university?", isOn: $isWithoutUniversity)
                    .toggleStyle(.switch)
                    .buttonStyle(.plain)
                    .onChange(of: isWithoutUniversity) { newValue in
                        if newValue {
                            let university = University(id: "com",
                                                        domain: ".com",
                                                        name: "Non-university",
                                                        shortName: "Non-university",
                                                        url: "https://www.partywithmixer.com")
                            viewModel.selectUniversity(university)
                        }
                    }
                
                Spacer()
            }
            
            if !isWithoutUniversity {
                HStack {
                    Image(systemName: "text.magnifyingglass")
                        .imageScale(.small)
                        .foregroundColor(Color.secondary)
                    
                    Text("Tap to search universities")
                        .foregroundColor(.white)
                    
                    Spacer()
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    viewModel.isShowingUniversityInputSheet = true
                }
            }
            
            if viewModel.universityName != "" && !isWithoutUniversity  {
                Text(viewModel.universityName)
                    .foregroundStyle(.secondary)
            }
        }
        .listRowBackground(Color.theme.secondaryBackgroundColor)
    }

    private var optionalDetailsSection: some View {
        Section(header: Text("Optional Details").fontWeight(.semibold)) {
            Stepper("Age: \(viewModel.age)", value: $viewModel.age, in: 17...100)
                .disabled(viewModel.username != "")
            
            VStack {
                TextField("You can optionally add a note here ...", text: $viewModel.note, axis: .vertical)
                    .lineLimit(4, reservesSpace: true)
                    .frame(alignment: .leading)
                
                HStack {
                    CharactersRemainView(currentCount: viewModel.note.count,
                                         limit: 100)
                    
                    Spacer()
                }
            }
        }
        .listRowBackground(Color.theme.secondaryBackgroundColor)
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
