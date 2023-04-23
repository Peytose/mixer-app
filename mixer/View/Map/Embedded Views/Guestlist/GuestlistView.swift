//
//  GuestlistView.swift
//  mixer
//
//  Created by Jose Martinez on 1/18/23.
//

import SwiftUI
import Kingfisher

struct GuestlistView: View {
    @ObservedObject var viewModel: GuestlistViewModel
    @State private var searchText: String      = ""
    @State var showAddGuestView: Bool          = false
    @State var showUserInfoModal: Bool         = false
    @State var showCheckinAlert                = false
    
    init(viewModel: GuestlistViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        NavigationView {
            VStack {
                if viewModel.guests.isEmpty {
                    Text("No guests found")
                        .font(.headline)
                        .padding(.top)
                }
                
                List {
                    ForEach(viewModel.sectionDictionary.keys.sorted(), id:\.self) { key in
                        if let guests = viewModel.sectionDictionary[key]?.filter({ guest -> Bool in
                            searchText.isEmpty || guest.name.lowercased().contains(searchText.lowercased())
                        }), !guests.isEmpty {
                            Section {
                                ForEach(guests) { guest in
                                    GuestlistRow(guest: guest)
                                        .swipeActions {
                                            Button(role: .destructive,
                                                   action: { viewModel.remove(guest: guest) },
                                                   label: { Label("Delete", systemImage: "trash.fill") })
                                        }
                                        .swipeActions(edge: .leading) {
                                            Button(action: {
                                                viewModel.checkIn(guest: guest)
                                                showCheckinAlert.toggle()
                                            }, label: { Label("Add", systemImage: "list.clipboard") })
                                                .tint(Color.mixerIndigo)
                                        }
                                        .contentShape(Rectangle())
                                        .onTapGesture {
                                            withAnimation() {
                                                showUserInfoModal.toggle()
                                                viewModel.selectedGuest = guest
                                            }
                                        }
                                }
                            } header: { Text("\(key)") }
                        }
                    }
                }
            }
            .scrollContentBackground(.hidden)
            .background(Color.mixerBackground)
            .navigationTitle("Guest List")
            .navigationBarTitleDisplayMode(.automatic)
            .searchable(text: $searchText, prompt: "Search Guests") {
                if !searchText.isEmpty {
                    ForEach(viewModel.guests.filter({ $0.name.localizedCaseInsensitiveContains(searchText) })) { guestSuggestion in
                        Text(guestSuggestion.name)
                            .searchCompletion(guestSuggestion.name)
                    }
                }
            }
            .alert("Checked In", isPresented: $showCheckinAlert, actions: {}) {
                Text("Guest has been checked in")
            }
            .toolbar {
                ToolbarItem() {
                    Button("Add Guest") { showAddGuestView.toggle() }
                        .foregroundColor(.blue)
                }
                
            }
            
        }
        .preferredColorScheme(.dark)
        .sheet(isPresented: $showAddGuestView) { AddToGuestlistView(viewModel: viewModel,
                                                                    showAddGuestView: $showAddGuestView) }
        //        .sheet(isPresented: $showUserInfoModal, content: {
        //            GuestListUserView(user: guestManager.selectedGuest!)
        //                .presentationDetents([.medium])
        //        })
        .alert(item: $viewModel.alertItem, content: { $0.alert })
        .alert(item: $viewModel.alertItemTwo, content: { $0.alert })
    }
}

struct GuestlistView_Previews: PreviewProvider {
    static var previews: some View {
        GuestlistView(viewModel: GuestlistViewModel(eventUid: "r9g2vmTGF7RLefejzGko"))
    }
}

struct GuestlistRow: View {
    let guest: EventGuest
    
    var body: some View {
        HStack(alignment: .center, spacing: 8) {
            Image("default-avatar")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 30, height: 30)
                .clipShape(Circle())
            
            VStack(alignment: .leading, spacing: 0) {
                HStack(spacing: 0) {
                    Text(guest.name.capitalized)
                        .font(.callout.weight(.semibold))
                        .foregroundColor(.white)
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                    
                    
                    if let gender = guest.gender {
                        if let icon = AddToGuestlistView.Gender(rawValue: gender)?.icon {
                            Image(icon)
                                .resizable()
                                .renderingMode(.template)
                                .aspectRatio(contentMode: .fit)
                                .foregroundColor(.white)
                                .frame(width: 20, height: 20)
                        }
                    }
                    
                    if let status = guest.status {
                        Image(systemName: status == GuestStatus.invited ? "" : "checkmark")
                            .imageScale(.small)
                            .foregroundColor(status == GuestStatus.invited ? Color.secondary : Color.mixerIndigo)
                            .fontWeight(.semibold)
                    }
                }
                
                if let name = guest.invitedBy {
                    Text("Invited by \(name)")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                }
            }
            
            Spacer()
            
            Image(systemName: "graduationcap.fill")
                .imageScale(.small)
                .foregroundColor(.secondary)
            
            Text(guest.university)
                .font(.subheadline.weight(.medium))
                .foregroundColor(.secondary)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .listRowBackground(Color.mixerSecondaryBackground.opacity(0.7))
    }
}
