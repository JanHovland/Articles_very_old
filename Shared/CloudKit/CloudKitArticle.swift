//
//  CloudKitArticle.swift
//  Articles (iOS)
//
//  Created by Jan Hovland on 04/01/2021.
//

import CloudKit
import SwiftUI

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
    
    /// MARK: - saving to CloudKit inside CloudKitArticle
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
    
    // MARK: - delete from CloudKit inside CloudKitArticle
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
    
    // MARK: - check if the article record exists inside CloudKitArticle
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

    // MARK: - fetching from CloudKit inside CloudKitArticle
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
                
                /// Dette er greit dersom det finnes data i disse feltene
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
                                      mainType: mainType ?? " ",        /// Det må gjøres når noen feltet kan være blanke
                                      subType: subType ?? " ",          /// Det må gjøres når noen feltet kan være blanke
                                      subType1: subType1 ?? " ",        /// Det må gjøres når noen feltet kan være blanke
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
    
    // MARK: - modify in CloudKit inside CloudKitArticle
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
                    
                    let mainType = record["url"] as? String
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



