//
//  FavoriteCell.swift
//  mixer
//
//  Created by Peyton Lyons on 8/30/23.
//

import SwiftUI
import Kingfisher
import FirebaseFirestore

struct FavoriteCell: View {
    @EnvironmentObject var viewModel: FavoritesViewModel
    let event: Event
    
    var body: some View {
        HStack {
            if event.endDate > Timestamp() {
                ParticleEffectButton(systemImage: "heart.fill",
                                     status: event.isFavorited ?? false,
                                     activeTint: .pink,
                                     inActiveTint: .secondary,
                                     frameSize: 35) {
                    viewModel.updateFavorite(event)
                }
                                     .fixedSize()
            }
            
            NavigationLink(value: event) {
                HStack {
                    KFImage(URL(string: event.eventImageUrl))
                        .resizable()
                        .scaledToFill()
                        .frame(width: 50, height: 50)
                        .clipped()
                    
                    VStack(alignment: .leading) {
                        Text(event.title)
                            .font(.callout)
                            .foregroundColor(.white)
                            .lineLimit(1)
                            .minimumScaleFactor(0.8)
                        
                        Text(viewModel.getSubtitleString(event))
                            .font(.footnote)
                            .foregroundColor(event.endDate < Timestamp() ? .pink : .secondary)
                            .lineLimit(2)
                            .minimumScaleFactor(0.8)
                    }
                }
            }
            
            Spacer()
            
            if event.endDate < Timestamp() {
                ListCellActionButton(text: "Remove", isSecondaryLabel: true) {
                    print("DEBUG: Removing event !")
                    viewModel.updateFavorite(event)
                }
            } else if event.didGuestlist ?? false {
                ListCellActionButton(text: "Leave", isSecondaryLabel: true) {
                    print("DEBUG: Leaving guestlist !")
                    viewModel.leaveGuestlist(event)
                }
            } else if event.isGuestlistEnabled && !event.isInviteOnly {
                ListCellActionButton(text: "Join") {
                    print("DEBUG: Joining guestlist !")
                    viewModel.joinGuestlist(event)
                }
            }
        }
        .padding(.horizontal)
    }
}

struct FavoriteCell_Previews: PreviewProvider {
    static var previews: some View {
        FavoriteCell(event: dev.mockEvent)
    }
}
