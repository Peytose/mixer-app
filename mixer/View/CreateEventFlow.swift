//
//  CreateEventFlow.swift
//  mixer
//
//  Created by Peyton Lyons on 3/15/23.
//

import SwiftUI

struct CreateEventFlow: View {
    @ObservedObject var viewModel = CreateEventViewModel()
    @Binding var isShowingCreateEventView: Bool
    @State private var showArrow = false
    var namespace: Namespace.ID
    
    var body: some View {
        ZStack {
            Color.mixerBackground.ignoresSafeArea()
                .onTapGesture { self.hideKeyboard() }
            
            TabView(selection: $viewModel.active) {
                BasicEventInfo(selectedImage: $viewModel.image,
                               title: $viewModel.title,
                               description: $viewModel.description,
                               notes: $viewModel.notes,
                               hasNote: $viewModel.hasNote,
                               selectedType: $viewModel.type) { viewModel.next(); self.hideKeyboard() }
                    .tag(CreateEventViewModel.Screen.basicInfo)
                
                EventLocationAndDates(startDate: $viewModel.startDate,
                                      endDate: $viewModel.endDate,
                                      address: $viewModel.address,
                                      publicAddress: $viewModel.publicAddress,
                                      hasPublicAddress: $viewModel.eventOptions.binding(for: EventOption.hasPublicAddress.rawValue),
                                      coordinate: $viewModel.previewCoordinates) { viewModel.next(); self.hideKeyboard() }
                    .tag(CreateEventViewModel.Screen.locationAndDates)
                
                EventGuestsAndInvitations(checkInMethod: $viewModel.checkInMethod,
                                          guestLimit: $viewModel.guestLimit,
                                          guestInviteLimit: $viewModel.guestInviteLimit,
                                          memberInviteLimit: $viewModel.memberInviteLimit,
                                          isGuestlistEnabled: $viewModel.eventOptions.binding(for: EventOption.isGuestlistEnabled.rawValue),
                                          isGuestLimitEnabled: $viewModel.eventOptions.binding(for: EventOption.isGuestLimitEnabled.rawValue),
                                          isMemberInviteLimitEnabled: $viewModel.eventOptions.binding(for: EventOption.isMemberInviteLimitEnabled.rawValue),
                                          isGuestInviteLimitEnabled: $viewModel.eventOptions.binding(for: EventOption.isGuestInviteLimitEnabled.rawValue),
                                          isManualApprovalEnabled: $viewModel.eventOptions.binding(for: EventOption.isManualApprovalEnabled.rawValue),
                                          isWaitlistEnabled: $viewModel.eventOptions.binding(for: EventOption.isWaitlistEnabled.rawValue),
                                          isRegistrationDeadlineEnabled: $viewModel.eventOptions.binding(for: EventOption.isRegistrationDeadlineEnabled.rawValue),
                                          isInviteOnly: $viewModel.eventOptions.binding(for: EventOption.isInviteOnly.rawValue),
                                          isPrivate: $viewModel.eventOptions.binding(for: EventOption.isPrivate.rawValue),
                                          alertItem: $viewModel.alertItem,
                                          action: viewModel.next)
                .tag(CreateEventViewModel.Screen.guestsAndInvitations)
                
                EventAmenitiesAndCost(viewModel: viewModel,
                                      selectedAmenities: $viewModel.selectedAmenities,
                                      bathroomCount: $viewModel.bathroomCount,
                                      action: viewModel.next)
                .tag(CreateEventViewModel.Screen.costAndAmenities)
                
                ReviewCreatedEventView(viewModel: viewModel, namespace: namespace) { viewModel.createEvent(); isShowingCreateEventView = false }
                    .tag(CreateEventViewModel.Screen.review)
            }
            .animation(.easeInOut, value: viewModel.active)
            .tabViewStyle(.page(indexDisplayMode: .never))
            .padding(.top, 60)
        }
        .overlay(alignment: .top) {
            HStack(alignment: .center) {
                Button(action: showArrow ? viewModel.previous : { isShowingCreateEventView = false } ) {
                    Image(systemName: showArrow ? "chevron.backward" : "xmark")
                }
                .buttonStyle(SmallButtonStyle())
                .frame(width: 50, height: 50)
                
                Spacer()
                
                Text(viewModel.active.ScreenTitle)
                    .secondaryHeading()
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
        .alert(item: $viewModel.alertItem, content: { $0.alert })
    }
}

struct CreateEventFlow_Previews: PreviewProvider {
    @Namespace static var namespace
    static var previews: some View {
        CreateEventFlow(isShowingCreateEventView: .constant(true), namespace: namespace)
            .preferredColorScheme(.dark)
    }
}
