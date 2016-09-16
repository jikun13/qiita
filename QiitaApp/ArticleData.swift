//
//  ArticleData.swift
//  QiitaApp
//
//  Created by Junki Takada on 2016/09/13.
//  Copyright © 2016年 Junki Takada. All rights reserved.
//

import Foundation
import RealmSwift

class ArticleData: Object {
    // 記事URL
    dynamic var url: String?
    // サムネイルURL
    dynamic var thumbnailUrl: String?
    // 記事タイトル
    dynamic var title: String?
    // ユーザID
    dynamic var userId: String?
}