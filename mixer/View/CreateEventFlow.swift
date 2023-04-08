//
//  CreateEventFlow.swift
//  mixer
//
//  Created by Peyton Lyons on 3/15/23.
//

import SwiftUI

struct CreateEventFlow: View {
    @ObservedObject var viewModel = CreateEventViewModel()
    @State private var showArrow = false
    
    var body: some View {
        ZStack {
            Color.mixerBackground.ignoresSafeArea()
            
            TabView(selection: $viewModel.active) {
                BasicEventInfo(selectedImage: $viewModel.image,
                               title: $viewModel.title,
                               description: $viewModel.description,
                               privacy: $viewModel.privacy,
                               visibility: $viewModel.visibility,
                               action: viewModel.next)
                    .tag(CreateEventViewModel.Screen.basicInfo)
                
                EventLocationAndDates(startDate: $viewModel.startDate,
                                      endDate: $viewModel.endDate,
                                      address: $viewModel.address,
                                      action: viewModel.next)
                    .tag(CreateEventViewModel.Screen.locationAndDates)
                
//                EventGuestsAndInvitations(startDate: viewModel.startDate,
//                                          privacy: viewModel.privacy,
//                                          guestLimit: $viewModel.guestLimit,
//                                          guestInviteLimit: $viewModel.guestInviteLimit,
//                                          memberInviteLimit: $viewModel.memberInviteLimit,
//                                          registrationDeadlineDate: $viewModel.registrationDeadlineDate,
//                                          checkInMethod: $viewModel.checkInMethod,
//                                          isManualApprovalEnabled: $viewModel.isManualApprovalEnabled,
//                                          isGuestLimitEnabled: $viewModel.isGuestLimitEnabled,
//                                          isWaitlistEnabled: $viewModel.isWaitlistEnabled,
//                                          isMemberInviteLimitEnabled: $viewModel.isMemberInviteLimitEnabled,
//                                          isGuestInviteLimitEnabled: $viewModel.isGuestInviteLimitEnabled,
//                                          isRegistrationDeadlineEnabled: $viewModel.isRegistrationDeadlineEnabled,
//                                          isCheckInOptionsEnabled: $viewModel.isCheckInOptionsEnabled,
//                                          action: viewModel.next)
//                    .tag(CreateEventViewModel.Screen.guestsAndInvitations)
                
//                PrototypeView(checkInMethod: $viewModel.checkInMethod, useGuestList: $viewModel.isGuestListEnabled, isGuestLimit: $viewModel.isGuestLimitEnabled, isMemberInviteLimit: $viewModel.isMemberInviteLimitEnabled, isGuestInviteLimit: $viewModel.isGuestInviteLimitEnabled, ManuallyApproveGuests: $viewModel.isManualApprovalEnabled, enableWaitlist: $viewModel.isWaitlistEnabled, registrationcutoff: $viewModel.isRegistrationDeadlineEnabled, action: viewModel.next)
//                    .tag(CreateEventViewModel.Screen.guestsAndInvitations)
                PrototypeView(checkInMethod: $viewModel.checkInMethod,
                              guestLimit: $viewModel.guestLimit,
                              guestInviteLimit: $viewModel.guestInviteLimit,
                              memberInviteLimit: $viewModel.memberInviteLimit,
                              useGuestList: $viewModel.isGuestListEnabled,
                              isGuestLimit: $viewModel.isGuestLimitEnabled,
                              isMemberInviteLimit: $viewModel.isMemberInviteLimitEnabled,
                              isGuestInviteLimit: $viewModel.isGuestInviteLimitEnabled,
                              manuallyApproveGuests: $viewModel.isManualApprovalEnabled,
                              enableWaitlist: $viewModel.isWaitlistEnabled,
                              registrationcutoff: $viewModel.isRegistrationDeadlineEnabled, action: viewModel.next)
                .tag(CreateEventViewModel.Screen.guestsAndInvitations)

                
                
                EventAmenitiesAndCost(selectedAmenities: $viewModel.selectedAmenities,
                                      action: viewModel.next)
                    .tag(CreateEventViewModel.Screen.costAndAmenities)
                
                ReviewCreatedEventView(viewModel: viewModel)
                    .tag(CreateEventViewModel.Screen.review)
            }
            .animation(.easeInOut, value: viewModel.active)
            .tabViewStyle(.page(indexDisplayMode: .never))
            .padding(.top, 60)
        }
        .overlay(alignment: .top) {
            HStack(alignment: .center) {
                Button(action: viewModel.previous) {
                    Image(systemName: showArrow ? "chevron.backward" : "xmark")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 23, height: 23)
                }
                .frame(width: 50, height: 50)
                
                Spacer()
                
                Text(viewModel.active.ScreenTitle)
                    .font(.title)
                    .bold()
                    .foregroundColor(.white)
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)
                
                Spacer()
                
                
                ProgressView(value: Double(viewModel.active.rawValue) / 5.0)
                    .frame(width: 50)
            }
            .padding(.horizontal)
        }
        .animation(.easeInOut, value: showArrow)
        .onAppear { UIScrollView.appearance().isScrollEnabled = false }
        .onDisappear { UIScrollView.appearance().isScrollEnabled = true }
        .onChange(of: viewModel.active) { newValue in
            guard let firstScreen = AuthViewModel.Screen.allCases.first else { return }
            showArrow = newValue.rawValue != firstScreen.rawValue
        }
    }
}

struct CreateEventFlow_Previews: PreviewProvider {
    static var previews: some View {
        CreateEventFlow()
            .preferredColorScheme(.dark)
    }
}
