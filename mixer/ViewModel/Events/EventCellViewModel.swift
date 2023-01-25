//
//  EventCellViewModel.swift
//  mixer
//
//  Created by Peyton Lyons on 1/22/23.
//

import SwiftUI
import Firebase

final class EventCellViewModel: ObservableObject {
    @Published var event: Event
    
    var likeString: String {
        let label = event.likes == 1 ? "like" : "likes"
        return "\(event.likes) \(label)"
    }

    init(event: Event) {
        self.event = event
        checkIfUserLikedEvent()
        fetchEventHost()
    }

    func like() {
        guard let uid = AuthViewModel.shared.userSession?.uid, let eventId = event.id else { return }
        
        let eventLikeRef = COLLECTION_EVENTS.document(eventId).collection("event-likes").document(uid)
        let userLikeRef = COLLECTION_USERS.document(uid).collection("user-likes").document(eventId)
        let eventRef = COLLECTION_EVENTS.document(eventId)
        
        Firestore.firestore().runTransaction({ (transaction, errorPointer) -> Any? in
            do {
                let eventDoc = try transaction.getDocument(eventRef)
                let likes = eventDoc.data()?["likes"] as? Int ?? 0
                transaction.setData([:], forDocument: eventLikeRef)
                transaction.setData([:], forDocument: userLikeRef)
                transaction.updateData(["likes": likes + 1], forDocument: eventRef)
            } catch let error as NSError {
                errorPointer?.pointee = error
            }
            return nil
        }) { (object, error) in
            if let error = error {
                print("Transaction failed with error: \(error)")
            } else {
                self.event.didLike = true
                self.event.likes += 1
            }
        }
    }


    func unlike() {
        guard event.likes > 0 else { return }
        guard let uid = AuthViewModel.shared.userSession?.uid else { return }
        guard let eventId = event.id else { return }
        
        let eventLikeRef = COLLECTION_EVENTS.document(eventId).collection("event-likes").document(uid)
        let userLikeRef = COLLECTION_USERS.document(uid).collection("user-likes").document(eventId)
        let eventRef = COLLECTION_EVENTS.document(eventId)
        
        let batch = Firestore.firestore().batch()
        batch.deleteDocument(eventLikeRef)
        batch.deleteDocument(userLikeRef)
        batch.updateData(["likes": self.event.likes - 1], forDocument: eventRef)
        
        batch.commit { _ in
            self.event.didLike = false
            self.event.likes -= 1
        }
    }
    
    
    func checkIfUserLikedEvent() {
        guard let uid = AuthViewModel.shared.userSession?.uid else { return }
        guard let eventId = event.id else { return }
        
        COLLECTION_USERS.document(uid).collection("user-likes").document(eventId).getDocument { snapshot, _ in
            guard let didLike = snapshot?.exists else { return }
            self.event.didLike = didLike
        }
    }
    
    
    func fetchEventHost() {
        COLLECTION_USERS.document(event.hostUuid).getDocument { snapshot, _ in
            self.event.host = try? snapshot?.data(as: Host.self)
        }
    }
}
