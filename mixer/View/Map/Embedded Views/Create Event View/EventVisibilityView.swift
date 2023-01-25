//
//  EventVisibilityView.swift
//  mixer
//
//  Created by Jose Martinez on 12/22/22.
//


import SwiftUI

struct EventVisibilityView: View {
    @StateObject var viewModel = CreateEventViewModel()
    @Environment(\.presentationMode) var presentationMode
    
    var colors = ["Invite Only", "Green", "Blue", "Tartan"]
    @State private var selectedColor = "Invite Only"
    
    var body: some View {
        ZStack {
            Color.mixerBackground
                .ignoresSafeArea()
            
            VStack {
                
                visibilityToggle
                
                VStack(alignment: .leading, spacing: 20) {
                    Text("Invite only Event Description")
                        .font(.title).bold()
                        .padding(.bottom, -15)
                    
                    Text(viewModel.isPrivate == .yes ? "Only invited attendees can view and attend a Private Party" : "Anyone can view a Public Party and join its guestlist")
                        .font(.title3).fontWeight(.medium)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(EdgeInsets(top: 0, leading: 21, bottom: 0, trailing: 10))
                
                List {
                    if viewModel.isPrivate == .yes {
                        includeInviteListSection
                        inviteLimitSection
                        
                        guestInviteLimitSection
                    } else {
                        includeInviteListSection
                        
                        if viewModel.includeInviteList {
                            inviteLimitSection
                            
                            guestInviteLimitSection
                        }
                    }
                    
                }
                .tint(.mixerIndigo)
                .preferredColorScheme(.dark)
                .scrollContentBackground(.hidden)
            }
        }
        .overlay(alignment: .bottom, content: {
            NavigationLink(destination: EventFlyerUploadView()) {
                NextButton()
            }
        })
        .navigationBarTitle(Text("Event Settings"), displayMode: .large)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }, label: {
                    BackArrowButton()
                })
            }
        }
    }
    
    var visibilityToggle: some View {
        Picker("Invite only", selection: self.$viewModel.isPrivate.animation()) {
            Text("Public").tag(isPrivate.no)
            Text("Private").tag(isPrivate.yes)
        }
        .pickerStyle(.segmented)
        .padding()
    }
    
    var includeInviteListSection: some View {
        Section {
            Toggle("Invite List?", isOn: $viewModel.includeInviteList.animation())
                .font(.body.weight(.semibold))
        } header: {
            Text("Include Invite List")
        }
        .listRowBackground(Color.mixerSecondaryBackground)
    }
    
    var inviteLimitSection: some View {
        Section {
            Toggle("Invite Limit?", isOn: $viewModel.isInviteLimit.animation())
                .font(.body.weight(.semibold))
            
            if viewModel.isInviteLimit == true {
                TextField("Invites per brother*", text: $viewModel.guestLimit)
                    .foregroundColor(Color.mainFont)
                    .keyboardType(.numberPad)
            }
        } header: {
            Text("Maximum Invites")
        }
        .listRowBackground(Color.mixerSecondaryBackground)
    }
    
    var guestInviteLimitSection: some View {
        Section {
            Toggle("Allow guests to invite guests?", isOn: $viewModel.isGuestInviteLimit.animation())
                .font(.body.weight(.semibold))
            
            if viewModel.isGuestInviteLimit {
                TextField("Invites per Guest*", text: $viewModel.guestLimitForGuests)
                    .foregroundColor(Color.mainFont)
                    .keyboardType(.numberPad)
            }
        } header: {
            Text("Maximum Guest Invites")
        }
        .listRowBackground(Color.mixerSecondaryBackground)
    }
    
}


struct EventVisibilityView_Previews: PreviewProvider {
    static var previews: some View {
        EventVisibilityView()
    }
}

