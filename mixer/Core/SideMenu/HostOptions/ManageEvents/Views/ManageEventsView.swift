//
//  ManageEventsView.swift
//  mixer
//
//  Created by Peyton Lyons on 9/14/23.
//

import SwiftUI

struct ManageEventsView: View {
    @ObservedObject var viewModel: ManageEventsViewModel
    
    var body: some View {
        ZStack {
            Color.theme.backgroundColor
                .ignoresSafeArea()
            
            VStack {
                ChangeHostView(hosts: UserService.shared.user?.associatedHosts,
                               selectedHost: viewModel.selectedHost) { host in
                    viewModel.changeHost(to: host)
                }
                
                StickyHeaderView(items: EventState.allCases,
                                 selectedItem: $viewModel.currentState)
                
                ScrollView {
                    LazyVGrid(columns: Array(repeating: GridItem(spacing: .zero), count: 2), spacing: 10) {
                        ForEach(viewModel.eventsForSelectedState) { event in
                            NavigationLink {
                                GuestlistView(viewModel: GuestlistViewModel(event: event,
                                                                            host: viewModel.selectedHost))
                            } label: {
                                ManageEventCell(viewModel: viewModel, event: event)
                            }
                        }
                    }
                }
                .padding(.top, 10)
                
                Spacer()
            }
            .padding(.bottom, 100)
        }
        .navigationBar(title: "Manage Events", displayMode: .inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                PresentationBackArrowButton()
            }
            
//            if !viewModel.hosts.isEmpty {
//                ToolbarItem(placement: .navigationBarTrailing) {
//                    EditNotificationsButton(viewModel: viewModel)
//                }
//            }
        }
    }
}

//struct ManageEventsView_Previews: PreviewProvider {
//    static var previews: some View {
//        ManageEventsView()
//    }
//}

fileprivate struct ChangeHostView: View {
    let hosts: [Host]?
    let selectedHost: Host?
    let action: (Host) -> Void

    var body: some View {
        if let hosts = hosts, !hosts.isEmpty, hosts.count > 1 {
            Menu {
                ForEach(hosts) { host in
                    Button {
                        action(host)
                    } label: {
                        Text(host.name)
                            .primaryHeading(color: Color.theme.mixerIndigo)
                            .multilineTextAlignment(.trailing)
                    }
                }
            } label: {
                Text(selectedHost?.name ?? "No hosts found.")
                    .multilineTextAlignment(.trailing)
            }
        } else {
            Text(selectedHost?.name ?? "No host found.")
                .primaryHeading()
                .multilineTextAlignment(.trailing)
        }
    }
}
