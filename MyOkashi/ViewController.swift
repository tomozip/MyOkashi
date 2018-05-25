//
//  ViewController.swift
//  MyOkashi
//
//  Created by 島田智貴 on 2018/02/10.
//  Copyright © 2018年 hakusan-labo. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UISearchBarDelegate, UITableViewDataSource {

  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.
    searchText.delegate = self
    searchText.placeholder = "お菓子の名前を入力してください"
    tableView.dataSource = self
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  var okashiList : [(maker:String, name:String, link:String, image:String)] = []

  @IBOutlet weak var searchText: UISearchBar!
  
  @IBOutlet weak var tableView: UITableView!
  
  func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
    view.endEditing(true)
    print(searchBar.text!)
    if let searchWord = searchBar.text {
      searchOkashi(keyword: searchWord)
    }
  }
  
  func searchOkashi(keyword : String) {
    let keyword_encode = keyword.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
    let URL = Foundation.URL(string: "http://www.sysbird.jp/toriko/api/?apikey=guest&format=json&keyword=\(keyword_encode!)&max=10&order=r")
    print(URL!)
    
    let req = URLRequest(url: URL!)
    let configuration = URLSessionConfiguration.default
    let session = URLSession(configuration: configuration, delegate: nil, delegateQueue: OperationQueue.main)
    
    let task = session.dataTask(with: req, completionHandler: {(data, request, error) in
      do {
        let json = try JSONSerialization.jsonObject(with: data!) as! [String:Any]
        self.okashiList.removeAll()
        if let items = json["item"] as? [[String:Any]] {
          for item in items {
            guard let maker = item["maker"] as? String else {
              continue
            }
            guard let name = item["name"] as? String else {
              continue
            }
            guard let link = item["url"] as? String else {
              continue
            }
            guard let image = item["image"] as? String else {
              continue
            }
            let okashi = (maker, name, link, image)
            self.okashiList.append(okashi)
          }
        }
        self.tableView.reloadData()
      } catch {
        print("エラーが発生しました")
      }
    })
    task.resume()
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return okashiList.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "okashiCell", for: indexPath)
    cell.textLabel?.text = okashiList[indexPath.row].name
    let url = URL(string: okashiList[indexPath.row].image)
    if let image_data = try? Data(contentsOf: url!) {
      cell.imageView?.image = UIImage(data: image_data)
    }
    return cell
  }
}

