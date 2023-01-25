////
////  EventCardView.swift
////  mixer
////
////  Created by Jose Martinez on 12/20/22.
////
//
import SwiftUI

struct EventCard: View {
    @EnvironmentObject var model: Model

    var event: MockEvent
    var namespace: Namespace.ID
    let link = URL(string: "https://mixer.llc")!

    var body: some View {
        CustomStickyStackView {
            Label {
                Rectangle()
                    .fill(Color.mixerBackground)
                    .ignoresSafeArea()
                    .overlay {
                        VStack(alignment: .center, spacing: 12) {
                            VStack {
                                Text(event.stickyMonth)
                                    .font(.headline.weight(.regular))
                                    .foregroundColor(.secondary)
                                
                                Text(event.stickyDay)
                                    .font(.title.weight(.bold))
                            }
                            
                            Image(systemName: event.visibility == "Open" ? "globe" : "lock.fill")
                                .imageScale(.large)
                                .padding(.top, -7)
                        }
                        .padding(.top, 10)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                        
                        
                    }
            } icon: {
            }
        } contentView: {
            VStack(spacing: 15) {
                VStack(alignment: .trailing) {
                        ShareLink(item: link) {
                                Image(systemName: "square.and.arrow.up")
                                .imageScale(.medium)
                                .fontWeight(.medium)
                                .padding(6)
                                .background(.ultraThinMaterial)
                                .clipShape(Circle())
                                .offset(y: -3)
                        }
                        .buttonStyle(.plain)
                        .padding(.top, 10)
                        .padding(.trailing, 10)
                    
                    Spacer()
                    
                    VStack(alignment: .leading, spacing: 0) {
                            Text(event.title)
                                .font(.title).bold()
                                .foregroundColor(.white)
                                .lineLimit(1)
                                .minimumScaleFactor(0.5)
                        
                        HStack(spacing: 5) {
                            Text("By \(event.hostName)")
                                .font(.subheadline.weight(.semibold))
                                .foregroundColor(.secondary)
                            
                            Image(systemName: "checkmark.seal.fill")
                                .imageScale(.small)
                                .symbolRenderingMode(.palette)
                                .foregroundStyle(.white, .blue)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 15)
                    .padding(.bottom, 5)
                    .padding(.top, 8)
                    .background(
                        Rectangle()
                            .fill(.ultraThinMaterial.opacity(0.98))
                            .background(Color.mixerBackground.opacity(0.1))
                            .frame(maxHeight: .infinity, alignment: .bottom)
                            .padding(-1)
                            .blur(radius: 9)
                            .padding(.horizontal, -20)
                            .padding(.bottom, -10)
                            .padding(.top, 3)
                    )
                }
                .background(
                    Image(event.flyer)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                )
                .mask(
                    RoundedRectangle(cornerRadius: 20)
                )
                
                VStack(alignment: .leading, spacing: 10) {
                    HStack(spacing: 20) {
                        VStack(alignment: .leading) {
                            Text(event.shortDate)
                                .font(.title3.bold())
                                .lineLimit(1)
                                .minimumScaleFactor(0.7)
                            
                            Text("\(event.type)")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .offset(y: 2)
                                .padding(0)
                        }
                        .padding(.trailing, -20)

                        Spacer()
                        
                        VStack(spacing: 6) {
                            Image(systemName: "drop.fill")
                                .resizable()
                                .scaledToFill()
                                .frame(width: 18, height: 18)
                            
                            Text("\(event.wetOrDry) Event")
                                .font(.footnote)
                                .foregroundColor(.secondary)
                                .offset(y: 2)
                        }
                        
                        VStack(spacing: 6) {
                            Image(systemName: "person.3.fill")
                                .resizable()
                                .scaledToFill()
                                .frame(width: 18, height: 18)
                                .symbolRenderingMode(.hierarchical)
                            
                            Text("\(event.attendance) Going")
                                .font(.footnote)
                                .foregroundColor(.secondary)
                                .offset(y: 2)
                        }
                    }
                    
                    Text(event.description)
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.7))
                        .lineLimit(3)
                        .minimumScaleFactor(0.75)
                }
                .padding(.trailing)
            }
        }
    }
}
//
struct RandomItem_Previews: PreviewProvider {
    @Namespace static var namespace

    static var previews: some View {
        EventCard(event: events[4], namespace: namespace)
            .environmentObject(Model())
    }
}
