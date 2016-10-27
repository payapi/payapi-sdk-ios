//
//  SecureForm.swift
//  PayapiSDK
//
//  Created by Francisco on 21/10/16.
//  Copyright © 2016 Payapi. All rights reserved.
//

import UIKit
import JWT

open class SecureForm{
    var publicId = ""
    var apiKey = ""
    var messages: Array<[String:Any]> = []
    public init(publicId: String, apiKey: String){
        
        if !SecureForm.validateKeyFormat(key: apiKey) {
            print("Key format is wrong")
        } else if !SecureForm.validatePublicIdFormat(pId: publicId){
            print("Incorrect public Id")
        } else {
            print("valid config")
            self.apiKey = apiKey
            self.publicId = publicId
        }
    }
    
    public func addSecureFormToButton(button: UIButton, message: [String: Any]){
        messages.append(message)
        button.tag = messages.count - 1
        button.addTarget(self, action: #selector(SecureForm.pressed(_:)), for: .touchUpInside)
    }
    
    public func openSecureForm(jsObject: [String:Any]){
        
        let jwtSignedToken = JWT.encode(jsObject, algorithm: Algorithm.hs512(apiKey.data(using: .utf8)!))
        
        var urlRequest = URLRequest(url: URL(string: "https://\(PayapiWebView.getPayApiHost())/v1/secureform/\(publicId)")!)
        
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.setValue("application/json", forHTTPHeaderField: "Accept")
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: ["data":jwtSignedToken], options: [])
            urlRequest.setValue(String(data: jsonData, encoding:.utf8), forHTTPHeaderField: "x-body-data")
        }catch let error{
            print("JSON Error: \(error)")
        }
        
        let activityViewController = PayapiWebViewController(urlReq: urlRequest)
        
        let appDelegate  = UIApplication.shared.delegate
        
        if let viewController = appDelegate?.window??.rootViewController {
            viewController.present(activityViewController, animated:true, completion:nil )
        }
        
    }
    
    
    fileprivate static func validateKeyFormat(key: String) -> Bool {
        return key.characters.count == 32
    }
    
    fileprivate static func validatePublicIdFormat(pId: String) -> Bool {
        
        if pId.characters.count >= 6 && pId.characters.count <= 50 {
            do {
                let regex = try NSRegularExpression(pattern: "^([a-z])[a-z0-9-_]{5,49}$")
                let results = regex.matches(in: pId, range: NSRange(location: 0, length: pId.characters.count))
                return results.count > 0
            } catch let error {
                print("invalid regex: \(error.localizedDescription)")
                return false
            }
        }
        
        return false
    }
    
    @IBAction public func pressed(_ sender: UIButton) {
        if sender.tag < messages.count {
            self.openSecureForm(jsObject: messages[sender.tag])
        }
    }
}
