////
////  WikipediaView.swift
////  Ravens
////
////  Created by Eric de Quartel on 16/05/2024.
////
//
//import SwiftUI
//import Kingfisher
//
//struct WikipediaView: View {
//    @StateObject var viewModel = WikipediaViewModel()
////    @State private var topic = ""
//    
//    var topic: String = ""
//    
//    var body: some View {
//        NavigationView {
//            VStack {
////                TextField("Search Wikipedia", text: topic, onCommit: {
////                    viewModel.fetchDetails(topic: topic)
////                })
////                .textFieldStyle(RoundedBorderTextFieldStyle())
////                .padding()
////                .padding(.horizontal, 20)  // Extra horizontal padding for the text field
//                
//                if viewModel.isLoading {
//                    ProgressView()
//                } else {
//                    VStack(alignment: .leading, spacing: 20) {  // Increased spacing for elements within the VStack
//                        Text(viewModel.pageDetail.title)
//                            .font(.title)
//                            .fontWeight(.bold)
//                            .padding(.bottom, 5)  // Small padding below the title to separate from the text
//                        
//                        if let thumbnail = viewModel.pageDetail.thumbnail {
//                          KFImage(URL(string: thumbnail.source))
//                            .resizable()
//                            .aspectRatio(contentMode: .fit)
//                            .frame(width: 100, height: 100)
//                            .cornerRadius(8)
//                            .padding([.top, .horizontal], 20)  // Padding around the image
////                          CachedAsyncImage(url: URL(string: thumbnail.source)) { image in
////                                image.resizable()
////                            } placeholder: {
////                                ProgressView()
////                            }
////                            .aspectRatio(contentMode: .fit)
////                            .frame(width: 100, height: 100)
////                            .cornerRadius(8)
////                            .padding([.top, .horizontal], 20)  // Padding around the image
//                        }
//                        
//                        ScrollView {
//                            Text(viewModel.pageDetail.extract)
//                                .padding()  // Padding inside the ScrollView around the extract text
//                        }
//                    }
//                    .padding(.horizontal, 20)  // Padding for the entire VStack to align with the text field above
//                }
//            }
//            .onAppear() {
//                print(topic)
//                viewModel.fetchDetails(topic: topic)
//            }
//            .navigationTitle("Wikipedia Explorer")
//            .navigationBarTitleDisplayMode(.inline)
//        }
//    }
//}
//
//
//
//
//#Preview {
//    WikipediaView()
//}
