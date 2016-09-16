//
//  FavoriteListViewController.swift
//  QiitaApp
//
//  Created by Junki Takada on 2016/09/15.
//  Copyright © 2016年 Junki Takada. All rights reserved.
//

import UIKit

class FavoriteListViewController: UITableViewController {
    
    // お気に入りデータを入れるクラス？配列？
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // お気に入りデータリストを読み込んでリスト表示する
    // お気に入りボタン押された時にデータを保存する処理

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 0
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 0
    }

}
