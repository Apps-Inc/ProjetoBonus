//
//  ViewController.swift
//  BonusProject
//
//  Created by FRANCISCO SAMUEL DA SILVA MARTINS on 17/11/21.
//

import UIKit

class ViewController: UITableViewController {
    
    var urlsList : [UrlInfos] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let defaults = UserDefaults.standard
        if let data = defaults.data(forKey: "UrlList") {
            do {
                let decoder = JSONDecoder()
                urlsList = try decoder.decode([UrlInfos].self, from: data)
            } catch {
                urlsList = []
            }
        }
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(searchNewWebSite))
        title = "Saved Pages"
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress))
        tableView.addGestureRecognizer(longPress)
    }
    
    @objc func searchNewWebSite(){
        openNewPage(url: URL(string: "http://www.google.com"))
    }
    
    func openNewPage(url: URL?){
        let newViewController = WebViewController()
        newViewController.urlDelegate = self
        newViewController.initialUrl = url
        self.navigationController?.pushViewController(newViewController, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return urlsList.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "WebCell", for: indexPath)
        var cellConfig = cell.defaultContentConfiguration()
        cellConfig.text = urlsList[indexPath.row].name
        cell.contentConfiguration = cellConfig
        return cell
    }
    
    @objc private func handleLongPress(sender: UILongPressGestureRecognizer) {
        if sender.state == .began {
            let touchPoint = sender.location(in: tableView)
            if let indexPath = tableView.indexPathForRow(at: touchPoint) {
                let ac = UIAlertController(title: "Options", message: "actions", preferredStyle: .alert)
                
                ac.addAction(UIAlertAction(title: "Update", style: .default, handler: { [weak self] _  in
                    let acu = UIAlertController(title: "Update", message: "Write new Name", preferredStyle: .alert)
                    acu.addTextField()
                    acu.addAction(UIAlertAction(title: "Save", style: .default, handler: { _ in
                        guard let text = acu.textFields?[0].text else {return}
                        
                        if self?.urlsList.contains(where: {$0.name == text}) ?? true {
                            acu.message = "Name alredy exists"
                            self?.present(acu, animated: true, completion: nil)
                            return
                        } else {
                            self?.urlsList[indexPath.row].name = text
                            self?.tableView.reloadRows(at: [indexPath], with: .automatic)
                            self?.saveUrlList()
                            return
                        }
                        
                    }))
                    
                    acu.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                    
                    self?.present(acu, animated: true, completion: nil)
                }))
                
                ac.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                
                ac.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { [weak self] _ in
                    self?.urlsList.remove(at: indexPath.row)
                    self?.tableView.deleteRows(at: [indexPath], with: .automatic)
                    self?.saveUrlList()
                }))
                
                present(ac, animated: true, completion: nil)
            }
        }
    }
    
    func saveUrlList(){
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(urlsList)
            UserDefaults.standard.set(data, forKey: "UrlList")
        } catch {}
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        openNewPage(url: urlsList[indexPath.row].url)
    }
    
    
}

extension ViewController: UrlBookmarkDelegate {
    func exists(url: URL) -> Bool {
        return self.urlsList.contains(where: {$0.url == url})
    }
    
    func removeUrl(url: URL) {
        guard let idx = self.urlsList.firstIndex(where: { $0.url == url}) else { return }
        self.urlsList.remove(at: idx)
        self.tableView.reloadData()
        self.saveUrlList()
    }
    
    func addUrl(url: UrlInfos) {
        self.urlsList.append(url)
        self.tableView.reloadData()
        self.saveUrlList()
    }
    
    func exists(name: String) -> Bool {
        return self.urlsList.contains(where: {$0.name == name})
    }
}
