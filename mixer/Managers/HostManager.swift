//
//  HostManager.swift
//  mixer
//
//  Created by Peyton Lyons on 8/18/23.
//

import Firebase

class HostManager: ObservableObject {
    static let shared = HostManager()
    @Published var selectedHost: Host?
    @Published var hosts = [Host]()
    
    init() {
        self.fetchHosts()
    }
    
    
    func fetchHosts() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        COLLECTION_HOSTS.getDocuments { snapshot, _ in
            print("DEBUG: Did fetch user from firestore.")
            guard let documents = snapshot?.documents else { return }
            let hosts = documents.compactMap({ try? $0.data(as: Host.self) })
            self.hosts = hosts
        }
    }
    
    
    func fetchHosts(with ids: [String], completion: @escaping ([Host]) -> Void) {
        var hosts: [Host] = []
        let group = DispatchGroup()
        
        for id in ids {
            group.enter()
            COLLECTION_HOSTS
                .document(id)
                .getDocument { snapshot, error in
                    if let error = error {
                        print("DEBUG: Error fetching host. \(error.localizedDescription)")
                        return
                    }
                    
                    guard let host = try? snapshot?.data(as: Host.self) else { return }
                    hosts.append(host)
                    
                    group.leave()
                }
        }
        
        group.notify(queue: .main) {
            completion(hosts)
        }
    }
}

