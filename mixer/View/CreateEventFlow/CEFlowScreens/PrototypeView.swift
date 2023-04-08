//
//  PrototypeView.swift
//  mixer
//
//  Created by Jose Martinez on 4/7/23.
//

import SwiftUI

struct PrototypeView: View {
    @State var selectedVisibility : VisibilityEnum = .open
    @State var selectedInvitePreferrence : InvitePreferrenceEnum = .open
    @State var selectedCheckinMethod : CheckinMethodEnum = .qrcode
    @Binding var checkInMethod: CreateEventViewModel.CheckInMethod?

    //Values
    @Binding var guestLimit: String
    @Binding var guestInviteLimit: String
    @Binding var memberInviteLimit: String
    
    //Alert bools
    @State private var showGuestlistAlert = false
    @State private var showGuestLimitAlert = false
    @State private var showMemberInviteLimitAlert = false
    @State private var showGuestInviteLimitAlert = false
    
    @State private var showmManuallyApproveAlert = false
    @State private var showWaitlistAlert = false
    @State private var showRegistrationCutoffAlert = false
    
    //Toggle bools
    @Binding  var useGuestList: Bool
    @Binding  var isGuestLimit: Bool
    @Binding  var isMemberInviteLimit: Bool
    @Binding  var isGuestInviteLimit: Bool

    @Binding  var manuallyApproveGuests: Bool
    @Binding  var enableWaitlist: Bool
    @Binding  var registrationcutoff: Bool
    let action: () -> Void

    var body: some View {
            VStack {
                VStack(alignment: .leading, spacing: 10) {
                    HStack(spacing: 10) {
                        Text(selectedVisibility == .open ? "Open Event" : "Private Event")
                            .font(.title).bold()
                        
                        Image(systemName: selectedCheckinMethod == .qrcode ? "qrcode" : "rectangle.and.pencil.and.ellipsis")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 18, height: 18)
                    }
                    
                    Text(selectedVisibility == .open ? "Everyone can see this event. " : "Only invited users can see this event. ")
                        .font(.title3).fontWeight(.medium)
                    
                    + Text(selectedInvitePreferrence == .open ? "Anyone check in to this event" : "Only users on the guest list can check in to the event")
                        .font(.title3).fontWeight(.medium)
                    
                    + Text(selectedCheckinMethod == .qrcode ? " and check-in will be handled via QR Code." : " and check-in will be handled manually by the host.")
                        .font(.title3).fontWeight(.medium)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
                
                segmentedToggles
                                
                List {
                    guestListSettingsSection

                    if useGuestList {
                        inviteLimitsSection
                        
                        advancedSettingsSection
                    }
                }
                .scrollContentBackground(.hidden)
                .tint(.mixerIndigo)
            }
            .frame(maxHeight: .infinity, alignment: .topLeading)
            .background(Color.mixerBackground)
            .preferredColorScheme(.dark)
            .navigationTitle("")
            .padding(.bottom, 80)
            .overlay(alignment: .bottom) {
                CreateEventNextButton(text: "Continue", action: action, isActive: true)
        }
    }
}

struct PrototypeView_Previews: PreviewProvider {
    static var previews: some View {
//        PrototypeView(checkInMethod: .constant(nil), useGuestList: .constant(false), isGuestLimit: .constant(false), isMemberInviteLimit: .constant(false), isGuestInviteLimit: .constant(false), ManuallyApproveGuests: .constant(false), enableWaitlist: .constant(false), registrationcutoff: .constant(false)) {}
//            .preferredColorScheme(.dark)
        PrototypeView(checkInMethod: .constant(nil), guestLimit: .constant(""), guestInviteLimit: .constant(""), memberInviteLimit: .constant(""), useGuestList: .constant(false), isGuestLimit: .constant(false), isMemberInviteLimit: .constant(false), isGuestInviteLimit: .constant(false), manuallyApproveGuests: .constant(false), enableWaitlist: .constant(false), registrationcutoff: .constant(false)) {}
        
    }
}

extension PrototypeView {
    
