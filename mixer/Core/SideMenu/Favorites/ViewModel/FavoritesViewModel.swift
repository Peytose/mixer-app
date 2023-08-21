//
//  FavoritesViewModel.swift
//  mixer
//
//  Created by Peyton Lyons on 8/8/23.
//

import SwiftUI
import Firebase

class FavoritesViewModel: ObservableObject {
    @Published var favorites = Set<Event>()
    private var listener: ListenerRegistration?

    deinit {
        listener?.remove()
    }

    @MainActor
    func startListeningForFavorites() {
        guard let uid = UserService.shared.user?.id else { return }

        listener = COLLECTION_USERS
            .document(uid)
            .collection("user-favorites")
            .addSnapshotListener { [weak self] snapshot, error in
                if let error = error {
                    print("DEBUG: Error listening for changes. \(error.localizedDescription)")
                    return
                }

                self?.fetchFavorites()
            }
    }
    
    
    @MainActor
    private func fetchFavorites() {
        guard let uid = UserService.shared.user?.id else { return }

        COLLECTION_USERS
            .document(uid)
            .collection("user-favorites")
            .getDocuments { snapshot, error in
                if let error = error {
                    print("DEBUG: Error getting user's favorites. \(error.localizedDescription)")
                    return
                }

                guard let documents = snapshot?.documents else { return }
                let eventIds = documents.compactMap({ $0.documentID })
                
                let chunks = eventIds.chunked(into: 10)
                
                for chunk in chunks {
                    COLLECTION_EVENTS
                        .whereField(FieldPath.documentID(), in: chunk)
                        .getDocuments { snapshot, error in
                            if let error = error {
                                print("DEBUG: Error getting events. \(error.localizedDescription)")
                                return
                            }
                            
                            guard let eventDocuments = snapshot?.documents else { return }
                            print("DEBUG: \(eventDocuments)")
                            self.favorites.formUnion(eventDocuments.compactMap({ try? $0.data(as: Event.self) }))
                        }
                }
            }
    }

}
