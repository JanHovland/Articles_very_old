//
//  ArticleAllView.swift
//  Articles
//
//  Created by Jan Hovland on 04/01/2021.
//

import SwiftUI
import CloudKit

struct ArticleAllView: View {
    var article: Article
    
    @State private var isShowingEditView: Bool = false
    
    var body: some View {
        VStack {
            HStack {
                Image(systemName: "square.and.pencil")
                    .resizable()
                    .frame(width: 10, height: 10, alignment: .center)
                    .font(Font.title.weight(.semibold))
                    .foregroundColor(.accentColor)
                    .gesture(
                        TapGesture()
                            .onEnded({_ in
                                /// Rutine for å editere en artikkel
                                isShowingEditView.toggle()
                            })
                    )
                VStack (alignment: .leading, spacing: 5) {
                    #if os(iOS)
                    Text(article.subType1)
                        .font(.system(size: 15, weight: .regular))
                        .foregroundColor(.red)
                    Text(article.title)
                        .font(.system(size: 15, weight: .regular))
                    Text(article.introduction)
                        .font(.system(size: 13, weight: .light))
                    Text(article.url)
                        .font(.system(size: 13, weight: .light))
                        .foregroundColor(.blue)
                    #elseif os(macOS)
                    Text(article.subType1)
                        .font(.system(size: 15, weight: .regular))
                        .foregroundColor(.red)
                    Text(article.title)
                        .font(.system(size: 15, weight: .regular))
                        .lineLimit(nil)
                    Text(article.introduction)
                        .font(.system(size: 11, weight: .light))
                        .lineLimit(nil)
                    Text(article.url)
                        .font(.system(size: 11, weight: .light))
                        .foregroundColor(.green)
                        .lineLimit(nil)
                    #endif
                }
            }
        }
        .padding(.top, 5)
        .sheet(isPresented: $isShowingEditView) {
            ArticleEditView(article: article)
        }
    }
}
