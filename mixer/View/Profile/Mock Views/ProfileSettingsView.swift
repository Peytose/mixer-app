//
//  UserProfileView.swift
//  mixer
//
//  Created by Jose Martinez on 12/18/22.
//

import SwiftUI

struct ProfileSettingsView: View {
    var body: some View {
        NavigationView {
            List {
                PersonalInformationView()
                
                SupportView()
                
                LegalView()
            }
            .background {
                ZStack {
                    Rectangle()
                        .fill(Color.mixerBackground)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .edgesIgnoringSafeArea(.all)
                    
                    Image("Blob 1")
                        .offset(x: 250, y: -180)
                        .opacity(0.9)
                    
                    Rectangle()
                        .fill(Color.clear)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                        .backgroundBlur(radius: 12, opaque: true)
                        .ignoresSafeArea()
                }
            }
            .scrollContentBackground(.hidden)
            .listStyle(.insetGrouped)
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.automatic)
            .scrollIndicators(.hidden)
            .preferredColorScheme(.dark)
        }
    }
}


struct ProfileSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileSettingsView()
            .preferredColorScheme(.dark)
    }
}

fileprivate struct PersonalInformationView: View {
    @StateObject var viewModel = UserProfileViewModel()

    var body: some View {
        Section(header: Text("Personal Information").fontWeight(.semibold)) {
            HStack {
                Text("Email")
                Spacer()
                Text(viewModel.email)
                    .foregroundColor(.secondary)
            }
            HStack {
                Text("Phone Number")
                Spacer()
                Text(viewModel.phone)
                    .foregroundColor(.secondary)
            }
        }
        .listRowBackground(Color.mixerSecondaryBackground)
    }
}

fileprivate struct SupportView: View {
    var body: some View {
        Section(header: Text("Support").fontWeight(.semibold)) {
            Link(destination: URL(string: "https://mixer.llc/contact/")!) {
                HStack {
                    HStack {
                        Image(systemName: "questionmark.circle")
                            .foregroundColor(.mixerIndigo)
                        Text("Help")
                    }
                    Spacer()
                    Image(systemName: "link")
                        .foregroundColor(.secondary)
                }
            }
        }
        .accentColor(.white)
        .listRowBackground(Color.mixerSecondaryBackground)
    }
}


fileprivate struct LegalView: View {
    var body: some View {
        Section(header: Text("LEGAL").fontWeight(.semibold)) {
            Link(destination: URL(string: "https://mixer.llc/privacy-policy/")!) {
                HStack {
                    Text("Privacy Policy")
                    Spacer()
                    Image(systemName: "link")
                        .foregroundColor(.secondary)
                }
            }
            
            Link(destination: URL(string: "https://mixer.llc")!) {
                HStack {
                    Text("Terms of Service")
                    Spacer()
                    Image(systemName: "link")
                        .foregroundColor(.secondary)
                }
            }
        }
        .listRowBackground(Color.mixerSecondaryBackground)
        .accentColor(.white)
    }
}
