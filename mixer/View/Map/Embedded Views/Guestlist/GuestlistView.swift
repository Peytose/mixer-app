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
    @Binding var isShowingGuestlistView: Bool
    @State private var searchText: String = ""
    @State var showAddGuestView: Bool     = false
    @State var showGuestlistCharts: Bool  = false
    
    init(viewModel: GuestlistViewModel, isShowingGuestlistView: Binding<Bool>) {
        self.viewModel = viewModel
        self._isShowingGuestlistView = isShowingGuestlistView
    }
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 0) {
                HStack {
                    Text(viewModel.event.title)
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(.secondary)

                    Spacer()
                    
                    Menu("Change") {
                        Button("Event 1", action: {})
                        Button("Event 2", action: {})
                        Button("Event 3", action: {})
                        Button("Event 4", action: {})
                        Button("See all", action: {})
                    }
                    .accentColor(.mixerIndigo)
                }
                .padding(.horizontal)
                
                Text("\(viewModel.guests.count) guests")
                    .font(.headline)
                    .foregroundColor(.secondary)
                    .padding(.horizontal)

                List {
                    if viewModel.guests.isEmpty {
                        Section {
                            VStack(alignment: .center) {
                                Text("📭 The guestlist is currently empty ...")
                                    .font(.headline)
                            }
                            .listRowBackground(Color.mixerSecondaryBackground)
                        }
                    }
                    
                    ForEach(viewModel.sectionDictionary.keys.sorted(), id:\.self) { key in
                        if var guests = viewModel.sectionDictionary[key]?.filter({ guest -> Bool in
                            searchText.isEmpty || guest.name.lowercased().contains(searchText.lowercased())
                        }), !guests.isEmpty {
                            Section {
                                ForEach(guests.indices, id: \.self) { index in
                                    GuestlistRow(guest: guests[index])
                                        .contentShape(Rectangle())
                                        .onTapGesture {
                                            withAnimation() {
                                                viewModel.showUserInfoModal = true
                                                viewModel.selectedGuest = guests[index]
                                            }
                                        }
                                        .swipeActions {
                                            Button(role: .destructive) {
                                                viewModel.remove(guest: guests[index])
                                            } label: {
                                                Label("Delete", systemImage: "trash.fill")
                                            }
                                        }
                                        .swipeActions(edge: .leading) {
                                            Button {
                                                viewModel.checkIn(guest: &guests[index])
                                            } label: {
                                                Label("Check-in", systemImage: "list.bullet.clipboard.fill")
                                            }
                                        }
                                }
                            } header: { Text("\(key)") }
                        }
                    }
                }
                .refreshable { viewModel.refreshGuests() }
                .scrollContentBackground(.hidden)
                .background { Color.mixerBackground.ignoresSafeArea()}
                .onTapGesture {
                    self.hideKeyboard()
                }
                .navigationTitle("Guestlist")
                .navigationBarTitleDisplayMode(.automatic)
                .searchable(text: $searchText, prompt: "Search Guests")
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        HStack {
                            Button("Analytics") { showGuestlistCharts.toggle() }
                            
                            Button("Add Guest") { showAddGuestView.toggle() }
                                .foregroundColor(.blue)
                        }
                    }

                    ToolbarItem(placement: .navigationBarLeading) {
                        HStack {
                            Button { isShowingGuestlistView = false } label: {
                                Image(systemName: "xmark")
                                    .font(.title3)
                                    .fontWeight(.medium)
                                    .foregroundColor(.white)
                                    .contentShape(Rectangle())
                            }
                        }
                    }
                }
            }
            .background(Color.mixerBackground)
        }
        .background(Color.mixerBackground.ignoresSafeArea())
        .preferredColorScheme(.dark)
        .sheet(isPresented: $showAddGuestView) { AddToGuestlistView(viewModel: viewModel,
                                                                    showAddGuestView: $showAddGuestView) }
        .sheet(isPresented: $viewModel.showUserInfoModal) {
            if let guest = viewModel.selectedGuest {
                GuestlistUserView(viewModel: viewModel, guest: guest)
                    .presentationDetents([.medium])
            }
        }
        .sheet(isPresented: $showGuestlistCharts, content: {
            GuestlistChartsView()
        })
        .alert(item: $viewModel.alertItem, content: { $0.alert })
        .alert(item: $viewModel.alertItemTwo, content: { $0.alert })
    }
}

struct GuestlistView_Previews: PreviewProvider {
    static var previews: some View {
        GuestlistView(viewModel: GuestlistViewModel(event: CachedEvent(from: Mockdata.event)), isShowingGuestlistView: .constant(false))
    }
}

struct GuestlistRow: View {
    let guest: EventGuest
    
    var body: some View {
        HStack(alignment: .center, spacing: 8) {
            if let imageUrl = guest.profileImageUrl {
                KFImage(URL(string: imageUrl))
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 30, height: 30)
                    .clipShape(Circle())
            } else {
                Image("default-avatar")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 30, height: 30)
                    .clipShape(Circle())
            }
            
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
