//
//  ReviewCreatedEventView.swift
//  mixer
//
//  Created by Jose Martinez on 12/22/22.
//

//
//  EventVisibilityView.swift
//  mixer
//
//  Created by Jose Martinez on 12/22/22.
//


import SwiftUI

struct ReviewCreatedEventView: View {
    @StateObject var viewModel = CreateEventViewModel()
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        ZStack {
            Color.mixerBackground
                .ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 15) {
                    Text("Private Party \(Image(systemName: "lock.fill"))")
                        .font(.title3).fontWeight(.medium)
                        .foregroundColor(.secondary)
                        .padding(.bottom, 5)
                    
                    HStack {
                        Text("Starts:")
                            .font(.title3).fontWeight(.medium)
                        
                        Text("Fri, Jan 20 at 9:00 PM")
                            .font(.headline)
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("Ends:")
                            .font(.title3).fontWeight(.medium)
                        
                        Text("Sat, Jan 21 at 1:00 AM")
                            .font(.headline)
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("Address:")
                            .font(.title3).fontWeight(.medium)
                        
                        Text("528 Beacon St, Boston MA 02215")
                            .font(.headline)
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity)

                    }
                    
                    HStack {
                        Text("Type:")
                            .font(.title3).fontWeight(.medium)
                        
                        Text("Wet")
                            .font(.headline)
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("Theme:")
                            .font(.title3).fontWeight(.medium)
                        
                        Text("Neon")
                            .font(.headline)
                            .foregroundColor(.secondary)
                    }
                    
                    VStack(alignment: .leading) {
                        Text("Event Description:")
                            .font(.title3).fontWeight(.medium)
                        
                        Text("Neon party at Theta Chi, need we say more?cjhsdbvsjdvvjshdvbsdvsjhdbvsdvjhbsdvkjndsvklnsdkvjnjsdjvnsdvnskdvnsdvskjvsdvnsdkjvnsdkvjndsvskvjndsvsdjnvsvsdjvsdvhbsdvsjdhvbsdvj")
                            .font(.headline)
                            .foregroundColor(.secondary)
                            .lineLimit(4)
                            .frame(maxWidth: .infinity)
                    }
                    
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Event Flyer:")
                            .font(.title3).fontWeight(.medium)
                        
                        Image(uiImage: viewModel.flyer)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .cornerRadius(20)
                            .frame(width: 208, height: 250, alignment: .center)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding()
                            
                        
                    }
                }
                .preferredColorScheme(.dark)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                .padding(EdgeInsets(top: 0, leading: 21, bottom: 80, trailing: 10))
            }
            
            
            
        }
        .overlay(alignment: .bottom, content: {
            NavigationLink(destination: EventFlyerUploadView()) {
                NextButton(text: "Create Party")
            }
        })
        .navigationBarTitle(Text("Review Neon Party"), displayMode: .large)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }, label: {
                    BackArrowButton()
                })
            }
        }
    }
    

    
    var includeInviteListSection: some View {
        Section {
            Toggle("Invite List?", isOn: $viewModel.includeInviteList.animation())
                .font(.body.weight(.semibold))
        } header: {
            Text("Include Invite List")
        }
        .listRowBackground(Color.mixerSecondaryBackground)
    }
    
    var inviteLimitSection: some View {
        Section {
            Toggle("Invite Limit?", isOn: $viewModel.isInviteLimit.animation())
                .font(.body.weight(.semibold))

            if viewModel.isInviteLimit == true {
                TextField("Invites per brother*", text: $viewModel.guestLimit)
                    .foregroundColor(Color.mainFont)
                    .keyboardType(.numberPad)
            }
        } header: {
            Text("Maximum Invites")
        }
        .listRowBackground(Color.mixerSecondaryBackground)
    }
    

    
}


struct ReviewCreatedEventView_Previews: PreviewProvider {
    static var previews: some View {
        ReviewCreatedEventView()
    }
}

