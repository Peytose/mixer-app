////
////  EventGuestsAndInvitations.swift
////  mixer
////
////  Created by Peyton Lyons on 3/15/23.
////
//
//import SwiftUI
//import Combine
//
//struct EventGuestsAndInvitations: View {
//    let startDate: Date
//    let privacy: CreateEventViewModel.PrivacyType
//    @Binding var guestLimit: String
//    @Binding var guestInviteLimit: String
//    @Binding var memberInviteLimit: String
//    @Binding var registrationDeadlineDate: Date?
//    @Binding var checkInMethod: CreateEventViewModel.CheckInMethod?
//    @Binding var isManualApprovalEnabled: Bool
//    @Binding var isGuestLimitEnabled: Bool
//    @Binding var isWaitlistEnabled: Bool
//    @Binding var isMemberInviteLimitEnabled: Bool
//    @Binding var isGuestInviteLimitEnabled: Bool
//    @Binding var isRegistrationDeadlineEnabled: Bool
//    @Binding var isCheckInOptionsEnabled: Bool
//    let action: () -> Void
//    @State private var selectedMethod: Selection<CreateEventViewModel.CheckInMethod>?
//
//    var body: some View {
//        ScrollView(showsIndicators: false) {
//            VStack(alignment: .leading, spacing: 40) {
//                CommitmentView()
//
//                // Manually Approve Option
//                OptionView(boolean: $isManualApprovalEnabled,
//                           text: "Manually approve guests",
//                           subtext: "Require approval for guests to attend invite-only events.",
//                           isEnabled: privacy == .inviteOnly)
//
//                // Guest List Limit
//                VStack(alignment: .center) {
//                    OptionView(boolean: $isGuestLimitEnabled,
//                               text: "Set guest limit",
//                               subtext: "Limit the total number of guests allowed to attend the event. Default: ∞",
//                               isEnabled: true)
//
//                    LimitInputView(placeholder: "100",
//                                   text: $guestLimit,
//                                   isEnabled: $isGuestLimitEnabled)
//                }
//
//                // Waitlist option
//                OptionView(boolean: $isWaitlistEnabled,
//                           text: "Pre-enable waitlist",
//                           subtext: "Allow guests to join a waitlist if the guest limit is reached.",
//                           isEnabled: isGuestLimitEnabled)
//
//                // Member Invite Limit
//                VStack(alignment: .center) {
//                    OptionView(boolean: $isMemberInviteLimitEnabled,
//                               text: "Set member invite limit",
//                               subtext: "Limit the number of guests members of your organization can invite. Default: 10",
//                               isEnabled: privacy == .inviteOnly)
//
//                    LimitInputView(placeholder: "10",
//                                   text: $memberInviteLimit,
//                                   isEnabled: $isMemberInviteLimitEnabled)
//                }
//
//                // Guest Invite Limit
//                VStack(alignment: .center) {
//                    OptionView(boolean: $isGuestInviteLimitEnabled,
//                               text: "Set guest invite limit",
//                               subtext: "Limit the number of additional guests each guest can invite. Default: 0",
//                               isEnabled: privacy == .inviteOnly)
//
//                    LimitInputView(placeholder: "0",
//                                   text: $guestInviteLimit,
//                                   isEnabled: $isGuestInviteLimitEnabled)
//                }
//
//                // Registration Deadline Option
////                VStack(alignment: .center) {
////                    OptionView(boolean: $isRegistrationDeadlineEnabled,
////                               text: "Registration deadline",
////                               subtext: "Specify a date by which guests must RSVP or register to attend the event.",
////                               isEnabled: true)
////                    .onChange(of: isRegistrationDeadlineEnabled) { newValue in
////                        if newValue { registrationDeadlineDate = Date() }
////                    }
////
////                    OptionalDatePicker(date: $registrationDeadlineDate,
////                                       range: Date()...startDate)
////                    .foregroundColor(isRegistrationDeadlineEnabled ? .white : .secondary)
////                    .padding()
////                    .background(alignment: .center) {
////                        RoundedRectangle(cornerRadius: 9)
////                            .stroke(lineWidth: isRegistrationDeadlineEnabled ? 2 : 1)
////                            .foregroundColor(.mixerPurple.opacity(isRegistrationDeadlineEnabled ? 1 : 0.75))
////                    }
////                    .disabled(!isRegistrationDeadlineEnabled)
////                }
//
//                // Check-In Options
//                VStack(alignment: .center) {
//                    OptionView(boolean: $isCheckInOptionsEnabled,
//                               text: "Guest check-in options",
//                               subtext: "Select a check-in method for your guests. If not specified here, you can decide the check-in method later or handle it at the event.",
//                               isEnabled: true)
//                    .onChange(of: isCheckInOptionsEnabled) { newValue in
//                        checkInMethod = newValue ? .qrCode : nil
//                    }
//
//                    SelectionPicker(selections: CreateEventViewModel.CheckInMethod.allCases.map { Selection($0) }, selectedSelection: $selectedMethod)
//                        .onChange(of: selectedMethod) { newValue in
//                            self.checkInMethod = newValue?.value
//                        }
//                }
//
//                VStack(alignment: .center) { NextButton(action: action) }
//            }
//            .padding()
//        }
//        .background(Color.mixerBackground.ignoresSafeArea())
//    }
//}
//
//struct EventGuestsAndInvitations_Previews: PreviewProvider {
//    static var previews: some View {
//        EventGuestsAndInvitations(startDate: Date().addingTimeInterval(86400),
//                                  privacy: .open,
//                                  guestLimit: .constant(""),
//                                  guestInviteLimit: .constant(""),
//                                  memberInviteLimit: .constant(""),
//                                  registrationDeadlineDate: .constant(Date()),
//                                  checkInMethod: .constant(nil),
//                                  isManualApprovalEnabled: .constant(false),
//                                  isGuestLimitEnabled: .constant(false),
//                                  isWaitlistEnabled: .constant(false),
//                                  isMemberInviteLimitEnabled: .constant(false),
//                                  isGuestInviteLimitEnabled: .constant(false),
//                                  isRegistrationDeadlineEnabled: .constant(false),
//                                  isCheckInOptionsEnabled: .constant(false)) {}
//        .preferredColorScheme(.dark)
//    }
//}
//
//fileprivate struct CommitmentView: View {
//    var body: some View {
//        VStack(alignment: .center) {
//            HStack(alignment: .center) {
//                Image(systemName: "checkmark.shield.fill")
//                    .resizable()
//                    .scaledToFit()
//                    .foregroundColor(.mixerPurple)
//                    .frame(width: 40, height: 40)
//
//                Text("Your Event, Your Control")
//                    .font(.title2)
//                    .fontWeight(.semibold)
//                    .foregroundColor(.white)
//            }
//
//            Text("We prioritize your privacy and ensure that only guests approved by you can attend your events. Feel confident in managing and customizing your guest list anytime.")
//                .font(.body)
//                .fontWeight(.medium)
//                .foregroundColor(.secondary)
//                .multilineTextAlignment(.center)
//        }
//        .padding()
//        .background(alignment: .center) {
//            RoundedRectangle(cornerRadius: 9)
//                .stroke(lineWidth: 2)
//                .foregroundColor(.mixerPurple)
//        }
//    }
//}
//
//fileprivate struct LimitInputView: View {
//    let placeholder: String
//    @Binding var text: String
//    @Binding var isEnabled: Bool
//
//    var body: some View {
//        TextFieldDynamicWidth(title: placeholder, text: $text)
//            .lineLimit(1)
//            .keyboardType(.numberPad)
//            .foregroundColor(Color.mainFont)
//            .font(.body)
//            .fontWeight(.semibold)
//            .padding()
//            .padding(.horizontal)
//            .background(alignment: .center) {
//                RoundedRectangle(cornerRadius: 9)
//                    .stroke(lineWidth: isEnabled ? 2 : 1)
//                    .foregroundColor(.mixerPurple.opacity(isEnabled ? 1 : 0.75))
//            }
//            .onReceive(Just(text)) { newValue in
//                let filtered = newValue.filter { "0123456789".contains($0) }
//                if filtered != newValue {
//                    self.text = filtered
//                }
//            }
//            .disabled(!isEnabled)
//    }
//}
//
//fileprivate struct OptionalDatePicker: View {
//    @Binding var date: Date?
//    var range: ClosedRange<Date>
//
//    var body: some View {
//        DatePicker("Choose date", selection: Binding<Date>(
//            get: { date ?? range.lowerBound },
//            set: { date = $0 }
//        ), in: range, displayedComponents: [.date, .hourAndMinute])
//        .datePickerStyle(CompactDatePickerStyle())
//    }
//}
