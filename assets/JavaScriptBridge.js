
function callNativeFunction(func, data) {
	return callNative({"function": func}, data)
}

function callNativeClassMethod(cls, method, data) {
	return callNative({"class": cls, method}, data)
}

function callNative(callable, data) {
	return new Promise((resolve, reject) => {
		let task = (+ new Date()) + '/' + Math.random()
		window[task] = function(result) {
			delete window[task]

			if (result.message.toUpperCase() == "OK") {
				resolve(result.data)
			}
			else {
				reject(result.message)
			}
		}

		try {
			if ('webkit' in window && 'messageHandlers' in window.webkit && 'JavaScriptBridge' in window.webkit.messageHandlers) {
				window.webkit.messageHandlers.JavaScriptBridge.postMessage({...callable, data, task})
			}
			else {
				reject('without App')
			}
		}
		catch (e) {
			reject(e)
		}
	})
}
