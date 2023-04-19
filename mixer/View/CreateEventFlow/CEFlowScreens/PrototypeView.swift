//
//  EventGuestsAndInvitations.swift
//  mixer
//
//  Created by Jose Martinez on 4/7/23.
//

import SwiftUI

struct EventGuestsAndInvitations: View {
    @Binding var selectedVisibility: CreateEventViewModel.VisibilityType
    @Binding var selectedInvitePreferrence: CreateEventViewModel.InvitePreferrence
    @Binding var selectedCheckInMethod: CheckInMethod
    
    //Values
    @Binding var guestLimit: String
    @Binding var guestInviteLimit: String
    @Binding var memberInviteLimit: String
    
    //Alert bools
    @Binding var alertItem: AlertItem?
    
    //Toggle bools
    @Binding var useGuestList: Bool
    @Binding var isGuestLimit: Bool
    @Binding var isMemberInviteLimit: Bool
    @Binding var isGuestInviteLimit: Bool
    @Binding var manuallyApproveGuests: Bool
    @Binding var enableWaitlist: Bool
    @Binding var registrationcutoff: Bool
    let action: () -> Void
    
    var body: some View {
        ScrollView {
            VStack {
                VStack(alignment: .leading, spacing: 10) {
                    HStack(spacing: 10) {
                        Text(selectedVisibility == ._public ? "Open Event" : "Private Event")
                            .font(.title).bold()
                        
                        Image(systemName: selectedCheckInMethod == .qrCode ? "qrcode" : "rectangle.and.pencil.and.ellipsis")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 18, height: 18)
                        
                        Spacer()
                        
                        Menu("Choose preset") {
                            Button("Just post it") {
                                setDefaultOptions(visibility: ._public, invitePreference: .open, checkInMethod: .manual, useGuestList: false)
                            }
                            
                            Button("Public Open Party") {
                                setDefaultOptions(visibility: ._public, invitePreference: .open, checkInMethod: .qrCode, useGuestList: true)
                            }
                            
                            Button("Public Invite Only Party") {
                                setDefaultOptions(visibility: ._public, invitePreference: .inviteOnly, checkInMethod: .qrCode, useGuestList: true)
                            }
                            
                            Button("Private Open Party") {
                                setDefaultOptions(visibility: ._private, invitePreference: .open, checkInMethod: .qrCode, useGuestList: true)
                            }
                            
                            Button("Private Invite Only Party") {
                                setDefaultOptions(visibility: ._private, invitePreference: .inviteOnly, checkInMethod: .qrCode, useGuestList: true)
                            }
                        }
                        .accentColor(.mixerIndigo)
                        .fontWeight(.medium)
                    }
                    
                    Text("\(selectedVisibility == ._public ? "Everyone" : "Only invited users") can see this event. " +
                         "\(selectedInvitePreferrence == .open ? "Anyone" : "Only users on the guest list") can check in to this event and see its details" +
                         "\(selectedCheckInMethod == .qrCode ? " and check-in will be handled via QR Code." : " and check-in will be handled manually by the host.")")
                    .font(.title3)
                    .fontWeight(.medium)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
                
                VStack {
                    HStack(spacing: 5) {
                        InfoButton(action: { alertItem = AlertContext.eventVisiblityInfo })
                        
                        Picker("", selection: $selectedVisibility.animation()) {
                            Text("Public").tag(CreateEventViewModel.VisibilityType._public)
                            Text("Private").tag(CreateEventViewModel.VisibilityType._private)
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        .padding(.trailing)
                    }
                    
                    HStack(spacing: 5) {
                        InfoButton(action: { alertItem = AlertContext.invitePreferrenceInfo })
                        
                        Picker("", selection: $selectedInvitePreferrence.animation()) {
                            Text("Open").tag(CreateEventViewModel.InvitePreferrence.open)
                            Text("Invite Only").tag(CreateEventViewModel.InvitePreferrence.inviteOnly)
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        .padding(.trailing)
                    }
                    
                    HStack(spacing: 5) {
                        InfoButton(action: { alertItem = AlertContext.checkInMethodInfo })
                        
                        Picker("", selection: $selectedCheckInMethod.animation()) {
                            Text("Manual").tag(CheckInMethod.manual)
                            Text("QR Code").tag(CheckInMethod.qrCode)
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        .padding(.trailing)
                    }
                    .onChange(of: selectedCheckInMethod) { newValue in
                        useGuestList = newValue == .qrCode
                    }
                }
                
                List {
                    Section {
                        HStack {
                            InfoButton(action: { alertItem = AlertContext.guestlistInfo})
                            
                            Toggle("Use guestlist", isOn: $useGuestList.animation())
                                .font(.body.weight(.semibold))
                        }
                        
                        if useGuestList {
                            HStack {
                                InfoButton(action: { alertItem = AlertContext.guestLimitInfo })
                                
                                Toggle("Set guest limit", isOn: $isGuestLimit.animation())
                                    .font(.body.weight(.semibold))
                            }
                            
                            if isGuestLimit {
                                TextField("Maximum guests", text: $guestLimit)
                                    .foregroundColor(Color.mainFont)
                                    .keyboardType(.numberPad)
                            }
                        }
                    } header: { Text("Guestlist Settings") }
                        .listRowBackground(Color.mixerSecondaryBackground)
                    
                    if useGuestList {
                        inviteLimitsSection
                        
                        advancedSettingsSection
                    }
                }
                .scrollContentBackground(.hidden)
                .tint(.mixerIndigo)
                .onTapGesture {
                    self.hideKeyboard()
                }
                
                CreateEventNextButton(text: "Continue", action: action, isActive: true)
            }
            .frame(maxHeight: .infinity, alignment: .topLeading)
            .frame(height: DeviceTypes.ScreenSize.height)
        }
        .background(Color.mixerBackground.edgesIgnoringSafeArea(.all).onTapGesture { self.hideKeyboard() })
        .preferredColorScheme(.dark)
    }
}

struct EventGuestsAndInvitations_Previews: PreviewProvider {
    static var previews: some View {
        EventGuestsAndInvitations(selectedVisibility: .constant(._public),
                                  selectedInvitePreferrence: .constant(.open),
                                  selectedCheckInMethod: .constant(.manual),
                                  guestLimit: .constant(""),
                                  guestInviteLimit: .constant(""),
                                  memberInviteLimit: .constant(""),
                                  alertItem: .constant(.init(title: Text(""),
                                                             message: Text(""),
                                                             dismissButton: .cancel(Text("")))),
                                  useGuestList: .constant(false),
                                  isGuestLimit: .constant(false),
                                  isMemberInviteLimit: .constant(false),
                                  isGuestInviteLimit: .constant(false),
                                  manuallyApproveGuests: .constant(false),
                                  enableWaitlist: .constant(false),
                                  registrationcutoff: .constant(false)) {}
    }
}

extension EventGuestsAndInvitations {
    var inviteLimitsSection: some View {
        Section {
            if useGuestList {
                HStack {
                    InfoButton(action: { alertItem = AlertContext.memberInviteLimitInfo })
                    
                    Toggle("Set member invite limit", isOn: $isMemberInviteLimit.animation())
                        .font(.body.weight(.semibold))
                }
                
                if isMemberInviteLimit {
                    TextField("Invites per member", text: $memberInviteLimit)
                        .foregroundColor(Color.mainFont)
                        .keyboardType(.numberPad)
                }
                
                HStack {
                    InfoButton(action: { alertItem = AlertContext.guestInviteLimitInfo })
                    
                    Toggle("Set guest invite limit", isOn: $isGuestInviteLimit.animation())
                        .font(.body.weight(.semibold))
                }
                
                if isGuestInviteLimit {
                    TextField("Invites per guest", text: $guestInviteLimit)
                        .foregroundColor(Color.mainFont)
                        .keyboardType(.numberPad)
                }
            }
            
            
            
        } header: {
            Text("Invite Settings")
        }
        .listRowBackground(Color.mixerSecondaryBackground)
    }
    
    var advancedSettingsSection: some View {
        Section(header: Text("Advanced Settings")) {
            HStack {
                InfoButton(action: { alertItem = AlertContext.manuallyApproveInfo })
                
                Toggle("Manually approve guests", isOn: $manuallyApproveGuests.animation())
                    .font(.body.weight(.semibold))
            }
            
            HStack {
                InfoButton(action: { alertItem = AlertContext.preEnableWaitlistInfo })
                
                Toggle("Pre-enable waitlist", isOn: $enableWaitlist.animation())
                    .font(.body.weight(.semibold))
            }
            
            HStack {
                InfoButton(action: { alertItem = AlertContext.registrationCutoffInfo })
                
                Toggle("Registration cutoff", isOn: $registrationcutoff.animation())
                    .font(.body.weight(.semibold))
            }
        }
        .listRowBackground(Color.mixerSecondaryBackground)
    }
    
    func setDefaultOptions(visibility: CreateEventViewModel.VisibilityType, invitePreference: CreateEventViewModel.InvitePreferrence, checkInMethod: CheckInMethod, useGuestList: Bool) {
        selectedVisibility = visibility
        selectedInvitePreferrence = invitePreference
        selectedCheckInMethod = checkInMethod
        self.useGuestList = useGuestList
    }
}

struct InfoButton: View {
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: "info.circle")
                .font(.body)
                .foregroundColor(.mixerIndigo)
        }
    }
}
