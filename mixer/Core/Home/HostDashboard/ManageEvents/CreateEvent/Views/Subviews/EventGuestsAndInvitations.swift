//
//  EventGuestsAndInvitations.swift
//  mixer
//
//  Created by Jose Martinez on 4/7/23.
//

import SwiftUI

struct EventGuestsAndInvitations: View {
    @EnvironmentObject var viewModel: EventCreationViewModel
    @State private var isGuestLimitEnabled           = false
    @State private var isMemberInviteLimitEnabled    = false
    @State private var isRegistrationCutoffEnabled = false

    var body: some View {
        FlowContainerView {
            List {
                // MARK: Event privacy & visibility section
                Section {
                    VStack(alignment: .leading, spacing: 10) {
                        eventPresetRow
                        
                        Text("i.e. \(!viewModel.isPrivate ? "Everyone" : "Only users who have a link") can see this event, and \(!viewModel.isInviteOnly ? "anyone" : "only users on the guestlist") can check-in to this event and see its details. Check-in will be handled \(viewModel.isCheckInViaMixer ? "via mixer" : "manually by you").")
                        .body(color: .secondary)
                    }
                    .padding(.horizontal)
                    
                    segmentedPickers
                    
                } header: {
                    Text("Privacy & Visibility")
                }
                .listRowBackground(Color.theme.secondaryBackgroundColor)
                
                Section {
                    HStack {
                        InfoButton { viewModel.alertItem = AlertContext.alcoholInfo }

                        Toggle("Serving Alcohol", isOn: $viewModel.containsAlcohol.animation())
                            .font(.body.weight(.semibold))
                    }

                    Picker("", selection: $viewModel.containsAlcohol.animation()) {
                        Text("Dry").tag(false)
                        Text("Wet").tag(true)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding(.trailing)
                } header: {
                    Text("Event Alcohol Status")
                }
                .listRowBackground(Color.theme.secondaryBackgroundColor)
                .onChange(of: viewModel.containsAlcohol) { newValue in
                    if newValue {
                        viewModel.selectedAmenities.insert(EventAmenity.alcohol)
                    } else {
                        viewModel.selectedAmenities.remove(EventAmenity.alcohol)
                    }
                }
                
                // MARK: Guestlist settings
//                if viewModel.isCheckInViaMixer {
//                    Section {
//                        HStack {
//                            InfoButton { viewModel.alertItem = AlertContext.guestLimitInfo }
//                            
//                            Toggle("Set guest limit", isOn: $isGuestLimitEnabled.animation())
//                                .font(.body)
//                                .fontWeight(.semibold)
//                        }
//                        
//                        if isGuestLimitEnabled {
//                            TextField("Maximum guests", text: $viewModel.guestLimitStr)
//                                .foregroundColor(.white)
//                                .keyboardType(.numberPad)
//                        }
//                    } header: { Text("Guestlist Settings") }
//                        .listRowBackground(Color.theme.secondaryBackgroundColor)
//                    
//                    // MARK: Invite limits section
//                    if isGuestLimitEnabled {
//                        inviteLimitsSection
//                    }
//                    
//                    // MARK: Advanced settings sections
//                    advancedSettingsSection
//                }
            }
            .padding(.bottom, 80)
            .scrollContentBackground(.hidden)
        }
    }
}

extension EventGuestsAndInvitations {
    var eventPresetRow: some View {
        HStack(spacing: 10) {
            InfoButton { viewModel.alertItem = AlertContext.checkInMethodInfo }
            
            Text("\(viewModel.isPrivate ? "Private" : "Open") Event")
                .secondaryHeading()
                .lineLimit(1)
                .minimumScaleFactor(0.8)

            if viewModel.isCheckInViaMixer {
                Image("mixer-icon-white")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 30, height: 30)
            } else {
                Image(systemName: "arrow.up.doc.on.clipboard")
                    .resizable()
                    .scaledToFit()
                    .foregroundColor(.white)
                    .frame(width: 30, height: 30)
            }

            Spacer()

            Menu("Quick Select") {
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
                .onChange(of: viewModel.isInviteOnly) { newValue in
                    if newValue {
                        viewModel.isManualApprovalEnabled = false
                    }
                }
            }

            // Check-in Method Picker
            HStack {
                InfoButton { viewModel.alertItem = AlertContext.invitePreferrenceInfo }
                
                Picker("", selection: $viewModel.isCheckInViaMixer.animation()) {
                    Text("Via mixer").tag(true)
                    Text("Out-of-app").tag(false)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.trailing)
            }
            .onChange(of: viewModel.isCheckInViaMixer) { newValue in
                if !newValue {
                    viewModel.resetCheckInRelatedOptions()
                    self.isGuestLimitEnabled           = false
                    self.isMemberInviteLimitEnabled    = false
                    self.isRegistrationCutoffEnabled = false
                }
            }
        }
    }

    var inviteLimitsSection: some View {
        Section {
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
            
            // MARK: Will be added
//                HStack {
//                    InfoButton { viewModel.alertItem = AlertContext.guestInviteLimitInfo }
//
//                    Toggle("Set guest invite limit", isOn: $isGuestInviteLimitEnabled.animation())
//                        .font(.body.weight(.semibold))
//                }
//
//                if isGuestInviteLimitEnabled {
//                    TextField("Invites per guest", text: $viewModel.guestInviteLimitStr)
//                        .foregroundColor(.white)
//                        .keyboardType(.numberPad)
//                }
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
                    .font(.body)
                    .fontWeight(.semibold)
                    .disabled(viewModel.isInviteOnly)
            }
            
            HStack {
                InfoButton { viewModel.alertItem = AlertContext.registrationCutoffInfo }

                Toggle("Registration cutoff", isOn: $isRegistrationCutoffEnabled.animation())
                    .font(.body)
                    .fontWeight(.semibold)
            }
            
            if isRegistrationCutoffEnabled {
                Picker("Cutoff time", selection: $viewModel.selectedDeadlineOption) {
                    ForEach(DeadlineOption.allCases, id: \.self) { option in
                        Text(option.description).tag(option)
                    }
                }
                .pickerStyle(WheelPickerStyle())
                
                if viewModel.selectedDeadlineOption == .custom {
                    DatePicker("", selection: $viewModel.cutoffDate,
                               in: Date.now...viewModel.startDate,
                               displayedComponents: [.date, .hourAndMinute])
                    .datePickerStyle(.compact)
                    .labelsHidden()
                    .frame(maxWidth: DeviceTypes.ScreenSize.width, alignment: .center)
                }
            }
        }
        .listRowBackground(Color.theme.secondaryBackgroundColor)
    }
}
