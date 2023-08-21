////
////  EventGuestsAndInvitations.swift
////  mixer
////
////  Created by Jose Martinez on 4/7/23.
////
//
//import SwiftUI
//
//struct EventGuestsAndInvitations: View {
//    @EnvironmentObject var viewModel: EventCreationViewModel
//    @State private var isGuestLimitEnabled                  = false
//    @State private var isMemberInviteLimitEnabled           = false
//    @State private var isGuestInviteLimitEnabled            = false
//    @State private var isRegistrationDeadlineEnabled        = false
//    @State private var selectedCheckInMethod: CheckInMethod = .manual
//
//    var checkInMethodPresetText: String {
//        switch selectedCheckInMethod {
//        case .qrCode:
//            "Check-in will be handled via QR Code."
//        case .manual:
//            "Check-in will be handled manually by the host."
//        case .outOfApp:
//            "You will handle check-in outside the app."
//        }
//    }
//
//    var body: some View {
//        ScrollView(showsIndicators: false) {
//            VStack {
//                // MARK: Event Presets
//                VStack(alignment: .leading, spacing: 10) {
//                    //Preset Menu
//                    eventPresetRow
//
////                    Preset Description
//                    Text("\(!viewModel.isPrivate ? "Everyone" : "Only allowed users") can see this event, and " +
//                         "\(!isInviteOnly ? "anyone" : "only users on the guestlist") can check-in to this event and see its details." + checkInMethodPresetText)
//                    .secondarySubheading()
//                }
//                .frame(maxWidth: .infinity, alignment: .leading)
//                .padding(.horizontal)
//
//                // MARK: Segmented Pickers
//                segmentedPickers
//
//                List {
//                    Section {
//                        HStack {
//                            InfoButton(action: { alertItem = AlertContext.guestlistInfo})
//
//                            Toggle("Use guestlist", isOn: $isGuestlistEnabled.animation())
//                                .font(.body)
//                                .fontWeight(.semibold)
//                                .disabled(selectedCheckInMethod == .outOfApp)
//                        }
//
//                        if isGuestlistEnabled {
//                            HStack {
//                                InfoButton(action: { alertItem = AlertContext.guestLimitInfo })
//
//                                Toggle("Set guest limit", isOn: $isGuestLimitEnabled.animation())
//                                    .font(.body.weight(.semibold))
//                            }
//
//                            if isGuestLimitEnabled {
//                                TextField("Maximum guests", text: $guestLimit)
//                                    .foregroundColor(.white)
//                                    .keyboardType(.numberPad)
//                            }
//                        }
//                    } header: { Text("Guestlist Settings") }
//                        .listRowBackground(Color.theme.secondaryBackgroundColor)
//
//                    if isGuestLimitEnabled {
//                        inviteLimitsSection
//
//                        advancedSettingsSection
//                    }
//                }
//                .scrollContentBackground(.hidden)
//                .tint(Color.theme.mixerIndigo)
//                .onTapGesture {
//                    self.hideKeyboard()
//                }
//            }
//            .frame(maxHeight: .infinity, alignment: .topLeading)
//            .frame(height: DeviceTypes.ScreenSize.height)
//            .padding(4)
//            .padding(.bottom, 80)
//        }
//        .background(Color.theme.backgroundColor.edgesIgnoringSafeArea(.all).onTapGesture { self.hideKeyboard() })
//        .preferredColorScheme(.dark)
//        .overlay(alignment: .bottom) {
//            EventFlowActionButton(text: "Continue", action: action, isActive: true)
//        }
//    }
//}
//
//extension EventGuestsAndInvitations {
//    var eventPresetRow: some View {
//        HStack(spacing: 10) {
//            Text(viewModel.isPrivate ? "Private Event" : "Open Event")
//                .primaryHeading()
//
//            Image(systemName: selectedCheckInMethod.icon)
//                .resizable()
//                .aspectRatio(contentMode: .fit)
//                .frame(width: 18, height: 18)
//
//            Spacer()
//
//            Menu("Choose preset") {
//                Button("Just post it") {
//                    setDefaultOptions(viewModel.isPrivateBool: false,
//                                      isInviteOnlyBool: false,
//                                      checkInMethod: .outOfApp)
//                }
//
//                Button("Public Open Party") {
//                    setDefaultOptions(viewModel.isPrivateBool: false,
//                                      isInviteOnlyBool: false,
//                                      checkInMethod: .qrCode)
//                }
//
//                Button("Public Invite Only Party") {
//                    setDefaultOptions(viewModel.isPrivateBool: false,
//                                      isInviteOnlyBool: true,
//                                      checkInMethod: .qrCode)
//                }
//
//                Button("Private Open Party") {
//                    setDefaultOptions(viewModel.isPrivateBool: true,
//                                      isInviteOnlyBool: false,
//                                      checkInMethod: .qrCode)
//                }
//
//                Button("Private Invite Only Party") {
//                    setDefaultOptions(viewModel.isPrivateBool: true,
//                                      isInviteOnlyBool: true,
//                                      checkInMethod: .qrCode)
//                }
//            }
//            .menuTextStyle()
//        }
//    }
//
//    var segmentedPickers: some View {
//        VStack {
//
//            // Visibility Picker
//            HStack(spacing: 5) {
//                InfoButton(action: { alertItem = AlertContext.eventVisiblityInfo })
//
//                Picker("", selection: $viewModel.isPrivate.animation()) {
//                    Text("Public").tag(false)
//                    Text("Private").tag(true)
//                }
//                .pickerStyle(SegmentedPickerStyle())
//                .padding(.trailing)
//            }
//
//            // Invite Preferrence Picker
//            HStack(spacing: 5) {
//                InfoButton(action: { alertItem = AlertContext.invitePreferrenceInfo })
//
//                Picker("", selection: $isInviteOnly.animation()) {
//                    Text("Open").tag(false)
//                    Text("Invite Only").tag(true)
//                }
//                .pickerStyle(SegmentedPickerStyle())
//                .padding(.trailing)
//            }
//
//            // Check-in Method Picker
//            HStack(spacing: 5) {
//                InfoButton(action: { alertItem = AlertContext.checkInMethodInfo })
//
//                Picker("", selection: $selectedCheckInMethod.animation()) {
//                    Text("Manual").tag(CheckInMethod.manual)
//                    Text("QR Code").tag(CheckInMethod.qrCode)
//                    Text("Out-of-app").tag(CheckInMethod.outOfApp)
//                }
//                .pickerStyle(SegmentedPickerStyle())
//                .padding(.trailing)
//            }
//            .onChange(of: selectedCheckInMethod) { newValue in
//                checkInMethod = selectedCheckInMethod
//                if newValue == .outOfApp {
//                    isGuestlistEnabled = false
//                }
//            }
//        }
//    }
//
//    var inviteLimitsSection: some View {
//        Section {
//            if isGuestLimitEnabled {
//                HStack {
//                    InfoButton(action: { alertItem = AlertContext.memberInviteLimitInfo })
//
//                    Toggle("Set member invite limit", isOn: $isMemberInviteLimitEnabled.animation())
//                        .font(.body.weight(.semibold))
//                }
//
//                if isMemberInviteLimitEnabled {
//                    TextField("Invites per member", text: $memberInviteLimit)
//                        .foregroundColor(.white)
//                        .keyboardType(.numberPad)
//                }
//
//                HStack {
//                    InfoButton(action: { alertItem = AlertContext.guestInviteLimitInfo })
//
//                    Toggle("Set guest invite limit", isOn: $isGuestInviteLimitEnabled.animation())
//                        .font(.body.weight(.semibold))
//                }
//
//                if isGuestInviteLimitEnabled {
//                    TextField("Invites per guest", text: $guestInviteLimit)
//                        .foregroundColor(.white)
//                        .keyboardType(.numberPad)
//                }
//            }
//        } header: {
//            Text("Invite Settings")
//        }
//        .listRowBackground(Color.theme.secondaryBackgroundColor)
//    }
//
//    var advancedSettingsSection: some View {
//        Section(header: Text("Advanced Settings")) {
//            HStack {
//                InfoButton(action: { alertItem = AlertContext.manuallyApproveInfo })
//
//                Toggle("Manually approve guests", isOn: $isManualApprovalEnabled.animation())
//                    .font(.body.weight(.semibold))
//            }
//
//            HStack {
//                InfoButton(action: { alertItem = AlertContext.preEnableWaitlistInfo })
//
//                Toggle("Pre-enable waitlist", isOn: $isWaitlistEnabled.animation())
//                    .font(.body.weight(.semibold))
//            }
//
//            HStack {
//                InfoButton(action: { alertItem = AlertContext.registrationCutoffInfo })
//
//                Toggle("Registration cutoff", isOn: $isRegistrationDeadlineEnabled.animation())
//                    .font(.body.weight(.semibold))
//            }
//        }
//        .listRowBackground(Color.theme.secondaryBackgroundColor)
//    }
//
//    func setDefaultOptions(viewModel.isPrivateBool: Bool, isInviteOnlyBool: Bool, checkInMethod: CheckInMethod) {
//        viewModel.isPrivate = viewModel.isPrivateBool
//        isInviteOnly = isInviteOnlyBool
//        selectedCheckInMethod = checkInMethod
//    }
//}
