//
//  NotificationsView.swift
//  mixer
//
//  Created by Peyton Lyons on 8/23/23.
//

import SwiftUI
import FirebaseFirestore

struct NotificationsView: View {
    @StateObject var viewModel = NotificationsViewModel()
    @EnvironmentObject var homeViewModel: HomeViewModel
    @Namespace var namespace
    
    var body: some View {
        ZStack {
            Color.theme.backgroundColor
                .ignoresSafeArea()
            
            VStack(alignment: .leading) {
                HStack {
                    Text("Notifications")
                        .font(.title)
                        .fontWeight(.semibold)
                        .foregroundStyle(.white)
                    
                    Spacer()
                }
                .padding(.bottom, 10)
                .padding(.leading)
                
                
                HStack(alignment: .center, spacing: 7) {
                    ForEach(viewModel.availableCategories, id: \.self) { category in
                        NotificationCategoryCell(text: category.stringVal,
                                                 isSecondaryLabel: category != viewModel.currentCategory) {
                            viewModel.setCurrentCategory(category)
                        }
                    }
                    
                    Spacer()
                }
                .padding(.leading)
                
                List {
                    let now = Date()
                    let sevenDaysAgo = Calendar.current.date(byAdding: .day, value: -7, to: now)!
                    // Separate notifications into recent and older
                    let recentNotifications = viewModel.notifications.filter { $0.timestamp.dateValue() >= sevenDaysAgo && ($0.type.category == viewModel.currentCategory || viewModel.currentCategory == .all) }
                    let olderNotifications = viewModel.notifications.filter { $0.timestamp.dateValue() < sevenDaysAgo && ($0.type.category == viewModel.currentCategory || viewModel.currentCategory == .all) }
                    
                    // Conditionally display "Last 7 Days" if there are recent notifications
                    if !recentNotifications.isEmpty {
                        Section {
                            ForEach(recentNotifications) { notification in
                                NotificationCell(cellViewModel: viewModel.viewModelForNotification(notification))
                                    .environmentObject(self.viewModel)
                                    .environmentObject(homeViewModel)
                                    .listRowBackground(Color.clear)
                                    .listRowSeparator(.hidden)
                                    .swipeActions {
                                        Button(role: .destructive) {
                                            viewModel.deleteNotification(notification: notification)
                                        } label: {
                                            Label("Delete", systemImage: "trash")
                                        }
                                    }
                            }
                        } header: {
                            NotificationHeader(text: "Last 7 Days")
                        }
                    }
                    
                    // Conditionally display "Older" if there are older notifications
                    if !olderNotifications.isEmpty {
                        Section {
                            ForEach(olderNotifications) { notification in
                                NotificationCell(cellViewModel: viewModel.viewModelForNotification(notification))
                                    .environmentObject(self.viewModel)
                                    .environmentObject(homeViewModel)
                                    .listRowBackground(Color.clear)
                                    .listRowSeparator(.hidden)
                                    .swipeActions {
                                        Button(role: .destructive) {
                                            viewModel.deleteNotification(notification: notification)
                                        } label: {
                                            Label("Delete", systemImage: "trash")
                                        }
                                    }
                            }
                        } header: {
                            NotificationHeader(text: "Older")
                        }
                    }
                }
                .listStyle(.plain)
                
                Spacer()
            }
            .padding(.top, 10)
        }
        .navigationBarBackButtonHidden(true)
        .onAppear {
            viewModel.saveCurrentTimestamp()
        }
    }
}

fileprivate struct NotificationHeader: View {
    let text: String
    
    var body: some View {
        VStack {
            HStack {
                Text(text)
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundStyle(.white)
                Spacer()
            }
            
            RoundedRectangle(cornerRadius: 4, style: .continuous)
                .fill(Color.secondary)
                .frame(height: 2)
                .opacity(0.7)
                .padding(.bottom, 7)
        }
    }
}
