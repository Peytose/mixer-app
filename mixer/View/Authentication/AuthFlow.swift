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
    @State private var showHeaderItems = false
    
    var body: some View {
        ZStack {
            Color.mixerBackground.ignoresSafeArea()
            
            TabView(selection: $viewModel.active) {
                GetNameAndPhoneView(name: $viewModel.name,
                                    phoneNumber: $viewModel.phoneNumber,
                                    countryCode: $viewModel.countryCode,
                                    action: viewModel.sendPhoneVerification)
                    .tag(AuthViewModel.Screen.nameAndPhone)
                
                GetCode(code: $viewModel.code) { viewModel.verifyPhoneNumber() }
                    .tag(AuthViewModel.Screen.code)
                
                GetEmail(name: viewModel.name,
                        email: $viewModel.email) { viewModel.sendEmailLink() }
                    .tag(AuthViewModel.Screen.email)
                
                GetProfilePictureAndBio(bio: $viewModel.bio, selectedImage: $viewModel.image) { viewModel.next() }
                    .tag(AuthViewModel.Screen.picAndBio)
                
                GetPersonalInfo(name: viewModel.name,
                                birthday: $viewModel.birthdayString,
                                isValidBirthday: $viewModel.isValidBirthday,
                                gender: $viewModel.gender) { viewModel.next() }
                    .tag(AuthViewModel.Screen.personal)
                
                GetUsername(name: viewModel.name,
                            username: $viewModel.username) { viewModel.register() }
                    .tag(AuthViewModel.Screen.username)
            }
            .animation(.easeInOut, value: viewModel.active)
            .tabViewStyle(.page(indexDisplayMode: .never))
            .padding(.top, 70)
        }
        .overlay(alignment: .top) {
            HStack(alignment: .center) {
                if showHeaderItems {
                    Button(action: viewModel.previous) {
                        Image(systemName: "chevron.backward")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 15)
                    }
                    .frame(width: 50)
                }
                
                Spacer()
                
                Image("mixer-icon-white")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 50)
                
                Spacer()
                
                if showHeaderItems {
                    ProgressView(value: Double(viewModel.active.rawValue) / 8.0)
                        .frame(width: 50)
                }
            }
            .padding(.horizontal, 5)
        }
        .animation(.easeInOut, value: showHeaderItems)
        .onAppear { UIScrollView.appearance().isScrollEnabled = false }
        .onDisappear { UIScrollView.appearance().isScrollEnabled = true }
        .onChange(of: viewModel.active) { newValue in
            showHeaderItems = newValue == AuthViewModel.Screen.allCases.first ? false : true
        }
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
