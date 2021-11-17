//
//  WebviewController.swift
//  BonusProject
//
//  Created by FRANCISCO SAMUEL DA SILVA MARTINS on 17/11/21.
//

import UIKit
import WebKit

protocol AddUrlDelegate {
    func addUrl(url: UrlInfos)
}

class WebViewController: UIViewController, WKNavigationDelegate {
    private var webView: WKWebView = WKWebView()
    private var progressView: UIProgressView =  UIProgressView(progressViewStyle: .default)
    var initialUrl: URL?
    
    var addUrlDelegate: AddUrlDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(saveUrl))
        
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
    }
    
    @objc func reloadPage(){
        progressView.isHidden = false
        webView.reload()
    }
    
    @objc func saveUrl(){
        guard let url = webView.url else { return }
        let ac = UIAlertController(title: "Save Page", message: "Name", preferredStyle: .alert)
        ac.addTextField()
        
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        ac.addAction(UIAlertAction(title: "Save", style: .default, handler: { [weak self, weak ac] _ in
            guard let text = ac?.textFields?[0].text else { return }
            self?.addUrlDelegate?.addUrl(url: UrlInfos(name: text, url: url))
        }))
        
        
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
    
}
