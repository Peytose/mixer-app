//
//  GuestListView.swift
//  mixer
//
//  Created by Jose Martinez on 1/18/23.
//

import SwiftUI

struct GuestListView: View {
    @StateObject private var guestManager = GuestManager()

    @State private var searchText = ""
    @State var showUserInfoModal = false
    @State var showAlert = false
    @StateObject var mockUserDictionary = MockUserDictionary()

    var body: some View {
        NavigationView {
            VStack {
                if guests.isEmpty {
                    Text("No guests found")
                        .font(.headline)
                        .padding(.top)
                }
                
                List {
                    content
                }
            }
            .scrollContentBackground(.hidden)
            .background(Color.mixerBackground)
            .navigationTitle("Guest List")
            .navigationBarTitleDisplayMode(.automatic)
            .searchable(text: $searchText, prompt: "Search Guests") {
                ForEach(suggestions) { suggestion in
                    Text(suggestion.text)
                        .searchCompletion(suggestion.text)
                }
            }
        }
        .preferredColorScheme(.dark)
        .sheet(isPresented: $showUserInfoModal) {
            GuestListUserView(user: guestManager.selectedGuest!)
                .presentationDetents([.medium])
        }
        .alert("Checked In", isPresented: $showAlert, actions: {}) {
            Text("Guest has been checked in")
        }
    }
    var content: some View {
        ForEach(mockUserDictionary.sectionDictionary.keys.sorted(), id:\.self) { key in
            if let guests = mockUserDictionary.sectionDictionary[key]!.filter({ (guest) -> Bool in
                self.searchText.isEmpty ? true :
                "\(guest)".lowercased().contains(self.searchText.lowercased())}), !guests.isEmpty
            {
                Section(header: Text("\(key)")) {
                    ForEach(guests) { guest in
                        VStack(alignment: .leading, spacing: 1) {
                            HStack(spacing: 8) {
                                Image(guest.image)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 30, height: 30)
                                    .clipShape(Circle())
                                
                                HStack(spacing: 0) {
                                    Text(guest.name)
                                        .font(.callout.weight(.semibold))
                                        .foregroundColor(.white)
                                        .lineLimit(1)
                                        .minimumScaleFactor(0.7)
                                    
                                    Image("human-male")
                                        .resizable()
                                        .renderingMode(.template)
                                        .aspectRatio(contentMode: .fit)
                                        .foregroundColor(.white)
                                        .frame(width: 20, height: 20)
                                }
                                
                                Spacer()
                                
                                Image(systemName: "graduationcap.fill")
                                    .imageScale(.small)
                                    .foregroundColor(.secondary)
                                
                                Text(guest.school)
                                    .font(.subheadline.weight(.medium))
                                    .foregroundColor(.secondary)
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.7)
                            }
                            
                            Text("Invited by Brian Robinson")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .lineLimit(1)
                                .minimumScaleFactor(0.7)
                        }
                        .padding(.vertical, -4)
                        .listRowBackground(Color.mixerSecondaryBackground.opacity(0.7))
                        .swipeActions {
                            Button(role: .destructive) {
                            } label: {
                                Label("Delete", systemImage: "trash.fill")
                            }
                            
                            Button() {
                                showAlert.toggle()
                            } label: {
                                VStack {
                                    Label("Delete", systemImage: "list.clipboard")
                                    Text("Add to guest list")
                                }
                            }
                            .tint(.green)
                        }
                        .onTapGesture {
                            showUserInfoModal.toggle()
                            guestManager.selectedGuest = guest
                        }
                    }
                }
            }
        }
    }
    
    var suggestions: [Suggestion2] {
        if searchText.isEmpty {
            return suggestionsData2
        } else {
            return suggestionsData2.filter { $0.text.localizedCaseInsensitiveContains(searchText) }
        }
    }
}

struct GuestListView_Previews: PreviewProvider {
    static var previews: some View {
        GuestListView()
    }
}

