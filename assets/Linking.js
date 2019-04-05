var Linking = {
	canOpenURL: function(url) {
		return callNativeClassMethod("Linking", "canOpenURL", {url})
	},

	openURL: function(url) {
		return callNativeClassMethod("Linking", "openURL", {url})
	},

	instantView: function(url) {
		return callNativeFunction("instantView", {url})
	},
}
