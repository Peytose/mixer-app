//
//  GuestlistView.swift
//  mixer
//
//  Created by Jose Martinez on 1/18/23.
//

import SwiftUI

struct GuestlistView: View {
    @ObservedObject var viewModel: GuestlistViewModel
    @State private var searchText: String      = ""
    @State var showAddGuestView: Bool          = false
    
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
                                    VStack(alignment: .leading) {
                                        HStack(spacing: 8) {
                                            Text(guest.name)
                                                .font(.callout)
                                                .fontWeight(.semibold)
                                                .foregroundColor(.white)
                                                .lineLimit(1)
                                                .minimumScaleFactor(0.7)

                                            if let status = guest.status {
                                                Image(systemName: status == GuestStatus.invited ? "dot.radiowaves.right" : "checkmark")
                                                    .imageScale(.small)
                                                    .foregroundColor(status == GuestStatus.invited ? Color.secondary : Color.mixerIndigo)
                                            }

                                            Spacer()

                                            HStack(alignment: .center) {
                                                Image(systemName: "graduationcap.fill")
                                                    .imageScale(.small)
                                                    .foregroundColor(.secondary)
                                                
                                                Text(guest.university)
                                                    .font(.subheadline.weight(.medium))
                                                    .foregroundColor(.secondary)
                                                    .lineLimit(1)
                                                    .minimumScaleFactor(0.7)
                                            }
                                        }

                                        if let name = guest.invitedBy {
                                            Text("Invited by \(name)")
                                                .font(.subheadline)
                                                .foregroundColor(.secondary)
                                                .lineLimit(1)
                                                .minimumScaleFactor(0.7)
                                        }
                                    }
                                    .padding()
                                    .listRowBackground(Color.mixerSecondaryBackground.opacity(0.7))
                                    .swipeActions {
                                        Button(role: .destructive,
                                               action: { viewModel.remove(guest: guest) },
                                               label: { Label("Delete", systemImage: "trash.fill") })
                                    }
                                    .swipeActions(edge: .leading) {
                                        Button(action: { viewModel.checkIn(guest: guest) }, label: { Label("Add", systemImage: "list.clipboard") })
                                            .tint(.green)
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
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Add guest") { showAddGuestView.toggle() }
                }
            }
            .searchable(text: $searchText, prompt: "Search Guests") {
                if !searchText.isEmpty {
                    ForEach(viewModel.guests.filter({ $0.name.localizedCaseInsensitiveContains(searchText) })) { guestSuggestion in
                        Text(guestSuggestion.name)
                            .searchCompletion(guestSuggestion.name)
                    }
                }
            }
        }
        .preferredColorScheme(.dark)
        .sheet(isPresented: $showAddGuestView) { AddToGuestlistView(viewModel: viewModel,
                                                                    showAddGuestView: $showAddGuestView) }
        .alert(item: $viewModel.alertItem, content: { $0.alert })
        .alert(item: $viewModel.alertItemTwo, content: { $0.alert })
    }
}

struct GuestlistView_Previews: PreviewProvider {
    static var previews: some View {
        GuestlistView(viewModel: GuestlistViewModel(eventUid: ""))
    }
}
