////
////  AddToGuestlistView.swift
////  mixer
////
////  Created by Jose Martinez on 10/10/22.
////
//
//import SwiftUI
//
//struct AddToGuestlistView: View {
//    @EnvironmentObject var guestlistViewModel: GuestlistViewModel
//    @Environment(\.presentationMode) var mode
//    @Binding var isShowingAddGuestView: Bool
//    @State var guestUsername: String          = ""
//    @State var guestName: String              = ""
//    @State var university: UniversityExamples = .mit
//    @State var customUniversityName: String   = ""
//    @State var guestStatus: GuestStatus       = .invited
//    @State var guestGender: Gender            = .preferNot
//    @State var guestAge: Int = 17
//    
//    enum UniversityExamples: String, CaseIterable {
//        case mit = "MIT"
//        case neu = "NEU"
//        case bu = "BU"
//        case harvard = "Harvard"
//        case bc = "BC"
//        case tufts = "Tufts"
//        case simmons = "Simmons"
//        case wellesley = "Wellesley"
//        case berklee = "Berklee College of Music"
//        case other = "Other"
//    }
//    
//    enum Gender: String, CaseIterable {
//        case male      = "Male"
//        case female    = "Female"
//        case other     = "Other"
//        case preferNot = "Prefer not to say"
//        
//        var icon: String {
//            switch(self) {
//                case .male: return "human-male"
//                case .female: return "human-female"
//                default: return ""
//            }
//        }
//    }
//
//    var body: some View {
//        NavigationView {
//            List {
//                statusPicker
//                
//                userSearchSection
//                
//                guestDetailsSection
//                
//                optionalDetailsSection
//                
//                Section{}.listRowBackground(Color.clear)
//            }
//            .configureList()
//            .navigationBar(title: "Add Guest", displayMode: .inline)
//            .toolbar {
//                ToolbarItem(placement: .navigationBarTrailing) {
//                    Button(action: {
//                        guestlistViewModel.createGuest(username: guestUsername,
//                                                       name: guestName,
//                                                       university: university == .other ? customUniversityName : university.rawValue,
//                                                       status: guestStatus,
//                                                       age: guestAge,
//                                                       gender: guestGender.rawValue)
//                        
//                        isShowingAddGuestView.toggle()
//                    }, label: {
//                        Text("Submit")
//                            .foregroundColor(.blue)
//                            .bold()
//                    })
//                }
//                
//                ToolbarItem(placement: .navigationBarLeading) {
//                    Button(role: .cancel, action: {
//                        withAnimation() {
//                            mode.wrappedValue.dismiss()
//                        }
//                    }, label: {
//                        Text("Cancel")
//                            .foregroundColor(.secondary)
//                    })
//                }
//            }
//            .preferredColorScheme(.dark)
//        }
//    }
//}
//
//extension AddToGuestlistView {
//    var userSearchSection: some View {
//        Section {
//            TextField("Enter a user's username ...", text: $guestUsername)
//                .foregroundColor(.white)
//                .autocorrectionDisabled()
//                .disabled(guestName != "")
//        } header: {
//            Text("Username")
//                .fontWeight(.semibold)
//        } footer: {
//            Text("If user doesn't have a mixer account, continue below")
//        }
//        .listRowBackground(Color.theme.secondaryBackgroundColor)
//    }
//    
//    var guestDetailsSection: some View {
//        Section {
//            guestNameField
//            
//            universityField
//            
//            if university == .other {
//                customUniversityField
//            }
//            
//            genderField
//        } header: {
//            Text("Guest Details")
//                .fontWeight(.semibold)
//        }
//        .listRowBackground(Color.theme.secondaryBackgroundColor)
//    }
//    
//    var optionalDetailsSection: some View {
//        Section {
//            Stepper("Age: \(guestAge == 17 ? "N/A" : String(guestAge))", value: $guestAge, in: 17...100)
//                .disabled(guestUsername != "")
//        } header: {
//            Text("Optional Details")
//                .fontWeight(.semibold)
//        }
//        .listRowBackground(Color.theme.secondaryBackgroundColor)
//    }
//
//    var guestNameField: some View {
//        TextField("Name", text: $guestName)
//            .foregroundColor(.white)
//            .autocorrectionDisabled()
//            .disabled(guestUsername != "")
//    }
//    
//    var universityField: some View {
//        HStack {
//            Text(university == UniversityExamples.other ? customUniversityName : university.rawValue)
//
//            Spacer()
//
//            Menu("Select School") {
//                ForEach(UniversityExamples.allCases, id: \.self) { university in
//                    Button(university.rawValue) {
//                        self.university = university
//                    }
//                }
//            }
//            .accentColor(Color.theme.mixerIndigo)
//            .disabled(guestUsername != "")
//        }
//    }
//    
//    var customUniversityField: some View {
//        TextField("School Name", text: $customUniversityName, axis: .vertical)
//            .foregroundColor(.white)
//            .autocorrectionDisabled()
//            .disabled(guestUsername != "")
//    }
//    
//    var genderField: some View {
//        HStack {
//            Text(guestGender.rawValue)
//            
//            Spacer()
//            
//            Menu("Select Gender") {
//                ForEach(Gender.allCases, id: \.self) { gender in
//                    Button(gender.rawValue) {
//                        self.guestGender = gender
//                    }
//                }
//            }
//            .accentColor(Color.theme.mixerIndigo)
//            .disabled(guestUsername != "")
//        }
//    }
//    
//    var statusPicker: some View {
//        Section {
//            Picker("", selection: $guestStatus) {
//                ForEach(GuestStatus.allCases, id: \.self) { status in
//                    Text(status.stringVal)
//                        .tag(status)
//                }
//            }
//            .pickerStyle(.segmented)
//        } header: {
//            Text("Status")
//                .fontWeight(.semibold)
//        }
//        .listRowBackground(Color.theme.secondaryBackgroundColor)
//    }
//}
