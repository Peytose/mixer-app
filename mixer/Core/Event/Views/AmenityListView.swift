////
////  AmenityListView.swift
////  mixer
////
////  Created by Peyton Lyons on 2/22/23.
////
//
//import SwiftUI
//import UIKit
//
//struct AmenityListView: View {
//    let amenities: [EventAmenity]
//    @Environment(\.presentationMode) var mode
//    
//    var body: some View {
//        VStack(alignment: .leading) {
//            Text("Amenities")
//                .font(.title)
//                .fontWeight(.bold)
//                .padding(.leading)
//                .padding(.top)
//            
////            List {
////                ForEach(AmenityCategory.allCases, id: \.self) { category in
////                    if let amenities = amenities.filter({ $0.category == category }) {
////                        if !amenities.isEmpty {
////                            Section(header: CustomHeader(text: category.rawValue)) {
////                                ForEach(amenities, id: \.self) { amenity in
////                                    HStack(spacing: 15) {
////                                        Image(systemName: amenity.icon)
////                                            .resizable()
////                                            .scaledToFit()
////                                            .frame(width: 20, height: 20)
////                                        
////                                        Text(amenity.rawValue)
////                                            .font(.body)
////                                            .foregroundColor(.secondary)
////                                        
////                                        Spacer()
////                                    }
////                                }
////                            }
////                            .listSectionSeparator(.hidden)
////                            .listRowBackground(Color.clear)
////                            .textCase(.none)
////                        }
////                    }
////                }
////            }
////            .scrollContentBackground(.hidden)
////            .listStyle(.grouped)
//        }
//        .background(Color.theme.backgroundColor.edgesIgnoringSafeArea(.all))
//        .overlay(alignment: .topTrailing) {
//            XDismissButton { mode.wrappedValue.dismiss() }
//                .padding(.trailing)
//                .padding(.top)
//        }
//    }
//}
//
//fileprivate struct CustomHeader: View {
//    let text: String
//    
//    var body: some View {
//        Text(text.capitalized)
//            .font(.title3)
//            .fontWeight(.medium)
//            .foregroundColor(Color.theme.mixerIndigo.opacity(0.8))
//    }
//}
//
//struct AmenityListView_Previews: PreviewProvider {
//    static var previews: some View {
//        AmenityListView(amenities: Mockdata.event.amenities)
//            .preferredColorScheme(.dark)
//    }
//}
