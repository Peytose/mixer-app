//
//  BecomeHostView.swift
//  mixer
//
//  Created by Peyton Lyons on 2/23/24.
//

import SwiftUI
import CoreLocation

enum BecomeHostViewState: Int, CaseIterable {
    case nameAndDescription
    case hostAndEventInfo
    case location
    case pictureAndTagline
    case contactEmail
    case username
}

struct BecomeHostView: View {
    
    @Environment(\.dismiss) private var dismiss
    @StateObject var viewModel: BecomeHostViewModel
    @State var viewState: BecomeHostViewState = .nameAndDescription
    
    init(notificationId: String) {
        self._viewModel = StateObject(wrappedValue: BecomeHostViewModel(notificationId: notificationId))
    }
    
    var body: some View {
        FlowContainerView {
            ScrollView(showsIndicators: false) {
                viewForState(viewState)
                    .padding(.bottom, 200)
                    .padding(.top, 50)
                    .transition(.move(edge: .leading))
            }
        }
        .mapItemPicker(isPresented: $viewModel.showPicker) { item in
            viewModel.handleItem(item, state: &viewState)
        }
        .overlay(alignment: .bottom) {
            SignUpContinueButton(message: viewModel.buttonMessage(for: viewState),
                                 text: viewModel.buttonText(for: viewState),
                                 isButtonActive: viewModel.isButtonActive(for: viewState)) {
                viewModel.buttonAction(for: &viewState)
            }.disabled(!viewModel.isButtonActive(for: viewState))
        }
        .overlay(alignment: .topLeading) {
            if viewState != BecomeHostViewState.allCases.first {
                BackArrowButton { viewModel.backArrowAction(for: &viewState) }
                    .padding(.horizontal, 4)
                    .padding(.top, 5)
            }
        }
        .overlay(alignment: .topTrailing) {
            XDismissButton { dismiss() }
        }
        .onChange(of: UserService.shared.user?.currentHost) { host in
            if let host = host { dismiss() }
        }
    }
}

extension BecomeHostView {
    @ViewBuilder
    func viewForState(_ state: BecomeHostViewState) -> some View {
        switch state{
        case .nameAndDescription:
            VStack(spacing: 50) {
                SignUpTextField(input: $viewModel.name,
                                title: "Name your host profile",
                                note: "Keep it short and sweet.",
                                placeholder: "e.g., MIT Theta Chi",
                                footnote: "Avoid including chapter details or locations unless they are essential to differentiate your group. Aim for clarity and simplicity, such as 'MIT Theta Chi' instead of 'Theta Chi Chapter at Massachusetts Institute of Technology.'")
                
                Divider().padding(.horizontal)
                
                MultilineTextField(text: $viewModel.description,
                                   title: "Tell your story",
                                   placeholder: "Our mission is to ...",
                                   footnote: "In a nutshell, what's your organization all about? Share your mission and vibe in a few sentences to people considering attending your events.",
                                   limit: 150)
            }
            
        case .hostAndEventInfo, .location:
            VStack(spacing: 50) {
                VStack(alignment: .center, spacing: 7) {
                    Text("Select your hosting niche")
                        .primaryHeading(weight: .semibold)
                        .lineLimit(2)
                        .minimumScaleFactor(0.75)
                        .padding(.bottom, 10)
                        .frame(width: DeviceTypes.ScreenSize.width * 0.9, alignment: .leading)
                    
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())],
                              spacing: 20) {
                        ForEach(HostType.allCases, id: \.self) { hostType in
                            HostTypeCell(type: $viewModel.type,
                                         hostType: hostType)
                        }
                    }
                }
                
                Divider()
                
