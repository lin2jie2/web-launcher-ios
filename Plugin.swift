//
//  Plugin.swift
//  WebLauncher.iOS
//
//  Created by linjie on 03/04/2019.
//  Copyright © 2019 linjie. All rights reserved.
//


import Foundation
import WebKit

@objc
class Plugin: NSObject {
	var data: NSDictionary;
	var taskId: String;
	var wkWebView: WKWebView;

	required init(data: NSDictionary, taskId: String, wkWebView: WKWebView) {
		self.taskId = taskId
		self.data = data
		self.wkWebView = wkWebView
	}

	func invokeMethod(_ method: String) {
		let selector = Selector(method)
		if self.responds(to: selector) {
			performSelector(onMainThread: selector, with: self, waitUntilDone: true)
		}
		else {
			error("NoSuchMethod: \(method)")
		}
	}

	func success(_ data: Any?) {
		response(message: "OK", data: data)
	}

	func error(_ message: String) {
		response(message: message, data: nil)
	}

	func response(message: String, data: Any?) {
		let result: NSDictionary = ["message": message, "data": data ?? ""]

		Plugin.callback(self.wkWebView, self.taskId, result)
	}

	static func callback(_ wkWebView: WKWebView, _ taskId: String, _ data: NSDictionary) {
		do {
			let jsonData = try JSONSerialization.data(withJSONObject: data, options: JSONSerialization.WritingOptions())
			if let jsonString = NSString(data: jsonData, encoding: String.Encoding.utf8.rawValue) as String? {
				wkWebView.evaluateJavaScript("window['\(taskId)'](\(jsonString))", completionHandler: nil)
			}
		}
		catch let error as NSError {
			NSLog(error.localizedDescription)
		}
	}
}
