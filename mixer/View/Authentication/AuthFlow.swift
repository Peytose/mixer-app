//
//  AuthFlow.swift
//  mixer
//
//  Created by Peyton Lyons on 11/16/22.
//

import SwiftUI
import FirebaseAuth

struct AuthFlow: View {
    @EnvironmentObject var viewModel: AuthViewModel
    @State private var showArrow = true
    
    var body: some View {
        ZStack {
            Color.mixerBackground
                .ignoresSafeArea()

            TabView(selection: $viewModel.active) {
                GetNameView(name: $viewModel.name) { viewModel.next() }
                    .tag(AuthViewModel.Screen.name)

                GetPhoneView(phoneNumber: $viewModel.phoneNumber, countryCode: $viewModel.countryCode, action: viewModel.sendPhoneVerification)
                    .tag(AuthViewModel.Screen.phone)
//
                GetCode(phoneNumber: viewModel.phoneNumber,
                        code: $viewModel.code) { viewModel.verifyPhoneNumber() }
                    .tag(AuthViewModel.Screen.code)

                GetEmail(name: viewModel.name,
                         email: $viewModel.email) { viewModel.sendEmailLink() }
                    .tag(AuthViewModel.Screen.email)
                
                GetProfilePictureAndBio(bio: $viewModel.bio, selectedImage: $viewModel.image) { viewModel.next() }
                    .tag(AuthViewModel.Screen.picAndBio)
                
                GetBirthdayView(name: viewModel.name,
                                birthday: $viewModel.birthdayString,
                                isValidBirthday: $viewModel.isValidBirthday,
                                gender: $viewModel.gender) { viewModel.next() }
                    .tag(AuthViewModel.Screen.birthday)
                
                GetGenderView(gender: $viewModel.gender, isGenderPublic: $viewModel.isGenderPublic) {
                    viewModel.next()
                }
                .tag(AuthViewModel.Screen.gender)
                
                GetUsername(name: viewModel.name,
                            username: $viewModel.username) { viewModel.register() }
                    .tag(AuthViewModel.Screen.username)
            }
            .animation(.easeInOut, value: viewModel.active)
            .tabViewStyle(.page(indexDisplayMode: .never))
            .padding(.top, 40)
        }
        .preferredColorScheme(.dark)
        .overlay(alignment: .topLeading) {
            VStack(alignment: .leading) {
                ProgressView(value: Double(viewModel.active.rawValue) / 7.0)
                    .accentColor(Color.mixerIndigo)
                
                HStack {
                    if showArrow {
                        if viewModel.active == AuthViewModel.Screen.name {
                            Button {
                                withAnimation() {
                                    viewModel.showAuthFlow.toggle()
                                }
                            } label: {
                                XDismissButton()
                            }
                            .frame(width: 50)
                        } else {
                            Button(action: viewModel.previous) {
                                Image(systemName: "chevron.backward")
                                    .resizable()
                                    .scaledToFit()
                                    .foregroundColor(.mixerIndigo)
                                    .frame(width: 15)
                            }
                            .frame(width: 50)
                        }
                    }
                }
                .padding(.horizontal, 4)
                .padding(.top, 5)
            }
            .preferredColorScheme(.dark)
        }
        .animation(.easeInOut, value: showArrow)
        .onAppear { UIScrollView.appearance().isScrollEnabled = false }
        .onDisappear { UIScrollView.appearance().isScrollEnabled = true }
//        .onChange(of: viewModel.active) { newValue in
//            showArrow = newValue == AuthViewModel.Screen.allCases.first ? true : true
//        }
        .alert(item: $viewModel.alertItem, content: { $0.alert })
        .onOpenURL { url in viewModel.handleEmailLink(url) }
    }
}

struct AuthFlow_Previews: PreviewProvider {
    static var previews: some View {
        AuthFlow()
            .preferredColorScheme(.dark)
            .environmentObject(AuthViewModel())
    }
}
