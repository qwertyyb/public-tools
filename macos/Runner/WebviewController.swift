//
//  WebviewController.swift
//  Runner
//
//  Created by 虚幻 on 2022/7/9.
//

import Foundation
import AppKit
import WebKit
import FlutterMacOS


class WebviewController: NSViewController, WKUIDelegate {
    
    
    
    var webview: WKWebView!
    
    init(controller: FlutterViewController) {
        super.init(nibName: nil, bundle: nil)
        let userController = WKUserContentController()
        var config = WKWebViewConfiguration()
        config.preferences.setValue(true, forKey: "allowFileAccessFromFileURLs")
//        config.preferences.setValue(true, forKey: "allowUniversalAccessFromFileURLs")
        config.preferences.setValue(false, forKey: "webSecurityEnabled")
        config.preferences.setValue(false, forKey: "mediaCaptureRequiresSecureConnection")
        config.preferences.setValue(false, forKey: "secureContextChecksEnabled")
        webview = WKWebView(frame: .zero, configuration: config)
        webview.setValue(false, forKey: "drawsBackground")
        webview.uiDelegate = self
        self.view = webview
        let channel = FlutterMethodChannel(name: "webview", binaryMessenger: controller.engine.binaryMessenger)
        channel.setMethodCallHandler { caller, setResult in
            print("caller: \(caller.method), \(caller.arguments)")
            if caller.method == "setRect" {
                let dict = caller.arguments as! Dictionary<String, CGFloat>
                self.webview.frame = NSMakeRect(dict["x"]!, self.view.window!.frame.height - dict["height"]! - dict["y"]!, dict["width"]!, dict["height"]!)
            } else if caller.method == "hide" {
                self.webview.frame = .zero
            } else if caller.method == "setUrl" {
                self.webview.load(URLRequest(url: URL(string: caller.arguments as! String)!))
            } else if caller.method == "setHTML" {
                self.webview.loadHTMLString(caller.arguments as! String, baseURL: URL(string: "https://public.qwertyyb.com"))
            }
            setResult(nil)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
