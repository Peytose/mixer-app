//
//  EnterBirthdayAndUniversityView.swift
//  mixer
//
//  Created by Jose Martinez on 4/2/23.
//

import SwiftUI

struct EnterBirthdayAndUniversityView: View {
    @EnvironmentObject private var viewModel: AuthViewModel
    @StateObject var universitySearchViewModel = UniversitySearchViewModel()
    @State private var isWithoutUniversity = false
    @State private var isEditing = false
    
    var body: some View {
        FlowContainerView {
            ScrollView {
                VStack(spacing: 50) {
                    SignUpTextField(input: $viewModel.birthdayStr,
                                    title: "When's your birthday?",
                                    placeholder: "MM / DD / YYYY",
                                    footnote: "Mixer uses your birthday for research and verification purposes. You can change the visibilty of your age in your settings.",
                                    keyboard: .numberPad)
                    .onChange(of: viewModel.birthdayStr) { newValue in
                        viewModel.birthdayStr = newValue.applyPattern()
                    }
                    
                    Divider()
                        .padding(.horizontal)
                    
                    // View for selecting a university
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Now, select your university")
                                .largeTitle(weight: .semibold)
                                .lineLimit(1)
                                .minimumScaleFactor(0.7)
                        
                        if viewModel.universityName != "" {
                            Text(viewModel.universityName)
                                .body()
                                .lineLimit(2)
                                .minimumScaleFactor(0.8)
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            UniversitySearchView(viewModel: universitySearchViewModel,
                                                 action: viewModel.selectUniversity(_:))
                            .onTapGesture { isEditing.toggle() }
                            .padding(EdgeInsets(top: 12, leading: 10, bottom: 12, trailing: 10))
                            .background {
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(lineWidth: isEditing ? 3 : 1)
                                    .foregroundColor(Color.theme.mixerIndigo)
                            }
                            .disabled(isWithoutUniversity)
                            
                            Toggle("No university?", isOn: $isWithoutUniversity)
                                .toggleStyle(iOSCheckboxToggleStyle())
                                .buttonStyle(.plain)
                                .onChange(of: isWithoutUniversity) { newValue in
                                    if newValue {
                                        let university = University(id: "com",
                                                                    domain: ".com",
                                                                    name: "Non-university",
                                                                    shortName: "Non-university",
                                                                    url: "https://www.partywithmixer.com")
                                        viewModel.selectUniversity(university)
                                    } else {
                                        viewModel.universityId   = ""
                                        viewModel.universityName = ""
                                    }
                                }
                            
                            if !isWithoutUniversity {
                                Text("To ensure a community of verified university affiliates, we ask that you confirm your university via email verification in your profile settings after registration. Please make sure to use your university email address for a seamless verification process.")
                                    .font(.footnote)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .textFieldFrame()
                }
                .padding(.bottom, 100)
            }
        }
    }
}

struct EnterBirthdayAndUniversityView_Preview: PreviewProvider {
    static var previews: some View {
        EnterBirthdayAndUniversityView()
            .environmentObject(AuthViewModel.shared)
    }
}
