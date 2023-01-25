//
//  CreateEventView.swift
//  mixer
//
//  Created by Jose Martinez on 12/18/22.
//

import SwiftUI
import MapItemPicker

struct CreateEventView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject var viewModel = CreateEventViewModel()
    @State var showAddressPicker = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.mixerBackground
                    .ignoresSafeArea()
                
                List {
                    flyerSection
                    
                    mainDetailsSection
                    
                    dateSection
                    
                    addressSection
                    
                    Section(header: Text("Map Preview")) {
                        MapSnapshotView(location: viewModel.coordinates, span: 0.001, delay: 0)
                            .cornerRadius(12)
                            .padding(.bottom, 60)
                    }
                    .listRowBackground(Color.clear)
                }
                .tint(.mixerIndigo)
                .preferredColorScheme(.dark)
                .scrollContentBackground(.hidden)
                .scrollIndicators(.hidden)
            }
            .overlay(alignment: .bottom, content: {
                NavigationLink(destination: EventVisibilityView()) {
                    NextButton()
                }
            })
            .navigationBarTitle(Text("Create an Event"), displayMode: .large)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading, content: {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.blue)
                })
            }
            .mapItemPicker(isPresented: $showAddressPicker) { item in
                if let name = item?.name {
                    print("Selected \(name)")
                }
            }
            .sheet(isPresented: $viewModel.isShowingPhotoPicker) { PhotoPicker(image: $viewModel.flyer) }
        }
    }
    
    var flyerSection: some View {
        Section(header: Text("Upload flyer")) {
            VStack {
                Image(uiImage: viewModel.flyer)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .cornerRadius(12)
                    .frame(width: 140, height: 140)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .padding()
            .onTapGesture {
                let impact = UIImpactFeedbackGenerator(style: .medium)
                impact.impactOccurred()
                
                viewModel.isShowingPhotoPicker = true
            }
            .listRowBackground(Color.clear)
        }
        
    }
    
    var mainDetailsSection: some View {
        Section(header: Text("Main Details")) {
            TextField("Event Title*", text: $viewModel.title)
                .foregroundColor(Color.mainFont)
                .font(.body.weight(.semibold))
            
            TextField("Event Theme*", text: $viewModel.theme, axis: .vertical)
                .foregroundColor(Color.mainFont)
                .font(.body.weight(.semibold))
                .lineLimit(4)
            
            TextField("Event/Theme Description*", text: $viewModel.description, axis: .vertical)
                .foregroundColor(Color.mainFont)
                .font(.body.weight(.semibold))
                .lineLimit(4)
        }
        .listRowBackground(Color.mixerSecondaryBackground)
    }
    
    var dateSection: some View {
        Section(header: Text("Date Details")) {
            EventDatePicker(text: "Start date*", selection: $viewModel.startDate)
            
            EventDatePicker(text: "End date*", selection: $viewModel.endDate)
            
            Picker("Wet or Dry", selection: $viewModel.selectedWetDry) {
                Text("Dry").tag(WetOrDry.dry)
                Text("Wet").tag(WetOrDry.wet)
            }
            .pickerStyle(.segmented)
            .padding(.vertical, 8)
        }
        .listRowBackground(Color.mixerSecondaryBackground)
    }
    
    var addressSection: some View {
        Section(header: Text("Location Details")) {
            Picker("Wet or Dry", selection: $viewModel.selectedAddress) {
                Text("Default Address").tag(UseCustomAddress.no)
                Text("Custom Address").tag(UseCustomAddress.yes)
            }
            .pickerStyle(.segmented)
            .padding(.vertical, 8)
            
            if viewModel.selectedAddress == .yes {
                Text("Tap to change")
                    .font(.body.weight(.semibold))
                    .foregroundColor(Color.secondary)
                    .onTapGesture {
                        showAddressPicker.toggle()

                    }
            } else {
                Text("Theta Chi House - 528 Beacon St")
                    .font(.body.weight(.semibold))
            }
            
        }
        .listRowBackground(Color.mixerSecondaryBackground)
    }
    
}


struct AddEventView_Previews: PreviewProvider {
    static var previews: some View {
        CreateEventView()
    }
}


fileprivate struct EventDatePicker: View {
    var text: String
    var selection: Binding<Date>
    
    var body: some View {
        DatePicker(text,
                   selection: selection,
                   displayedComponents: [.date, .hourAndMinute])
        .datePickerStyle(.automatic)
        .padding(EdgeInsets(top: 10, leading: 0, bottom: 10, trailing: -5))
    }
}
