//
//  PayapiWebViewController.swift
//  FngrShare
//
//  Created by FastFingers Mika on 24/05/16.
//  Copyright © 2016 FastFingers. All rights reserved.
//

import UIKit
import WebKit

class PayapiWebViewController: UIViewController, PayapiWebViewDelegate {

    var webview: PayapiWebView?
    var buttonView: UIButton?
    var isShowing = true
    
    convenience init( urlReq: URLRequest ) {
        self.init()
        webview = PayapiWebView(target: self.view)
        webview!.delegate = self
        webview!.loadPayapiRequest(urlReq)
        self.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("PayapiWebViewController: viewDidLoad")
        setBlurView()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setCancelButton()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: PayapiWebViewDelegate
    
    func payapiReturn() {
        print("PayapiWebViewDelegate: payapiReturn")
        if isShowing {
            presentingViewController?.dismiss(animated: true, completion: nil)
        } else {
            print("ALREADY CLOSED!")
        }
        isShowing = false
    }
    
    func payapiFail(_ error: NSError) {
        print("PayapiWebViewDelegate: payapiFail: error: ", error)
        if isShowing {
            presentingViewController?.dismiss(animated: true, completion: nil)
        } else {
            print("ALREADY CLOSED!")
        }
        isShowing = false
    }

    func cancelButtonAction(_ sender: UIButton) {
        print("PayapiWebViewDelegate: cancelButtonAction")
        if isShowing {
            presentingViewController?.dismiss(animated: true, completion: nil)
        } else {
            print("ALREADY CLOSED!")
        }
        isShowing = false
    }
    
    func setBlurView() {
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.extraLight)
        let visualEffectView = UIVisualEffectView(effect: blurEffect)
        //visualEffectView.alpha = 0.85
        visualEffectView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(visualEffectView)
        
        let height = NSLayoutConstraint(item: visualEffectView, attribute: .height, relatedBy: .equal, toItem: view, attribute: .height, multiplier: 1, constant: 0)
        let width = NSLayoutConstraint(item: visualEffectView, attribute: .width, relatedBy: .equal, toItem: view, attribute: .width, multiplier: 1, constant: 0)
        view.addConstraints([height, width])
    }
    
    func setCancelButton() {
        print("PayapiWebViewDelegate: setCancelButton")
        buttonView = UIButton()
        buttonView!.frame = CGRect(x: 0,y: 0,width: 0,height: 0)
        buttonView!.alpha = 0
        buttonView!.tintColor = UIColor.white
        let img = UIImage(named: "ic_cancel", in: Bundle(for: PayapiWebViewController.self), compatibleWith: nil)
        buttonView!.setImage(img, for: UIControlState())
        buttonView!.addTarget(self, action: #selector(PayapiWebViewController.cancelButtonAction(_:)), for: UIControlEvents.touchUpInside)

        UIView.animate(withDuration: 1, animations: { () -> Void in
            self.buttonView!.frame = CGRect(x: 0,
                y: 0,
                width: 75,
                height: 75)
            self.buttonView!.alpha = 1
        })
        
        view.addSubview(buttonView!)
    }
    
}
