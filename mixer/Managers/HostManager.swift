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
}

