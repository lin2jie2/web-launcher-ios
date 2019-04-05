//
//  Linking.swift
//  WebLauncher.iOS
//
//  Created by linjie on 03/04/2019.
//  Copyright © 2019 linjie. All rights reserved.
//

import UIKit

@objc(Linking)
@objcMembers
class Linking: Plugin {
	func canOpenURL() {
		if let uri = data["url"] as? String {
			let url = URL(string: uri)
			let shared = UIApplication.shared
			if shared.canOpenURL(url!) {
				success(nil)
			}
			else {
				error("unsupport")
			}
		}
		else {
			error("Invalid URL")
		}
	}

	func openURL() {
		if let uri = data["url"] as? String {
			let url = URL(string: uri)
			UIApplication.shared.open(url!, options: [:])
			success(nil)
		}
		else {
			error("Invalid URL")
		}
	}
}
