//
//  GuestlistView.swift
//  mixer
//
//  Created by Peyton Lyons on 8/10/23.
//

import SwiftUI
import FirebaseFirestore
import Kingfisher
import CodeScanner
import Combine

struct GuestlistView: View {
    @StateObject var viewModel: GuestlistViewModel
    @State private var isShowingUserInfoModal  = false
    @State private var isShowingQRCodeScanView = false
    @State private var isTorchOn               = false
    @State private var searchText              = ""
    
    init(event: Event) {
        self._viewModel = StateObject(wrappedValue: GuestlistViewModel(event: event))
    }
    
    var body: some View {
            ZStack {
                Color.theme.backgroundColor
                    .ignoresSafeArea()
                
                VStack {
                    StickyHeaderView(items: GuestStatus.allCases,
                                     selectedItem: $viewModel.selectedGuestSection)
                    
                    // Section count text
                    HStack {
                        Text(viewModel.getGuestlistSectionCountText())
                        
                        Spacer()
                        
                        HStack {
                            Text(viewModel.getGenderRatioText())
                        }
                    }
                    .font(.headline)
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)
                    .padding(.horizontal)
                    
                    Group {
                        switch viewModel.viewState {
                        case .loading:
                            LoadingView()
                            Spacer()
                        case .empty:
                            emptyView
                            Spacer()
                        case .list:
                            List {
                                ForEach(viewModel.sectionedGuests.keys.sorted(), id: \.self) { key in
                                    Section(header: Text(key)) {
                                        ForEach(viewModel.sectionedGuests[key] ?? []) { guest in
                                            GuestlistRow(guest: guest)
                                                .environmentObject(viewModel)
                                        }
                                    }
                                }
                                
                                Spacer(minLength: 100)
                                    .listRowBackground(Color.clear)
                            }
                            .scrollContentBackground(.hidden)
                        }
                    }
                }
            }
            .navigationBarBackButtonHidden(true)
            .navigationBar(title: viewModel.event.title, displayMode: .inline)
            .searchable(text: $searchText, prompt: "Search guests..") {
                ForEach(viewModel.filterGuests(for: searchText)) { guest in
                    GuestlistRow(guest: guest)
                        .environmentObject(viewModel)
                }
            }
            .autocorrectionDisabled(true)
            .overlay(alignment: .bottom) {
                if viewModel.event.endDate > Timestamp() {
                    QRCodeScannerButton(isShowingQRCodeScanView: $isShowingQRCodeScanView)
                        .opacity(viewModel.event.endDate < Timestamp() ? 0 : 1)
                        .disabled(viewModel.event.endDate < Timestamp())
                }
            }
            .sheet(isPresented: $viewModel.isShowingUserInfoModal) {
                if let _ = viewModel.selectedGuest {
                    GuestDetailView()
                        .environmentObject(viewModel)
                        .presentationDetents([.medium])
                }
            }
            .fullScreenCover(isPresented: $isShowingQRCodeScanView) {
                QRCodeScannerView(isShowingQRCodeScanView: $isShowingQRCodeScanView,
                                  isTorchOn: $isTorchOn) { result in
                    isShowingQRCodeScanView = false
                    viewModel.handleScan(result)
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    PresentationBackArrowButton()
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    HStack(spacing: 0) {
                        DownloadGuestlistButton(url: GuestlistPDF(
                            event: viewModel.event,
                            guests: viewModel.guests.filter({ $0.status == .checkedIn})).renderPDF(title: viewModel.getPdfTitle())
                        )
                        
                        if viewModel.event.endDate > Timestamp() {
                            AddToGuestlistButton(viewModel: viewModel)
                        }
                    }
                }
            }
            .withAlerts(currentAlert: $viewModel.currentAlert)
    }
}

extension GuestlistView {
    var emptyView: some View {
        Group {
            switch viewModel.selectedGuestSection {
            case .invited:
                Text("Tap '+' to invite a guest to \(viewModel.event.title)!")
                    .multilineTextAlignment(.center)
            case .checkedIn, .requested:
                Text("Currently empty ...")
            }
        }
        .foregroundColor(.secondary)
        .padding(.top)
    }
}

fileprivate struct EventTitleView: View {
    let events: [Event]
    let selectedEvent: Event?
    let action: (Event) -> Void
    
    var body: some View {
        if !events.isEmpty, events.count > 1 {
            Menu {
                ForEach(events) { event in
                    Button(event.title) { action(event) }
                }
            } label: {
                Text(selectedEvent?.title ?? "No events found.")
                    .multilineTextAlignment(.trailing)
            }
            .menuTextStyle()
        } else {
            Text(selectedEvent?.title ?? "No events found.")
                .primaryHeading()
                .multilineTextAlignment(.trailing)
        }
    }
}

fileprivate struct DownloadGuestlistButton: View {
    let url: URL
    
    var body: some View {
        ShareLink(item: url,
                  subject: Text(""),
                  message: Text("")) {
            Image(systemName: "square.and.arrow.down.fill")
                .font(.title2)
                .imageScale(.medium)
                .foregroundColor(.white)
                .padding(5)
                .contentShape(Rectangle())
        }
    }
}

fileprivate struct QRCodeScannerButton: View {
    @Binding var isShowingQRCodeScanView: Bool
    
    var body: some View {
        Button {
            HapticManager.playLightImpact()
            isShowingQRCodeScanView = true
        } label: {
            Image(systemName: "qrcode.viewfinder")
                .resizable()
                .scaledToFit()
                .foregroundColor(.white)
                .frame(width: 50, height: 50)
                .padding(25)
                .background {
                    Circle()
                        .foregroundColor(Color.theme.mixerIndigo)
                        .shadow(radius: 20)
                }
        }
    }
}

fileprivate struct AddToGuestlistButton: View {
    @ObservedObject var viewModel: GuestlistViewModel
    
    var body: some View {
        NavigationLink {
            GuestlistEntryForm()
                .environmentObject(viewModel)
        } label: {
            Image(systemName: "plus")
                .font(.title2)
                .imageScale(.medium)
                .foregroundColor(Color.theme.backgroundColor)
                .padding(4)
                .background {
                    Circle()
                        .foregroundColor(Color.white)
                        .shadow(radius: 20)
                }
        }
    }
}


struct GuestlistView_Previews: PreviewProvider {
    static var previews: some View {
        GuestlistView(event: dev.mockEvent)
    }
}
