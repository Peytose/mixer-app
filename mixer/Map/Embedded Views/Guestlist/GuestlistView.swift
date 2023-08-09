//
//  GuestlistView.swift
//  mixer
//
//  Created by Jose Martinez on 1/18/23.
//

import SwiftUI
import Kingfisher
import CodeScanner
import Combine

struct GuestlistView: View {
    @Environment(\.presentationMode) var mode
    @EnvironmentObject var viewModel: GuestlistViewModel
    @Binding var isShowingGuestlistView: Bool
    @State private var searchText: String             = ""
    @State private var isShowingAddGuestView: Bool    = false
    @State private var isTorchOn: Bool                = false
    
    init(isShowingGuestlistView: Binding<Bool>) {
        self._isShowingGuestlistView = isShowingGuestlistView
    }
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 0) {
                HeaderView()
                
                List {
                    if viewModel.guests.isEmpty {
                        GuestlistEmptyView()
                    } else {
                        ForEach(viewModel.guests) { guest in
                            GuestlistRow(guest: guest)
                        }
                    }
                }
                .refreshable {
                    viewModel.refreshGuests()
                }
                .configureList()
                .onTapGesture {
                    self.hideKeyboard()
                }
                .navigationBar(title: "Guestlist", displayMode: .automatic)
                .searchBar(text: $searchText, viewModel: viewModel)
                .configureToolbar(isShowingQRCodeScanView: $viewModel.isShowingQRCodeScanView,
                                  isShowingAddGuestView: $isShowingAddGuestView,
                                  isShowingGuestlistView: $isShowingGuestlistView)
                .alert(item: $viewModel.alertItem, content: { $0.alert })
                .alert(item: $viewModel.alertItemTwo, content: { $0.alert })
            }
            .onAppear { viewModel.refreshGuests() }
            .sheet(isPresented: $isShowingAddGuestView) {
                AddToGuestlistView(isShowingAddGuestView: $isShowingAddGuestView)
                    .presentationDetents([.medium])
            }
            .sheet(isPresented: $viewModel.isShowingUserInfoModal) {
                if let _ = viewModel.selectedGuest {
                    GuestlistUserView()
                        .presentationDetents([.medium])
                }
            }
            .fullScreenCover(isPresented: $viewModel.isShowingQRCodeScanView) {
                CodeScannerView(codeTypes: [.qr],
                                scanMode: .oncePerCode,
                                manualSelect: false,
                                showViewfinder: true,
                                shouldVibrateOnSuccess: true,
                                isTorchOn: isTorchOn) { response in viewModel.handleScan(response) }
                    .overlay(alignment: .topLeading) {
                        XDismissButton { viewModel.isShowingQRCodeScanView.toggle() }
                            .padding([.leading, .top])
                    }
                    .overlay(alignment: .topTrailing) {
                        Button { isTorchOn.toggle() } label: {
                            Image(systemName: isTorchOn ? "lightbulb.fill" : "lightbulb")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .foregroundColor(Color.mixerIndigo)
                                .frame(width: 40, height: 40)
                        }
                        .padding([.trailing, .top])
                    }
            }
        }
    }
}

fileprivate struct HeaderView: View {
    @EnvironmentObject var viewModel: GuestlistViewModel
    @State private var timer: AnyCancellable?
    @State private var isShowingCheckedInRatio = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text(viewModel.currentEvent?.title ?? "")
                    .secondarySubheading()

                Spacer()
                
                if !viewModel.events.isEmpty {
                    Menu("Change") {
                        ForEach(viewModel.events) { event in
                            Button(event.title) { viewModel.changeEvent(to: event) }
                        }
                    }
                    .menuTextStyle()
                }
            }
            .padding(.horizontal)
            
            Text(isShowingCheckedInRatio ? "\(viewModel.guests.filter({ $0.status == .checkedIn }).count) / \(viewModel.guests.count) guests checked in" : "\(viewModel.guests.count) \(viewModel.guests.count == 1 ? "guest" : "guests") total")
                .primaryHeading(color: .secondary)
                .lineLimit(1)
                .minimumScaleFactor(0.75)
                .padding(.leading)
                .onAppear {
                    timer = Timer.publish(every: Double.random(in: 3...7), on: .main, in: .common)
                        .autoconnect()
                        .sink { _ in
                            withAnimation(.easeInOut) {
                                self.isShowingCheckedInRatio.toggle()
                            }
                        }
                }
                .onDisappear {
                    timer?.cancel()
                }
                .onTapGesture {
                    withAnimation(.easeInOut) {
                        isShowingCheckedInRatio.toggle()
                    }
                }
        }
        .background { Color.mixerBackground.ignoresSafeArea() }
    }
}

fileprivate struct GuestlistEmptyView: View {
    var body: some View {
        Section {
            VStack(alignment: .center) {
                Text("📭 The guestlist is currently empty ...")
                    .primaryHeading()
            }
            .listRowBackground(Color.mixerSecondaryBackground)
        }
    }
}

fileprivate struct GuestlistRow: View {
    let guest: EventGuest
    @EnvironmentObject var viewModel: GuestlistViewModel
    
    var body: some View {
        HStack(alignment: .center, spacing: 8) {
            AvatarView(url: guest.profileImageUrl, size: 30)
            
            VStack(alignment: .leading, spacing: 0) {
                HStack(spacing: 5) {
                    Text(guest.name.capitalized)
                        .body(color: .white)
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                    
                    if let gender = guest.gender, let icon = AddToGuestlistView.Gender(rawValue: gender)?.icon, icon != "" {
                        Image(icon)
                            .resizable()
                            .renderingMode(.template)
                            .aspectRatio(contentMode: .fit)
                            .foregroundColor(.white)
                            .frame(width: 20, height: 20)
                    }
                    
                    if let status = guest.status {
                        Image(systemName: status == GuestStatus.invited ? "paperplane.fill" : "checkmark")
                            .imageScale(.small)
                            .foregroundColor(status == GuestStatus.invited ? Color.secondary : Color.mixerIndigo)
                            .fontWeight(.semibold)
                    }
                }
                
                if let name = guest.invitedBy {
                    Text("Invited by \(name)")
                        .footnote()
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                }
            }
            
            Spacer()
            
            Image(systemName: "graduationcap.fill")
                .imageScale(.small)
                .foregroundColor(.secondary)
            
            Text(guest.university)
                .subheadline()
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .listRowBackground(Color.mixerSecondaryBackground.opacity(0.7))
        .contentShape(Rectangle())
        .onTapGesture {
            withAnimation() {
                viewModel.isShowingUserInfoModal = true
                viewModel.selectedGuest = guest
            }
        }
        .swipeActions {
            Button(role: .destructive) {
                Task {
                    viewModel.remove(guest: guest)
                }
            } label: {
                Label("Delete", systemImage: "trash.fill")
            }
        }
        .swipeActions(edge: .leading) {
            if guest.status == .invited {
                Button {
                    Task {
                        viewModel.checkIn(guest: guest)
                    }
                } label: {
                    Label("Check-in", systemImage: "list.bullet.clipboard.fill")
                }
            }
        }
    }
}

struct GuestlistView_Previews: PreviewProvider {
    static var previews: some View {
        GuestlistView(isShowingGuestlistView: .constant(false))
            .environmentObject(GuestlistViewModel(hostEventsDict: [CachedHost(from: Mockdata.host): [CachedEvent(from: Mockdata.event)]]))
    }
}
