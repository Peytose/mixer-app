//
//  EditAmenitiesView.swift
//  mixer
//
//  Created by Peyton Lyons on 12/10/23.
//

import SwiftUI

struct EditAmenitiesView: View {
    @Environment (\.dismiss) private var dismiss
    @ObservedObject var viewModel: EditEventViewModel
    var amenities: [EventAmenity]?
    var bathroomCount: Int?
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading) {
                ToggleAmenityView(viewModel: viewModel)
            }
            .padding()
            .padding(.bottom, 80)
        }
        .background(Color.theme.backgroundColor.ignoresSafeArea())
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                PresentationBackArrowButton()
            }

            ToolbarItem(placement: .navigationBarTrailing) {
                if let amenities = amenities {
                    ListCellActionButton(text: "Save",
                                         isSecondaryLabel: viewModel.isSecondaryButton()) {
                        if !viewModel.isSecondaryButton() {
                            viewModel.save(for: .amenities)
                            dismiss()
                        }
                    }
                }
            }
        }
    }
}
