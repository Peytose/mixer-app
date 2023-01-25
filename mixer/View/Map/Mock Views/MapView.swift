//
//  MapView.swift
//  mixer
//
//  Created by Peyton Lyons on 11/12/22.
//

import SwiftUI
import UIKit
import MapKit
import CoreLocationUI

struct MapView: View {
    @Namespace var namespace
    @StateObject private var viewModel = LocationMapViewModel()
    
    @State var showGuestListView = false
    
    var body: some View {
        ZStack(alignment: .top) {
            MapClusterView()
                .ignoresSafeArea()
            
            VStack(spacing: 10) {
                EventUsersListButton(action: $showGuestListView)
            }
            .frame(maxWidth:.infinity, maxHeight: .infinity, alignment: .topTrailing)
            .padding(EdgeInsets(top: 60, leading: 0, bottom: 0, trailing: 6))
            
            BlurredStatusBar()
        }
        .overlay(alignment: .bottomTrailing, content: {
            LocationButton(.currentLocation) {
                withAnimation() {
                }
            }
            .foregroundColor(Color.mainFont)
            .symbolVariant(.fill)
            .tint(Color.mixerSecondaryBackground)
            .labelStyle(.iconOnly)
            .clipShape(Circle())
            .shadow(radius: 5, y: 10)
            .padding(EdgeInsets(top: 0, leading: 0, bottom: 20, trailing: 20))
        })
        .overlay(alignment: .bottomTrailing, content: {
            AddEventButton()
                .padding(EdgeInsets(top: 0, leading: 0, bottom: 100, trailing: 20))
                .onTapGesture {
                    let impact = UIImpactFeedbackGenerator(style: .medium)
                    impact.impactOccurred()
                    
                    viewModel.isShowingAddEventView.toggle()
                }
        })
        .overlay(alignment: .bottom, content: {
            UserQRCodeButton()
                .onTapGesture {
                    withAnimation() {
                        viewModel.isShowingQRCodeView.toggle()
                    }
                }
                .padding(EdgeInsets(top: 0, leading: 0, bottom: 90, trailing: 20))
                .onTapGesture {
                    let impact = UIImpactFeedbackGenerator(style: .medium)
                    impact.impactOccurred()
                    
                    viewModel.isShowingAddEventView.toggle()
                }
        })
        .sheet(isPresented: $showGuestListView, content: {
            GuestListView()
        })

        //        .sheet(isPresented: $viewModel.isShowingHostView, content: { HostOrganizationView(viewModel: HostOrganizationViewModel(host: hostManager.selectedHost!, namespace: namespace)) })
                .fullScreenCover(isPresented: $viewModel.isShowingAddEventView, content: { CreateEventView() })
        //        .sheet(isPresented: $viewModel.isShowingEventUsersListView, content: { EventListHostView(viewModel: EventListHostViewModel(host: viewModel.hostOrganization!)) })
    }
}


struct MapView_Previews: PreviewProvider {
    static var previews: some View {
        MapView()
            .preferredColorScheme(.dark)
    }
}


fileprivate struct AddEventButton: View {
    var body: some View {
        Image(systemName: "plus")
            .font(.title.weight(.medium))
            .foregroundColor(Color.white)
            .padding(20)
            .background(Color.mixerPurpleGradient)
            .clipShape(Circle())
            .shadow(radius: 5, y: 10)
    }
}


fileprivate struct EventUsersListButton: View {
    @Binding var action: Bool
    var body: some View {
        Image(systemName: "list.clipboard")
            .font(.title2.weight(.medium))
            .foregroundColor(Color.mainFont)
            .padding(12)
            .background(Color.mixerSecondaryBackground)
            .clipShape(Circle())
            .shadow(radius: 5, y: 8)
            .onTapGesture {
                let impact = UIImpactFeedbackGenerator(style: .light)
                impact.impactOccurred()
                
                action.toggle()
            }
    }
}


fileprivate struct UserQRCodeButton: View {
    var body: some View {
        Rectangle()
            .fill(Color.mixerPurpleGradient)
            .cornerRadius(30)
            .frame(width: 150, height: 50)
            .shadow(radius: 5, y: 10)
            .overlay(content: {
                HStack(spacing: 15) {
                    Image(systemName: "qrcode")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 26, height: 26)
                        .foregroundColor(Color.white)
                }
            })
    }
}


struct BlurredStatusBar: View {
    var height: CGFloat = 50
    var color: Color = Color.clear
    var blurRadius: CGFloat = 5
    var body: some View {
        VStack {
            Rectangle()
                .fill(color)
                .frame(maxWidth: .infinity, maxHeight: height, alignment: .top)
                .backgroundBlur(radius: blurRadius, opaque: true)
                .blur(radius: 2)
                .ignoresSafeArea()
            
            Spacer()
        }
    }
}
