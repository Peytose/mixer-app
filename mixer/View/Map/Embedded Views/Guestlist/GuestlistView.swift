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
                                    VStack(alignment: .leading, spacing: 4) {
                                        HStack(spacing: 8) {
//                                            KFImage(URL(string: guest.guestImageUrl)
//                                                .resizable()
//                                                .aspectRatio(contentMode: .fill)
//                                                .frame(width: 28, height: 28)
//                                                .clipShape(Circle())

                                            HStack(spacing: 0) {
                                                Text(guest.name.capitalized)
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
                                            
                                            if let status = guest.status {
                                                Image(systemName: status == GuestStatus.invited ? "dot.radiowaves.right" : "checkmark")
                                                    .imageScale(.small)
                                                    .foregroundColor(status == GuestStatus.invited ? Color.secondary : Color.mixerIndigo)
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
                                        
                                        if let name = guest.invitedBy {
                                            Text("Invited by \(name)")
                                                .font(.subheadline)
                                                .foregroundColor(.secondary)
                                                .lineLimit(1)
                                                .minimumScaleFactor(0.7)
                                        }
                                        
                                    }
                                    .padding(.vertical, -4)
                                    .listRowBackground(Color.mixerSecondaryBackground.opacity(0.7))
                                    .swipeActions {
                                        Button(role: .destructive,
                                               action: { viewModel.remove(guest: guest) },
                                               label: { Label("Delete", systemImage: "trash.fill") })
                                    }
                                    .swipeActions(edge: .leading) {
                                        Button(action: { viewModel.checkIn(guest: guest) }, label: { Label("Add", systemImage: "list.clipboard") })
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
