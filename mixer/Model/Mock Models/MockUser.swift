//
//  MockUser.swift
//  mixer
//
//  Created by Jose Martinez on 12/20/22.
//

import SwiftUI

struct MockUser: Identifiable {
    let id = UUID()
    var index: Int
    var name: String
    var status: String
    var affiliation: String
    var image: String
    var school: String
    var major: String
    var username: String
    var banner: String
    var age: String
    var instagram: String
}
//Profile Background 2
//banner-image-1
var users = [
    MockUser(index: 0, name: "Albert Garcia", status: "Single and ready to mingle", affiliation: "MIT Theta Chi", image: "mock-user-3", school: "MIT", major: "Computer Science", username: "albertgarcia1", banner: "banner-image-1", age: "22", instagram: "https://instagram.com/albert0507?igshid=Zjc2ZTc4Nzk="),
    MockUser(index: 1, name: "Vijay Dey", status: "Down for anything", affiliation: "MIT Theta Chi", image: "mock-user-2", school: "MIT", major: "Quant Guy", username: "vijaydey", banner: "Profile Background 2", age: "21", instagram: "https://instagram.com/v_dey123?igshid=Zjc2ZTc4Nzk="),
    MockUser(index: 2, name: "Andre Hamelburg", status: "Taken :(", affiliation: "MIT Theta Chi", image: "mock-user-4", school: "MIT", major: "Chemical Engineering", username: "andrehamelburg", banner: "Profile Background 2", age: "20", instagram: "https://instagram.com/andre.hamelberg?igshid=Zjc2ZTc4Nzk="),
    MockUser(index: 3, name: "Divij Lankalapalli", status: "Ready to bang", affiliation: "MIT Theta Chi", image: "mock-user-5", school: "MIT", major: "Computer Science and Math", username: "divijlankalapalli", banner: "banner-image-1", age: "20", instagram: "https://instagram.com/mrdivij?igshid=Zjc2ZTc4Nzk="),
    MockUser(index: 4, name: "Spencer Yandrofski", status: "Newly Single", affiliation: "MIT Theta Chi", image: "profile-banner-2", school: "MIT", major: "Mechanical Engineering", username: "spenceryandrofski", banner: "banner-image-1", age: "20", instagram: "https://instagram.com/spencer__y?igshid=Zjc2ZTc4Nzk="),
    MockUser(index: 5, name: "Roberto Sarabia", status: "Taken :)", affiliation: "MIT Theta Chi", image: "mock-user-6", school: "MIT", major: "Mechanical Engineering", username: "robertosarabia1", banner: "Profile Background 2", age: "22", instagram: "https://instagram.com/roberto_sarabia?igshid=Zjc2ZTc4Nzk="),
    MockUser(index: 6, name: "Mario Peraza", status: "Single and ready to mingle", affiliation: "MIT Theta Chi", image: "mock-user-7", school: "MIT", major: "Mechanical Engineering", username: "marioperaza", banner: "banner-image-1", age: "20", instagram: "https://instagram.com/mperaza0714?igshid=Zjc2ZTc4Nzk="),
    MockUser(index: 7, name: "Julian Hamelburg", status: "Down for anything", affiliation: "MIT Theta Chi", image: "mock-user-8", school: "MIT", major: "Computer Science and Music", username: "julianhamelburg", banner: "Profile Background 2", age: "22", instagram: "https://instagram.com/prodbyjwln?igshid=Zjc2ZTc4Nzk="),
    MockUser(index: 8, name: "Jose Martinez", status: "Taken :)", affiliation: "MIT Theta Chi", image: "profile-banner-1", school: "MIT", major: "Aerospace Engineering", username: "josemartinez", banner: "Profile Background 2", age: "21", instagram: "https://instagram.com/jose_miguel_martinezzz?igshid=YmMyMTA2M2Y="),
    MockUser(index: 9, name: "Juan Reyes", status: "Ready to bang", affiliation: "MIT Theta Chi", image: "default-avatar", school: "MIT", major: "Math and Computer Science", username: "juanreyes", banner: "banner-image-1", age: "20", instagram: "https://instagram.com/juanesreyees?igshid=Zjc2ZTc4Nzk="),
    MockUser(index: 10, name: "Lucas Marden", status: "French Kissing rn", affiliation: "MIT Theta Chi", image: "default-avatar", school: "MIT", major: "Material Science", username: "lucasmarden", banner: "banner-image-1", age: "20", instagram: "https://instagram.com/lucas_marden?igshid=Zjc2ZTc4Nzk="),
    MockUser(index: 11, name: "Gabriel Burbridge", status: "Taken :)", affiliation: "", image: "default-avatar", school: "MSU", major: "Physics", username: "gabrielburbridge", banner: "Profile Background 2", age: "20", instagram: ""),
    MockUser(index: 12, name: "Creel Hendricks", status: "DTF XOXO", affiliation: "", image: "default-avatar", school: "MIT", major: "Civil Engineering", username: "creelhendricks", banner: "Profile Background 2", age: "20", instagram: ""),
    MockUser(index: 13, name: "Kevin Awoufak", status: "Single and ready to mingle", affiliation: "MIT Theta Chi", image: "default-avatar", school: "MIT", major: "Computer Science", username: "kevinawoufak", banner: "banner-image-1", age: "20", instagram: ""),
    MockUser(index: 14, name: "Derek Liang", status: "Down for anything", affiliation: "MIT Theta Chi", image: "default-avatar", school: "MIT", major: "Computer Science", username: "derekliang", banner: "banner-image-1", age: "20", instagram: ""),
    MockUser(index: 15, name: "Leon Fan", status: "Single", affiliation: "MIT Theta Chi", image: "default-avatar", school: "MIT", major: "Pre-med", username: "leonfan4", banner: "Profile Background 2", age: "20", instagram: ""),
    MockUser(index: 16, name: "Brian Robinson", status: "Ready to bang", affiliation: "MIT Theta Chi", image: "default-avatar", school: "MIT", major: "Aerospace Engineering", username: "brianrobinson", banner: "banner-image-1", age: "20", instagram: "https://instagram.com/brianrobinson5060?igshid=Zjc2ZTc4Nzk="),
    MockUser(index: 17, name: "Alex Edwards", status: "French Kissing rn", affiliation: "MIT Theta Chi", image: "default-avatar", school: "MIT", major: "Mechanical Engineering and Nuclear Engineering", username: "alexedwards99", banner: "banner-image-1", age: "20", instagram: ""),
    MockUser(index: 18, name: "Erik Thompson", status: "Taken :)", affiliation: "", image: "default-avatar", school: "MIT", major: "Mechanical Engineering", username: "erickthompson7", banner: "Profile Background 2", age: "20", instagram: ""),
    MockUser(index: 19, name: "Peyton Lyons", status: "Taken ;)", affiliation: "", image: "mock-user-1", school: "Fordham University", major: "Computer Science", username: "peytonlyons", banner: "banner-image-1", age: "20", instagram: "https://instagram.com/peytonalyons?igshid=Zjc2ZTc4Nzk=")
]
