//
//  ArticleEditView.swift
//  Articles
//
//  Created by Jan Hovland on 11/02/2021.
//

import SwiftUI

struct ArticleEditView: View {
    var article: Article
    
    @State private var title = ""
    @State private var mainType = ""
    @State private var subType = ""
    @State private var subType1 = ""
    @State private var introduction = ""
    @State private var url = ""
    @State private var alertIdentifier: AlertID?
    @State private var message: String = ""
    @State private var message1: String = ""
    
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        Form {
            VStack {
                HStack {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }, label: {
                        Image(systemName: "chevron.left")
                            .foregroundColor(Color.blue)
                            .font(.system(size: 15, design: .rounded))
                    })
                    .padding(.leading, 10
                    )
                    Spacer()
                    Text(NSLocalizedString("Edit an article", comment: "ArticleEditView"))
                        .font(.system(size: 35, weight: .ultraLight, design: .rounded))
                        .padding(.trailing, 100)
                }
                InputTextField(heading: NSLocalizedString("mainType", comment: "ArticleEditView"),
                               placeHolder: NSLocalizedString("Enter subTitle", comment: "ArticleEditView"),
                               space: 24,
                               value: $mainType)
                InputTextField(heading: NSLocalizedString("SubTitle", comment: "ArticleEditView"),
                               placeHolder: NSLocalizedString("Enter subTitle", comment: "ArticleEditView"),
                               space: 34,
                               value: $subType)
                InputTextField(heading: NSLocalizedString("SubTitle1", comment: "ArticleEditView"),
                               placeHolder: NSLocalizedString("Enter subTitle1", comment: "ArticleEditView"),
                               space: 26,
                               value: $subType1)
                InputTextField(heading: NSLocalizedString("Title", comment: "ArticleEditView"),
                               placeHolder: NSLocalizedString("Enter Title", comment: "ArticleEditView"),
                               space: 57,
                               value: $title)
                InputTextField(heading: NSLocalizedString("Introduction", comment: "ArticleEditView"),
                               placeHolder: NSLocalizedString("Enter Introduction", comment: "ArticleEditView"),
                               space: 10,
                               value: $introduction)
                
                #if os(iOS)
                InputTextFieldURL(heading: NSLocalizedString("Url", comment: "ArticleEditView"),
                                  placeHolder: NSLocalizedString("Enter Url", comment: "ArticleEditView"),
                                  space: 71,
                                  value: $url)
                #elseif os(macOS)
                InputTextField(heading: NSLocalizedString("Url", comment: "ArticleEditView"),
                               placeHolder: NSLocalizedString("Enter Url", comment: "ArticleEditView"),
                               space: 71,
                               value: $url)
                #endif
                Spacer()
                
                Button(action: {
                    saveEditArticle(title: title,
                                    introduction: introduction,
                                    mainType: mainType,
                                    subType: subType,
                                    subType1: subType1,
                                    url: url)
                              
                }, label: {
                    HStack {
                        Text(NSLocalizedString("Update article", comment: "ArticleEditView"))
                    }
                })
            }
            .padding()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .alert(item: $alertIdentifier) { alert in
            switch alert.id {
            case .first:
                return Alert(title: Text(message), message: Text(message1), dismissButton: .cancel())
            case .second:
                return Alert(title: Text(message), message: Text(message1), dismissButton: .cancel())
            case .delete:
                return Alert(title: Text(message), message: Text(message1), primaryButton: .cancel(),
                             secondaryButton: .default(Text("OK"), action: {}))
            }
        }
        .onAppear {
            title = article.title
            introduction = article.introduction
            mainType = article.mainType
            subType = article.subType
            subType1 = article.subType1
            url = article.url
        }
        
    }
    
    func saveEditArticle(title: String,
                         introduction: String,
                         mainType: String,
                         subType: String,
                         subType1: String,
                         url: String) {
        
        /// Alle feltene må ha verdi
        if  title.count > 0,
            introduction.count > 0,
            mainType.count > 0,
            subType.count > 0,
            subType1.count > 0,
            url.count > 0  {
            
            #if os(iOS)
            /// Dette må legges inn for å virke på iPhone og iPad !!!!!!!!! Hvorfor ??????
            message = ""
            message1 = ""
            alertIdentifier = AlertID(id: .first)
            #endif
            if url.contains("https") ||
                url.contains("http") ||
                url.contains("www")  ||
                url.contains("://")  ||
                url.contains(".") {
                /// Sjekker om artikkelen finnes fra før
                CloudKitArticle.doesArticleExist(url: url) { (result) in
                    if result == false {
                        let message0 = NSLocalizedString("Url error", comment: "saveEditArticle")
                        message = message0 + " : \n" + url
                        message1 = NSLocalizedString("Check that the url contains https:// or http://, but some url only accepts https", comment: "saveEditArticle")
                        alertIdentifier = AlertID(id: .first)
                    } else {
                        /// Personen finnes i Artikkel tabellen
                        /// Må finne recordID for den enkelte artikkelen
                        let predicate = NSPredicate(format: "url == %@", url)
                        CloudKitArticle.fetchArticle(predicate: predicate)  { (result) in
                            switch result {
                            /// Finne recordID for å kunne oppdatere artikkelen
                            case .success(let article):
                                let recordID = article.recordID
                                let article = Article(
                                    recordID: recordID,
                                    title: title,
                                    introduction: introduction,
                                    mainType: mainType,
                                    subType: subType,
                                    subType1: subType1,
                                    url: url)
                                /// Oppdatere artikkelen
                                CloudKitArticle.modifyArticle(item: article) { (res) in
                                    switch res {
                                    case .success:
                                        
                                        /// Finner ikke message og message1
                                        
                                        print("Updated data")
                                        
                                        message = NSLocalizedString("Updated data", comment: "saveEditArticle")
                                        message1 = NSLocalizedString("This article is now updated", comment: "saveEditArticle")
                                        alertIdentifier = AlertID(id: .first)
                                    case .failure(let err):
                                        message = err.localizedDescription
                                        alertIdentifier = AlertID(id: .second)
                                    }
                                }
                            case .failure(let err):
                                let _ = err.localizedDescription
                            }
                        }
                    }
                 }
            } else {
                message = NSLocalizedString("Incorrect url", comment: "saveEditArticle")
                message1 = NSLocalizedString("Check that the url contains https:// or http://, but some url only accepts https", comment: "saveEditArticle")
                alertIdentifier = AlertID(id: .first)
            }
        } else {
            message = NSLocalizedString("Missing data", comment: "saveEditArticle")
            message1 = NSLocalizedString("Check that all fields have a value", comment: "saveEditArticle")
            alertIdentifier = AlertID(id: .first)
        }
    }

}

