//
//  WebViewController.swift
//  FngrShare
//
//  Created by FastFingers Mika on 24/05/16.
//  Copyright © 2016 FastFingers. All rights reserved.
//

import Foundation
import WebKit

protocol PayapiWebViewDelegate{
    
    func payapiReturn()
    func payapiFail(_ error: NSError)
}

class PayapiWebView: NSObject, WKNavigationDelegate, WKUIDelegate {
    
    let webView_: WKWebView?
    var delegate: PayapiWebViewDelegate?
    var view: UIView
    init(target: UIView) {
        self.webView_ = WKWebView(frame: CGRect.zero)
        self.view = target
        super.init()
        print("WebViewController: init()")
        webView_!.navigationDelegate = self
        webView_!.uiDelegate = self
        webView_!.scrollView.layer.cornerRadius = 10
        webView_!.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(webView_!)
        let height = NSLayoutConstraint(item: webView_!, attribute: .height, relatedBy: .equal, toItem: view, attribute: .height, multiplier: 1, constant: -100)
        let width = NSLayoutConstraint(item: webView_!, attribute: .width, relatedBy: .equal, toItem: view, attribute: .width, multiplier: 1, constant: -20)
        view.addConstraints([height, width])
        NSLayoutConstraint(item: webView_!, attribute: NSLayoutAttribute.centerX, relatedBy: NSLayoutRelation.equal, toItem: view, attribute: NSLayoutAttribute.centerX, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: webView_!, attribute: NSLayoutAttribute.centerY, relatedBy: NSLayoutRelation.equal, toItem: view, attribute: NSLayoutAttribute.centerY, multiplier: 1, constant: 10).isActive = true
        webView_!.allowsBackForwardNavigationGestures = true
        self.setActivityIndicator()
    }
    
    deinit {
        // remove all
        self.cancelUrlRequest()
        self.removeActivityIndicator()
        webView_?.removeFromSuperview()
    }
    
    func loadPayapiUrl(_ urlStr: String) {
        print("WebViewController: loadPayapiUrl: url =", urlStr)
        print("PayapiWebView: cookie accept policy: ", HTTPCookieStorage.shared.cookieAcceptPolicy.rawValue)
       
        let requestObj = URLRequest(url: URL(string:urlStr)!);
        webView_!.load(requestObj);
    }
    
    func loadPayapiRequest(_ urlRequest: URLRequest) {
        print("WebViewController: loadPayapiRequest: url =", urlRequest.url?.absoluteString)
        print(urlRequest.allHTTPHeaderFields)
        webView_!.load(urlRequest)
    }
    
    func cancelUrlRequest() {
        print("WebViewController: cancelUrlRequest:")
        webView_?.stopLoading()
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        print("WebViewController: didFailNavigation: error = ", error)
        self.delegate?.payapiFail(error as NSError)
    }
    
    func webViewWebContentProcessDidTerminate(_ webView: WKWebView) {
        print("WebViewController: webViewWebContentProcessDidTerminate: ", webView)
        let userError = NSError(domain: "Bad request", code: 400, userInfo: nil)
        self.delegate?.payapiFail(userError)
    }
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        print("WebViewController: didStartProvisionalNavigation: ", webView.url)
        self.setActivityIndicator()
        if let url = webView.url {
            checkCloseURL(url.absoluteString)
        }
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        print("WebViewController: didFinishNavigation: ", webView.url)
        
        for cookie in HTTPCookieStorage.shared.cookies ?? [] {
            
            // Is the cookie for current domain?
            if cookie.domain.hasSuffix("payapi.io") == true {
                print("payapi cookie: -> ", cookie)
            }
            
        }
        
        self.removeActivityIndicator()
        let path: String? = webView.url?.path
        print("WebViewController: didFinishNavigation: path: ", path)
        if webView.url?.host == PayapiWebView.getPayApiHost() &&
           path != nil {
            // /v1/secureform/payapishop/return
            var secureform = false
            var returnPath = false
            let items = path!.components(separatedBy: "/")
            for item in items {
                if item == "secureform" { secureform = true }
                if item == "return" { returnPath = true }
            }
            if returnPath == true &&
               secureform == true {
                let delayTime = DispatchTime.now() + Double(Int64(2 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
                DispatchQueue.main.asyncAfter(deadline: delayTime, execute: { () -> Void in
                    print("WebViewController: didFinishNavigation: return: ")
                    self.delegate?.payapiReturn()
                })
            }
        }
    }
    
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        print("WebViewController: createWebViewWithConfiguration: ", navigationAction)
        return nil
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        print("WebViewController: didFailProvisionalNavigation: ", error.localizedDescription)
        if error._code == -1001 { // TIMED OUT:
            print("WebViewController: TIMED OUT: ")
            self.delegate?.payapiFail(error as NSError)
            
        } else if error._code == -1003 { // SERVER CANNOT BE FOUND
            
            print("WebViewController: SERVER CANNOT BE FOUND: ")
            self.delegate?.payapiFail(error as NSError)
            
        } else if error._code == -1100 { // URL NOT FOUND ON SERVER
            
            print("WebViewController: URL NOT FOUND ON SERVER: ")
            self.delegate?.payapiFail(error as NSError)
            
        }
        
    }
    
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
        // make sure the response is a NSHTTPURLResponse
        guard let response = navigationResponse.response as? HTTPURLResponse else { return decisionHandler(.allow) }
        print("decidePolicyForNavigationResponse: ", response.statusCode)
        
