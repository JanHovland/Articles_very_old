//
//  Articles.swift
//  Shared
//
//  Created by Jan Hovland on 04/01/2021.
//

/// Det er et problem dersom en drar skillet mellom de 2 halvdelene til venstre med musen til hele vinduet blir svart.
/// Oppskrift for å gjenopprette appen:
///   a) Gå til fullskjerm modum
///   b) Få frem bildet
///   c) Velg en artillel for å starte Internet
///   d) Da kommer det en feilmedling
///   e) Avslutt Xcode og start på nytt
///   f) Trykk cmd + shift + K for å "Clean" og feilmeldingen forsvinner
///   g) Kompiler på nytt
///   h) OK

import SwiftUI
import Network
import CoreData

var selectedRecordId: CKRecord.ID?

struct Articles: View {
    
    @State private var articles = [Article]()
    @State private var alertIdentifier: AlertID?
    @State private var message: String = ""
    @State private var message1: String = ""
    @State private var title: String = ""
    @State private var choise: String = ""
    @State private var indexSetDelete = IndexSet()
    @State private var searchText: String = ""
    @State private var device = ""
    
    let internetMonitor = NWPathMonitor()
    let internetQueue = DispatchQueue(label: "InternetMonitor")
    @State private var hasConnectionPath = false
    
