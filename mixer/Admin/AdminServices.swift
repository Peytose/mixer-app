//
//  AdminServices.swift
//  mixer
//
//  Created by Peyton Lyons on 2/25/24.
//

import SwiftUI
import Firebase

class AdminServices {
    static let shared = AdminServices()
    let authorizedUserIds = ["DLnvVKUstSZew6EMAxv9rET66WQ2", "HFFUDxglMGTL4gQJLztpEKQu0Uz1"]
    
    private init() { }
    
    func inviteHost(with username: String, completion: @escaping (Error?) -> Void) {
        guard let userId = UserService.shared.user?.id, authorizedUserIds.contains(userId) else {
            completion(UserError.unauthorized)
            return
        }
        
        let queryKey = QueryKey(collectionPath: "users",
                                filters: ["username == \(username)"],
                                limit: 1)
        
        COLLECTION_USERS
            .whereField("username", isEqualTo: username)
            .limit(to: 1)
            .fetchWithCachePriority(queryKey: queryKey, freshnessDuration: 7200) { snapshot, error in
                if let error = error {
                    completion(error)
                    return
                }
                
                guard let toUid = snapshot?.documents.first?.documentID else {
                    completion(UserError.userNotFound)
                    return
                }
                
                NotificationsViewModel.uploadNotification(toUid: toUid, type: .hostInvited)
                completion(nil)
            }
    }
}
