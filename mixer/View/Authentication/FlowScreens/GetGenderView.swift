//
//  GetGenderView.swift
//  mixer
//
//  Created by Jose Martinez on 4/2/23.
//

import SwiftUI

struct GetGenderView: View {
    @Binding var gender: String
    @Binding var isGenderPublic: Bool
    
    let action: () -> Void
    
    var body: some View {
        OnboardingPageViewContainer {
            VStack(alignment: .leading, spacing: 80) {
                Text("I am a \(gender.lowercased())")
                    .font(.largeTitle)
                    .foregroundColor(.mainFont)
                    .fontWeight(.semibold)
                    .lineLimit(2)
                    .minimumScaleFactor(0.75)
                    .padding(.bottom, 10)
                
                VStack {
                    GenderButton(title: "Woman")
                        .onTapGesture {
                            self.gender = "Woman"
                        }
                    
                    GenderButton(title: "Man")
                        .onTapGesture {
                            self.gender = "Man"
                        }
                    
                    GenderButton(title: "Other")
                        .onTapGesture {
                            self.gender = "Other"
                        }
                    
                    GenderButton(title: "Prefer not to say")
                        .onTapGesture {
                            self.gender = "Other"
                        }
                }
                
                Spacer()
            }
        }
        .overlay(alignment: .bottom) {
            Toggle(isOn: $isGenderPublic) {
                Text("Show my gender on my profile")
                
            }
            .toggleStyle(iOSCheckboxToggleStyle())
            .buttonStyle(.plain)
            .offset(y: -100)
            
            ContinueSignUpButton(text: "Continue", action: action, isActive: true)
        }
    }
}

struct GetGenderView_Previews: PreviewProvider {
    static var previews: some View {
        GetGenderView(gender: .constant("Male"), isGenderPublic: .constant(false)) {
        }
        .preferredColorScheme(.dark)
    }
}

fileprivate struct GenderButton: View {
    let title: String
        
    var body: some View {
        Capsule()
            .stroke(lineWidth: 2)
            .fill(Color.mixerPurpleGradient.opacity(0.8))
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
