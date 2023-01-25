//
//  GetGender.swift
//  mixer
//
//  Created by Peyton Lyons on 11/24/22.
//

import SwiftUI

struct GetGender: View {
    @Binding var gender: String
    let action: () -> Void
    
    var body: some View {
        VStack {
            GenderPicker(title: "Almost there! What's your gender?",
                         input: $gender,
                         placeholder: "",
                         footnote: "We use this for research purposes. It will not be public.")
            
            Spacer()
        }
        .overlay(alignment: .bottom) {
            ContinueSignUpButton(text: "Continue", action: action)
                .padding(.bottom, 30)
        }
    }
}

fileprivate struct GenderPicker: View {
    let title: String
    var input: Binding<String>
    let placeholder: String
    let footnote: String
    let genders = ["Female", "Male", "Other"]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 7) {
            Text(title)
                .foregroundColor(.mainFont)
                .font(.title.weight(.semibold))
                .lineLimit(2)
                .minimumScaleFactor(0.75)
                .padding(.bottom, 5)
            
            Picker(placeholder, selection: input) {
                ForEach(genders, id: \.self) {
                    Text($0)
                }
            }
            .pickerStyle(.menu)
            .foregroundColor(Color.mainFont)
            .font(.system(size: 25))
            .tint(Color.mixerIndigo)
            .padding(.bottom, -5)
            
            Rectangle()
                .frame(height: 1)
                .foregroundColor(.gray)
            
            Text(footnote)
                .foregroundColor(.secondary)
                .font(.footnote)
        }
        .frame(width: 300)
    }
}

struct GetGender_Previews: PreviewProvider {
    static var previews: some View {
        GetGender(gender: .constant("Female")) {}
            .preferredColorScheme(.dark)
    }
}
