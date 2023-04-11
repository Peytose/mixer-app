//
//  PrototypeView.swift
//  mixer
//
//  Created by Jose Martinez on 4/7/23.
//

import SwiftUI

struct PrototypeView: View {
    @Binding var selectedVisibility: CreateEventViewModel.VisibilityEnum
    @Binding var selectedInvitePreferrence:CreateEventViewModel.InvitePreferrenceEnum
    @Binding var selectedCheckinMethod:CreateEventViewModel.CheckinMethodEnum

    //Values
    @Binding var guestLimit: String
    @Binding var guestInviteLimit: String
    @Binding var memberInviteLimit: String
    
    //Alert bools
    @State private var showVisibilityInfoAlert = false
    @State private var showInvitePreferrenceInfoAlert = false
    @State private var showCheckInMethodInfoAlert = false
    
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
        ScrollView {
            VStack {
                VStack(alignment: .leading, spacing: 10) {
                    HStack(spacing: 10) {
                        Text(selectedVisibility == ._public ? "Open Event" : "Private Event")
                            .font(.title).bold()
                        
                        Image(systemName: selectedCheckinMethod == .qrcode ? "qrcode" : "rectangle.and.pencil.and.ellipsis")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 18, height: 18)
                        
                        Spacer()
                        
                        Menu("Choose preset") {
                            Button("Just post it", action: { justPostIt() })
                            Button("Public Open Party", action: { setPublicOpenParty() })
                            Button("Public Invite Only Party", action: { setPublicInviteOnlyParty() })
                            Button("Private Open Party", action: { setPrivateOpenParty() })
                            Button("Private Invite Only Party", action: { setPrivateInviteOnlyParty() })
                        }
                        .accentColor(.mixerIndigo)
                        .fontWeight(.medium)
                    }
                    
                    Text(selectedVisibility == ._public ? "Everyone can see this event. " : "Only invited users can see this event. ")
                        .font(.title3).fontWeight(.medium)
                    
                    + Text(selectedInvitePreferrence == .open ? "Anyone can check in to this event and see its details" : "Only users on the guest list can check in to the event and see its details")
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
                .onTapGesture {
                    self.hideKeyboard()
                }
                
                CreateEventNextButton(text: "Continue", action: action, isActive: true)
            }
            .frame(maxHeight: .infinity, alignment: .topLeading)
            .frame(height: DeviceTypes.ScreenSize.height)
            .background(Color.mixerBackground.onTapGesture {self.hideKeyboard()})
            .preferredColorScheme(.dark)
            .navigationTitle("")
        }
    }
}

struct PrototypeView_Previews: PreviewProvider {
    static var previews: some View {
        PrototypeView(selectedVisibility: .constant(._public), selectedInvitePreferrence: .constant(.open), selectedCheckinMethod: .constant(.manual), guestLimit: .constant(""), guestInviteLimit: .constant(""), memberInviteLimit: .constant(""), useGuestList: .constant(false), isGuestLimit: .constant(false), isMemberInviteLimit: .constant(false), isGuestInviteLimit: .constant(false), manuallyApproveGuests: .constant(false), enableWaitlist: .constant(false), registrationcutoff: .constant(false)) {}
    }
}

