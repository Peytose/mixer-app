//
//  NotificationsView.swift
//  mixer
//
//  Created by Peyton Lyons on 8/23/23.
//

import SwiftUI
import FirebaseFirestore
import SwipeActions

struct NotificationsView: View {
    @StateObject var viewModel = NotificationsViewModel()
    @EnvironmentObject var homeViewModel: HomeViewModel
    @Namespace var namespace
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                HStack(spacing: 7) {
                    ForEach(viewModel.availableCategories, id: \.self) { category in
                        NotificationCategoryCell(text: category.stringVal,
                                                 isSecondaryLabel: category != viewModel.currentCategory) {
                            viewModel.setCurrentCategory(category)
                        }
                    }
                }
                .padding(.bottom)
                
                LazyVStack {
                    let now = Date()
                    let sevenDaysAgo = Calendar.current.date(byAdding: .day, value: -7, to: now)!
                    // Separate notifications into recent and older
                    let recentNotifications = viewModel.notifications.filter { $0.timestamp.dateValue() >= sevenDaysAgo && ($0.type.category == viewModel.currentCategory || viewModel.currentCategory == .all) }
                    let olderNotifications = viewModel.notifications.filter { $0.timestamp.dateValue() < sevenDaysAgo && ($0.type.category == viewModel.currentCategory || viewModel.currentCategory == .all) }
                    
                    // Conditionally display "Last 7 Days" if there are recent notifications
                    if !recentNotifications.isEmpty {
                        VStack {
                            NotificationHeader(text: "Last 7 Days")
                            
                            ForEach(recentNotifications) { notification in
                                NotificationCell(cellViewModel: viewModel.viewModelForNotification(notification))
                                    .environmentObject(self.viewModel)
                                    .environmentObject(homeViewModel)
                                    .background(Color.theme.backgroundColor)
                                    .addFullSwipeAction(menu: .slided,
                                                        swipeColor: .red,
                                                        swipeRole: .destructive) {
                                        Leading { }
                                        Trailing {
                                            Button {
                                                withAnimation {
                                                    viewModel.deleteNotification(notification: notification)
                                                }
                                            } label: {
                                                Image(systemName: "trash")
                                                    .foregroundColor(.white)
                                            }
                                            .contentShape(Rectangle())
                                            .frame(width: 60)
                                            .frame(maxHeight: .infinity)
                                            .background(Color.red)
                                        }
                                    } action: {
                                        withAnimation {
                                            viewModel.deleteNotification(notification: notification)
                                        }
                                    }
                            }
                        }
                    }
                    
                    // Conditionally display "Older" if there are older notifications
                    if !olderNotifications.isEmpty {
                        VStack {
                            NotificationHeader(text: "Older")
                            
                            ForEach(olderNotifications) { notification in
                                NotificationCell(cellViewModel: viewModel.viewModelForNotification(notification))
                                    .environmentObject(self.viewModel)
                                    .environmentObject(homeViewModel)
                                    .background(Color.theme.backgroundColor)
                                    .addFullSwipeAction(menu: .slided,
                                                        swipeColor: .red,
                                                        swipeRole: .destructive) {
                                        Leading { }
                                        Trailing {
                                            Button {
                                                withAnimation {
                                                    viewModel.deleteNotification(notification: notification)
                                                }
                                            } label: {
                                                Image(systemName: "trash")
                                                    .foregroundColor(.white)
                                            }
                                            .contentShape(Rectangle())
                                            .frame(width: 60)
                                            .frame(maxHeight: .infinity)
                                            .background(Color.red)
                                        }
                                    } action: {
                                        withAnimation {
                                            viewModel.deleteNotification(notification: notification)
                                        }
                                    }
                            }
                        }
                    }
                }
            }
            .padding(.top, 10)
            .padding(.leading)
        }
        .onAppear {
            viewModel.saveCurrentTimestamp()
        }
        .background(Color.theme.backgroundColor)
        .navigationBarBackButtonHidden(true)
        .navigationBarTitle("Notifications", displayMode: .inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                PresentationBackArrowButton()
            }
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
                    .foregroundColor(.white)
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
