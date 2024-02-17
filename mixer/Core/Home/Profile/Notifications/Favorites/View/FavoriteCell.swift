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
    @ObservedObject var viewModel: FavoritesViewModel
    let event: Event
    
    var body: some View {
        HStack {
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
                        
                        Text(viewModel.formattedEventSubtitle(event))
                            .font(.footnote)
                            .foregroundColor(event.endDate < Timestamp() ? .pink : .secondary)
                            .lineLimit(2)
                            .minimumScaleFactor(0.8)
                            .multilineTextAlignment(.leading)
                    }
                }
            }
            
            Spacer()
            
            if event.endDate > Timestamp() {
                ParticleEffectButton(systemImage: "heart.fill",
                                     status: event.isFavorited ?? false,
                                     activeTint: .pink,
                                     inActiveTint: .secondary,
                                     frameSize: 35) {
                    viewModel.toggleFavoriteStatus(event)
                }
                                     .fixedSize()
            }
            
//            ListCellActionButton(text: EventUserActionState(event: event).favoriteText,
//                                 isSecondaryLabel: EventUserActionState(event: event).isSecondaryLabel) {
//                let state = EventUserActionState(event: event)
//                print("DEBUG: State \(state)")
//                viewModel.actionForState(state, event: event)
//            }
        }
        .padding(.horizontal)
    }
}

struct FavoriteCell_Previews: PreviewProvider {
    static var previews: some View {
        FavoriteCell(viewModel: FavoritesViewModel(), event: dev.mockEvent)
    }
}
