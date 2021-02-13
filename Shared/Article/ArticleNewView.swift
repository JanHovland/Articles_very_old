//
//  ArticleNewView.swift
//  Articles
//
//  Created by Jan Hovland on 04/01/2021.
//

import SwiftUI
import CloudKit

struct ArticleNewView: View {
    
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
                    Text(NSLocalizedString("Enter a new article", comment: "ArticleEditView"))
                        .font(.system(size: 35, weight: .ultraLight, design: .rounded))
                        .padding(.trailing, 100)
                }
                InputTextField(heading: NSLocalizedString("mainType", comment: "ArticleNewView"),
                               placeHolder: NSLocalizedString("Enter subTitle", comment: "ArticleNewView"),
                               space: 24,
                               value: $mainType)
                InputTextField(heading: NSLocalizedString("SubTitle", comment: "ArticleNewView"),
                               placeHolder: NSLocalizedString("Enter subTitle", comment: "ArticleNewView"),
                               space: 34,
                               value: $subType)
                InputTextField(heading: NSLocalizedString("SubTitle1", comment: "ArticleNewView"),
                               placeHolder: NSLocalizedString("Enter subTitle1", comment: "ArticleNewView"),
                               space: 26,
                               value: $subType1)
                InputTextField(heading: NSLocalizedString("Title", comment: "ArticleNewView"),
                               placeHolder: NSLocalizedString("Enter Title", comment: "ArticleNewView"),
                               space: 57,
                               value: $title)
                InputTextField(heading: NSLocalizedString("Introduction", comment: "ArticleNewView"),
                               placeHolder: NSLocalizedString("Enter Introduction", comment: "ArticleNewView"),
                               space: 10,
                               value: $introduction)
#if os(iOS)
                InputTextFieldURL(heading: NSLocalizedString("Url", comment: "ArticleNewView"),
                                  placeHolder: NSLocalizedString("Enter Url", comment: "ArticleNewView"),
                                  space: 71,
                                  value: $url)
#elseif os(macOS)
                InputTextField(heading: NSLocalizedString("Url", comment: "ArticleNewView"),
                               placeHolder: NSLocalizedString("Enter Url", comment: "ArticleNewView"),
                               space: 71,
                               value: $url)
