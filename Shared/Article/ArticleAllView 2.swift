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
    
    var body: some View {
        VStack (alignment: .leading, spacing: 5) {
            #if os(iOS)
            Text(article.title)
                .font(.system(size: 15, weight: .regular))
            Text(article.introduction)
                .font(.system(size: 13, weight: .light))
            Text(article.url)
                .font(.system(size: 13, weight: .light))
                .foregroundColor(.blue)
            #elseif os(macOS)
            Text(article.title)
                .font(.system(size: 15, weight: .regular))
            Text(article.introduction)
                .font(.system(size: 10, weight: .regular))
            Text(article.url)
                .font(.system(size: 10, weight: .regular))
                .foregroundColor(.blue)
            #endif
        }
        .padding(.top, 5)
    }
}

