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
    @Binding var checkInMethod: CheckInMethod?
    
    @Binding var guestLimit: String
    @Binding var guestInviteLimit: String
    @Binding var memberInviteLimit: String
    
    @Binding var isGuestlistEnabled: Bool
    @Binding var isGuestLimitEnabled: Bool
    @Binding var isMemberInviteLimitEnabled: Bool
    @Binding var isGuestInviteLimitEnabled: Bool
    @Binding var isManualApprovalEnabled: Bool
    @Binding var isWaitlistEnabled: Bool
    @Binding var isRegistrationDeadlineEnabled: Bool
    @Binding var isInviteOnly: Bool
    @Binding var isPrivate: Bool
    
    @Binding var alertItem: AlertItem?
    
    @State private var selectedCheckInMethod: CheckInMethod = .manual
    let action: () -> Void
    
    var body: some View {
        ScrollView {
            VStack {
                VStack(alignment: .leading, spacing: 10) {
                    HStack(spacing: 10) {
                        Text(selectedVisibility == ._public ? "Open Event" : "Private Event")
                            .font(.title).bold()
                        
                        Image(systemName: selectedCheckInMethod.icon)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 18, height: 18)
                        
                        Spacer()
                        
                        Menu("Choose preset") {
                            Button("Just post it") {
                                setDefaultOptions(visibility: ._public, invitePreference: .open, checkInMethod: .outOfApp)
                            }
                            
                            Button("Public Open Party") {
                                setDefaultOptions(visibility: ._public, invitePreference: .open, checkInMethod: .qrCode)
                            }
                            
                            Button("Public Invite Only Party") {
                                setDefaultOptions(visibility: ._public, invitePreference: .inviteOnly, checkInMethod: .qrCode)
                            }
                            
                            Button("Private Open Party") {
                                setDefaultOptions(visibility: ._private, invitePreference: .open, checkInMethod: .qrCode)
                            }
                            
                            Button("Private Invite Only Party") {
                                setDefaultOptions(visibility: ._private, invitePreference: .inviteOnly, checkInMethod: .qrCode)
                            }
                        }
                        .accentColor(.mixerIndigo)
                        .fontWeight(.medium)
                    }
                    
                    Text("\(selectedVisibility == ._public ? "Everyone" : "Only invited users") can see this event, and " +
                         "\(selectedInvitePreferrence == .open ? "anyone" : "only users on the guest list") can check in to this event and see its details." +
                         "\(selectedCheckInMethod == .qrCode ? "Check-in will be handled via QR Code." : (selectedCheckInMethod == .manual ? "Check-in will be handled manually by the host." : "You will handle check-in outside the app."))")
                    .font(.title3)
                    .fontWeight(.medium)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
                
                VStack {
                    HStack(spacing: 5) {
                        InfoButton(action: { alertItem = AlertContext.eventVisiblityInfo })
                        
                        Picker("", selection: $isPrivate.animation()) {
                            Text("Public").tag(false)
                            Text("Private").tag(true)
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        .padding(.trailing)
                    }
                    
                    HStack(spacing: 5) {
                        InfoButton(action: { alertItem = AlertContext.invitePreferrenceInfo })
                        
                        Picker("", selection: $isInviteOnly.animation()) {
                            Text("Open").tag(false)
                            Text("Invite Only").tag(true)
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        .padding(.trailing)
                    }
                    
                    HStack(spacing: 5) {
                        InfoButton(action: { alertItem = AlertContext.checkInMethodInfo })
                        
                        Picker("", selection: $selectedCheckInMethod.animation()) {
                            Text("Manual").tag(CheckInMethod.manual)
                            Text("QR Code").tag(CheckInMethod.qrCode)
                            Text("Out-of-app").tag(CheckInMethod.outOfApp)
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        .padding(.trailing)
                    }
                    .onChange(of: selectedCheckInMethod) { newValue in
                        checkInMethod = selectedCheckInMethod
                        if newValue == .outOfApp {
                            isGuestlistEnabled = false
                        }
                    }
                }
                
                List {
                    Section {
                        HStack {
                            InfoButton(action: { alertItem = AlertContext.guestlistInfo})
                            
                            Toggle("Use guestlist", isOn: $isGuestlistEnabled.animation())
                                .font(.body)
                                .fontWeight(.semibold)
                                .disabled(selectedCheckInMethod == .outOfApp)
                        }
                        
                        if isGuestlistEnabled {
                            HStack {
                                InfoButton(action: { alertItem = AlertContext.guestLimitInfo })
                                
                                Toggle("Set guest limit", isOn: $isGuestLimitEnabled.animation())
                                    .font(.body.weight(.semibold))
                            }
                            
                            if isGuestLimitEnabled {
                                TextField("Maximum guests", text: $guestLimit)
                                    .foregroundColor(Color.mainFont)
                                    .keyboardType(.numberPad)
                            }
                        }
                    } header: { Text("Guestlist Settings") }
                        .listRowBackground(Color.mixerSecondaryBackground)
                    
                    if isGuestLimitEnabled {
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

//struct EventGuestsAndInvitations_Previews: PreviewProvider {
//    static var previews: some View {
//        EventGuestsAndInvitations(selectedVisibility: .constant(._public),
//                                  selectedInvitePreferrence: .constant(.open),
//                                  eventOptions: .constant(["containsAlcohol": false,
//                                                           "isInviteOnly": false,
//                                                           "hasPublicAddress": false,
//                                                           "isManualApprovalEnabled": false,
//                                                           "isGuestLimitEnabled": false,
//                                                           "isWaitlistEnabled": false,
//                                                           "isMemberInviteLimitEnabled": false,
//                                                           "isGuestInviteLimitEnabled": false,
//                                                           "isRegistrationDeadlineEnabled": false,
//                                                           "isCheckInEnabled": false]),
//                                  checkInMethod: .constant(.manual),
//                                  guestLimit: .constant(""),
//                                  guestInviteLimit: .constant(""),
//                                  memberInviteLimit: .constant(""),
//                                  alertItem: .constant(.init(title: Text(""),
//                                                             message: Text(""),
//                                                             dismissButton: .cancel(Text(""))))) {}
//    }
//}

extension EventGuestsAndInvitations {
    var inviteLimitsSection: some View {
        Section {
            if isGuestLimitEnabled {
                HStack {
                    InfoButton(action: { alertItem = AlertContext.memberInviteLimitInfo })
                    
                    Toggle("Set member invite limit", isOn: $isMemberInviteLimitEnabled.animation())
                        .font(.body.weight(.semibold))
                }
                
                if isMemberInviteLimitEnabled {
                    TextField("Invites per member", text: $memberInviteLimit)
                        .foregroundColor(Color.mainFont)
                        .keyboardType(.numberPad)
                }
                
                HStack {
                    InfoButton(action: { alertItem = AlertContext.guestInviteLimitInfo })
                    
                    Toggle("Set guest invite limit", isOn: $isGuestInviteLimitEnabled.animation())
                        .font(.body.weight(.semibold))
                }
                
                if isGuestInviteLimitEnabled {
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
                
                Toggle("Manually approve guests", isOn: $isManualApprovalEnabled.animation())
                    .font(.body.weight(.semibold))
            }
            
            HStack {
                InfoButton(action: { alertItem = AlertContext.preEnableWaitlistInfo })
                
                Toggle("Pre-enable waitlist", isOn: $isWaitlistEnabled.animation())
                    .font(.body.weight(.semibold))
            }
            
            HStack {
                InfoButton(action: { alertItem = AlertContext.registrationCutoffInfo })
                
                Toggle("Registration cutoff", isOn: $isRegistrationDeadlineEnabled.animation())
                    .font(.body.weight(.semibold))
            }
        }
        .listRowBackground(Color.mixerSecondaryBackground)
    }
    
    func setDefaultOptions(visibility: CreateEventViewModel.VisibilityType, invitePreference: CreateEventViewModel.InvitePreferrence, checkInMethod: CheckInMethod) {
        selectedVisibility = visibility
        selectedInvitePreferrence = invitePreference
        selectedCheckInMethod = checkInMethod
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
