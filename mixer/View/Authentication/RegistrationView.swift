////
////  RegistrationView.swift
////  mixer
////
////  Created by Peyton Lyons on 1/8/23.
////
//
//import SwiftUI
//
//struct RegistrationView: View {
//    @State private var email = ""
//    @State private var username = ""
//    @State private var fullname = ""
//    @State private var password = ""
//    @State private var selectedImage: UIImage?
//    @State private var image: Image?
//    @State var imagePickerPresented = false
//    @Environment(\.presentationMode) var mode
//    @EnvironmentObject var viewModel: AuthViewModel
//
//    var body: some View {
//        ZStack {
//            LinearGradient(gradient: Gradient(colors: [.purple, .blue]), startPoint: .top, endPoint: .bottom)
//                .ignoresSafeArea()
//
//            VStack {
//                Button { imagePickerPresented.toggle() } label: {
//                    if let image = image {
//                        image
//                            .resizable()
//                            .scaledToFill()
//                            .frame(width: 140, height: 140)
//                            .clipShape(Circle())
//                    } else {
//                        Image(systemName: "plus.app")
//                            .resizable()
//                            .scaledToFill()
//                            .frame(width: 140, height: 140)
//                            .foregroundColor(.white)
//                    }
//                }
//                .sheet(isPresented: $imagePickerPresented, onDismiss: loadImage, content: {
//                    ImagePicker(image: $selectedImage)
//                })
//                .padding()
//
//
//                VStack(spacing: 20) {
//                    CustomTextField(text: $email, placeholder: Text("Email"), imageName: "envelope")
//                        .padding()
//                        .background(Color(.init(white: 1, alpha: 0.15)))
//                        .cornerRadius(10)
//                        .foregroundColor(.white)
//                        .padding(.horizontal, 32)
//
//                    CustomTextField(text: $username, placeholder: Text("Username"), imageName: "person")
//                        .padding()
//                        .background(Color(.init(white: 1, alpha: 0.15)))
//                        .cornerRadius(10)
//                        .foregroundColor(.white)
//                        .padding(.horizontal, 32)
//
//                    CustomTextField(text: $fullname, placeholder: Text("Full Name"), imageName: "person")
//                        .padding()
//                        .background(Color(.init(white: 1, alpha: 0.15)))
//                        .cornerRadius(10)
//                        .foregroundColor(.white)
//                        .padding(.horizontal, 32)
//
//                    CustomSecureField(text: $password, placeholder: Text("Password"))
//                        .padding()
//                        .background(Color(.init(white: 1, alpha: 0.15)))
//                        .cornerRadius(10)
//                        .foregroundColor(.white)
//                        .padding(.horizontal, 32)
//                }
//
//                Button { viewModel.register(withEmail: email, password: password, image: selectedImage, fullname: fullname, username: username) } label: {
//                    Text("Sign Up")
//                        .font(.headline)
//                        .foregroundColor(.white)
//                        .frame(width: 360, height: 50)
//                        .background(Color(red: 0.693, green: 0.319, blue: 0.877))
//                        .clipShape(Capsule())
//                        .padding()
//                }
//
//                Spacer()
//
//                Button { mode.wrappedValue.dismiss() } label: {
//                    HStack {
//                        Text("Already have an account?")
//                            .font(.system(size: 14))
//
//                        Text("Sign In")
//                            .font(.system(size: 14, weight: .semibold))
//                    }
//                    .foregroundColor(.white)
//                }
//                .padding(.bottom, 16)
//            }
//        }
//    }
//}
//
//extension RegistrationView {
//    func loadImage() {
//        guard let selectedImage = selectedImage else { return }
//        image = Image(uiImage: selectedImage)
//    }
//}
//
//struct RegistrationView_Previews: PreviewProvider {
//    static var previews: some View {
//        RegistrationView()
//    }
//}
