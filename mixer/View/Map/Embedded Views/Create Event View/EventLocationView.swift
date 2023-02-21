//
//  EventLocationView.swift
//  mixer
//
//  Created by Jose Martinez on 12/22/22.
//


import SwiftUI
import MapItemPicker

struct EventLocationView: View {
    @StateObject var viewModel = CreateEventViewModel()
    @Environment(\.presentationMode) var presentationMode
    
    @State var showAddressPicker = false

    var body: some View {
        GeometryReader { proxy in
            ZStack {
                Color.mixerBackground
                    .ignoresSafeArea()
                
                VStack {
                    List {
                        Section(header: Text("Location Details")) {
                            HStack {
                                Text("528 Beacon St\nBoston, MA 02215")
                                    .font(.body.weight(.semibold))
                                
                                Spacer()
                                
                                Button {
                                    showAddressPicker.toggle()
                                } label: {
                                    Text("Tap to change")
                                        .foregroundColor(.blue)
                                }
                            }
                        }
                        .listRowBackground(Color.mixerSecondaryBackground)
                        
                            Section(header: Text("Map Preview")) {
                                MapSnapshotView(location: viewModel.coordinates, span: 0.002, delay: 0, width: (proxy.size.width - 50), height: (proxy.size.height * 0.5))
                                    .cornerRadius(20)
                            }
                            .listRowBackground(Color.clear)
                    }
                    .tint(.mixerIndigo)
                    .preferredColorScheme(.dark)
                    .scrollContentBackground(.hidden)
                }
            }
            .overlay(alignment: .bottom, content: {
                NavigationLink(destination: EventVisibilityView()) {
                    NextButton()
                }
            })
            .mapItemPicker(isPresented: $showAddressPicker) { item in
                if let name = item?.name {
                    print("Selected \(name)")
                }
            }
            .navigationBarTitle(Text("Location Details"), displayMode: .large)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }, label: {
                        BackArrowButton()
                    })
                }
        }
        }
    }
    
}


struct EventLocationView_Previews: PreviewProvider {
    static var previews: some View {
        EventLocationView()
    }
}

