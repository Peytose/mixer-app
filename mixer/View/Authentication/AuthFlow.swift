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
                
                GetPhoneView(phoneNumber: $viewModel.phoneNumber,
                             countryCode: $viewModel.countryCode,
                             action: viewModel.sendPhoneVerification)
                .tag(AuthViewModel.Screen.phone)
                
                GetCode(code: $viewModel.code,
                        phoneNumber: viewModel.phoneNumber) { viewModel.verifyPhoneNumber() }
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
            
            if viewModel.isLoading { LoadingView() }
        }
        .preferredColorScheme(.dark)
        .overlay(alignment: .topLeading) {
            HStack {
                if showArrow {
                    if viewModel.active == AuthViewModel.Screen.name {
                        Button {
                            withAnimation() {
                                viewModel.showAuthFlow.toggle()
                            }
                        } label: {
                            Image(systemName: "xmark")
                                .font(.title.weight(.semibold))
                                .foregroundColor(.mainFont)
                        }
                        .frame(width: 50)
                    } else {
                        Button(action: viewModel.previous) {
                            Image(systemName: "chevron.backward")
                                .font(.title.weight(.semibold))
                                .foregroundColor(.mixerIndigo)
                        }
                        .frame(width: 50)
                    }
                }
            }
            .padding(.horizontal, 4)
            .padding(.top, 5)
            .preferredColorScheme(.dark)
        }
        .animation(.easeInOut, value: showArrow)
        .onAppear { UIScrollView.appearance().isScrollEnabled = false }
        .onDisappear { UIScrollView.appearance().isScrollEnabled = true }
        .onChange(of: viewModel.active) { newValue in
            showArrow = newValue != AuthViewModel.Screen.allCases.first
        }
        .alert(item: $viewModel.alertItem, content: { $0.alert })
        .alert(item: $viewModel.alertItemTwo, content: { $0.alert })
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
