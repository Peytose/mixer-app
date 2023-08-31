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
    
    init(hosts: [Host]) {
        _viewModel = StateObject(wrappedValue: GuestlistViewModel(associatedHosts: hosts))
    }

    var body: some View {
        ZStack {
            Color.theme.backgroundColor
                .ignoresSafeArea()
            
            VStack {
                EventTitleView(events: viewModel.events,
                               selectedEvent: viewModel.selectedEvent) { event in
                    viewModel.changeEvent(to: event)
                }
                               .frame(maxWidth: DeviceTypes.ScreenSize.width, alignment: .leading)
                               .padding([.leading, .top])
                
                StickyHeaderView(items: GuestStatus.allCases,
                                 selectedItem: $viewModel.selectedGuestSection)
                
                
                switch viewModel.viewState {
                case .loading:
                    LoadingView()
                case .empty:
                    emptyView
                case .list:
                    List {
                        Text(viewModel.getGuestlistSectionCountText())
                            .secondaryHeading(color: .secondary)
                            .lineLimit(1)
                            .minimumScaleFactor(0.75)
                            .listRowBackground(Color.theme.secondaryBackgroundColor)
                        
                        ForEach(viewModel.filteredGuests) { guest in
                            GuestlistRow(guest: guest)
                                .environmentObject(viewModel)
                        }
                    }
                    .scrollContentBackground(.hidden)
                }
                
                Spacer()
            }
        }
        .navigationBarBackButtonHidden(true)
        .overlay(alignment: .bottom) {
            HStack {
                Spacer()
                
                if let selectedEvent = viewModel.selectedEvent {
                    DownloadGuestlistButton(url: GuestlistPDF(
                        event: selectedEvent,
                        guests: viewModel.guests.filter({ $0.status == .checkedIn})).renderPDF(title: viewModel.getPdfTitle())
                    )
                }
                
                Spacer()
                
                if let selectedEvent = viewModel.selectedEvent, selectedEvent.endDate > Timestamp() {
                    QRCodeScannerButton(isShowingQRCodeScanView: $isShowingQRCodeScanView)
                        .opacity(selectedEvent.endDate < Timestamp() ? 0 : 1)
                        .disabled(selectedEvent.endDate < Timestamp())
                    
                    Spacer()
                }
                
                if let selectedEvent = viewModel.selectedEvent, selectedEvent.endDate > Timestamp() {
                    AddToGuestlistButton(viewModel: viewModel)
                    
                    Spacer()
                }
            }
            .padding(.horizontal, 30)
            .padding(.bottom, 50)
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
            ToolbarItem(placement: .navigationBarLeading) {
                PresentationBackArrowButton()
            }
        }
        .alert(item: $viewModel.currentAlert) { alertType in
            hideKeyboard()
            
            switch alertType {
            case .regular(let alertItem):
                guard let item = alertItem else { break }
                return item.alert
            case .confirmation(let confirmationAlertItem):
                guard let item = confirmationAlertItem else { break }
                return item.alert
            }
            
            return Alert(title: Text("Unexpected Error"))
        }
    }
}

struct GuestlistView_Previews: PreviewProvider {
    static var previews: some View {
        GuestlistView(hosts: [dev.mockHost])
            .environmentObject(GuestlistViewModel(associatedHosts: [dev.mockHost]))
    }
}

extension GuestlistView {
    var emptyView: some View {
        Group {
            if let selectedEvent = viewModel.selectedEvent {
                switch viewModel.selectedGuestSection {
                case .invited:
                    Text("Tap '+' to invite a guest to \(selectedEvent.title)!")
                        .multilineTextAlignment(.center)
                case .checkedIn:
                    Text("Currently empty ...")
                }
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
                .resizable()
                .scaledToFit()
                .foregroundColor(.black)
                .frame(width: 30, height: 30)
                .padding(13)
                .background {
                    Circle()
                        .foregroundColor(Color.white)
                        .shadow(radius: 20)
                }
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
                .resizable()
                .scaledToFit()
                .foregroundColor(.black)
                .frame(width: 30, height: 30)
                .padding(13)
                .background {
                    Circle()
                        .foregroundColor(Color.white)
                        .shadow(radius: 20)
                }
        }
    }
}

