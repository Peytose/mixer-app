//
//  UniversalLinkManager.swift
//  mixer
//
//  Created by Peyton Lyons on 5/19/23.
//

import SwiftUI
import Firebase
import FirebaseFirestore
import FirebaseFirestoreSwift

class UniversalLinkManager: ObservableObject {
    static let shared = UniversalLinkManager()

    @Published var incomingEventId: String?
    @Published var incomingToken: String?

    
    func processIncomingURL(_ url: URL, completion: @escaping (Event?) -> Void) {
        guard handleIncomingURL(url) else {
            completion(nil)
            return
        }
        
        fetchIncomingEvent { event in
            if event.isPrivate {
                guard let _ = self.incomingToken else {
                    // Handle the error: A token is required but not provided
                    completion(nil)
                    return
                }
                
                self.verifyToken { success in
                    completion(success ? event : nil)
                }
            } else {
                completion(event)
            }
        }
    }
    
    
    private func handleIncomingURL(_ url: URL) -> Bool {
        guard url.scheme == "mixerapp" else {
            return false
        }

        let components = URLComponents(url: url, resolvingAgainstBaseURL: true)

        switch url.host {
        case "open-event":
            if let eventId = components?.queryItems?.first(where: { $0.name == "id" })?.value {
                self.incomingEventId = eventId
                print("DEBUG: incoming Event Id: \(incomingEventId ?? "")")
            }

            if let token = components?.queryItems?.first(where: { $0.name == "token" })?.value {
                self.incomingToken = token
                print("DEBUG: incoming Token: \(incomingToken ?? "")")
            }

            return incomingEventId != nil
        default:
            return false
        }
    }
    
    
    private func verifyToken(completion: @escaping (Bool) -> Void) {
        guard let token = self.incomingToken else { return }
        let url = URL(string: "https://us-central1-mixer-firebase-project.cloudfunctions.net/verifyEventToken")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                completion(false)
                return
            }
            
            // If you wish, you can also decode the response to get the eventId
            // and cross-check it with the eventId you have if needed.
            
            completion(true)
        }.resume()
    }
    
    
    private func fetchIncomingEvent(completion: @escaping (Event) -> Void) {
        guard let incomingEventId = self.incomingEventId else { return }
        
        COLLECTION_EVENTS
            .document(incomingEventId)
            .getDocument { snapshot, error in
                if let error = error {
                    print("DEBUG: Error fetching incoming event.\n\(error.localizedDescription)")
                    return
                }
                
                guard let event = try? snapshot?.data(as: Event.self) else { return }
                completion(event)
            }
    }
}
