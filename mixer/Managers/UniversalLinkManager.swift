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
    enum LinkType {
        case event(String)
        case host(String)
        case user(String)
    }
    
    
    static let shared = UniversalLinkManager()

    @Published var incomingToken: String?
    
    
    static func generateShareURL(type: LinkType,
                                 isPrivateEvent: Bool = false,
                                 completion: @escaping (URL?) -> Void) {
        print("DEBUG: Generating share url....")
        switch type {
        case .event(let eventId):
            let baseURL = "mixerapp://open-event?id=\(eventId)"
            
            if isPrivateEvent {
                generateToken(for: eventId) { token in
                    guard let token = token else {
                        completion(nil)
                        return
                    }
                    
                    let fullURLString = baseURL + "&token=\(token)"
                    let shareURL = URL(string: fullURLString)
                    completion(shareURL)
                }
            } else {
                let shareURL = URL(string: baseURL)
                completion(shareURL)
            }
        case .host(let hostId):
            let baseURL = "mixerapp://open-host?id=\(hostId)"
            let shareURL = URL(string: baseURL)
            completion(shareURL)
        case .user(let userId):
            let baseURL = "mixerapp://open-user?id=\(userId)"
            let shareURL = URL(string: baseURL)
            completion(shareURL)
        }
    }
    
    
    private static func generateToken(for eventId: String, completion: @escaping (String?) -> Void) {
        guard let url = URL(string: "https://us-central1-mixer-firebase-project.cloudfunctions.net/generateEventToken") else {
            print("Invalid URL")
            completion(nil)
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let requestBody: [String: Any] = ["eventId": eventId]
        request.httpBody = try? JSONSerialization.data(withJSONObject: requestBody)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error:", error)
                completion(nil)
                return
            }
            
            if let data = data {
                do {
                    if let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                       let token = jsonResponse["token"] as? String {
                        completion(token)
                    } else {
                        print("Invalid response format")
                        completion(nil)
                    }
                } catch {
                    print("Error parsing JSON:", error)
                    completion(nil)
                }
            } else {
                print("No data received")
                completion(nil)
            }
        }.resume()
    }
    
    
    func processIncomingURL(_ url: URL, completion: @escaping (Any?) -> Void) {
        handleIncomingURL(url) { linkType in
            if let type = linkType {
                switch type {
                case .event(let eventId):
                    self.fetchIncomingEvent(eventId: eventId) { event in
                        if event.isPrivate {
                            guard let _ = self.incomingToken else {
                                // Handle the error: A token is required but not provided
                                completion(nil)
                                return
                            }
                            
                            self.verifyToken(eventId: eventId) { success in
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
                case .host(let hostId):
                    self.fetchIncomingHost(hostId: hostId, completion: completion)
                case .user(let userId):
                    self.fetchIncomingUser(userId: userId, completion: completion)
                }
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
    
    
    private func handleIncomingURL(_ url: URL, completion: @escaping (LinkType?) -> Void) {
        guard url.scheme == "mixerapp" else { return }
        let components = URLComponents(url: url, resolvingAgainstBaseURL: true)

        switch url.host {
        case "open-event":
            if let eventId = components?.queryItems?.first(where: { $0.name == "id" })?.value {
                print("DEBUG: incoming event id: \(eventId)")
                completion(LinkType.event(eventId))
            }

            if let token = components?.queryItems?.first(where: { $0.name == "token" })?.value {
                self.incomingToken = token
                print("DEBUG: incoming Token: \(incomingToken ?? "")")
            }
        case "open-host":
            if let hostId = components?.queryItems?.first(where: { $0.name == "id" })?.value {
                print("DEBUG: incoming host id: \(hostId)")
                completion(LinkType.host(hostId))
            }
        case "open-user":
            if let userId = components?.queryItems?.first(where: { $0.name == "id" })?.value {
                print("DEBUG: incoming user id: \(userId)")
                completion(LinkType.user(userId))
            }
        case .none: break
        case .some(_): break
        }
    }

    
    private func verifyToken(eventId: String, completion: @escaping (Bool) -> Void) {
        guard let token = self.incomingToken else {
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
    
    
    private func fetchIncomingEvent(eventId: String, completion: @escaping (Event) -> Void) {
        COLLECTION_EVENTS
            .document(eventId)
            .getDocument { snapshot, error in
                if let error = error {
                    print("DEBUG: Error fetching incoming event.\n\(error.localizedDescription)")
                    return
                }
                
                guard let event = try? snapshot?.data(as: Event.self) else { return }
                completion(event)
            }
    }
    
    
    private func fetchIncomingHost(hostId: String, completion: @escaping (Host) -> Void) {
        COLLECTION_HOSTS
            .document(hostId)
            .getDocument { snapshot, error in
                if let error = error {
                    print("DEBUG: Error fetching incoming event.\n\(error.localizedDescription)")
                    return
                }
                
                guard let host = try? snapshot?.data(as: Host.self) else { return }
                completion(host)
            }
    }
    
    
    private func fetchIncomingUser(userId: String, completion: @escaping (User) -> Void) {
        COLLECTION_USERS
            .document(userId)
            .getDocument { snapshot, error in
                if let error = error {
                    print("DEBUG: Error fetching incoming event.\n\(error.localizedDescription)")
                    return
                }
                
                guard let user = try? snapshot?.data(as: User.self) else { return }
                completion(user)
            }
    }
}
