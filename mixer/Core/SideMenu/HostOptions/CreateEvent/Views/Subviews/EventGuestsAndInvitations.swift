//
//  EventGuestsAndInvitations.swift
//  mixer
//
//  Created by Jose Martinez on 4/7/23.
//

import SwiftUI

struct EventGuestsAndInvitations: View {
    @EnvironmentObject var viewModel: EventCreationViewModel
    @State private var isGuestLimitEnabled                  = false
    @State private var isMemberInviteLimitEnabled           = false
    @State private var isGuestInviteLimitEnabled            = false
    @State private var isRegistrationDeadlineEnabled        = false

    var checkInMethodPresetText: String {
        switch viewModel.selectedCheckInMethod {
        case .qrCode: return "Check-in will be handled via QR Code."
        case .manual: return "Check-in will be handled manually by the host."
        case .outOfApp: return "You will handle check-in outside the app."
        }
    }

    var body: some View {
        FlowContainerView {
            List {
                // MARK: Event privacy & visibility section
                Section {
                    VStack(alignment: .leading, spacing: 10) {
                        eventPresetRow
                        
                        Text("i.e. \(!viewModel.isPrivate ? "Everyone" : "Only users who have a link") can see this event, and \(!viewModel.isInviteOnly ? "anyone" : "only users on the guestlist") can check-in to this event and see its details. \(checkInMethodPresetText)")
                        .body(color: .secondary)
                    }
                    .padding(.horizontal)
                    
                    segmentedPickers
                    
                } header: {
                    Text("Privacy & Visibility")
                }
                .listRowBackground(Color.theme.secondaryBackgroundColor)
                
                // MARK: Guestlist settings
                Section {
                    HStack {
                        InfoButton { viewModel.alertItem = AlertContext.guestlistInfo }
                        
                        Toggle("Use guestlist", isOn: $viewModel.isGuestlistEnabled.animation())
                            .font(.body)
                            .fontWeight(.semibold)
                            .disabled(viewModel.selectedCheckInMethod == .outOfApp)
                    }
                    
                    if viewModel.isGuestlistEnabled {
                        HStack {
                            InfoButton { viewModel.alertItem = AlertContext.guestLimitInfo }
                            
                            Toggle("Set guest limit", isOn: $isGuestLimitEnabled.animation())
                                .font(.body)
                                .fontWeight(.semibold)
                        }
                        
                        if isGuestLimitEnabled {
                            TextField("Maximum guests", text: $viewModel.guestLimitStr)
                                .foregroundColor(.white)
                                .keyboardType(.numberPad)
                        }
                    }
                } header: { Text("Guestlist Settings") }
                    .listRowBackground(Color.theme.secondaryBackgroundColor)
                
                // MARK: Invite limits section
                if isGuestLimitEnabled {
                    inviteLimitsSection
                }
                
                // MARK: Advanced settings sections
                advancedSettingsSection
            }
            .padding(.bottom, 80)
            .scrollContentBackground(.hidden)
        }
    }
}

extension EventGuestsAndInvitations {
    var eventPresetRow: some View {
        HStack(spacing: 10) {
            Text(viewModel.isPrivate ? "Private Event" : "Open Event")
                .secondaryHeading()
                .lineLimit(1)
                .minimumScaleFactor(0.8)

            Image(systemName: viewModel.selectedCheckInMethod.icon)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)

            Spacer()

            Menu("Select Preset") {
                ForEach(EventCreationViewModel.DefaultPrivacyOption.allCases, id: \.self) { option in
                    Button(option.description) {
                        withAnimation() {
                            viewModel.setDefaultOptions(for: option)
                        }
                    }
                }
            }
            .menuTextStyle()
        }
    }

    var segmentedPickers: some View {
        VStack {
            // Visibility Picker
            HStack(spacing: 5) {
                InfoButton { viewModel.alertItem = AlertContext.eventVisiblityInfo }

                Picker("", selection: $viewModel.isPrivate.animation()) {
                    Text("Public").tag(false)
                    Text("Private").tag(true)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.trailing)
            }

            // Invite Preferrence Picker
            HStack(spacing: 5) {
                InfoButton { viewModel.alertItem = AlertContext.invitePreferrenceInfo }

                Picker("", selection: $viewModel.isInviteOnly.animation()) {
                    Text("Open").tag(false)
                    Text("Invite Only").tag(true)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.trailing)
            }

            // Check-in Method Picker
            HStack(spacing: 5) {
                InfoButton { viewModel.alertItem = AlertContext.checkInMethodInfo }

                Picker("", selection: $viewModel.selectedCheckInMethod.animation()) {
                    Text("Manual").tag(CheckInMethod.manual)
                    Text("QR Code").tag(CheckInMethod.qrCode)
                    Text("Out-of-app").tag(CheckInMethod.outOfApp)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.trailing)
            }
            .onChange(of: viewModel.selectedCheckInMethod) { newValue in
                if newValue == .outOfApp {
                    viewModel.isGuestlistEnabled = false
                }
            }
        }
    }

    var inviteLimitsSection: some View {
        Section {
            if isGuestLimitEnabled {
                HStack {
                    InfoButton { viewModel.alertItem = AlertContext.memberInviteLimitInfo }

                    Toggle("Set member invite limit", isOn: $isMemberInviteLimitEnabled.animation())
                        .font(.body.weight(.semibold))
                }

                if isMemberInviteLimitEnabled {
                    TextField("Invites per member", text: $viewModel.memberInviteLimitStr)
                        .foregroundColor(.white)
                        .keyboardType(.numberPad)
                }

                HStack {
                    InfoButton { viewModel.alertItem = AlertContext.guestInviteLimitInfo }

                    Toggle("Set guest invite limit", isOn: $isGuestInviteLimitEnabled.animation())
                        .font(.body.weight(.semibold))
                }

                if isGuestInviteLimitEnabled {
                    TextField("Invites per guest", text: $viewModel.guestInviteLimitStr)
                        .foregroundColor(.white)
                        .keyboardType(.numberPad)
                }
            }
        } header: {
            Text("Invite Settings")
        }
        .listRowBackground(Color.theme.secondaryBackgroundColor)
    }

    var advancedSettingsSection: some View {
        Section(header: Text("Advanced Settings")) {
            HStack {
                InfoButton { viewModel.alertItem = AlertContext.manuallyApproveInfo }

                Toggle("Manually approve guests", isOn: $viewModel.isManualApprovalEnabled.animation())
                    .font(.body.weight(.semibold))
            }

            HStack {
                InfoButton { viewModel.alertItem = AlertContext.registrationCutoffInfo }

                Toggle("Registration cutoff", isOn: $isRegistrationDeadlineEnabled.animation())
                    .font(.body.weight(.semibold))
            }
        }
        .listRowBackground(Color.theme.secondaryBackgroundColor)
    }
}
