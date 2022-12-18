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


class WebviewController: NSViewController, WKUIDelegate, WKScriptMessageHandlerWithReply {
    var webview: WKWebView!
    var channel: FlutterMethodChannel!
    
    init(controller: FlutterViewController) {
        super.init(nibName: nil, bundle: nil)
        let config = WKWebViewConfiguration()
        config.preferences.setValue(true, forKey: "allowFileAccessFromFileURLs")
        config.preferences.setValue(false, forKey: "webSecurityEnabled")
        config.preferences.setValue(false, forKey: "mediaCaptureRequiresSecureConnection")
        config.preferences.setValue(false, forKey: "secureContextChecksEnabled")
        config.userContentController.addScriptMessageHandler(self, contentWorld: .page, name: "PublicJSBridgeInvoke")
        webview = WKWebView(frame: .zero, configuration: config)
        webview.setValue(false, forKey: "drawsBackground")
        webview.uiDelegate = self
        self.view = webview
        let channel = FlutterMethodChannel(name: "webview", binaryMessenger: controller.engine.binaryMessenger)
        channel.setMethodCallHandler { caller, setResult in
            if caller.method == "setRect" {
                let dict = caller.arguments as! Dictionary<String, CGFloat>
                self.webview.frame = NSMakeRect(dict["x"]!, self.view.window!.frame.height - dict["height"]! - dict["y"]!, dict["width"]!, dict["height"]!)
            } else if caller.method == "hide" {
                self.webview.frame = .zero
            } else if caller.method == "setUrl" {
                self.webview.load(URLRequest(url: URL(string: caller.arguments as! String)!))
            } else if caller.method == "setHTML" {
                if #available(macOS 12.0, *) {
                    self.webview.loadSimulatedRequest(URLRequest(url: URL(string: "https://public.qwertyyb.com")!), responseHTML: caller.arguments as! String)
                } else {
                    self.webview.loadHTMLString(caller.arguments as! String, baseURL: URL(string: "https://public.qwertyyb.com"))
                }
            }
            setResult(nil)
        }
        self.channel = channel
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public typealias Handler = (Any?) -> Void
    var handlers = [String: Handler]()
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage, replyHandler: @escaping (Any?, String?) -> Void) {
        print(message.body)
        guard message.name == "PublicJSBridgeInvoke",
              let body = message.body as? [String:Any],
              let funcName = body["funcName"] as? String else {
                return
        }
        channel.invokeMethod(funcName, arguments: body["args"]) { result in
            replyHandler(result, nil)
        }
    }
}
