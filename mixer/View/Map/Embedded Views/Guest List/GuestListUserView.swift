//
//  GuestListUserView.swift
//  mixer
//
//  Created by Jose Martinez on 1/19/23.
//

import SwiftUI

struct GuestListUserView: View {
    @State var showAlert = false
    var user: MockUser
    
    var body: some View {
        VStack {
            Image(user.image)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .clipShape(Circle())
                .frame(width: 180, height: 180)
                .padding(.top)
            
            Text(user.name)
                .font(.title.weight(.semibold))
            
            HStack() {
                Image(systemName: "graduationcap.fill")
                    .imageScale(.small)
                    .padding(.trailing, -6)
                
                Text(user.school)
                    .font(.headline)
                    .foregroundColor(.secondary)
                
                
                Image(systemName: "house.fill")
                    .imageScale(.small)
                    .padding(.trailing, -6)

                Text(user.affiliation)
                    .font(.headline)
                    .foregroundColor(.secondary)
            }
            
            HStack(spacing: 50) {
                VStack(alignment: .center, spacing: 0) {
                    Text(user.age)
                        .font(.title2.weight(.bold))
                    
                    Text("Age")
                        .foregroundColor(.secondary)
                        .font(.body.weight(.semibold))
                }
                
                
                VStack(alignment: .center, spacing: 0) {
                    Text("Male")
                        .font(.title2.weight(.bold))
                    
                    Text("Gender")
                        .foregroundColor(.secondary)
                        .font(.body.weight(.semibold))
                }
                
            }
            .font(.title3.weight(.semibold))
            .padding(2)
            
            Text("Invited by Brian Robinson")
                .font(.headline)
                .foregroundColor(.secondary)
                .padding(.bottom, 10)
            
            HStack {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(Color.mixerPurpleGradient)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .padding(.horizontal, 30)
                    .shadow(radius: 15)
                    .shadow(radius: 5, y: 10)
                    .overlay(content: {
                        Text("Check in")
                            .foregroundColor(Color.white)
                            .font(.title2.weight(.semibold))
                    })
                
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(Color.red.opacity(0.7))
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .padding(.horizontal, 30)
                    .shadow(radius: 15)
                    .shadow(radius: 5, y: 10)
                    .overlay(content: {
                        Text("Blacklist")
                            .foregroundColor(Color.white)
                            .font(.title2.weight(.semibold))
                    })
                    .onTapGesture {
                        showAlert.toggle()
                    }
            }
            
        }
        .frame(maxWidth: .infinity ,maxHeight: .infinity, alignment: .top)
        .background(Color.mixerBackground)
        .preferredColorScheme(.dark)
        .alert("Are you sure?", isPresented: $showAlert, actions: {
            // 1
            Button("Cancel", role: .cancel, action: {})
            
            Button("Blacklist", role: .destructive, action: {})
        }, message: {
            Text("Selecting Blacklist will add this user to your organization's blacklist thus preventing them from attending your organization's events in the future.")
        })
     }
}

struct GuestListUserView_Previews: PreviewProvider {
    static var previews: some View {
        GuestListUserView(user: users[0])
    }
}
