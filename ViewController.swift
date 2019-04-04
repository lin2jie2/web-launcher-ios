//
//  ViewController.swift
//  WebLauncher.iOS
//
//  Created by linjie on 03/04/2019.
//  Copyright © 2019 linjie. All rights reserved.
//

import UIKit
import WebKit

class ViewController: UIViewController, WKUIDelegate, WKNavigationDelegate, WKScriptMessageHandler {

    var wkWebView: WKWebView!

    override func loadView() {
        let wkWebViewConfiguration = WKWebViewConfiguration()
        wkWebViewConfiguration.applicationNameForUserAgent = "WebLauncher.iOS/0.0.1 (iOS)"

        // inject JavaScriptBridge
        wkWebViewConfiguration.userContentController = WKUserContentController()
        wkWebViewConfiguration.userContentController.add(self, name: "JavaScriptBridge")

        wkWebView = WKWebView(frame: .zero, configuration: wkWebViewConfiguration)
        wkWebView.uiDelegate = self
        wkWebView.navigationDelegate = self
        self.view = wkWebView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        let myUrl = URL(string: "https://dv321.xyz/dilidili/")
        let myRequest = URLRequest(url: myUrl!)
        wkWebView.load(myRequest)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

// custom handler
extension ViewController {
    // injectScript("document.getElementsByTagName('h2')[0].innerText = '我是ios原生为h5注入的脚本'")
    func injectScript(js: String) {
        let script = WKUserScript.init(source: js, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
        self.wkWebView.configuration.userContentController.addUserScript(script)
    }

    // callJavascript("navButtonClick(name, age)")
    func callJavascript(js: String) {
        self.wkWebView.evaluateJavaScript(js) {
            (response, error) in
            if error == nil {
                // OK
            }
            else {
                // Log4jMessage(message: error)
            }
        }
    }
}

// WKUserContentController
extension ViewController {
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if message.name == "JavaScriptBridge" {
            // {"class": "class", "method": "method", "data": {data}, "task": "taskId"}
            if let dic = message.body as? NSDictionary,
                let className = dic["class"] as? String,
                let method = dic["method"] as? String,
                let data = dic["data"] as? NSDictionary,
                let taskId = dic["task"] as? String {

                if let bundleId = Bundle.main.object(forInfoDictionaryKey: "CFBundleName") as? String {
                    if let cls = NSClassFromString(bundleId + "." + className) as? Plugin.Type {
                        let obj = cls.init(data: data, taskId: taskId, wkWebView: wkWebView)
                        obj.invokeMethod(method)
                    }
                    else {
                        if let cls = NSClassFromString(className) as? Plugin.Type {
                            let obj = cls.init(data: data, taskId: taskId, wkWebView: wkWebView)
                            obj.invokeMethod(method)
                        }
                        else {
                            let js = "window['\(taskId)']({\"message\":\"class: \(className) not found\"})"
                            wkWebView.evaluateJavaScript(js, completionHandler: nil)
                        }
                    }
                }
                else {
                    print("bundleId fail!")
                }
            }
            else {
                print("message.body extract fail!")
                print(message.body)
            }
        }
        else {
            print("unregister handler")
            print(message.name)
            print(message.body)
        }
    }
}

// WKUIDelegate
extension ViewController {
    // alert
    func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
        let ac = UIAlertController(title: webView.title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        ac.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: {
            (aa) -> Void in completionHandler()
        }))
        self.present(ac, animated: true, completion: nil)
    }
    
    // confirm
    func webView(_ webView: WKWebView, runJavaScriptConfirmPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (Bool) -> Void) {
        let ac = UIAlertController(title: webView.title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        ac.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: {
            (aa) -> Void in completionHandler(false)
        }))
        ac.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: {
            (aa) -> Void in completionHandler(true)
        }))
        self.present(ac, animated: true, completion: nil)
    }
    
    // prompt
    func webView(_ webView: WKWebView, runJavaScriptTextInputPanelWithPrompt prompt: String, defaultText: String?, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (String?) -> Void) {
        //
    }
}

// UINavigationDelegate
extension ViewController {
    // handle window.open
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
//        if navigationAction.targetFrame == nil {
//            NSLog("open in current webview")
//            webView.load(navigationAction.request)
//        }
//        else {
            if let url = navigationAction.request.url {
                UIApplication.shared.open(url, options: [:])
            }
            else {
                NSLog(navigationAction.request.url?.absoluteString ?? "about:blank")
            }
//        }
        
        return nil
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        NSLog(error.localizedDescription)
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        NSLog(error.localizedDescription)
    }
}
