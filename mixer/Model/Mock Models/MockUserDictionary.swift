//
//  MockUserDictionary.swift
//  mixer
//
//  Created by Jose Martinez on 1/19/23.
//
import SwiftUI

class MockUserDictionary : ObservableObject {
    //MARK:- Variables
    var guestData : [MockUser]
    @Published var sectionDictionary : Dictionary<String , [MockUser]>
    //MARK:- initializer
    init() {
        guestData = users
        sectionDictionary = [:]
        sectionDictionary = getSectionedDictionary()
    }
    //MARK:- sectioned dictionary
    func getSectionedDictionary() -> Dictionary <String , [MockUser]> {
        let sectionDictionary: Dictionary<String, [MockUser]> = {
            return Dictionary(grouping: guestData, by: {
                let name = $0.name
                let normalizedName = name.folding(options: [.diacriticInsensitive, .caseInsensitive], locale: .current)
                let firstChar = String(normalizedName.first!).uppercased()
                return firstChar
            })
        }()
        return sectionDictionary
    }
}