        let headerFields = response.allHeaderFields as NSDictionary
        //let cookieField = headerFields.objectForKey("Cookie")
        
        print("decidePolicyForNavigationResponse: headerFields: ", headerFields)
        
        let cookies = HTTPCookie.cookies(withResponseHeaderFields: headerFields as! [String : String], for: response.url!) //as! [NSHTTPCookie]
        
        for cookie in cookies {
            if cookie.name == "payConsumerId" {
                var cookieProperties = [HTTPCookiePropertyKey: Any]()
                cookieProperties[HTTPCookiePropertyKey.name] = cookie.name
                cookieProperties[HTTPCookiePropertyKey.value] = cookie.value
                cookieProperties[HTTPCookiePropertyKey.domain] = cookie.domain
                cookieProperties[HTTPCookiePropertyKey.path] = cookie.path
                //cookieProperties[NSHTTPCookieSecure] = cookie.secure
                cookieProperties[HTTPCookiePropertyKey.version] = NSNumber(value: cookie.version as Int)
                cookieProperties[HTTPCookiePropertyKey.expires] = cookie.expiresDate //NSDate().dateByAddingTimeInterval(31536000)
            
                let newCookie = HTTPCookie(properties: cookieProperties)
                HTTPCookieStorage.shared.setCookie(newCookie!)
            
                print("decidePolicyForNavigationResponse: setCookie: cookie: \(newCookie)")
            }
        }
        
        print("decidePolicyForNavigationResponse: cookies: ", cookies)
        
        if response.statusCode != 200 { // only 200 is ok
            let delayTime = DispatchTime.now() + Double(Int64(2 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
            DispatchQueue.main.asyncAfter(deadline: delayTime, execute: { () -> Void in
                print("WebViewController: HTTP fail: code: ", response.statusCode)
                let userError = NSError(domain: "Bad request", code: response.statusCode, userInfo: nil)
                self.delegate?.payapiFail(userError)
            })
        }
        decisionHandler(WKNavigationResponsePolicy.allow)
    }
       
    
    var indicator: UIActivityIndicatorView?
    var dimmView: UIView?
    
    func setActivityIndicator() {
        if indicator == nil {
            indicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.whiteLarge)
            indicator!.frame = CGRect(x: 0,y: 0,width: 75,height: 75)
            //indicator!.center = view.center
            indicator!.translatesAutoresizingMaskIntoConstraints = false
            //dimmView = UIView(frame: view.bounds)
            dimmView = UIView()
            dimmView!.frame = CGRect(x: 0,y: 0,width: 100,height: 100)
            dimmView!.layer.cornerRadius = 10
            //dimmView!.center = view.center
            dimmView!.translatesAutoresizingMaskIntoConstraints = false
            dimmView!.backgroundColor = UIColor.black
            dimmView!.alpha = 0.5
            
            view.addSubview(dimmView!)
            view.addSubview(indicator!)
            
            // dimmview constraints
            NSLayoutConstraint(item: dimmView!, attribute: NSLayoutAttribute.centerX, relatedBy: NSLayoutRelation.equal, toItem: view, attribute: NSLayoutAttribute.centerX, multiplier: 1, constant: 0).isActive = true
            NSLayoutConstraint(item: dimmView!, attribute: NSLayoutAttribute.centerY, relatedBy: NSLayoutRelation.equal, toItem: view, attribute: NSLayoutAttribute.centerY, multiplier: 1, constant: 0).isActive = true
            NSLayoutConstraint(item: dimmView!, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: 100).isActive = true
            NSLayoutConstraint(item: dimmView!, attribute: NSLayoutAttribute.width, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: 100).isActive = true
            // indicator constraints
            NSLayoutConstraint(item: indicator!, attribute: NSLayoutAttribute.centerX, relatedBy: NSLayoutRelation.equal, toItem: view, attribute: NSLayoutAttribute.centerX, multiplier: 1, constant: 0).isActive = true
            NSLayoutConstraint(item: indicator!, attribute: NSLayoutAttribute.centerY, relatedBy: NSLayoutRelation.equal, toItem: view, attribute: NSLayoutAttribute.centerY, multiplier: 1, constant: 0).isActive = true
            NSLayoutConstraint(item: indicator!, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: 100).isActive = true
            NSLayoutConstraint(item: indicator!, attribute: NSLayoutAttribute.width, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: 100).isActive = true
            
        }
        if indicator!.isAnimating == false {
            indicator!.startAnimating()
        }
    }
    
    func removeActivityIndicator() {
        if indicator == nil { return }
        if indicator!.isAnimating == true {
            indicator!.stopAnimating()
        }
        indicator?.removeFromSuperview()
        dimmView?.removeFromSuperview()
        
        indicator = nil
        dimmView = nil
    }
    
    var nextClose = false
    func checkCloseURL(_ url: String){
        
        if nextClose {
            nextClose = false;
            self.delegate?.payapiReturn()
        } else {
            nextClose = url.range(of: "https://(staging-)?input.payapi.io/v[0-9]+/secureform/[a-z0-9_]+/return", options: .regularExpression) != nil
            
        }
    }
    
    static func getPayApiHost() -> String{
        
        #if DEBUG
            print("getPayApiHost: I'm in debug mode!")
            return "staging-input.payapi.io"
        #else
            print("getPayApiHost: I'm in release mode!")
            return "input.payapi.io"
        #endif
    }

}
