////
////  MapView.swift
////  mixer
////
////  Created by Peyton Lyons on 2/4/23.
////
//
//import SwiftUI
//import MapKit
//import CoreLocationUI
//
//struct MapView: View {
//    @ObservedObject var viewModel = MapViewModel()
//    @State var isShowingEventDetailView: Bool = false
//    @State var isShowingHostDetailView: Bool  = false
//    @State var isShowingGuestlistView: Bool   = false
//    @State var isShowingEventFlowView: Bool = false
//    @State private var selectedEvent: Event?
//    @State private var selectedHost: Host?
//    @State private var progress: CGFloat = 0
//    let gradient1 = Gradient(colors: [.purple, .pink])
//    let gradient2 = Gradient(colors: [.blue, .purple])
//    var namespace: Namespace.ID
//    
//    var eventSheetBinding: Binding<Bool> {
//        Binding {
//            return isShowingEventDetailView && selectedEvent != nil && (viewModel.eventDetailViewModel?.isDataReady ?? false)
//        } set: { newValue in
//            isShowingEventDetailView = newValue
//        }
//    }
//
//    var hostSheetBinding: Binding<Bool> {
//        Binding {
//            return isShowingHostDetailView && selectedHost != nil && (viewModel.hostDetailViewModel?.isDataReady ?? false)
//        } set: { newValue in
//            isShowingHostDetailView = newValue
//        }
//    }
//
//    
//    var body: some View {
//        ZStack(alignment: .center) {
//            ZStack(alignment: .top) {
//                Map(coordinateRegion: $viewModel.region,
//                    showsUserLocation: true,
//                    annotationItems: viewModel.mapItems.keys.compactMap { $0.self }) { host in
//                    
//                    MapAnnotation(coordinate: host.location.locationCoordinate,
//                                  anchorPoint: CGPoint(x: 0.75, y: 0.75)) {
//                        HostMapAnnotation(host: host)
//                            .onTapGesture {
//                                if let event = viewModel.mapItems[host] as? Event {
//                                    self.selectedEvent = event
//                                    viewModel.eventDetailViewModel = EventDetailViewModel(event: event)
//                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
//                                        isShowingEventDetailView = true
//                                    }
//                                } else {
//                                    // Set the selected host
//                                    self.selectedHost = host
//                                    viewModel.hostDetailViewModel = HostDetailViewModel(host: host)
//                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
//                                        isShowingHostDetailView = true
//                                    }
//                                }
//                            }
//                    }
//                }
//                .ignoresSafeArea()
//                
//                Spacer()
//                
//                LogoView(frameWidth: 65)
//                    .shadow(radius: 10)
//                    .allowsHitTesting(false)
//            }
//            
//            if viewModel.isLoading {
//                LoadingView()
//            }
//        }
//        .sheet(isPresented: eventSheetBinding) {
//            if let event = selectedEvent {
//                EventDetailView(viewModel: viewModel.eventDetailViewModel!,
//                                namespace: namespace)
//                .overlay(alignment: .topTrailing) {
//                    XDismissButton { isShowingEventDetailView = false }
//                }
//            }
//        }
//        .sheet(isPresented: hostSheetBinding) {
//            if let host = selectedHost {
//                HostDetailView(viewModel: viewModel.hostDetailViewModel!,
//                               namespace: namespace)
//                .overlay(alignment: .topTrailing) {
//                    Button { isShowingHostDetailView = false  } label: { XDismissButton { isShowingHostDetailView = false }
//                    }
//                }
//            }
//        }
//        .fullScreenCover(isPresented: $isShowingGuestlistView) {
//            if !viewModel.hostEventsDict.isEmpty {
//                GuestlistView(isShowingGuestlistView: $isShowingGuestlistView)
//                    .environmentObject(GuestlistViewModel(hostEventsDict: viewModel.hostEventsDict))
//                    .zIndex(2)
//            }
//        }
//        .fullScreenCover(isPresented: $isShowingEventFlowView) {
//            EventFlow(isShowingEventFlowView: $isShowingEventFlowView, namespace: namespace)
//        }
//        .overlay(alignment: .topTrailing) {
//            if AuthViewModel.shared.currentUser?.isHost ?? false {
//                MapIconButton(icon: "plus") { isShowingEventFlowView.toggle() }
//                    .padding(.trailing)
//                    .padding(.top)
//            }
//        }
//        .overlay(alignment: .bottom) {
//            VStack(alignment: .center) {
//                HStack {
//                    Spacer()
//                    Button {
//                        viewModel.requestAlwaysOnLocationPermission()
//                    } label: {
//                        Image("recenter-button")
//                            .renderingMode(.template)
//                            .resizable()
//                            .aspectRatio(contentMode: .fill)
//                            .foregroundColor(.white)
//                            .frame(width: 25, height: 25)
//                            .padding(10)
//                            .background(Color.theme.secondaryBackgroundColor)
//                            .clipShape(Circle())
//                            .shadow(radius: 5, y: 8)
//                    }
//                    .padding(.trailing)
//                    .padding(.bottom, 40)
//                }
//                
//                if viewModel.hostEventsDict.values.contains(where: { !$0.isEmpty }) && AuthViewModel.shared.currentUser?.isHost ?? false {
//                    GuestlistButton { isShowingGuestlistView.toggle() }
//                }
//            }
//            .frame(maxWidth: .infinity)
//            .padding(.bottom, 100)
//        }
//        .alert(item: $viewModel.alertItem, content: { $0.alert })
//        .task {
//            viewModel.getMapItems()
//            viewModel.getEventsForGuestlist()
//        }
//    }
//}
//
//struct MapView_Previews: PreviewProvider {
//    @Namespace static var namespace
//    
//    static var previews: some View {
//        MapView(namespace: namespace)
//    }
//}
//
//fileprivate struct MapIconButton: View {
//    let icon: String
//    let action: () -> Void
//    
//    var body: some View {
//        Button {
//            HapticManager.playLightImpact()
//            action()
//        } label: {
//            Image(systemName: icon)
//                .font(.title2)
//                .fontWeight(.medium)
//                .foregroundColor(.white)
//                .padding(15)
//                .background(Color.theme.mixerPurpleGradient)
//                .clipShape(Circle())
//                .shadow(radius: 5, y: 8)
//        }
//        .buttonStyle(.plain)
//    }
//}
//
//fileprivate struct GuestlistButton: View {
//    let action: () -> Void
//    
//    var body: some View {
//        Button {
//            let impact = UIImpactFeedbackGenerator(style: .light)
//            impact.impactOccurred()
//            action()
//        } label: {
//            Capsule()
//                .fill(Color.theme.secondaryBackgroundColor)
//                .longButtonFrame()
//                 .shadow(radius: 20, x: -8, y: -8)
//                .shadow(radius: 20, x: 8, y: 8)
//                .overlay {
//                    HStack {
//                        Image(systemName: "list.clipboard")
//                            .imageScale(.large)
//                            .foregroundColor(.white)
//                        
//                        Text("Guestlist")
//                            .font(.body.weight(.medium))
//                            .foregroundColor(.white)
//                    }
//                }
//                .shadow(radius: 5, y: 10)
//        }
//    }
//}