    var segmentedToggles: some View {
        VStack {
            Picker("", selection: $selectedVisibility.animation()) {
                Text("Public").tag(VisibilityEnum.open)
                
                Text("Private").tag(VisibilityEnum.closed)
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding(.horizontal)
            
            Picker("", selection: $selectedInvitePreferrence.animation()) {
                Text("Open").tag(InvitePreferrenceEnum.open)
                Text("Invite Only").tag(InvitePreferrenceEnum.inviteOnly)
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding(.horizontal)
            
            Picker("", selection: $selectedCheckinMethod.animation()) {
                Text("QR Code").tag(CheckinMethodEnum.qrcode)
                Text("Manual").tag(CheckinMethodEnum.manual)
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding(.horizontal)
        }
    }
    
    var guestListSettingsSection: some View {
        Section {
            HStack {
                Image(systemName: "info.circle")
                    .font(.body)
                    .foregroundColor(.mixerIndigo)
                    .onTapGesture {
                        showGuestlistAlert.toggle()
                    }
                    .alert("Use guestlist?", isPresented: $showGuestlistAlert, actions: {}, message: { Text("N/A")}) // 4
                
                Toggle("Use guestlist", isOn: $useGuestList.animation())
                    .font(.body.weight(.semibold))
            }
            
            if useGuestList {
                HStack {
                    Image(systemName: "info.circle")
                        .font(.body)
                        .foregroundColor(.mixerIndigo)
                        .onTapGesture {
                            showGuestLimitAlert.toggle()
                        }
                        .alert("Set guest limit", isPresented: $showGuestLimitAlert, actions: {}, message: { Text("N/A")}) // 4
                    
                    Toggle("Set guest limit", isOn: $isGuestLimit.animation())
                        .font(.body.weight(.semibold))
                }
                
                if isGuestLimit {
                    TextField("Maximum guests", text: $guestLimit)
                        .foregroundColor(Color.mainFont)
                        .keyboardType(.numberPad)
                }
            }
        } header: {
            Text("Guestlist Settings")
        }
        .listRowBackground(Color.mixerSecondaryBackground)
    }
    
    var inviteLimitsSection: some View {
        Section {
            if useGuestList {
                
                HStack {
                    Image(systemName: "info.circle")
                        .font(.body)
                        .foregroundColor(.mixerIndigo)
                        .onTapGesture {
                            showMemberInviteLimitAlert.toggle()
                        }
                        .alert("Set member invite limit", isPresented: $showMemberInviteLimitAlert, actions: {}, message: { Text("N/A")}) // 4
                    
                    Toggle("Set member invite limit", isOn: $isMemberInviteLimit.animation())
                        .font(.body.weight(.semibold))
                }
                
                if isMemberInviteLimit {
                    TextField("Invites per member", text: $memberInviteLimit)
                        .foregroundColor(Color.mainFont)
                        .keyboardType(.numberPad)
                }
                
                HStack {
                    Image(systemName: "info.circle")
                        .font(.body)
                        .foregroundColor(.mixerIndigo)
                        .onTapGesture {
                            showGuestInviteLimitAlert.toggle()
                        }
                        .alert("Set guest invite limit", isPresented: $showGuestInviteLimitAlert, actions: {}, message: { Text("N/A")}) // 4
                    
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
        Section {
            HStack {
                Image(systemName: "info.circle")
                    .font(.body)
                    .foregroundColor(.mixerIndigo)
                    .onTapGesture {
                        showmManuallyApproveAlert.toggle()
                    }
                    .alert("Manually approve guests", isPresented: $showmManuallyApproveAlert, actions: {}, message: { Text("N/A")}) // 4
                
                Toggle("Manually approve guests", isOn: $manuallyApproveGuests.animation())
                    .font(.body.weight(.semibold))
            }
            
            HStack {
                Image(systemName: "info.circle")
                    .font(.body)
                    .foregroundColor(.mixerIndigo)
                    .onTapGesture {
                        showWaitlistAlert.toggle()
                    }
                    .alert("Pre-enable waitlist", isPresented: $showWaitlistAlert, actions: {}, message: { Text("N/A")}) // 4
                
                Toggle("Pre-enable waitlist", isOn: $enableWaitlist.animation())
                    .font(.body.weight(.semibold))
            }
            
            HStack {
                Image(systemName: "info.circle")
                    .font(.body)
                    .foregroundColor(.mixerIndigo)
                    .onTapGesture {
                        showRegistrationCutoffAlert.toggle()
                    }
                    .alert("Registration cutoff", isPresented: $showRegistrationCutoffAlert, actions: {}, message: { Text("N/A")}) // 4
                
                Toggle("Registration cutoff", isOn: $registrationcutoff.animation())
                    .font(.body.weight(.semibold))
            }
        } header: {
            Text("Advanced Settings")
        }
        .listRowBackground(Color.mixerSecondaryBackground)
    }
}

enum VisibilityEnum: String {
    case open, closed
    
    var stringVersion: String {
        switch self {
            case .open: return "Public"
            case .closed: return "Private"
        }
    }
}

enum InvitePreferrenceEnum: String {
    case open, inviteOnly
    
    var stringVersion: String {
        switch self {
            case .open: return "Open"
            case .inviteOnly: return "Invite Only"
        }
    }
}

enum CheckinMethodEnum: String {
    case qrcode, manual
    
    var stringVersion: String {
        switch self {
            case .qrcode: return "QR Code"
            case .manual: return "Manual"
        }
    }
}

