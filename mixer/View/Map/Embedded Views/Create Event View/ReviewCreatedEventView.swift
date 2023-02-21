//
//  ReviewCreatedEventView.swift
//  mixer
//
//  Created by Jose Martinez on 12/22/22.
//

//
//  EventVisibilityView.swift
//  mixer
//
//  Created by Jose Martinez on 12/22/22.
//


import SwiftUI

struct ReviewCreatedEventView: View {
    @StateObject var viewModel = CreateEventViewModel()
    @Environment(\.presentationMode) var presentationMode
    
    @State var showAlert = false
    
    var body: some View {
        ZStack {
            Color.mixerBackground
                .ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 18) {
                    Text("\(viewModel.isPrivate.stringVersion) Event \(Image(systemName: viewModel.isPrivate == .yes ? "lock.fill": "globe"))")
                        .font(.title3).fontWeight(.medium)
                        .foregroundColor(.secondary)
                        .padding(.bottom, 5)
                    
                    content
                    
                    VStack(alignment: .leading) {
                        Text("Event Description:")
                            .font(.title3).fontWeight(.medium)
                        
                        Text("Neon party at Theta Chi, need we say more?")
                            .font(.headline)
                            .foregroundColor(.secondary)
                            .lineLimit(4)
                    }
                    
                    VStack(alignment: .leading) {
                        Text("Attire Description:")
                            .font(.title3).fontWeight(.medium)
                        
                        Text("Normal party clothes, neon if possible")
                            .font(.headline)
                            .foregroundColor(.secondary)
                            .lineLimit(4)
                    }
                    
                    VStack(alignment: .leading) {
                        Text("Note for guest:")
                            .font(.title3).fontWeight(.medium)
                        
                        Text("N/A")
                            .font(.headline)
                            .foregroundColor(.secondary)
                            .lineLimit(4)
                    }
                    
                    
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Event Flyer:")
                            .font(.title3).fontWeight(.medium)
                        
                        Image(uiImage: viewModel.flyer)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .cornerRadius(20)
                            .frame(width: 208, height: 250, alignment: .center)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding()
                    }
                }
                .preferredColorScheme(.dark)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                .padding(EdgeInsets(top: 0, leading: 21, bottom: 80, trailing: 10))
            }
        }
        .navigationBarTitle(Text("Review Neon Party"), displayMode: .large)
        .navigationBarBackButtonHidden(true)
        .overlay(alignment: .bottom, content: {
            NextButton(text: "Create Party")
                .onTapGesture {
                    let impact = UIImpactFeedbackGenerator(style: .light)
                    impact.impactOccurred()
                    showAlert.toggle()
                }
            
        })
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }, label: {
                    BackArrowButton()
                })
            }
        }
        .alert("Event Created!", isPresented: $showAlert, actions: {})
    }
    
    var content: some View {
        VStack(alignment: .leading, spacing: 18) {
            reviewDetailRow(title: "Starts", value: "Friday, Jan 20 at 9:00 PM")
            reviewDetailRow(title: "Ends", value: "Saturday, Jan 21 at 1:00 AM")
            reviewDetailRow(title: "Location", value: "528 Beacon St, Boston MA 02215")
            reviewDetailRow(title: "Ends", value: "Saturday, Jan 21 at 1:00 AM")
            reviewDetailRow(title: "Type", value: "Wet")
            reviewDetailRow(title: "Theme", value: "Neon")
        }
    }
    
    private struct reviewDetailRow: View {
        var title: String
        var value: String
        var body: some View {
            HStack {
                Text("\(title):")
                    .font(.title3).fontWeight(.medium)
                
                Text(value)
                    .font(.headline)
                    .foregroundColor(.secondary)
            }
        }
    }
}


struct ReviewCreatedEventView_Previews: PreviewProvider {
    static var previews: some View {
        ReviewCreatedEventView()
    }
}



