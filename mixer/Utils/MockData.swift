//
//  MockData.swift
//  mixer
//
//  Created by Peyton Lyons on 11/12/22.
//

import Foundation

struct Mockdata {
    static var user: User {
        return User(username: "test_user",
                    email: "test@email.edu",
                    profileImageUrl: "https://images.squarespace-cdn.com/content/v1/53ed0e3ce4b0c296acaeae80/1584577511464-8FDZYWQVXUI1OBS4VTZP/Bonneville14082-Edit-DHWEB%2BNick%2BFerguson%2BDenver%2BBroncos%2BHeadshot%2BPhotography%2Bby%2BAaron%2BLucy%2BDenver%2BColorado%2BHeadshots%2BPhotographer.jpg?format=2500w",
                    firstName: "William",
                    lastName: "Hendricks",
                    age: "21",
                    university: "Mississippi State University",
                    major: "Civil Engineering",
                    bio: "This is an example bio. Here it is. I'm making it purposely long, so I can see how it looks on a profile.")
    }
}
