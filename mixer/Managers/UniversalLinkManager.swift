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
                    if success {
                        self.addEventToUserSpecificCollection(event: event)
                        completion(event)
                    } else {
                        completion(nil)
                    }
                }
            } else {
                completion(event)
            }
        }
    }
    
    
    private func addEventToUserSpecificCollection(event: Event) {
        guard let currentUserId = UserService.shared.user?.id,
              let eventId = event.id else { return }
        
        // Make sure the event is a private open party
        if event.isPrivate && !event.isInviteOnly {
            COLLECTION_USERS
                .document(currentUserId)
                .collection("accessible-events")
                .document(eventId)
                .setData(["timestamp": Timestamp(),
                          "hostIds": event.hostIds]) { error in
                    if let error = error {
                        print("DEBUG: Error adding event to user-specific collection: \(error.localizedDescription)")
                    } else {
                        print("DEBUG: Event added to user-specific collection.")
                    }
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
        guard let eventId = self.incomingEventId, let token = self.incomingToken else {
            print("DEBUG: Missing eventId or token")
            completion(false)
            return
        }

        guard let url = URL(string: "https://us-central1-mixer-firebase-project.cloudfunctions.net/verifyEventToken") else {
            print("DEBUG: Invalid URL")
            completion(false)
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        let requestBody: [String: Any] = ["eventId": eventId, "token": token]
        request.httpBody = try? JSONSerialization.data(withJSONObject: requestBody)

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("DEBUG: Error making request: \(error.localizedDescription)")
                completion(false)
                return
            }

            if let httpResponse = response as? HTTPURLResponse {
                print("DEBUG: HTTP Response Status Code: \(httpResponse.statusCode)")
                if httpResponse.statusCode == 200 {
                    completion(true)
                } else {
                    completion(false)
                }
            } else {
                print("DEBUG: Response is not HTTPURLResponse")
                completion(false)
            }

            if let data = data, let responseString = String(data: data, encoding: .utf8) {
                print("DEBUG: Response Data: \(responseString)")
            }
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
