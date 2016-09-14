//
//  ArticleListViewController.swift
//  QiitaApp
//
//  Created by Junki Takada on 2016/09/13.
//  Copyright © 2016年 Junki Takada. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class ArticleListViewController: UITableViewController {
    
    // 記事を入れるプロバティを定義
    var articles: [[String: String?]] = []
    
    var imageCache = NSCache()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let refresh = UIRefreshControl()
        refresh.attributedTitle = NSAttributedString(string: "更新中")
        refresh.tintColor = UIColor.grayColor()
        refresh.addTarget(self, action: #selector(ArticleListViewController.refreshTable), forControlEvents: UIControlEvents.ValueChanged)
        self.refreshControl = refresh
                
        self.getArticles()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        // Dispose of any resources that can be recreated.
    }
    
    func refreshTable() {
        sleep(2)
        self.getArticles()
        refreshControl?.endRefreshing()
    }
    
    func getArticles() {
        Alamofire.request(.GET, "https://qiita.com/api/v2/items")
            .responseJSON { response in
                guard let object = response.result.value else {
                    return
                }
                
                self.articles.removeAll()
                
                let json = JSON(object)
                json.forEach { (_, json) in
                    let article: [String: String?] = [
                        "title": json["title"].string,
                        "userId": json["user"]["id"].string,
                        "image": json["user"]["profile_image_url"].string,
                        "url": json["url"].string
                    ]
                    self.articles.append(article)
                }
                self.tableView.reloadData()
//                print(self.articles)
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("ArticleCell", forIndexPath: indexPath) as! ArticleTableViewCell
        let articleData = articles[indexPath.row] // 行数番目の記事を取得
        
        cell.articleTitleLabel.text = articleData["title"]!
        cell.articleTitleLabel.numberOfLines = 0;
        cell.articleUserIdLabel.text = articleData["userId"]!
        cell.articleUrl = articleData["url"]!
        
        if let itemImageUrl = articleData["image"]! {
            //キャッシュの画像を取り出す
            if let cacheImage = imageCache.objectForKey(itemImageUrl) as? UIImage {
                //キャッシュの画像を設定
                cell.articleThumbnailView.image = cacheImage
            } else {
                //画像のダウンロード処理
                let session = NSURLSession.sharedSession()
                if let url = NSURL(string: itemImageUrl){
                    let request = NSURLRequest(URL: url)
                    let task = session.dataTaskWithRequest(
                        request, completionHandler: {
                            (data:NSData?, response:NSURLResponse?, error:NSError?) -> Void in
                            if let data = data {
                                if let image = UIImage(data: data) {
                                    //ダウンロードした画像をキャッシュに登録しておく
                                    self.imageCache.setObject(image, forKey: itemImageUrl)
                                    //画像はメインスレッド上で設定する
                                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                                        cell.articleThumbnailView.image = image
                                    })
                                }
                            }
                    })
                    //画像の読み込み処理開始
                    task.resume()
                }
            }
        }
        return cell
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return articles.count
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let cell = sender as? ArticleTableViewCell {
            if let webViewConroller = segue.destinationViewController as? WebViewController {
                // 記事のURLを設定する
                webViewConroller.articleUrl = cell.articleUrl
            }
        }
    }
}