                VStack(alignment: .center, spacing: 7) {
                    Text("Define your event types")
                        .primaryHeading(weight: .semibold)
                        .lineLimit(2)
                        .minimumScaleFactor(0.75)
                        .padding(.bottom, 10)
                        .frame(width: DeviceTypes.ScreenSize.width * 0.9, alignment: .leading)
                    
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())],
                              spacing: 20) {
                        ForEach(EventType.allCases, id: \.self) { eventType in
                            EventTypeCell(selectedTypes: $viewModel.eventTypes,
                                          type: eventType)
                        }
                    }
                }
            }
            .padding(.horizontal)
            
        case .pictureAndTagline:
            VStack(spacing: 50) {
                SignUpPictureView(title: "Spotlight your host profile",
                                  selectedImage: $viewModel.image,
                                  footnote: "Add an image that best represents your group. This could be a logo or a photo from a memorable event.")
                
                Divider().padding(.horizontal)
                
                MultilineTextField(text: $viewModel.tagline,
                                   title: "Craft a memorable tagline",
                                   placeholder: "e.g., Remember: Theta Chi owns Friday nights",
                                   footnote: "Sum up your hosting essence in a catchy phrase. This tagline will appear prominently on your host profile.",
                                   limit: 50,
                                   lineLimit: 2)
            }
        
        case .contactEmail:
            VStack(alignment: .leading, spacing: 8) {
                SignUpTextField(input: $viewModel.contactEmail,
                                title: "Provide a contact email",
                                placeholder: "contact@yourhost.com",
                                footnote: "This email will be used for event inquiries. You can use the same as your account or provide a different one.",
                                keyboard: .emailAddress)
                .disabled(viewModel.useEmailForContact)
                
                Toggle("Use my account email", isOn: $viewModel.useEmailForContact)
                    .toggleStyle(iOSCheckboxToggleStyle())
                    .buttonStyle(.plain)
            }
            
        case .username:
            SignUpTextField(input: $viewModel.username,
                            title: "Create your username",
                            placeholder: "e.g., \(viewModel.name.trimmingAllSpaces().lowercased())",
                            footnote: "Use letters, numbers, or underscores. Avoid spaces and special characters.",
                            keyboard: .default,
                            isValidUsername: viewModel.isUsernameValid)
        }
    }
}

fileprivate struct EventTypeCell: View {
    @Binding var selectedTypes: Set<EventType>
    let type: EventType
    
    var body: some View {
        Button {
            if selectedTypes.contains(type) {
                selectedTypes.remove(type)
            } else {
                selectedTypes.insert(type)
                HapticManager.playLightImpact()
            }
        } label: {
            Text(type.description)
                .body(weight: selectedTypes.contains(type) ? .semibold : .medium,
                      color: selectedTypes.contains(type) ? .white : .secondary)
                .fixedSize(horizontal: false, vertical: true)
                .multilineTextAlignment(.center)
                .padding()
                .frame(width: 100, height: 100)
                .background {
                    RoundedRectangle(cornerRadius: 10)
                        .modify {
                            if selectedTypes.contains(type) {
                                $0.foregroundStyle(Color.theme.mixerIndigo)
                            } else {
                                $0.strokeBorder(Color.secondary, lineWidth: 2)
                            }
                        }
                }
        }
    }
}

fileprivate struct HostTypeCell: View {
    @Binding var type: HostType
    let hostType: HostType
    
    var body: some View {
        Button {
            type = hostType
            HapticManager.playLightImpact()
        } label: {
            VStack {
                Image(systemName: hostType.icon)
                    .imageScale(.medium)
                    .foregroundColor(hostType == type ? .white : .secondary)
                
                Text(hostType.text)
                    .body(weight: hostType == type ? .semibold : .medium,
                          color: hostType == type ? .white : .secondary)
                    .fixedSize(horizontal: false, vertical: true)
                    .multilineTextAlignment(.center)
            }
            .padding()
            .frame(width: 160, height: 100)
            .background {
                RoundedRectangle(cornerRadius: 10)
                    .modify {
                        if hostType == type {
                            $0.foregroundStyle(Color.theme.mixerIndigo)
                        } else {
                            $0.strokeBorder(Color.secondary, lineWidth: 2)
                        }
                    }
            }
        }
    }
}
