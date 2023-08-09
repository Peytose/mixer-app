//
//  SelectGenderView.swift
//  mixer
//
//  Created by Jose Martinez on 4/2/23.
//

import SwiftUI

struct SelectGenderView: View {
    @EnvironmentObject private var viewModel: AuthViewModel
    
    private var genderText: String {
        switch viewModel.gender {
            case .other: return "I prefer to identify as something else"
            case .preferNotToSay: return "I prefer not to say my gender"
            default: return "I am a \(viewModel.gender.stringVal.lowercased())"
        }
    }
    
    var body: some View {
        OnboardingPageViewContainer {
            VStack(alignment: .leading, spacing: 80) {
                Text(genderText)
                    .largeTitle(weight: .semibold)
                    .lineLimit(2)
                    .minimumScaleFactor(0.75)
                    .padding(.bottom, 10)
                
                VStack {
                    ForEach(Gender.allCases, id: \.self) { genderOption in
                        GenderButton(title: genderOption.stringVal)
                            .onTapGesture {
                                viewModel.gender = genderOption
                            }
                    }
                }
                
                Spacer()
            }
        }
    }
}

struct SelectGenderView_Previews: PreviewProvider {
    static var previews: some View {
        SelectGenderView()
            .environmentObject(AuthViewModel.shared)
    }
}

fileprivate struct GenderButton: View {
    let title: String
        
    var body: some View {
        Capsule()
            .stroke(lineWidth: 2)
            .fill(Color.theme.mixerIndigo.opacity(0.8))
            .frame(width: DeviceTypes.ScreenSize.width * 0.9, height: 55)
            .shadow(radius: 20, x: -8, y: -8)
            .shadow(radius: 20, x: 8, y: 8)
            .overlay {
                Text(title)
                    .font(.body.weight(.medium))
                    .foregroundColor(.white)
            }
            .contentShape(Rectangle())
            .padding(.bottom, 20)
    }
}
