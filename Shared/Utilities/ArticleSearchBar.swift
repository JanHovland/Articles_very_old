//
//  ArticleSearchBar.swift
//  Articles (iOS)
//
//  Created by Jan Hovland on 10/01/2021.
//

import SwiftUI

/// SearchBar er ikke er ikke en dekl av SWIFTUI
struct ArticleSearchBar: View {
    @Binding var text: String
    @State private var isEditing = false
    
    var body: some View {
        HStack {
             TextField(NSLocalizedString("Search...", comment: "SearchBar"), text: $text)
                .padding(.leading, 5)
                .padding(.horizontal, 45)
                .cornerRadius(8)
                .overlay(
                    HStack {
                      Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                        .frame(minWidth: 0, maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, minHeight: /*@START_MENU_TOKEN@*/0/*@END_MENU_TOKEN@*/, alignment: .leading)
                        .padding(.leading, 10)
                        
                        if isEditing {
                            Button(action: {
                                text = ""
                            }) {
                                Image(systemName: "multiply.circle.fill")
                                    .foregroundColor(.gray)
                                    .padding(.trailing, 5)
                            }
                        }
                    }
                )
                .padding(.horizontal, 10)
                .onTapGesture {
                    isEditing = true
                }
            
            if isEditing {
                Button(action: {
                    isEditing = false
                    text = ""
                }) {
                    Text(NSLocalizedString("Cancel", comment: "SearchBar"))
                }
                .padding(.trailing, 10)
                .transition(.move(edge: .trailing))
                .animation(.default)
            }
        }
    }
}
