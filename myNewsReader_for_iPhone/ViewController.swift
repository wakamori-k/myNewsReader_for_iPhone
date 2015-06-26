
//
//  ViewController.swift
//  myNewsReader_for_iPhone
//
//  Created by Kazumasa Wakamori on 2015/06/23.
//  Copyright (c) 2015年 wakamori. All rights reserved.
//

import UIKit
import Alamofire

class ViewController: UIViewController,UITableViewDataSource,UITableViewDelegate{
    
    @IBOutlet var table :UITableView!                   //ニュースを表示するテーブル
    @IBOutlet weak var searchTextField: UITextField!    //検索窓
    var newsDataArray = NSArray()                       //ニュースのデータの配列
    var newsUrl = ""
    var publisher = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateNews("")//最初は空文字列を与えてトップニュースを表示させる
    }
    
    func updateNews(keyword: String){
        //表示しているニュースを更新する
        
        table.estimatedRowHeight = 80//estimateRowHeightは設定することでスクロール中のパフォーマンス向上につながるらしい
        self.table.rowHeight =  UITableViewAutomaticDimension//セルの高さを自動調節
        
        table.dataSource = self
        table.delegate = self
        
        table.rowHeight = UITableViewAutomaticDimension
        
        var reqUrl :String
        if(count(keyword)>0){
            //keywordが空文字列でなければ、keywordの文字列を使ってニュースを検索
            reqUrl = "https://ajax.googleapis.com/ajax/services/search/news?v=1.1&q="+keyword+"&hl=ja&rsz=8"
        }else{
            //keywordが空文字列ならば、「topic=h」を使ってトップニュースを表示
            reqUrl = "https://ajax.googleapis.com/ajax/services/search/news?v=1.1&topic=h&hl=ja&rsz=8";
        }
        
        //URLをエンコード(日本語とか含まれている場合にそのままリクエストだすとエラーになる)
        reqUrl = reqUrl.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!
        
        //HTTPリクエスト送信！！
        Alamofire.request(.GET,reqUrl).responseJSON
            {(request, response, json, error) in
                //JSONで帰ってくるのでNSDictionaryに変換してデータを取り出す
                let jsonDic = json as! NSDictionary
                let responseData = jsonDic["responseData"] as! NSDictionary
                self.newsDataArray = responseData["results"] as! NSArray
                
                // println(self.newsDataArray)
                self.table.reloadData()
        }
        
    }
    
    @IBAction func pushSearchButton(sender: AnyObject) {
        //ボタンがおされたらtext fieldに入力された文字列を引数で渡してテーブルを更新
        var word = searchTextField.text
        updateNews(word)
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return newsDataArray.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
        let cell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "Cell")
        var newsDic = newsDataArray[indexPath.row] as! NSDictionary
        
        //フォントサイズ変更
        //  cell.textLabel?.font = UIFont.systemFontOfSize(15)
        var newsText = newsDic["title"] as? String
        //文字列に含まれる<b>,</b>タグを削除（なぜかはいっている）
        newsText = newsText?.stringByReplacingOccurrencesOfString("<b>", withString: "", options: nil, range: nil)
        newsText = newsText?.stringByReplacingOccurrencesOfString("</b>", withString: "", options: nil, range: nil)
        
        cell.textLabel?.text = newsText//ニュースのタイトルを表示
        cell.textLabel?.numberOfLines = 0// 行数の上限をなしにする
        
        cell.detailTextLabel?.text = newsDic["publishedDate"] as? String//ニュースの日付を表示
        return cell
    }
    
    //テーブルビューのセルがタップされた処理を追加
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        // ニュース記事データを取得（配列の要素で"indexPath.row"番目の要素を取得）
        var newsDic = newsDataArray[indexPath.row] as! NSDictionary
        // ニュース記事のURLを取得
        newsUrl = newsDic["unescapedUrl"] as! String
        
        //ブラウザへ遷移
        /*  let url = NSURL(string:newsUrl)
        let app = UIApplication.sharedApplication()
        app.openURL(url!)*/
        
        //WebViewController画面へ遷移
        performSegueWithIdentifier("toWebView", sender: self)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        //セグエ用にダウンキャストしたWebViewControllerのインスタンス
        var wvc = segue.destinationViewController as! WebViewContoller
        //変数newsUrlの値をWebViewControllerの変数newsUrlに代入
        wvc.newsUrl = newsUrl
        //titleプロパティでWebViewControllerのタイトルにpublisherを代入
        wvc.title = publisher
    }
    
    func htmlEncode(string: String) -> String {
        let allowedCharacters =  NSCharacterSet(charactersInString:" =\"#%/<>?@\\^`{}[]|&+").invertedSet
        return string.stringByAddingPercentEncodingWithAllowedCharacters(allowedCharacters) ?? string
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}

