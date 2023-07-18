//
//  View+Ext.swift
//  mixer
//
//  Created by Jose Martinez on 5/13/23.
//

import SwiftUI
import Firebase

extension View {
    func configureList() -> some View {
        self.background { Color.mixerBackground.ignoresSafeArea() }
            .scrollContentBackground(.hidden)
    }
    
    
    func navigationBar(title: String, displayMode: NavigationBarItem.TitleDisplayMode) -> some View {
        self.navigationTitle(title)
            .navigationBarTitleDisplayMode(displayMode)
    }
    
    
    // MARK: Guestlist View Extensions
    func searchBar(text: Binding<String>, viewModel: GuestlistViewModel) -> some View {
        self.searchable(text: text, prompt: "Search Guests")
            .onChange(of: text.wrappedValue) { searchText in
                viewModel.filterGuests(with: searchText)
            }
    }
    
    
    func configureToolbar(isShowingQRCodeScanView: Binding<Bool>, isShowingAddGuestView: Binding<Bool>, isShowingGuestlistView: Binding<Bool>) -> some View {
        self.toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                HStack {
                    Button { isShowingQRCodeScanView.wrappedValue.toggle() } label: {
                        Image(systemName: "qrcode.viewfinder")
                            .font(.title3)
                            .foregroundColor(.mixerIndigo)
                    }
                    
                    Button("Add Guest") { isShowingAddGuestView.wrappedValue.toggle() }
                        .foregroundColor(.white)
                }
            }
            
            ToolbarItem(placement: .navigationBarLeading) {
                Button { isShowingGuestlistView.wrappedValue = false } label: {
                    XDismissButton()
                }
            }
        }
    }
    
    
    // MARK: Notification View Extensions
    func notificationBackground() -> some View {
        self
            .frame(width: DeviceTypes.ScreenSize.width - 20, height: 60)
            .background(Color.mixerSecondaryBackground)
            .cornerRadius(24)
    }
    
    
    func notificationContentFrame() -> some View {
        self
            .frame(width: DeviceTypes.ScreenSize.width - 60, height: 60, alignment: .leading)
    }
    
    
    func notificationBackgroundShort() -> some View {
        self
            .frame(width: DeviceTypes.ScreenSize.width * 0.5, height: 60)
            .background(Color.mixerSecondaryBackground)
            .cornerRadius(24)
    }
    
    
    func notificationContentFrameShort() -> some View {
        self
            .frame(width: DeviceTypes.ScreenSize.width - 60, height: 60, alignment: .center)
    }
    
    
    // MARK: Frame Extensions
    func textFieldFrame() -> some View {
        self
            .frame(width: DeviceTypes.ScreenSize.width * 0.9)
    }
    
    
    func longButtonFrame() -> some View {
        self
            .frame(width: DeviceTypes.ScreenSize.width * 0.9, height: 55)
    }
    
    
    // MARK: [Insert next name here] Extensions
}
