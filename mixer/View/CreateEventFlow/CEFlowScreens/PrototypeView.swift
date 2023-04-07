//
//  PrototypeView.swift
//  mixer
//
//  Created by Jose Martinez on 4/7/23.
//

import SwiftUI

struct PrototypeView: View {
    @State var selectedVisibility : VisibilityEnum = .open
    @State var selectedCheckinMethod : CheckinMethodEnum = .qrcode

    @State var temp = ""
    
    //Alert bools
    @State private var showGuestlistAlert = false
    @State private var showGuestLimitAlert = false
    @State private var showMemberInviteLimitAlert = false
    @State private var showGuestInviteLimitAlert = false
    
    @State private var showmManuallyApproveAlert = false
    @State private var showWaitlistAlert = false
    @State private var showRegistrationCutoffAlert = false
    
    //Toggle bools
    @State private var useGuestList = false
    @State private var guestLimit = false
    @State private var memberInviteLimit = false
    @State private var guestInviteLimit = false

    
    @State private var manuallyApproveGuests = false
    @State private var enableWaitlist = false
    @State private var registrationcutoff = false
    
    var body: some View {
        NavigationView {
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
                    
                    Text(selectedVisibility == .open ? "Everyone can see this event" : "Only invited users can see this event")
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
            .navigationTitle("")
        }
    }
}

struct PrototypeView_Previews: PreviewProvider {
    static var previews: some View {
        PrototypeView()
            .preferredColorScheme(.dark)
    }
}

extension PrototypeView {
    
    var segmentedToggles: some View {
        VStack {
            Picker("", selection: $selectedVisibility.animation()) {
                Text("Open").tag(VisibilityEnum.open)
                
                Text("Private").tag(VisibilityEnum.closed)
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
                    
                    Toggle("Set guest limit", isOn: $guestLimit.animation())
                        .font(.body.weight(.semibold))
                }
                
                if guestLimit {
                    TextField("Maximum guests", text: $temp)
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
                    
                    Toggle("Set member invite limit", isOn: $memberInviteLimit.animation())
                        .font(.body.weight(.semibold))
                }
                
                if memberInviteLimit {
                    TextField("Invites per member", text: $temp)
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
                    
                    Toggle("Set guest invite limit", isOn: $guestInviteLimit.animation())
                        .font(.body.weight(.semibold))
                }
                
                if guestInviteLimit {
                    TextField("Invites per guest", text: $temp)
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
    case closed, open
    
    var stringVersion: String {
        switch self {
            case .closed: return "Private"
            case .open: return "Public"
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
