//
//  WebviewController.swift
//  BonusProject
//
//  Created by FRANCISCO SAMUEL DA SILVA MARTINS on 17/11/21.
//

import UIKit
import WebKit

protocol UrlBookmarkDelegate {
    func exists(name: String) -> Bool
    func exists(url: URL) -> Bool
    func addUrl(url: UrlInfos)
    func removeUrl(url: URL)
}

class WebViewController: UIViewController, WKNavigationDelegate {
    private var webView: WKWebView = WKWebView()
    private var progressView: UIProgressView =  UIProgressView(progressViewStyle: .default)
    var initialUrl: URL?
    
    var urlDelegate: UrlBookmarkDelegate?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "heart"), style: .plain, target: self, action: #selector(toggleUrl))
        
        
        webView.navigationDelegate = self
        webView.addObserver(self, forKeyPath: #keyPath(WKWebView.estimatedProgress), options: .new, context: nil)
        view = webView
        
        progressView.sizeToFit()
        let progressButtom = UIBarButtonItem(customView: progressView)
        let spacer = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let refresh = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(reloadPage))
        
        toolbarItems = [progressButtom,spacer, refresh]
        navigationController?.isToolbarHidden = false
        
        var url : URL
        if let stringUrl = initialUrl {
            url = stringUrl
        } else {
            url = URL(string: "http://www.google.com")!
        }
        
        webView.load(URLRequest(url: url))
        webView.allowsBackForwardNavigationGestures = true
        title = webView.title
        
        reloadPage()
        updateBookmarkButton()
    }
    
    @objc func reloadPage(){
        progressView.isHidden = false
        webView.reload()
    }
    
    @objc func toggleUrl(){
        guard let url = webView.url else { return }
        
        guard let exists = self.urlDelegate?.exists(url: url) else { return  }
        
        if !exists {
            save(url: url)
        } else {
            urlDelegate?.removeUrl(url: url)
            updateBookmarkButton(exists: false)
        }
    }
    
    func save(url: URL) {
        let ac = UIAlertController(title: "Save Page", message: "Name", preferredStyle: .alert)
        ac.addTextField()
        
        
        ac.addAction(UIAlertAction(title: "Save", style: .default, handler: { [weak self] _ in
            guard let text = ac.textFields?[0].text else { return }
            let urlInfos = UrlInfos(name: text, url: url)
            guard let exists = self?.urlDelegate?.exists(name: text) else { return  }

            if exists {
                ac.message = "Name alredy exists"
                self?.present(ac, animated: true, completion: nil)
            } else {
                self?.urlDelegate?.addUrl(url: urlInfos)
                self?.updateBookmarkButton(exists: true)
            }
        }))
        
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(ac, animated: true, completion: nil)
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "estimatedProgress" {
            progressView.progress = Float(webView.estimatedProgress)
            if progressView.progress == 1 {
                progressView.isHidden = true
            }
        }
    }
    
    func updateBookmarkButton() {
        guard let url = webView.url else { return }
        guard let delegate = self.urlDelegate else { return }
        
        updateBookmarkButton(exists: delegate.exists(url: url))
    }
    
    func updateBookmarkButton(exists: Bool) {
        if exists {
            navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "heart-full"), style: .plain, target: self, action: #selector(toggleUrl))
            
        } else {
            navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "heart"), style: .plain, target: self, action: #selector(toggleUrl))
        }
    }
    
}
