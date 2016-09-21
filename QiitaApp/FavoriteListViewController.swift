//
//  FavoriteListViewController.swift
//  QiitaApp
//
//  Created by Junki Takada on 2016/09/15.
//  Copyright © 2016年 Junki Takada. All rights reserved.
//

import UIKit
import RealmSwift

class FavoriteListViewController: UITableViewController {
    
    // お気に入りデータを入れる配列
    var favoriteArticles = [ArticleData]()
    
    var imageCache = NSCache()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.registerNib(UINib(nibName: "CustomCellTableViewCell", bundle: nil), forCellReuseIdentifier: "CustomCell")
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        self.getFavoriteArticle()
        self.tableView.reloadData()
    }
    
    // realmデータ取得
    func getFavoriteArticle() {
        self.favoriteArticles.removeAll()
        let realm = try! Realm()
        for article in realm.objects(ArticleData) {
            self.favoriteArticles.append(article)
        }
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return favoriteArticles.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("CustomCell", forIndexPath: indexPath) as! CustomCellTableViewCell
        let articleData = favoriteArticles[indexPath.row] // 行数番目の記事を取得
        
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
    
    // 記事を左にスワイプするとお気に入り削除ボタンが表示されるようにする
    override func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        // お気に入り追加ボタン
        let favButton: UITableViewRowAction = UITableViewRowAction(style: .Normal, title: "delete") { (action, index) -> Void in
            tableView.editing = false
            
            // お気に入りから削除する
            do{
                let realm = try Realm()
                
                if let deleteUrl = self.favoriteArticles[indexPath.row].url {
                    let articles = realm.objects(ArticleData).filter("url = '\(deleteUrl)'")
                    print(articles)
                    try realm.write {
                        realm.delete(articles)
                        print("消すぞー")
                    }
                }
            }catch{
                print("失敗")
            }
        }
        favButton.backgroundColor = UIColor.redColor()
        
        return [favButton]
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let cell = sender as? FavoriteArticleTableViewCell {
            if let webViewConroller = segue.destinationViewController as? WebViewController {
                // 記事のURLを設定する
                webViewConroller.articleUrl = cell.favoriteArticleUrl
            }
        }
    }

}