#endif
                Spacer()
                
                Button(action: {
                    saveNewArticle(titleArt: title,
                                   introductionArt: introduction,
                                   mainTypeArt: mainType,
                                   subTypeArt: subType,
                                   subType1Art: subType1,
                                   urlArt: url)
                }, label: {
                    HStack {
                        Text(NSLocalizedString("Save article", comment: "ArticleNewView"))
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
    }
    
    func saveNewArticle(titleArt: String,
                        introductionArt: String,
                        mainTypeArt: String,
                        subTypeArt: String,
                        subType1Art: String,
                        urlArt: String) {
        
        /// Alle feltene må ha verdi
        if  titleArt.count > 0,
            introductionArt.count > 0,
            mainTypeArt.count > 0,
            subTypeArt.count > 0,
            subType1Art.count > 0,
            urlArt.count > 0  {
            if urlArt.contains("https") ||
                urlArt.contains("http") ||
                urlArt.contains("www")     ||
                urlArt.contains("://") ||
                urlArt.contains(".") {
                /// Sjekker om denne posten finnes fra før
                CloudKitArticle.doesArticleExist(url: urlArt) { (result) in
                    if result == true {
                        message = NSLocalizedString("Existing data", comment: "AddArticleView")
                        message1 = NSLocalizedString("This article was stored earlier", comment: "AddArticleView")
                        alertIdentifier = AlertID(id: .first)
                    } else {
                        let article = Article(title: title,
                                              introduction: introduction,
                                              mainType: mainTypeArt,
                                              subType: subTypeArt,
                                              subType1: subType1Art,
                                              url: urlArt)
                        CloudKitArticle.saveArticle(item: article) { (result) in
                            switch result {
                            case .success:
                                title = ""
                                introduction = ""
                                url = ""
                                mainType = ""
                                subType = ""
                                subType1 = ""
                                message = NSLocalizedString("This article is now stored in CloudKit", comment: "AddArticleView")
                                alertIdentifier = AlertID(id: .first)
                            case .failure(let err):
                                message = err.localizedDescription
                                alertIdentifier = AlertID(id: .first)
                            }
                        }
                    }
                }
            } else {
                message = NSLocalizedString("Incorrect url", comment: "AddArticleView")
                message1 = NSLocalizedString("Check that the url contains https:// or http://, but some url only accepts https", comment: "AddArticleView")
                alertIdentifier = AlertID(id: .first)
            }
        } else {
            message = NSLocalizedString("Missing data", comment: "AddArticleView")
            message1 = NSLocalizedString("Check that all fields have a value", comment: "AddArticleView")
            alertIdentifier = AlertID(id: .first)
        }
    }
    
}

#if os(iOS)

struct InputTextFieldURL: View {
    var heading: String
    var placeHolder: String
    var space: Double
    @Binding var value: String
    var body: some View {
        HStack(alignment: .center, spacing: CGFloat(space*1.15)) {
            Text(heading)
            TextField(placeHolder, text: $value)
        }
        .font(.custom("Andale Mono Regular", size: 17))
        .padding(10)
        .keyboardType(.URL)
        .autocapitalization(.none)

    }
}
#endif

struct InputTextField: View {
    var heading: String
    var placeHolder: String
    var space: Double
    @Binding var value: String
    var body: some View {
        #if os(iOS)
        HStack(alignment: .center, spacing: CGFloat(space*1.15)) {
            Text(heading)
            TextField(placeHolder, text: $value)
        }
        .font(.custom("Andale Mono Regular", size: 17))
        .padding(10)
        #elseif os(macOS)
        HStack(alignment: .center, spacing: CGFloat(space*1.00)) {
            Text(heading)
            TextField(placeHolder, text: $value)
        }
        .font(.custom("Andale Mono Regular", size: 14))
        .padding(10)
        #endif
    }
}

/// Det viser seg at dette struct må ligge her,
/// kan ikke ligge i en egen fil
struct AlertID: Identifiable {
    enum Choice {
        case first, second, delete
    }

    var id: Choice
}

#if os(macOS)

struct Article: Identifiable {
    var id = UUID()
    var recordID: CKRecord.ID?
    var title: String = ""
    var introduction: String = ""
    var mainType: String = ""          /// iOS, macOS ...
    var subType: String = ""           /// Swift, SwiftUI ...
    var subType1: String = ""          /// List, Button, Navigation ...
    var url: String = ""
}

struct CloudKitArticle {
    struct RecordType {
        static let Article = "Article"
    }
    /// MARK: - errors
    enum CloudKitHelperError: Error {
        case recordFailure
        case recordIDFailure
        case castFailure
        case cursorFailure
    }
    
    /// MARK: - saving to CloudKit inside ArticleNewView
    static func saveArticle(item: Article, completion: @escaping (Result<Article, Error>) -> ()) {
        let itemRecord = CKRecord(recordType: RecordType.Article)
        itemRecord["title"] = item.title as CKRecordValue
        itemRecord["introduction"] = item.introduction as CKRecordValue
        itemRecord["mainType"] = item.mainType as CKRecordValue
        itemRecord["subType"] = item.subType as CKRecordValue
        itemRecord["subType1"] = item.subType1 as CKRecordValue
        itemRecord["url"] = item.url as CKRecordValue
        
        CKContainer.default().privateCloudDatabase.save(itemRecord) { (record, err) in
            DispatchQueue.main.async {
                if let err = err {
                    completion(.failure(err))
                    return
                }
                guard let record = record else {
                    completion(.failure(CloudKitHelperError.recordFailure))
                    return
                }
                let recordID = record.recordID
                guard let title = record["title"] as? String else {
                    completion(.failure(CloudKitHelperError.castFailure))
                    return
                }
                guard let introduction = record["introduction"] as? String else {
                    completion(.failure(CloudKitHelperError.castFailure))
                    return
                }
                guard let mainType = record["mainType"] as? String else {
                    completion(.failure(CloudKitHelperError.castFailure))
                    return
                }
                guard let subType = record["subType"] as? String else {
                    completion(.failure(CloudKitHelperError.castFailure))
                    return
                }
                guard let subType1 = record["subType1"] as? String else {
                    completion(.failure(CloudKitHelperError.castFailure))
                    return
                }
                guard let url = record["url"] as? String else {
                    completion(.failure(CloudKitHelperError.castFailure))
                    return
                }
                let article = Article(recordID: recordID,
                                      title: title,
                                      introduction: introduction,
                                      mainType: mainType,
                                      subType: subType,
                                      subType1: subType1,
                                      url: url)

                completion(.success(article))
            }
        }
    }
    
    // MARK: - delete from CloudKit inside ArticleNewView
    static func deleteArticle(recordID: CKRecord.ID, completion: @escaping (Result<CKRecord.ID, Error>) -> ()) {
        CKContainer.default().privateCloudDatabase.delete(withRecordID: recordID) { (recordID, err) in
            DispatchQueue.main.async {
                if let err = err {
                    completion(.failure(err))
                    return
                }
                guard let recordID = recordID else {
                    completion(.failure(CloudKitHelperError.recordIDFailure))
                    return
                }
                completion(.success(recordID))
            }
        }
    }
    
    // MARK: - check if the article record exists inside ArticleNewView
    static func doesArticleExist(url: String,
                                 completion: @escaping (Bool) -> ()) {
        var result = false
        let predicate = NSPredicate(format: "url == %@", url)
        let query = CKQuery(recordType: RecordType.Article, predicate: predicate)
        DispatchQueue.main.async {
             /// inZoneWith: nil : Specify nil to search the default zone of the database.
             CKContainer.default().privateCloudDatabase.perform(query, inZoneWith: nil, completionHandler: { (results, er) in
                DispatchQueue.main.async {
                    if results != nil {
                        if results!.count >= 1 {
                            result = true
                        }
                    }
                    completion(result)
                }
            })
        }
    }

    // MARK: - fetching from CloudKit inside ArticleNewView
    static func fetchArticle(predicate:  NSPredicate, completion: @escaping (Result<Article, Error>) -> ()) {
        let query = CKQuery(recordType: RecordType.Article, predicate: predicate)
        let operation = CKQueryOperation(query: query)
        operation.desiredKeys = ["title",
                                 "introduction",
                                 "mainType",
                                 "subType",
                                 "subType1",
                                 "url"]
        operation.resultsLimit = 500
        operation.recordFetchedBlock = { record in
            DispatchQueue.main.async {
                let recordID = record.recordID
                guard let title1  = record["title"] as? String else { return }
                guard let introduction1 = record["introduction"] as? String else { return }
                
//                guard let mainType = record["mainType"] as? String else { return }
//                guard let subType = record["subType"] as? String else { return }
//                guard let subType1 = record["subType1"] as? String else { return }
                
                /// Dersom det ikke finnes data i feltene, gjøres det  slik:
                let mainType = record["mainType"] as? String
                let subType = record["subType"] as? String
                let subType1 = record["subType1"] as? String
                
                guard let url = record["url"] as? String else { return }
                
                /// Fjerner eventuelle linjeskift med et balnkt tegn
                let title = title1.replacingOccurrences(of: "\n", with: "")
                let introduction = introduction1.replacingOccurrences(of: "\n", with: "")
 
                let article = Article(recordID: recordID,
                                      title: title,
                                      introduction: introduction,
                                      mainType: mainType ?? " ",    /// Det må gjøres når noen feltet kan være blanke
                                      subType: subType ?? " ",      /// Det må gjøres når noen feltet kan være blanke
                                      subType1: subType1 ?? " " ,   /// Det må gjøres når noen feltet kan være blanke
                                      url: url)
                
                completion(.success(article))
            }
        }
        operation.queryCompletionBlock = { ( _, err) in
            DispatchQueue.main.async {
                if let err = err {
                    completion(.failure(err))
                    return
                }
            }
        }
        CKContainer.default().privateCloudDatabase.add(operation)
    }
    
    // MARK: - modify in CloudKit inside ArticleNewView
    static func modifyArticle(item: Article, completion: @escaping (Result<Article, Error>) -> ()) {
        guard let recordID = item.recordID else { return }
        CKContainer.default().privateCloudDatabase.fetch(withRecordID: recordID) { record, err in
            if let err = err {
                DispatchQueue.main.async {
                    completion(.failure(err))
                }
                return
            }
            guard let record = record else {
                DispatchQueue.main.async {
                    completion(.failure(CloudKitHelperError.recordFailure))
                }
                return
            }
            record["title"] = item.title as CKRecordValue
            record["introduction"] = item.introduction as CKRecordValue
            record["mainType"] = item.mainType as CKRecordValue
            record["subType"] = item.subType as CKRecordValue
            record["subType1"] = item.subType1 as CKRecordValue
            record["url"] = item.url as CKRecordValue

            CKContainer.default().privateCloudDatabase.save(record) { (record, err) in
                DispatchQueue.main.async {
                    if let err = err {
                        completion(.failure(err))
                        return
                    }
                    guard let record = record else {
                        completion(.failure(CloudKitHelperError.recordFailure))
                        return
                    }
                    let recordID = record.recordID
                    guard let title = record["title"] as? String else {
                        completion(.failure(CloudKitHelperError.castFailure))
                        return
                    }
                    guard let introduction = record["introduction"] as? String else {
                        completion(.failure(CloudKitHelperError.castFailure))
                        return
                    }
                    
                    let mainType = record["mainType"] as? String
                    let subType = record["subType"] as? String
                    let subType1 = record["subType1"] as? String

                    guard let url = record["url"] as? String else {
                        completion(.failure(CloudKitHelperError.castFailure))
                        return
                    }

                    let article = Article(recordID: recordID,
                                          title: title,
                                          introduction: introduction,
                                          mainType: mainType ?? " ",
                                          subType: subType ?? " ",
                                          subType1: subType1 ?? " ",
                                          url: url)
                    
                    completion(.success(article))
                }
            }
        }
    }


}

#endif



