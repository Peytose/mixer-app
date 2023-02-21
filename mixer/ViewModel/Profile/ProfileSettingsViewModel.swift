//
//  ProfileSettingsViewModel.swift
//  mixer
//
//  Created by Peyton Lyons on 2/3/23.
//

import SwiftUI
import Firebase

final class ProfileSettingsViewModel: ObservableObject {
    var user: User
    @Published var uploadComplete = false
    var phoneNumber: String { return Auth.auth().currentUser?.phoneNumber ?? "" }
    let supportLink = "https://docs.google.com/forms/d/e/1FAIpQLSch7XiTBu2dq3WzrklYHAZ_NpkuiH-TUtZOhE-H-4QEVWexPA/viewform?usp=pp_url"
    
    enum ProfileActionType {
        case saveName
    }
    
    init(user: User) {
        self.user = user
    }
    
    
    func saveName(_ name: String) {
        guard let uid = user.id else { return }
        guard name != "" else { return }
        
        COLLECTION_USERS.document(uid).updateData(["name": name]) { _ in
            self.user.name = name
            self.uploadComplete = true
        }
    }
    
    
    func getVersion() -> String {
        let dictionary = Bundle.main.infoDictionary!
        let version = dictionary["CFBundleShortVersionString"] as! String
        let build = dictionary["CFBundleVersion"] as! String
        return "\(version) build \(build)"
    }
    
    
    func getDateJoined() -> String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.second, .minute, .hour, .day]
        formatter.maximumUnitCount = 1
        formatter.unitsStyle = .full
        let days = formatter.string(from: user.dateJoined.dateValue(), to: Date()) ?? ""
        let date = user.dateJoined.getTimestampString(format: "MMMM d, yyyy")
        
        return "You joined mixer \(days) ago on \(date)."
    }
}
