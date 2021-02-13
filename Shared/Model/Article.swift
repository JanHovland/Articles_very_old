//
//  Article.swift
//  Articles (iOS)
//
//  Created by Jan Hovland on 04/01/2021.
//

import SwiftUI
import CloudKit

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
