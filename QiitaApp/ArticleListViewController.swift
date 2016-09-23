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
import RealmSwift

class ArticleListViewController: UITableViewController, UISearchBarDelegate {
    
    // 記事を入れるプロバティを定義
    var articles = [ArticleData]()
    
    var imageCache = NSCache()
    
    //APIを利用するためのアプリケーションID
    let qiitaId: String = "ashidaka"
    
    //APIのURL
    let entryUrl: String = "https://qiita.com/api/v2/items"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.registerNib(UINib(nibName: "CustomCellTableViewCell", bundle: nil), forCellReuseIdentifier: "CustomCell")
        
        let refresh = UIRefreshControl()
        refresh.attributedTitle = NSAttributedString(string: "更新中")
        refresh.tintColor = UIColor.grayColor()
        refresh.addTarget(self, action: #selector(ArticleListViewController.refreshTable), forControlEvents: UIControlEvents.ValueChanged)
        self.refreshControl = refresh
        
        self.getArticles(entryUrl)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        // Dispose of any resources that can be recreated.
    }
    
    // 引っ張って画面更新
    func refreshTable() {
        sleep(2)
        self.getArticles(entryUrl)
        refreshControl?.endRefreshing()
    }
    
    // 記事の取得＆描画
    func getArticles(url: String) {
        Alamofire.request(.GET, url)
            .responseJSON { response in
                guard let object = response.result.value else {
                    return
                }
                
                self.articles.removeAll()
                
                let json = JSON(object)
                json.forEach { (_, json) in
                    let article = ArticleData()
                    
                    article.url = json["url"].string
                    article.thumbnailUrl = json["user"]["profile_image_url"].string
                    article.title = json["title"].string
                    article.userId = json["user"]["id"].string
                    
                    self.articles.append(article)
                }
                self.tableView.reloadData()
        }
    }
    
    // MARK: - search bar delegate
    //キーボードのsearchボタンがタップされた時に呼び出される
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        //商品検索を行なう
        let inputText = searchBar.text
        //入力文字数が0文字以上かどうかチェックする
        if inputText?.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) > 0 {
            //保持している商品を一旦削除
            self.articles.removeAll()
            
            //パラメータを指定する
            let parameter = ["id":qiitaId, "query":inputText]
            
            //パラメータをエンコードしたURLを作成する
            let requestUrl = createRequestUrl(parameter)
            
            //APIをリクエストする
            getArticles(requestUrl)
        }
        //キーボードを閉じる
        searchBar.resignFirstResponder()
    }

    //URL作成処理
    func createRequestUrl(parameter :[String:String?]) -> String {
        var parameterString = ""
        for key in parameter.keys {
            if let value = parameter[key] {
                //既にパラメータが設定されていた場合
                if parameterString.lengthOfBytesUsingEncoding(
                    NSUTF8StringEncoding) > 0 {
                    parameterString += "&"
                }
                
                //値をエンコードする
                if let escapedValue =
                    value!.stringByAddingPercentEncodingWithAllowedCharacters(
                        NSCharacterSet.URLQueryAllowedCharacterSet()) {
                    parameterString += "\(key)=\(escapedValue)"
                }
            }
        }
        let requestUrl = entryUrl + "?" + parameterString
        return requestUrl
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("CustomCell", forIndexPath: indexPath) as! CustomCellTableViewCell
        let articleData = articles[indexPath.row] // 行数番目の記事を取得

        cell.articleTitleLabel.text = articleData.title
        cell.articleTitleLabel.numberOfLines = 0;
        cell.articleUserIdLabel.text = articleData.userId
        cell.articleUrl = articleData.url
        
        if let itemImageUrl = articleData.thumbnailUrl {
            //キャッシュの画像を取り出す
            if let cacheImage = imageCache.objectForKey(itemImageUrl) as? UIImage {
                //キャッシュの画像を設定
                cell.articleImageView.image = cacheImage
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
                                        cell.articleImageView.image = image
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
    
    // 記事を左にスワイプするとお気に入り登録ボタンが表示されるようにする
    override func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        // お気に入り追加ボタン
        let favButton: UITableViewRowAction = UITableViewRowAction(style: .Normal, title: "★") { (action, index) -> Void in
            tableView.editing = false

            // 選んだ行のデータをお気に入りリストに入れる
            do{
               let realm = try Realm()
               try realm.write {
                   realm.add(self.articles[indexPath.row])
                }
            }catch{
                print("失敗")
            }
        }
        favButton.backgroundColor = UIColor.greenColor()
        
        return [favButton]
    }
    
    //カスタムセルを利用すると、セルからのsegueが無効になるので、didSelectedrowAtIndexPath でsegueを発生させる
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let article = self.articles[indexPath.row]
        self.performSegueWithIdentifier("toWebViewController", sender: article)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
//        let nav = segue.destinationViewController as! UINavigationController
//        let webViewController = nav.topViewController as! WebViewController
        let webViewController = segue.destinationViewController as! WebViewController
        webViewController.articleUrl = sender?.url
    }
}
