////
////  SearchView.swift
////  mixer
////
////  Created by Peyton Lyons on 11/12/22.
////
//
//import SwiftUI
//import Kingfisher
//import DebouncedOnChange
//
//struct SearchView: View {
//    @ObservedObject var viewModel = SearchViewModel()
//    @State var showAlert = false
//    
//    var body: some View {
//        NavigationView {
//            VStack {
//                List {
//                    listContent
//                        .redacted(reason: viewModel.isLoading ? .placeholder : [])
//                }
//                .scrollContentBackground(.hidden)
//            }
//            .background(Color.theme.backgroundColor)
//            .overlay {
//                Image("Blob 1")
//                    .resizable()
//                    .aspectRatio(contentMode: .fill)
//                    .frame(width: 300, height: 300, alignment: .top)
//                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
//                    .opacity(0.8)
//                    .offset(x: -40, y: -355)
//            }
//            .navigationTitle("Search")
//            .searchable(text: $viewModel.text,
//                        placement: .automatic,
//                        prompt: "Search Users")
//            .onChange(of: viewModel.text) { search in
//                viewModel.executeSearch(for: search.lowercased())
//            }
//        }
//        .preferredColorScheme(.dark)
//    }
//}
//
//extension SearchView {
//    var listContent: some View {
//        ForEach(viewModel.users) { user in
//            NavigationLink(destination: ProfileView(viewModel: ProfileViewModel(user: user))) {
//                UserSearchCell(user: user)
//            }
//            .listRowSeparator(.hidden)
//            .listRowBackground(Color.theme.backgroundColor)
//            .swipeActions {
//                Button("Add Friend") {
//                    showAlert.toggle()
//                }
//                .tint(Color.theme.mixerPurple)
//            }
//        }
//        .alert("Friend Request Sent", isPresented: $showAlert) {
//            Button("Ok", role: .cancel) { }
//        }    }
//}
//
//fileprivate struct UserSearchCell: View {
//    let user: User
//    
//    var body: some View {
//        HStack(spacing: 15) {
//            KFImage(URL(string: user.profileImageUrl))
//                .resizable()
//                .aspectRatio(contentMode: .fill)
//                .frame(width: 45, height: 45)
//                .clipShape(Circle())
//            
//            VStack(alignment: .leading) {
//                HStack(spacing: 2) {
//                    Text(user.name)
//                        .font(.callout.weight(.semibold))
//                        .foregroundColor(.white)
//                    
//                    Spacer()
//                    
//                    if let university = user.universityData["name"] {
//                        Image(systemName: "graduationcap.fill")
//                            .imageScale(.small)
//                            .foregroundColor(.secondary)
//                        
//                        Text(university)
//                            .font(.subheadline)
//                            .fontWeight(.medium)
//                            .foregroundColor(.secondary)
//                    }
//                }
//                
//                HStack {
//                    Text("@\(user.username)")
//                        .font(.subheadline)
//                        .foregroundColor(.secondary)
//                    
//                    Spacer()
//                    
//                    if user.relationshiptoUser == .friends {
//                        Text("Friend")
//                            .font(.subheadline)
//                            .foregroundColor(Color.theme.mixerIndigo)
//                    }
//                }
//            }
//        }
//        .padding(.vertical, -4)
//    }
//}
//
//struct SearchView_Previews: PreviewProvider {
//    static var previews: some View {
//        SearchView()
//            .preferredColorScheme(.dark)
//    }
//}
