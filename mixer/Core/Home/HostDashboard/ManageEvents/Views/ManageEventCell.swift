//
//  ManageEventCell.swift
//  mixer
//
//  Created by Peyton Lyons on 9/14/23.
//

import SwiftUI
import Kingfisher

struct ManageEventCell: View {
    @ObservedObject var viewModel: ManageEventsViewModel
    let event: Event
    @State private var showActionSheet = false
    @State private var showEditEventView = false
    
    var body: some View {
        KFImage(URL(string: event.eventImageUrl))
            .resizable()
            .scaledToFill()
            .clipped()
            .frame(width: DeviceTypes.ScreenSize.width / 2.5, height: 175)
            .overlay(alignment: .bottomLeading) {
                HStack {
                    Text(event.title)
                        .font(.body)
                        .foregroundColor(.white)
                        .lineLimit(2)
                        .minimumScaleFactor(0.8)
                        .multilineTextAlignment(.leading)
                    
                    Spacer()
                }
                .padding(.leading)
                .padding(.bottom, 5)
                .background {
                    Rectangle()
                        .fill(.ultraThinMaterial)
                        .mask {
                            VStack(spacing: 0) {
                                LinearGradient(
                                    colors: [
                                        Color.theme.backgroundColor.opacity(1),
                                        Color.theme.backgroundColor.opacity(0),
                                    ],
                                    startPoint: .bottom,
                                    endPoint: .top
                                )
                                Rectangle()
                            }
                        }
                        .frame(height: 90)
                }
            }
            .overlay(alignment: .topTrailing) {
                EllipsisButton(stroke: 0) {
                    showActionSheet.toggle()
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 13))
            .frame(height: 175)
            .confirmationDialog("Select an action", isPresented: $showActionSheet, titleVisibility: .hidden) {
                // TO-DO: Add condiiton for member type
                if viewModel.currentState != .past {
                    Button("Edit Event") { showEditEventView.toggle() }
                }

                Button("Delete Event", role: .destructive) {
                    viewModel.delete(event: event)
                }

                Button("Cancel", role: .cancel) { }
            }
            .contextMenu {
                if viewModel.currentState != .past {
                    Button("Edit Event") { showEditEventView.toggle() }
                }

                Button("Delete Event", role: .destructive) {
                    viewModel.delete(event: event)
                }
            }
            .fullScreenCover(isPresented: $showEditEventView) {
                EditEventView(viewModel: EditEventViewModel(event: event),
                              showEditEventView: $showEditEventView)
                    .multilineTextAlignment(.leading)
            }
    }
}

fileprivate struct NotificationSecondaryImage<Content: View>: View {
    let imageUrl: String
    @ViewBuilder let content: Content
    
    var body: some View {
        NavigationLink { content } label: {
            KFImage(URL(string: imageUrl))
                .resizable()
                .scaledToFill()
                .frame(width: 40, height: 40)
                .clipped()
        }
    }
}


struct ManageEventCell_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.theme.backgroundColor
                .ignoresSafeArea()
            
            ManageEventCell(viewModel: ManageEventsViewModel(),
                            event: dev.mockEvent)
        }
        .preferredColorScheme(.dark)
    }
}
