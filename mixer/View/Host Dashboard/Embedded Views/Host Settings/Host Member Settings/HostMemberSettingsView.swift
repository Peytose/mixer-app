//
//  HostMemberSettingsView.swift
//  mixer
//
//  Created by Jose Martinez on 1/21/23.
//

import SwiftUI

struct HostMemberSettingsView: View {
    
    var results: [MockUser] {
        return users
    }
    
    var body: some View {
            List {
                section
                
                preferencesSection
            }
            .scrollContentBackground(.hidden)
            .background(Color.mixerBackground)
            .navigationTitle("Members")
            .navigationBarTitleDisplayMode(.inline)
            .scrollIndicators(.hidden)
            .preferredColorScheme(.dark)
            .toolbar {
                ToolbarItem() {
                    Button(action: {
                    }, label: {
                        Text("Add Member")
                            .foregroundColor(.blue)
                    })
                }
            }
    }
    
    var section: some View {
        VStack {
            HStack(spacing: -35) {
                Circle()
                    .stroke()
                    .foregroundColor(.mixerSecondaryBackground)
                    .frame(width: 80, height: 60)
                    .overlay {
                        Image("mock-user-3")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .clipShape(Circle())
                    }
                
                Circle()
                    .stroke()
                    .foregroundColor(.mixerSecondaryBackground)
                    .frame(width: 80, height: 60)
                    .overlay {
                        Image("mock-user-4")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .clipShape(Circle())
                    }
                
                Circle()
                    .stroke()
                    .foregroundColor(.mixerSecondaryBackground)
                    .frame(width: 80, height: 60)
                    .overlay {
                        Image("mock-user-1")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .clipShape(Circle())
                    }
                
                Circle()
                    .stroke()
                    .foregroundColor(.mixerSecondaryBackground)
                    .frame(width: 80, height: 60)
                    .overlay {
                        Image("mock-user-5")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .clipShape(Circle())
                    }
                
                Circle()
                    .fill(Color.SlightlyDarkerBlueBackground)
                    .frame(width: 80, height: 60)
                    .overlay {
                        Text("+29")
                            .foregroundColor(.white)
                            .font(.caption)
                    }
                
                Text("Members")
                    .font(.headline)
                    .padding(.leading, 14)
            }
            .frame(maxWidth: .infinity)
            
            Text("MIT Theta Chi")
                .font(.title.bold())
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .listRowBackground(Color.clear)
        
        
    }
    
    var preferencesSection: some View {
        Section(header: Text("Members").fontWeight(.semibold)) {
            ForEach(Array(results.enumerated().prefix(9)), id: \.offset) { index, user in
                NavigationLink(destination: UserProfileView(user: user)) {
                    HStack(spacing: 10) {
                        Image(user.image)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .clipShape(Circle())
                            .frame(width: 40, height: 40)
                        
                        VStack(alignment: .leading) {
                            HStack {
                                Text(user.name)
                                    .font(.body)
                                    .lineLimit(1)
                                
                                    .foregroundColor(.white)
                                Text(user.school)
                                    .font(.body)
                                    .foregroundColor(.secondary)
                            }
                            
                            Text("Brother")
                                .font(.footnote)
                                .foregroundColor(.secondary)
                                .lineLimit(1)
                        }
                    }
                    .padding(.vertical, -1)
                    .swipeActions {
                        Button(role: .destructive) {
                            
                        } label: {
                            Image(systemName: "trash")
                        }
                        .tint(Color.red)

                    }
                }
            }
        }
        .listRowBackground(Color.mixerSecondaryBackground)
    }
    
    
    struct HostMemberSettingsView_Previews: PreviewProvider {
        static var previews: some View {
            HostMemberSettingsView()
        }
    }
    
    struct ImageCircleBackground: View {
        var image: String = "mock-user-1"
        
        var body: some View {
            Image(image)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .clipShape(Circle())
                .frame(width: 28, height: 46)
                .padding(1)
                .background(Color.mixerSecondaryBackground, in: Circle())
        }
    }
}