extension PrototypeView {
    var segmentedToggles: some View {
        VStack {
            HStack(spacing: 0) {
                Image(systemName: "info.circle")
                    .font(.body)
                    .foregroundColor(.mixerIndigo)
                    .onTapGesture {
                        showVisibilityInfoAlert.toggle()
                    }
                    .alert("Event Visibility", isPresented: $showVisibilityInfoAlert, actions: {}, message: { Text("Public events are visible to all users. Private events are only visible to invited users and users on the guest list.")})
                    .padding(.horizontal, 5)
                
                Picker("", selection: $selectedVisibility.animation()) {
                    Text("Public").tag(CreateEventViewModel.VisibilityEnum._public)
                    
                    Text("Private").tag(CreateEventViewModel.VisibilityEnum._private)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.trailing)
            }
            
            HStack(spacing: 0) {
                Image(systemName: "info.circle")
                    .font(.body)
                    .foregroundColor(.mixerIndigo)
                    .onTapGesture {
                        showInvitePreferrenceInfoAlert.toggle()
                    }
                    .alert("Event Exclusivity", isPresented: $showInvitePreferrenceInfoAlert, actions: {}, message: { Text("Anyone can be checked into and see an open event's details. Only invited individuals can be checked into and see an invite only event's details.")})
                    .padding(.horizontal, 5)
                
                Picker("", selection: $selectedInvitePreferrence.animation()) {
                    Text("Open").tag(CreateEventViewModel.InvitePreferrenceEnum.open)
                    Text("Invite Only").tag(CreateEventViewModel.InvitePreferrenceEnum.inviteOnly)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.trailing)
            }
            
            HStack(spacing: 0) {
                Image(systemName: "info.circle")
                    .font(.body)
                    .foregroundColor(.mixerIndigo)
                    .onTapGesture {
                        showCheckInMethodInfoAlert.toggle()
                    }
                    .alert("Check-in Method", isPresented: $showCheckInMethodInfoAlert, actions: {}, message: { Text("Manual check-in allows you to handle check-in however you want. QR Code check-in allows you to quickly scan guests in and check if they are on the guest list.")})
                    .padding(.horizontal, 5)
                
                Picker("", selection: $selectedCheckinMethod.animation()) {
                    Text("Manual").tag(CreateEventViewModel.CheckinMethodEnum.manual)
                    Text("QR Code").tag(CreateEventViewModel.CheckinMethodEnum.qrcode)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.trailing)
            }
            .onChange(of: selectedCheckinMethod) { newValue in
                if selectedCheckinMethod == CreateEventViewModel.CheckinMethodEnum.qrcode {
                    useGuestList = true
                } else {
                    useGuestList = false
                }
            }
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
                    .alert("Use guestlist?", isPresented: $showGuestlistAlert, actions: {}, message: { Text("The guest list features allows you to quickly")}) // 4
                
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
    
    func justPostIt() {
        selectedVisibility = CreateEventViewModel.VisibilityEnum._public
        selectedInvitePreferrence = CreateEventViewModel.InvitePreferrenceEnum.open
        selectedCheckinMethod = CreateEventViewModel.CheckinMethodEnum.manual
        useGuestList = false
    }
    
    func setPublicOpenParty() {
        selectedVisibility = CreateEventViewModel.VisibilityEnum._public
        selectedInvitePreferrence = CreateEventViewModel.InvitePreferrenceEnum.open
        selectedCheckinMethod = CreateEventViewModel.CheckinMethodEnum.qrcode
        useGuestList = true
    }
    
    func setPublicInviteOnlyParty() {
        selectedVisibility = CreateEventViewModel.VisibilityEnum._public
        selectedInvitePreferrence = CreateEventViewModel.InvitePreferrenceEnum.inviteOnly
        selectedCheckinMethod = CreateEventViewModel.CheckinMethodEnum.qrcode
        useGuestList = true
    }
    
    func setPrivateOpenParty() {
        selectedVisibility = CreateEventViewModel.VisibilityEnum._private
        selectedInvitePreferrence = CreateEventViewModel.InvitePreferrenceEnum.open
        selectedCheckinMethod = CreateEventViewModel.CheckinMethodEnum.qrcode
        useGuestList = true
    }
    
    func setPrivateInviteOnlyParty() {
        selectedVisibility = CreateEventViewModel.VisibilityEnum._private
        selectedInvitePreferrence = CreateEventViewModel.InvitePreferrenceEnum.inviteOnly
        selectedCheckinMethod = CreateEventViewModel.CheckinMethodEnum.qrcode
        useGuestList = true
    }
}
