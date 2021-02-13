//
//  SafariView.swift
//  Articles
//
//  Created by Jan Hovland on 04/01/2021.
//

import SwiftUI
import WebKit
import SafariServices
import CloudKit

#if os(macOS)

struct SafariView : NSViewRepresentable {
    var url: String
    var recordID: CKRecord.ID?
    
    func updateNSView(_ nsView: WKWebView, context: Context) {
        selectedRecordId =  recordID
    }
    
    func makeNSView(context: Context) -> WKWebView  {
        let view = WKWebView()
        if let url = URL(string: url) {
            view.load(URLRequest(url: url))
        }
        return view
    }
}

#elseif os(iOS)

struct SafariView: UIViewControllerRepresentable {
    typealias UIViewControllerType = SFSafariViewController

    var url: String
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<SafariView>) -> SFSafariViewController {
        return SFSafariViewController(url: URL(string: url)!)
    }

    func updateUIViewController(_ safariViewController: SFSafariViewController, context: UIViewControllerRepresentableContext<SafariView>) {
    }
}

#endif
