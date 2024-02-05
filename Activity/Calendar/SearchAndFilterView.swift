//
//  SearchAndFilterView.swift
//  iTrackWorkout
//
//  Created by JieTing on 2024/1/29.
//

import SwiftUI
import SwiftData

struct SearchAndFilterView: View {
    @Query var tags: [Tag]
    
    @Binding var isSearching : Bool
    @Binding var searchTerm : String
    
    @Binding var isShowingPopover: Bool
    
    var body: some View {
        ZStack{
            HStack{
                TextField("Type to search...".localized, text: $searchTerm)
                    .padding(7)
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                    .padding(.horizontal, 10)
                
                
                Button(action: {
                    self.isShowingPopover = true
                }) {
                    Text("Filter")
                }
                .padding()
            }
            .padding([.bottom])
            
            if isShowingPopover {
                HStack {
                    
                    Spacer()
                    
                    Text("Tags: ")
                        .font(.headline)
                    
                    Picker(selection: $searchTerm, label: Text("choice")) {
                        if tags.isEmpty{
                            Text("No tag exists").tag("")
                        }else{
                            Text("Choose tag").tag("")
                            ForEach(0..<tags.count) { index in
                                Text(tags[index].name).tag(tags[index].name)
                            }
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    
                    Spacer()
                    
                    Button(action: {
                        self.isShowingPopover = false
                        self.searchTerm = ""
                    })
                    {
                        Image(systemName: "xmark.circle.fill").imageScale(.large)
                    }
                    .padding()
                    
                }
                .frame(maxWidth: .infinity)
                .background(Color(UIColor.systemBackground))
                .cornerRadius(10)
                .shadow(radius: 5)
            }
        }
    }
}

//#Preview {
//    SearchAndFilterView()
//}