    #if os(iOS)
    var body: some View {
        NavigationView {
            VStack {
                ArticleSearchBar(text: $searchText)
                    .padding(.top, 10)
                HStack (alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/, spacing: 50) {
                    NavigationLink(destination: ArticleNewView()) {
                        Text(NSLocalizedString("New Article", comment: "Articles"))
                    }
                    Button(action: {
                        refresh()
                    }, label: {
                        HStack {
                            Text("Refresh")
                        }
                    })
                    .padding(.top, 5)
                    .padding(.leading, 5)
                }
                List {
                    ForEach(articles.filter({ searchText.isEmpty ||
                                                $0.title.localizedStandardContains (searchText) } )) {
                        article in
                        NavigationLink(destination: SafariView(url: article.url)) {
                            ArticleAllView(article: article)
                        }
                    }
                    /// onDelete finne bare i iOS
                    .onDelete(perform: { indexSet in
                        indexSetDelete = indexSet
                        selectedRecordId = articles[indexSet.first!].recordID
                        title = NSLocalizedString("Delete Article?", comment: "Articles")
                        choise = NSLocalizedString("Delete this article", comment: "Articles")
                        alertIdentifier = AlertID(id: .delete)
                    })
                }
                /// navigationBarHidden kan kun brukes i iOS
                .navigationBarHidden(true)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear(perform: {
            /// Sjekker internett forbindelse
            startInternetTracking()
            /// Henter alle artiklene på nytt
            refresh()
        })
        .alert(item: $alertIdentifier) { alert in
            switch alert.id {
            case .first:
                return Alert(title: Text(message))
            case .second:
                return Alert(title: Text(message))
            case .delete:
                return Alert(title: Text(title),
                             message: Text(message),
                             primaryButton: .destructive(Text(choise),
                                                         action: {
                                                            CloudKitArticle.deleteArticle(recordID: selectedRecordId!) { (result) in
                                                                switch result {
                                                                case .success :
                                                                    message =  NSLocalizedString("Successfully deleted an article", comment: "UserOverView")
                                                                    alertIdentifier = AlertID(id: .first)
                                                                case .failure(let err):
                                                                    message = err.localizedDescription
                                                                    alertIdentifier = AlertID(id: .first)
                                                                }
                                                            }
                                                            /// Sletter den valgte raden i iOS
                                                            articles.remove(atOffsets: indexSetDelete)
                                                            
                                                         }),
                             secondaryButton: .default(Text(NSLocalizedString("Cancel", comment: "UserOverView"))))
            }
        }
    } /// var body
    #elseif os(macOS)
    var body: some View {
        NavigationView {
            VStack {
                ArticleSearchBar(text: $searchText)
                    .padding(.top, 10)
                    .controlSize(ControlSize.small)
                HStack (alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/, spacing: 50) {
                    NavigationLink(destination: ArticleNewView()) {
                        Text(NSLocalizedString("New Article", comment: "Articles"))
                    }
                    Button(action: {
                        refresh()
                    }, label: {
                        HStack {
                            Text("Refresh")
                        }
                    })
                }
                .controlSize(ControlSize.regular)
                .padding(.top, 5)
                .padding(.leading, 5)
                List {
                    ForEach(articles.filter({ searchText.isEmpty ||
                                                $0.title.localizedStandardContains (searchText) })) {
                        article in
                        NavigationLink(destination: SafariView(url: article.url, recordID: article.recordID)) {
                            VStack (alignment: .leading) {
                                ArticleAllView(article: article)
                            }
                        }
                    }
                }
                .listStyle(SidebarListStyle())
                .onDeleteCommand {
                    /// Sjekk om denne artikkelen virkelig skal slettes
                    title = NSLocalizedString("Delete Article?", comment: "Articles")
                    choise = NSLocalizedString("Delete this article", comment: "Articles")
                    alertIdentifier = AlertID(id: .delete)
                    
                }
                Spacer()
            }
            .frame(minWidth: 300, idealWidth: 300, maxWidth: .infinity, minHeight: 400,idealHeight: 400, maxHeight: .infinity)
        }
        .frame(minWidth: 800, idealWidth: 800, maxWidth: .infinity, minHeight: 400,idealHeight: 400, maxHeight: .infinity)
        .onAppear {
            /// Sjekker internett forbindelse
            startInternetTracking()
            /// Henter alle artiklene på nytt
            refresh()
        }
        .alert(item: $alertIdentifier) { alert in
            switch alert.id {
            case .first:
                return Alert(title: Text(message), message: Text(message1), dismissButton: .cancel())
            case .second:
                return Alert(title: Text(message), message: Text(message1), dismissButton: .cancel())
            case .delete:
                return Alert(title: Text(title),
                             message: Text(message),
                             primaryButton: .destructive(Text(choise),
                                                         action: {
                                                            CloudKitArticle.deleteArticle(recordID: selectedRecordId!) { (result) in
                                                                switch result {
                                                                case .success :
                                                                    message =  NSLocalizedString("Successfully deleted an article", comment: "UserOverView")
                                                                    alertIdentifier = AlertID(id: .first)
                                                                case .failure(let err):
                                                                    message = err.localizedDescription
                                                                    alertIdentifier = AlertID(id: .first)
                                                                }
                                                            }
                                                         }),
                             secondaryButton: .default(Text(NSLocalizedString("Cancel", comment: "UserOverView"))))
            }
        }
    }  /// var body
    #endif
    
    func refresh() {
        //// Sletter alt tidligere innhold i article
        articles.removeAll()
        /// Fetch all articless  from CloudKit
        let predicate = NSPredicate(value: true)
        CloudKitArticle.fetchArticle(predicate: predicate)  { (result) in
            switch result {
            case .success(let article):
                articles.append(article)
                articles.sort(by: {$0.title.uppercased() < $1.title.uppercased()})
            case .failure(let err):
                message = err.localizedDescription
                alertIdentifier = AlertID(id: .first)
            }
        }
    }
    
    func startInternetTracking() {
        /// Only fires once
        guard internetMonitor.pathUpdateHandler == nil else {
            return
        }
        internetMonitor.pathUpdateHandler = { update in
            if update.status == .satisfied {
                self.hasConnectionPath = true
            } else {
                self.hasConnectionPath = false
            }
        }
        internetMonitor.start(queue: internetQueue)
        #if os(iOS)
        /// Legger inn en forsinkelse på 1 sekund
        /// Uten denne, kan det komme melding selv om Internett er tilhjengelig
        sleep(1)
        if hasInternet() == false {
            if UIDevice.current.localizedModel == "iPhone" {
                device = "iPhone"
            } else if UIDevice.current.localizedModel == "iPad" {
                device = "iPad"
            }
            let message1 = NSLocalizedString("No Internet connection for this ", comment: "SignInView")
            message = message1 + device + "."
            alertIdentifier = AlertID(id: .first)
        }
        #endif

    }
    
    /// Will tell you if the device has an Internet connection
    /// - Returns: true if there is some kind of connection
    func hasInternet() -> Bool {
        return hasConnectionPath
    }
    

}
