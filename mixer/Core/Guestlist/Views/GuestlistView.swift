//
//  GuestlistView.swift
//  mixer
//
//  Created by Peyton Lyons on 8/10/23.
//

import SwiftUI
import Kingfisher
import CodeScanner
import Combine

struct GuestlistView: View {
    @EnvironmentObject var viewModel: GuestlistViewModel
    @State private var isShowingUserInfoModal  = false
    @State private var isShowingQRCodeScanView = false
    @State private var isTorchOn               = false

    var body: some View {
        ZStack {
            Color.theme.backgroundColor
                .ignoresSafeArea()
            
            VStack {
                HStack {
                    Spacer()
                    
                    EventTitleView(events: viewModel.events, currentEvent: viewModel.currentEvent) { event in
                        viewModel.changeEvent(to: event)
                    }
                    .frame(maxWidth: DeviceTypes.ScreenSize.width * 0.60, alignment: .trailing)
                    .padding(.trailing)
                    .padding(.top, 4)
                }
                
                List {
                    if viewModel.guests.isEmpty {
                        GuestlistEmptyView()
                    } else {
                        Text("\(viewModel.guests.filter({ $0.status == .checkedIn }).count) / \(viewModel.guests.count) guests checked in")
                            .secondaryHeading(color: .secondary)
                            .lineLimit(1)
                            .minimumScaleFactor(0.75)
                            .listRowBackground(Color.theme.secondaryBackgroundColor)
                        
                        ForEach(viewModel.guests) { guest in
                            GuestlistRow(guest: guest)
                        }
                    }
                }
                .scrollContentBackground(.hidden)
            }
        }
        .overlay(alignment: .bottom) {
            HStack {
                SpacerView()
                
                QRCodeScannerButton(isShowingQRCodeScanView: $isShowingQRCodeScanView)
                
                Spacer()
                
                AddToGuestlistButton()
                    .padding(.trailing)
            }
            .padding(.bottom, 50)
        }
        .sheet(isPresented: $viewModel.isShowingUserInfoModal) {
            if let _ = viewModel.selectedGuest {
                GuestDetailView()
                    .presentationDetents([.medium])
            }
        }
        .fullScreenCover(isPresented: $isShowingQRCodeScanView) {
            QRCodeScannerView(isShowingQRCodeScanView: $isShowingQRCodeScanView,
                              isTorchOn: $isTorchOn) { result in
                viewModel.handleScan(result)
            }
        }
        .alert(item: $viewModel.alertItem, content: { $0.alert })
        .alert(item: $viewModel.confirmationAlertItem, content: { $0.alert })
    }
}

struct GuestlistView_Previews: PreviewProvider {
    static var previews: some View {
        GuestlistView()
            .environmentObject(GuestlistViewModel(events: [dev.mockEvent]))
    }
}

fileprivate struct GuestlistEmptyView: View {
    var body: some View {
        Section {
            VStack(alignment: .center) {
                Text("📭 The guestlist is currently empty ...")
                    .body(color: .white)
            }
            .listRowBackground(Color.theme.secondaryBackgroundColor)
        }
    }
}

fileprivate struct EventTitleView: View {
    let events: [Event]
    let currentEvent: Event?
    let action: (Event) -> Void

    var body: some View {
        if !events.isEmpty, events.count > 1 {
            Menu {
                ForEach(events) { event in
                    Button(event.title) { action(event) }
                }
            } label: {
                Text(currentEvent?.title ?? "")
                    .multilineTextAlignment(.trailing)
            }
            .menuTextStyle()
        } else {
            Text(currentEvent?.title ?? "")
                .primaryHeading()
                .multilineTextAlignment(.trailing)
        }
    }
}

fileprivate struct SpacerView: View {
    var body: some View {
        Image(systemName: "")
            .frame(width: 30, height: 30)
            .padding(13)
            .padding(.leading)
        
        Spacer()
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
    @EnvironmentObject var viewModel: GuestlistViewModel

    var body: some View {
        NavigationLink {
            AddToGuestlistView()
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

