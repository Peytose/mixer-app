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
                ScrollView(.horizontal) {
                    HStack(spacing: 10) {
                        ForEach(viewModel.availableCategories, id: \.self) { category in
                            NotificationCategoryCell(text: category.stringVal,
                                                     isSecondaryLabel: category != viewModel.currentCategory) {
                                viewModel.setCurrentCategory(category)
                            }
                        }
                    }
                    .scrollIndicators(.hidden)
                }
                .padding(.bottom)

                
                LazyVStack {
                    let now = Date()
                    let calendar = Calendar.current

                    // Start of today
                    let startOfToday = calendar.startOfDay(for: now)

                    // Start of the day 7 days ago
                    let sevenDaysAgo = calendar.date(byAdding: .day, value: -7, to: startOfToday)!

                    // Separate notifications based on the corrected logic
                    let todayNotifications = viewModel.notifications.filter {
                        $0.timestamp.dateValue() >= startOfToday &&
                        ($0.type.category == viewModel.currentCategory || viewModel.currentCategory == .all)
                    }

                    let recentNotifications = viewModel.notifications.filter {
                        let notificationDate = $0.timestamp.dateValue()
                        return notificationDate < startOfToday &&
                               notificationDate >= sevenDaysAgo &&
                               ($0.type.category == viewModel.currentCategory || viewModel.currentCategory == .all)
                    }

                    let olderNotifications = viewModel.notifications.filter {
                        $0.timestamp.dateValue() < sevenDaysAgo &&
                        ($0.type.category == viewModel.currentCategory || viewModel.currentCategory == .all)
                    }
                    
                    if !todayNotifications.isEmpty {
                        VStack(spacing: 0) {
                            NotificationHeader(text: "Today")
                                .padding(.bottom)
                            
                            ForEach(todayNotifications) { notification in
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
                            
                            Divider()
                                .padding(0)
                                .padding(.bottom, 4)
                        }
                    }

                    if !recentNotifications.isEmpty {
                        VStack(spacing: 0) {
                            NotificationHeader(text: "Last 7 Days")
                                .padding(.bottom)
                            
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
                            
                            Divider()
                                .padding(0)
                                .padding(.bottom, 4)
                        }
                    }
                    
                    // Conditionally display "Older" if there are older notifications
                    if !olderNotifications.isEmpty {
                        VStack(spacing: 0) {
                            NotificationHeader(text: "Older")
                                .padding(.bottom)
                            
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
                            
                            Divider()
                                .padding(0)
                                .padding(.bottom, 4)
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
        .navigationBarTitle("Notifications", displayMode: .large)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                PresentationBackArrowButton()
            }
        }
        .sheet(isPresented: $viewModel.showCreateHostView) {
            BecomeHostView(notificationId: viewModel.selectedNotificationId)
        }
    }
}

fileprivate struct NotificationHeader: View {
    let text: String
    
    var body: some View {
        VStack {
            HStack {
                Text(text)
                    .font(.headline)
                    .foregroundColor(.white)
                Spacer()
            }
        }
    }
}
